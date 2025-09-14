/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {callGoogleTTSWithGender} from "./utils/google";
import * as crypto from "crypto";

// Initialize Admin SDK once
try {
  admin.app();
} catch (_) {
  admin.initializeApp();
}

const USERS_COLLECTION = "users";
const FREE_PLAN_MAX_TOKENS = 3000; // default cap

function estimateTokens(text: string): number {
  // Simple approximation: count characters. Works for multi-byte languages too.
  // If you later switch to an LLM tokenizer, swap this implementation.
  return (text || "").length;
}

// Enforce App Check on callable endpoints to reduce abuse from non-genuine apps.
// Note: requires client to enable App Check; see Flutter setup.
export const ttsGenerate = onCall({enforceAppCheck: true}, async (request) => {
  const data = request.data ?? {};
  const text = (data.text ?? "").toString();
  const genderRaw = (data.gender ?? "female").toString().toLowerCase();
  const gender = genderRaw === "male" ? "male" : "female";

  // Accept both 'languageCode' and 'lang'
  const lang = (data.lang ?? data.languageCode ?? "en-US").toString();

  if (!text) {
    throw new HttpsError("invalid-argument", "Missing text");
  }

  // Require authentication to enforce per-user limits
  const auth = request.auth;
  const uid = auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  // Using Google Cloud client library with ADC; no API key required

  const db = admin.firestore();
  const usersRef = db.collection(USERS_COLLECTION).doc(uid);
  const inc = estimateTokens(text);

  // Reserve tokens in a transaction; reject if exceeding free cap.
  // For premium users, do NOT decrement tokens at all.
  let isPremium = false;
  // Prefer secure signal via custom claims if present, then fallback to Firestore plan.
  const claimsPremium = (auth?.token as Record<string, unknown> | undefined)?.["premium"] === true;
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(usersRef);
    const data = snap.exists ? (snap.data() || {}) : {};
    const plan = (data.plan as string) || "free";
    const used = (data.totalTokensUsed as number) || 0;
    isPremium = claimsPremium || plan === "premium";

    if (!isPremium && used + inc > FREE_PLAN_MAX_TOKENS) {
      throw new HttpsError(
        "resource-exhausted",
        `Token limit exceeded: ${used}/${FREE_PLAN_MAX_TOKENS}`,
      );
    }

    const baseFields: Record<string, unknown> = {
      plan,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: snap.exists
        ? (data.createdAt || admin.firestore.FieldValue.serverTimestamp())
        : admin.firestore.FieldValue.serverTimestamp(),
    };

    // Only increment tokens for non-premium users
    if (!isPremium) {
      baseFields.totalTokensUsed = admin.firestore.FieldValue.increment(inc);
    }

    tx.set(usersRef, baseFields, {merge: true});
  });

  try {
    const audioContent = await callGoogleTTSWithGender(text, lang, gender);
    return {audioContent, encoding: "MP3", languageCode: lang, gender};
  } catch (err) {
    // If TTS fails and user is not premium, refund reserved tokens best-effort
    if (!isPremium) {
      try {
        await usersRef.update({
          totalTokensUsed: admin.firestore.FieldValue.increment(-inc),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // ignore refund errors
      }
    }
    console.error("[ttsGenerate] TTS call failed:", err);
    // Normalize error for client
    const msg = err instanceof Error ? err.message : String(err);
    throw new HttpsError("internal", msg);
  }
});

/**
 * Sync premium plan status from the app to Firestore.
 * NOTE: This endpoint trusts the client signal and should be treated as a
 * best-effort sync to improve UX (e.g., instantly unlock). For strong security,
 * also configure a server-side webhook from RevenueCat to validate and persist
 * the real entitlement state.
 */
