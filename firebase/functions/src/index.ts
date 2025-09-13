/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {callGoogleTTSWithGender} from "./utils/google";

// Initialize Admin SDK once
try {
  admin.app();
} catch (_) {
  admin.initializeApp();
}

const USERS_COLLECTION = "users";
const FREE_PLAN_MAX_TOKENS = 1000; // default cap

function estimateTokens(text: string): number {
  // Simple approximation: count characters. Works for multi-byte languages too.
  // If you later switch to an LLM tokenizer, swap this implementation.
  return (text || "").length;
}

export const ttsGenerate = onCall({}, async (request) => {
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

  // Reserve tokens in a transaction; reject if exceeding free cap
  let isPremium = false;
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(usersRef);
    const data = snap.exists ? snap.data() || {} : {};
    const plan = (data.plan as string) || "free";
    const used = (data.totalTokensUsed as number) || 0;
    isPremium = plan === "premium";

    if (!isPremium && used + inc > FREE_PLAN_MAX_TOKENS) {
      throw new HttpsError(
        "resource-exhausted",
        `Token limit exceeded: ${used}/${FREE_PLAN_MAX_TOKENS}`,
      );
    }

    tx.set(
      usersRef,
      {
        plan,
        totalTokensUsed: admin.firestore.FieldValue.increment(inc),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: snap.exists
          ? data.createdAt || admin.firestore.FieldValue.serverTimestamp()
          : admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
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
