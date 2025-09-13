import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class TtsRequest {
  TtsRequest({
    required this.text,
    required this.languageCode,
    required this.gender, // 'MALE' | 'FEMALE'
    this.targetPath,
  });

  final String text;
  final String languageCode;
  final String gender;
  final String? targetPath;
}

class TtsResult {
  TtsResult({required this.filePath});
  final String filePath; // local mp3 path
}

class TtsService {
  TtsService({this.useMock = true});

  final bool useMock;

  Future<TtsResult> generate(TtsRequest req) async {
    final started = DateTime.now();
    debugPrint('[TTS] generate start: lang=${req.languageCode}, gender=${req.gender}, textLen=${req.text.length}');

    // Ensure Firebase is initialized; otherwise fallback to mock
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp();
        debugPrint('[TTS] Firebase.initializeApp() completed in service');
      } catch (e) {
        debugPrint('[TTS][WARN] Firebase init failed in service: $e');
      }
    }

    if (useMock || Firebase.apps.isEmpty) {
      // In mock mode, just write a tiny file placeholder to simulate an mp3
      final file = req.targetPath != null
          ? File(req.targetPath!)
          : File('${(await getTemporaryDirectory()).path}/tts_mock_${DateTime.now().millisecondsSinceEpoch}.mp3');
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsBytes(const <int>[]);
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      debugPrint('[TTS][MOCK] wrote placeholder: ${file.path} (${elapsed}ms)');
      return TtsResult(filePath: file.path);
    }

    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final callable = functions.httpsCallable('ttsGenerate');
    Future<Map<String, dynamic>> invoke() async {
      final response = await callable.call<Map<String, dynamic>>({
        'text': req.text,
        'languageCode': req.languageCode,
        'gender': req.gender,
        'audioEncoding': 'MP3',
        'speakingRate': 1.0,
        'pitch': 0.0,
      });
      return response.data;
    }
    Map<String, dynamic> data;
    try {
      data = await invoke();
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'unauthenticated') {
        debugPrint('[TTS][INFO] Unauthenticated. Trying anonymous sign-in then retry.');
        try {
          final auth = FirebaseAuth.instance;
          if (auth.currentUser == null) {
            await auth.signInAnonymously();
          }
        } catch (e2) {
          debugPrint('[TTS][WARN] Anonymous sign-in retry failed: $e2');
        }
        // retry once
        data = await invoke();
      } else {
        if (e.code == 'resource-exhausted') {
          debugPrint('[TTS][ERROR] Token limit exceeded for this user.');
        } else if (e.code == 'invalid-argument') {
          debugPrint('[TTS][ERROR] Invalid request: ${e.message}');
        }
        rethrow;
      }
    }
    final audioB64 = data['audioContent'] as String?;
    if (audioB64 == null || audioB64.isEmpty) {
      throw StateError('No audioContent returned from function');
    }
    final bytes = base64.decode(audioB64);

    final file = req.targetPath != null
        ? File(req.targetPath!)
        : File('${(await getTemporaryDirectory()).path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(bytes);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[TTS] Saved to: ${file.path}');
    }
    final elapsed = DateTime.now().difference(started).inMilliseconds;
    debugPrint('[TTS] generate done (${elapsed}ms)');
    return TtsResult(filePath: file.path);
  }
}
