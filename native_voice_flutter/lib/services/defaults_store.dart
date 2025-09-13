import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DefaultSettings {
  DefaultSettings({
    required this.language,
    required this.gender,
  });

  final String language; // e.g., en-US
  final String gender; // male | female

  Map<String, dynamic> toJson() => {
        'language': language,
        'gender': gender,
      };

  static DefaultSettings fromJson(Map<String, dynamic> json) => DefaultSettings(
        language: (json['language'] ?? 'en-US') as String,
        gender: (json['gender'] ?? 'female') as String,
      );
}

class DefaultsStore {
  Future<String> _filePath() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/settings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '${dir.path}/defaults.json';
  }

  Future<DefaultSettings> load() async {
    try {
      final path = await _filePath();
      final file = File(path);
      if (!await file.exists()) {
        return DefaultSettings(language: 'en-US', gender: 'female');
      }
      final content = await file.readAsString();
      final map = json.decode(content) as Map<String, dynamic>;
      return DefaultSettings.fromJson(map);
    } catch (_) {
      return DefaultSettings(language: 'en-US', gender: 'female');
    }
  }

  Future<void> save(DefaultSettings settings) async {
    final path = await _filePath();
    final file = File(path);
    await file.writeAsString(json.encode(settings.toJson()));
  }
}

