import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ReviewState {
  ReviewState({
    required this.generationCount,
    required this.prompted,
    required this.reviewed,
  });

  int generationCount;
  bool prompted;
  bool reviewed;

  Map<String, dynamic> toJson() => {
        'generationCount': generationCount,
        'prompted': prompted,
        'reviewed': reviewed,
      };

  static ReviewState fromJson(Map<String, dynamic> json) => ReviewState(
        generationCount: (json['generationCount'] ?? 0) as int,
        prompted: (json['prompted'] ?? false) as bool,
        reviewed: (json['reviewed'] ?? false) as bool,
      );
}

class ReviewTracker {
  static const int threshold = 10; // Show around after ~10 generations

  Future<String> _filePath() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/settings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '${dir.path}/review_state.json';
  }

  Future<ReviewState> _load() async {
    try {
      final path = await _filePath();
      final file = File(path);
      if (!await file.exists()) {
        return ReviewState(generationCount: 0, prompted: false, reviewed: false);
      }
      final content = await file.readAsString();
      final map = json.decode(content) as Map<String, dynamic>;
      return ReviewState.fromJson(map);
    } catch (_) {
      return ReviewState(generationCount: 0, prompted: false, reviewed: false);
    }
  }

  Future<void> _save(ReviewState state) async {
    final path = await _filePath();
    final file = File(path);
    await file.writeAsString(json.encode(state.toJson()));
  }

  Future<void> incrementGeneration() async {
    final state = await _load();
    state.generationCount += 1;
    await _save(state);
  }

  Future<bool> shouldPrompt() async {
    final state = await _load();
    return !state.reviewed && !state.prompted && state.generationCount >= threshold;
  }

  Future<void> markPrompted() async {
    final state = await _load();
    state.prompted = true;
    await _save(state);
  }

  Future<void> markReviewed() async {
    final state = await _load();
    state.reviewed = true;
    await _save(state);
  }
}