export const syncPremiumPlan = onCall({enforceAppCheck: true}, async (request) => {
  const auth = request.auth;
  const uid = auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  const body = (request.data ?? {}) as {isPremium?: unknown; plan?: unknown};
  const isPremium = typeof body.isPremium === "boolean" ? body.isPremium : undefined;
  const planRaw = typeof body.plan === "string" ? body.plan : undefined;

  // Derive plan: prefer explicit plan, otherwise map boolean to plan string
  const plan = planRaw ?? (isPremium === true ? "premium" : isPremium === false ? "free" : undefined);
  if (!plan || (plan !== "premium" && plan !== "free")) {
    throw new HttpsError("invalid-argument", "Missing or invalid plan");
  }

  const db = admin.firestore();
  const usersRef = db.collection(USERS_COLLECTION).doc(uid);
  await usersRef.set(
    {
      plan,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      // Track provenance of this update for observability
      lastPlanSyncSource: "client",
    },
    {merge: true},
  );

  return {ok: true, plan};
});

/**
 * RevenueCat webhook receiver.
 * Validates signature (best-effort) and updates user plan and optional custom claims.
 *
 * Configure RevenueCat to send events with App User ID equal to Firebase UID
 * (the app sets it via Purchases.logIn(uid)).
 *
 * Security:
 * - Protect this endpoint with a randomly generated URL in RC dashboard, and
 * - Verify signature header when possible. RevenueCat sends a signature header
 *   (e.g., 'X-RevenueCat-Signature' or 'X-Signature') you can validate with a
 *   shared secret. Implementation below attempts HMAC-SHA256 validation if header
 *   and secret are provided.
 */
export const revenueCatWebhook = onRequest({cors: true}, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  try {
    const signature = (req.header("X-RevenueCat-Signature") || req.header("X-Signature") || "").toString();
    const secret = process.env.REVENUECAT_WEBHOOK_SECRET || "";

    // If both signature and secret exist, attempt HMAC verification.
    if (signature && secret) {
      const bodyRaw = typeof req.rawBody === "object" && Buffer.isBuffer(req.rawBody)
        ? (req.rawBody as Buffer)
        : Buffer.from(JSON.stringify(req.body ?? {}));
      const hmac = crypto.createHmac("sha256", secret).update(bodyRaw).digest("hex");
      if (hmac !== signature) {
        console.warn("[webhook] signature verification failed");
        res.status(401).send("invalid signature");
        return;
      }
    }

    const event = req.body as any;
    const appUserId: string | undefined = event?.app_user_id || event?.event?.app_user_id;
    const type: string | undefined = event?.type || event?.event?.type;
    if (!appUserId || !type) {
      res.status(400).send("missing fields");
      return;
    }

    const uid = appUserId; // Must be same as Firebase UID via Purchases.logIn(uid)
    const db = admin.firestore();
    const usersRef = db.collection(USERS_COLLECTION).doc(uid);

    // Map webhook types to plan state
    const activating = [
      "INITIAL_PURCHASE",
      "NON_RENEWING_PURCHASE",
      "RENEWAL",
      "PRODUCT_CHANGE",
      "UNCANCELLATION",
      "BILLING_ISSUE_RESOLVED",
    ];
    const deactivating = [
      "CANCELLATION",
      "EXPIRATION",
      "BILLING_ISSUE",
    ];

    let plan: "premium" | "free" | undefined;
    if (activating.includes(type)) plan = "premium";
    if (deactivating.includes(type)) plan = "free";

    if (!plan) {
      // Ignore other event types gracefully
      res.status(200).send({ok: true, ignored: true});
      return;
    }

    await usersRef.set({
      plan,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastPlanSyncSource: "webhook",
    }, {merge: true});

    // Optionally also set custom claims so Functions can trust the token directly
    try {
      await admin.auth().setCustomUserClaims(uid, {premium: plan === "premium"});
      // Force token refresh by revoking refresh tokens so client picks up new claims
      await admin.auth().revokeRefreshTokens(uid);
    } catch (e) {
      console.warn("[webhook] setCustomUserClaims failed:", e);
    }

    res.status(200).send({ok: true, plan});
  } catch (e) {
    console.error("[webhook] error:", e);
    res.status(500).send("internal");
  }
});
