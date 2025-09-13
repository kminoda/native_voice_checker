import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SessionData {
  SessionData({
    required this.id,
    required this.text,
    required this.language,
    required this.gender,
  });

  final String id;
  String text;
  String language; // e.g., en-US
  String gender; // male | female

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'language': language,
        'gender': gender,
      };

  static SessionData fromJson(Map<String, dynamic> json) => SessionData(
        id: json['id'] as String,
        text: (json['text'] ?? '') as String,
        language: (json['language'] ?? 'en-US') as String,
        gender: (json['gender'] ?? 'female') as String,
      );
}

class SessionStore {
  Future<String> _dirPath() async {
    final docs = await getApplicationDocumentsDirectory();
    return '${docs.path}/sessions';
  }

  Future<File> _fileFor(String sessionId) async {
    final dir = Directory(await _dirPath());
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$sessionId.json');
  }

  Future<SessionData?> load(String sessionId) async {
    final file = await _fileFor(sessionId);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    final jsonMap = json.decode(content) as Map<String, dynamic>;
    return SessionData.fromJson(jsonMap);
  }

  Future<void> save(SessionData data) async {
    final file = await _fileFor(data.id);
    await file.writeAsString(json.encode(data.toJson()));
  }

  Future<List<SessionData>> listAll() async {
    final dir = Directory(await _dirPath());
    if (!await dir.exists()) return [];
    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    final List<SessionData> sessions = [];
    for (final f in files) {
      try {
        final content = await f.readAsString();
        final jsonMap = json.decode(content) as Map<String, dynamic>;
        sessions.add(SessionData.fromJson(jsonMap));
      } catch (_) {
        // ignore invalid file
      }
    }
    return sessions;
  }

  Future<void> delete(String sessionId) async {
    final file = await _fileFor(sessionId);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
