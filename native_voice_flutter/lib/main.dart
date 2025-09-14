import 'package:flutter/material.dart';
import 'package:native_voice_flutter/ui/theme.dart';
import 'package:native_voice_flutter/screens/text_session_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:native_voice_flutter/services/premium_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:native_voice_flutter/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Google Mobile Ads (AdMob)
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    // ignore: avoid_print
    print('[BOOT][WARN] MobileAds init failed: $e');
  }
  // Firebase initialization is optional at this point. If not configured,
  // the app will still run with a mock TTS service.
  try {
    await Firebase.initializeApp();
    // ignore: avoid_print
    print('[BOOT] Firebase.initializeApp() completed');
    // App Check helps ensure only genuine app instances call your backend.
    // For iOS: App Attest with DeviceCheck fallback, for Android: Play Integrity.
    try {
      await FirebaseAppCheck.instance.activate(
        appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
        androidProvider: AndroidProvider.playIntegrity,
      );
      // ignore: avoid_print
      print('[BOOT] Firebase App Check activated');
    } catch (e) {
      // ignore: avoid_print
      print('[BOOT][WARN] App Check activation failed: $e');
    }
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        final cred = await auth.signInAnonymously();
        // ignore: avoid_print
        print('[BOOT] Signed in anonymously: uid=${cred.user?.uid}');
        // Link RevenueCat app user id to Firebase UID for server/webhook correlation
        try {
          final uid = cred.user?.uid;
          if (uid != null) {
            await Purchases.logIn(uid);
          }
        } catch (e) {
          // ignore: avoid_print
          print('[BOOT][WARN] RevenueCat logIn failed: $e');
        }
      } else {
        // ignore: avoid_print
        print('[BOOT] Already signed in: uid=${auth.currentUser?.uid}');
        try {
          final uid = auth.currentUser?.uid;
          if (uid != null) {
            await Purchases.logIn(uid);
          }
        } catch (e) {
          // ignore: avoid_print
          print('[BOOT][WARN] RevenueCat logIn failed: $e');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[BOOT][WARN] Firebase anonymous sign-in failed: $e');
    }
  } catch (e) {
    // ignore: avoid_print
    print('[BOOT][WARN] Firebase init failed: $e');
  }
  // Configure RevenueCat (non-fatal if keys are missing)
  try {
    await PremiumService.instance.ensureConfigured();
  } catch (e) {
    // ignore: avoid_print
    print('[BOOT][WARN] RevenueCat init failed: $e');
  }
  runApp(const VoiceCheckApp());
}

class VoiceCheckApp extends StatelessWidget {
  const VoiceCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
      ],
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark,
      home: const TextSessionScreen(),
    );
  }
}
