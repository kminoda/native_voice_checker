import 'package:flutter/material.dart';
import 'package:native_voice_flutter/ui/theme.dart';
import 'package:native_voice_flutter/screens/text_session_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:native_voice_flutter/services/premium_service.dart';
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
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        final cred = await auth.signInAnonymously();
        // ignore: avoid_print
        print('[BOOT] Signed in anonymously: uid=${cred.user?.uid}');
      } else {
        // ignore: avoid_print
        print('[BOOT] Already signed in: uid=${auth.currentUser?.uid}');
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
