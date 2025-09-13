import 'dart:async';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:native_voice_flutter/screens/language_bottom_sheet.dart';
import 'package:native_voice_flutter/screens/menu_drawer.dart';
import 'package:native_voice_flutter/services/tts_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:native_voice_flutter/services/session_store.dart';
import 'package:native_voice_flutter/services/defaults_store.dart';

class TextSessionScreen extends StatefulWidget {
  const TextSessionScreen({super.key});

  @override
  State<TextSessionScreen> createState() => _TextSessionScreenState();
}

class _TextSessionScreenState extends State<TextSessionScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _hasAudio = false;
  String? _audioPath;
  String? _currentSessionId;
  final SessionStore _store = SessionStore();
  Timer? _saveDebounce;
  LanguageSettings _settings = LanguageSettings(language: 'en-US', gender: 'female');
  final DefaultsStore _defaultsStore = DefaultsStore();
  final TtsService _tts = TtsService(useMock: false);
  bool _isGenerating = false;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadDefaults();
    // Ensure no looping
    _player.setLoopMode(LoopMode.off);
    // Reset to beginning on completion so the UI returns to Play state.
    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await _player.pause();
        await _player.seek(Duration.zero);
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _loadDefaults() async {
    try {
      final d = await _defaultsStore.load();
      if (!mounted) return;
      setState(() {
        _settings = LanguageSettings(language: d.language, gender: d.gender);
      });
    } catch (_) {}
  }

  void _openSettings() async {
    final result = await showLanguageBottomSheet(
      context,
      initial: _settings,
    );
    if (result != null) {
      setState(() => _settings = result);
      _scheduleSaveSession();
    }
  }

  void _generateAudio() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    try {
      setState(() => _isGenerating = true);
      debugPrint('[UI] Request TTS: lang=${_settings.language}, gender=${_settings.gender}, len=${text.length}');
      // Ensure session id
      _currentSessionId ??= 'local_${DateTime.now().millisecondsSinceEpoch}';
      // Determine target file path
      final targetPath = await _sessionFilePath(_currentSessionId!);
      // Confirm overwrite if file exists
      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        final ok = await _confirm(
          context,
          title: '上書きしますか？',
          message: '既存の音声ファイルを上書きします。よろしいですか？',
          confirmText: '上書き',
        );
        if (ok != true) {
          setState(() => _isGenerating = false);
          return;
        }
      }

      final res = await _tts.generate(
        TtsRequest(
          text: text,
          languageCode: _settings.language,
          gender: _settings.gender.toUpperCase() == 'MALE' ? 'MALE' : 'FEMALE',
          targetPath: targetPath,
        ),
      );
      _audioPath = res.filePath;
      if (_player.playing) {
        await _player.stop();
      }
      await _player.setFilePath(_audioPath!);
      debugPrint('[UI] Audio file set to player: path=${_audioPath!}');
      setState(() => _hasAudio = true);
      _scheduleSaveSession();
      // No SnackBar: keep console logs only
    } catch (e) {
      debugPrint('[UI][ERROR] TTS generation failed: $e');
      // No SnackBar in failure either; rely on console logs
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _onSelectSession(String id, String text) async {
    await _maybeDeleteCurrentIfEmpty();
    setState(() {
      _currentSessionId = id;
      _textController.text = text;
    });
    await _loadSessionForCurrentSession();
  }

  Future<void> _maybeDeleteCurrentIfEmpty() async {
    final sid = _currentSessionId;
    if (sid == null) return;
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText) return;
    // If there is an audio file, keep the session
    final audioPath = await _sessionFilePath(sid);
    final hasAudio = await File(audioPath).exists();
    if (hasAudio) return;
    // Delete empty session json
    await _store.delete(sid);
    debugPrint('[SESSION] Deleted empty session: $sid');
  }

  void _scheduleSaveSession() {
    if (_currentSessionId == null) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final data = SessionData(
          id: _currentSessionId!,
          text: _textController.text,
          language: _settings.language,
          gender: _settings.gender,
        );
        await _store.save(data);
        debugPrint('[SESSION] Saved: ${data.id}');
      } catch (e) {
        debugPrint('[SESSION][ERROR] Failed to save: $e');
      }
    });
  }

  Future<void> _loadSessionForCurrentSession() async {
    await _loadAudioForCurrentSession();
    if (_currentSessionId == null) return;
    try {
      final data = await _store.load(_currentSessionId!);
      if (data != null) {
        setState(() {
          _textController.text = data.text;
          _settings = LanguageSettings(
            language: data.language,
            gender: data.gender,
          );
        });
        debugPrint('[SESSION] Loaded: ${data.id}');
      } else {
        // No saved session -> apply app defaults
        final d = await _defaultsStore.load();
        if (mounted) {
          setState(() {
            _settings = LanguageSettings(language: d.language, gender: d.gender);
          });
        }
      }
    } catch (e) {
      debugPrint('[SESSION][WARN] Load failed: $e');
    }
  }

  Future<String> _sessionFilePath(String sessionId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dirPath = '${docs.path}/tts';
    return '$dirPath/$sessionId.mp3';
  }

  Future<void> _loadAudioForCurrentSession() async {
    if (_currentSessionId == null) return;
    final path = await _sessionFilePath(_currentSessionId!);
    final file = File(path);
    if (await file.exists()) {
      if (_player.playing) {
        await _player.stop();
      }
      await _player.setFilePath(path);
      setState(() {
        _audioPath = path;
        _hasAudio = true;
      });
      debugPrint('[UI] Loaded session audio: $path');
    } else {
      setState(() {
        _audioPath = null;
        _hasAudio = false;
      });
      debugPrint('[UI] No audio for session: $_currentSessionId');
    }
  }

  Future<void> _deleteAudio() async {
    final ok = await _confirm(
      context,
      title: '削除しますか？',
      message: '音声ファイルを削除します。よろしいですか？',
      confirmText: '削除',
    );
    if (ok != true) return;

    try {
      await _player.stop();
    } catch (_) {}
    if (_audioPath != null) {
      try {
        final file = File(_audioPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('[UI] Deleted audio file: $_audioPath');
        }
      } catch (e) {
        debugPrint('[UI][WARN] Failed to delete file: $e');
      }
    }
    setState(() {
      _audioPath = null;
      _hasAudio = false;
    });
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _player.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dim the chat area slightly when the drawer (menu bar) is open
      drawerScrimColor: Colors.black26,
      drawer: MenuDrawer(onSelectSession: _onSelectSession),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'メニュー',
          ),
        ),
        title: const Text('Native Voice'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  onChanged: (_) {
                    setState(() {});
                    _scheduleSaveSession();
                  },
                  decoration: const InputDecoration(
                    hintText: 'ここにテキストを入力...',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: _openSettings,
                    icon: const Icon(Icons.tune),
                    tooltip: '言語設定',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_settings.language} / ${_settings.gender == 'male' ? '男性' : '女性'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _textController.text.trim().isEmpty || _isGenerating
                        ? null
                        : _generateAudio,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating ? '生成中…' : '生成'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_hasAudio)
                _PlaybackBar(
                  playerStateStream: _player.playerStateStream,
                  positionStream: _player.positionStream,
                  durationStream: _player.durationStream,
                  onPlayPause: () async {
                    final duration = _player.duration;
                    final position = _player.position;
                    final ps = await _player.playerStateStream.first;
                    final ended = ps.processingState == ProcessingState.completed;
                    if (_player.playing) {
                      await _player.pause();
                    } else {
                      if (ended || (duration != null && position >= duration)) {
                        await _player.seek(Duration.zero);
                      }
                      await _player.play();
                    }
                  },
                  onDelete: _deleteAudio,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '音声はまだ生成されていません',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaybackBar extends StatelessWidget {
  const _PlaybackBar({
    required this.playerStateStream,
    required this.positionStream,
    required this.durationStream,
    required this.onPlayPause,
    required this.onDelete,
  });
  final Stream<PlayerState> playerStateStream;
  final Stream<Duration> positionStream;
  final Stream<Duration?> durationStream;
  final VoidCallback onPlayPause;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder<PlayerState>(
        stream: playerStateStream,
        builder: (context, ps) {
          final playing = ps.data?.playing ?? false;
          final completed =
              ps.data?.processingState == ProcessingState.completed;
          final showPlay = !playing || completed;
          return Row(
            children: [
              ElevatedButton.icon(
                onPressed: onPlayPause,
                icon: Icon(showPlay ? Icons.play_arrow : Icons.pause),
                label: Text(showPlay ? '再生' : '一時停止'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PositionBar(
                  positionStream: positionStream,
                  durationStream: durationStream,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: '削除',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PositionBar extends StatelessWidget {
  const _PositionBar({
    required this.positionStream,
    required this.durationStream,
  });
  final Stream<Duration> positionStream;
  final Stream<Duration?> durationStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: durationStream,
      builder: (context, dSnap) {
        final duration = dSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: positionStream,
          initialData: Duration.zero,
          builder: (context, pSnap) {
            final position = pSnap.data ?? Duration.zero;
            final totalMs = duration.inMilliseconds;
            final posMs = position.inMilliseconds.clamp(0, totalMs == 0 ? 0 : totalMs);
            final value = totalMs == 0 ? 0.0 : posMs / totalMs;
            return LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white12,
            );
          },
        );
      },
    );
  }
}
