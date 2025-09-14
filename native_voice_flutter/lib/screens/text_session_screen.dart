import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:native_voice_flutter/l10n/app_localizations.dart';
import 'package:native_voice_flutter/screens/language_bottom_sheet.dart';
import 'package:native_voice_flutter/screens/menu_drawer.dart';
import 'package:native_voice_flutter/services/tts_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:native_voice_flutter/services/session_store.dart';
import 'package:native_voice_flutter/services/defaults_store.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:native_voice_flutter/services/premium_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:native_voice_flutter/screens/premium_bottom_sheet.dart';

class TextSessionScreen extends StatefulWidget {
  const TextSessionScreen({super.key});

  @override
  State<TextSessionScreen> createState() => _TextSessionScreenState();
}

class _TextSessionScreenState extends State<TextSessionScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
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
  // AdMob interstitial support
  InterstitialAd? _interstitialAd;
  bool _isLoadingAd = false;
  final Random _rand = Random();
  final PremiumService _premium = PremiumService.instance;
  // Ad unit IDs (prod and Google-provided test unit)
  static const String _interstitialUnitIdProd = 'ca-app-pub-5083707284208912/4312090887';
  static const String _interstitialUnitIdTest = 'ca-app-pub-3940256099942544/4411468910';
  String get _adUnitId => kReleaseMode ? _interstitialUnitIdProd : _interstitialUnitIdTest;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
    // Preload an interstitial ad only if not premium
    _loadInterstitial();
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
    // Ensure keyboard does not automatically appear on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      _textFocusNode.unfocus();
    });
    // React to premium status changes (dispose ads if user becomes premium)
    _premium.addListener(_onPremiumUpdate);
  }

  void _onPremiumUpdate() {
    if (_premium.isPremium) {
      try {
        _interstitialAd?.dispose();
      } catch (_) {}
      _interstitialAd = null;
      _isLoadingAd = false;
      if (mounted) setState(() {});
    }
  }

  void _loadInterstitial() {
    if (_premium.isPremium) return; // No ads for premium users
    if (_isLoadingAd || _interstitialAd != null) return;
    _isLoadingAd = true;
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingAd = false;
          debugPrint('[AD] Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoadingAd = false;
          debugPrint('[AD][WARN] Interstitial load failed: $error');
        },
      ),
    );
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
    await showLanguageBottomSheet(
      context,
      initial: _settings,
      onChanged: (val) {
        setState(() => _settings = val);
        _scheduleSaveSession();
      },
    );
  }

  void _generateAudio() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    try {
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
          title: AppLocalizations.of(context)!.confirmOverwriteTitle,
          message: AppLocalizations.of(context)!.confirmOverwriteMessage,
          confirmText: AppLocalizations.of(context)!.overwrite,
        );
        if (ok != true) {
          setState(() => _isGenerating = false);
          return;
        }
      }
      // Randomly show an interstitial before generation (~33%), except for premium
      final showAd = !_premium.isPremium && _rand.nextInt(3) == 0;
      if (showAd && _interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) => debugPrint('[AD] Interstitial shown'),
          onAdDismissedFullScreenContent: (ad) async {
            debugPrint('[AD] Interstitial dismissed');
            ad.dispose();
            _interstitialAd = null;
            _loadInterstitial();
            await _performGeneration(text, targetPath);
          },
          onAdFailedToShowFullScreenContent: (ad, error) async {
            debugPrint('[AD][WARN] Interstitial failed to show: $error');
            ad.dispose();
            _interstitialAd = null;
            _loadInterstitial();
            await _performGeneration(text, targetPath);
          },
        );
        _interstitialAd!.show();
        return; // continue in callbacks
      }

      // If no ad, proceed directly
      await _performGeneration(text, targetPath);
    } catch (e) {
      debugPrint('[UI][ERROR] TTS generation failed: $e');
      // No SnackBar in failure either; rely on console logs
    }
  }

  Future<void> _performGeneration(String text, String targetPath) async {
    try {
      if (mounted) setState(() => _isGenerating = true);
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
    } catch (e) {
      debugPrint('[UI][ERROR] Generation failed in _performGeneration: $e');
      // If free user hits token cap, show upsell. If premium locally but server
      // still thinks free (sync lag), try one-time resync + retry.
      if (e is FirebaseFunctionsException && e.code == 'resource-exhausted') {
        if (_premium.isPremium) {
          debugPrint('[UI] Local premium but server returned resource-exhausted. Attempting resync + retry.');
          try {
            // Refresh RC state then push plan to backend
            await _premium.syncPlanNow(refreshEntitlementsFirst: true);
          } catch (_) {}
          // One-time retry
          try {
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
            debugPrint('[UI] Audio file set to player after retry: path=${_audioPath!}');
            setState(() => _hasAudio = true);
            _scheduleSaveSession();
            return; // success after retry
          } catch (e2) {
            debugPrint('[UI][WARN] Retry after resync failed: $e2');
            // Fall through to dialog for guidance
            if (!mounted) return;
            await _showPremiumSyncFailedDialog();
            return;
          }
        } else {
          if (!mounted) return;
          await _showTokenLimitDialog();
        }
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _showPremiumSyncFailedDialog() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(l10n.tokenLimitTitle),
        content: Text(
          // Keep copy simple: premiumなのに失敗 → 復元/再同期の提案
          'Your premium status could not be synced yet. Try restoring purchases or retry shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              HapticFeedback.selectionClick();
              await _premium.restore();
            },
            child: const Text('Restore & Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTokenLimitDialog() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(l10n.tokenLimitTitle),
        content: Text(l10n.tokenLimitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              HapticFeedback.selectionClick();
              await showPremiumBottomSheet(context);
            },
            child: Text(l10n.goPremium),
          ),
        ],
      ),
    );
  }

  Future<void> _onSelectSession(String id, String text) async {
    // Avoid focusing the editor when switching sessions
    FocusScope.of(context).unfocus();
    _textFocusNode.unfocus();
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
      title: AppLocalizations.of(context)!.confirmDeleteAudioTitle,
      message: AppLocalizations.of(context)!.confirmDeleteAudioMessage,
      confirmText: AppLocalizations.of(context)!.delete,
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
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
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
            child: Text(AppLocalizations.of(context)!.cancel),
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
    try { _interstitialAd?.dispose(); } catch (_) {}
    _saveDebounce?.cancel();
    _player.dispose();
    _textFocusNode.dispose();
    _textController.dispose();
    _premium.removeListener(_onPremiumUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dim the chat area slightly when the drawer (menu bar) is open
      drawerScrimColor: Colors.black26,
      drawer: MenuDrawer(onSelectSession: _onSelectSession),
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          FocusScope.of(context).unfocus();
          _textFocusNode.unfocus();
        }
      },
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              HapticFeedback.selectionClick();
              Scaffold.of(context).openDrawer();
            },
            tooltip: AppLocalizations.of(context)!.menu,
          ),
        ),
        title: Text(AppLocalizations.of(context)!.appTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta != null && details.primaryDelta! > 6) {
              FocusScope.of(context).unfocus();
            }
          },
          child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _textFocusNode,
                  autofocus: false,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  onChanged: (_) {
                    setState(() {});
                    _scheduleSaveSession();
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.inputHint,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _openSettings();
                    },
                    icon: const Icon(Icons.tune),
                    tooltip: AppLocalizations.of(context)!.languageSettings,
                  ),
                  const SizedBox(width: 8),
                  Builder(builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    final genderLabel = _settings.gender == 'male' ? l10n.male : l10n.female;
                    final langName = _langName(context, _settings.language);
                    return Text(
                      l10n.currentVoice(langName, genderLabel),
                      style: const TextStyle(color: Colors.white70),
                    );
                  }),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _textController.text.trim().isEmpty || _isGenerating
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            _generateAudio();
                          },
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isGenerating
                          ? AppLocalizations.of(context)!.generating
                          : AppLocalizations.of(context)!.generate,
                    ),
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
                    HapticFeedback.selectionClick();
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
                  onSeek: (dur) async {
                    try {
                      await _player.seek(dur);
                    } catch (_) {}
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Builder(builder: (context) {
                    return Text(
                      AppLocalizations.of(context)!.notGeneratedYet,
                      style: const TextStyle(color: Colors.white54),
                    );
                  }),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

String _langName(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context)!;
  switch (code) {
    case 'en-US':
      return l10n.lang_en_US;
    case 'en-GB':
      return l10n.lang_en_GB;
    case 'ja-JP':
      return l10n.lang_ja_JP;
    case 'zh-CN':
      return l10n.lang_zh_CN;
    case 'zh-TW':
      return l10n.lang_zh_TW;
    case 'es-ES':
      return l10n.lang_es_ES;
    case 'fr-FR':
      return l10n.lang_fr_FR;
    case 'de-DE':
      return l10n.lang_de_DE;
    case 'ko-KR':
      return l10n.lang_ko_KR;
    case 'it-IT':
      return l10n.lang_it_IT;
    case 'pt-BR':
      return l10n.lang_pt_BR;
    case 'ru-RU':
      return l10n.lang_ru_RU;
    case 'ar-XA':
      return l10n.lang_ar_XA;
    case 'hi-IN':
      return l10n.lang_hi_IN;
    case 'tr-TR':
      return l10n.lang_tr_TR;
    case 'nl-NL':
      return l10n.lang_nl_NL;
    case 'pl-PL':
      return l10n.lang_pl_PL;
    case 'sv-SE':
      return l10n.lang_sv_SE;
    case 'vi-VN':
      return l10n.lang_vi_VN;
    case 'th-TH':
      return l10n.lang_th_TH;
    case 'id-ID':
      return l10n.lang_id_ID;
    case 'he-IL':
      return l10n.lang_he_IL;
    case 'da-DK':
      return l10n.lang_da_DK;
    case 'el-GR':
      return l10n.lang_el_GR;
    case 'fi-FI':
      return l10n.lang_fi_FI;
    case 'nb-NO':
      return l10n.lang_nb_NO;
    default:
      return code;
  }
}

class _PlaybackBar extends StatelessWidget {
  const _PlaybackBar({
    required this.playerStateStream,
    required this.positionStream,
    required this.durationStream,
    required this.onPlayPause,
    required this.onSeek,
  });
  final Stream<PlayerState> playerStateStream;
  final Stream<Duration> positionStream;
  final Stream<Duration?> durationStream;
  final VoidCallback onPlayPause;
  final void Function(Duration position) onSeek;

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
              Builder(builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return IconButton(
                  onPressed: onPlayPause,
                  iconSize: 28,
                  icon: Icon(showPlay ? Icons.play_arrow_rounded : Icons.pause_rounded),
                  tooltip: showPlay ? l10n.play : l10n.pause,
                );
              }),
              const SizedBox(width: 12),
              Expanded(
                child: _PositionBar(
                  positionStream: positionStream,
                  durationStream: durationStream,
                  onSeek: onSeek,
                ),
              ),
              const SizedBox(width: 12),
              // Time display: current position / total duration
              StreamBuilder<Duration?>(
                stream: durationStream,
                builder: (context, dSnap) {
                  final total = dSnap.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: positionStream,
                    initialData: Duration.zero,
                    builder: (context, pSnap) {
                      final pos = pSnap.data ?? Duration.zero;
                      return Text(
                        '${_fmt(pos)} / ${_fmt(total)}',
                        style: const TextStyle(color: Colors.white70),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    final s2 = s.toString().padLeft(2, '0');
    return '$m:$s2';
  }
}

class _PositionBar extends StatefulWidget {
  const _PositionBar({
    required this.positionStream,
    required this.durationStream,
    required this.onSeek,
  });
  final Stream<Duration> positionStream;
  final Stream<Duration?> durationStream;
  final void Function(Duration position) onSeek;

  @override
  State<_PositionBar> createState() => _PositionBarState();
}

class _PositionBarState extends State<_PositionBar> {
  bool _dragging = false;
  double? _dragValue; // 0.0 - 1.0

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: widget.durationStream,
      builder: (context, dSnap) {
        final duration = dSnap.data ?? Duration.zero;
        final totalMs = duration.inMilliseconds;
        return StreamBuilder<Duration>(
          stream: widget.positionStream,
          initialData: Duration.zero,
          builder: (context, pSnap) {
            final position = pSnap.data ?? Duration.zero;
            final posMs = position.inMilliseconds.clamp(0, totalMs == 0 ? 0 : totalMs);
            final liveValue = totalMs == 0 ? 0.0 : (posMs / (totalMs == 0 ? 1 : totalMs));
            final value = _dragging && _dragValue != null ? _dragValue!.clamp(0.0, 1.0) : liveValue;

            final slider = SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6, disabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                inactiveTrackColor: Colors.white12,
              ),
              child: Slider(
                value: value.isNaN ? 0.0 : value,
                onChangeStart: totalMs == 0
                    ? null
                    : (v) {
                        try {
                          HapticFeedback.selectionClick();
                        } catch (_) {}
                        setState(() {
                          _dragging = true;
                          _dragValue = v;
                        });
                      },
                onChanged: totalMs == 0
                    ? null
                    : (v) {
                        setState(() => _dragValue = v);
                      },
                onChangeEnd: totalMs == 0
                    ? null
                    : (v) {
                        final targetMs = (v.clamp(0.0, 1.0) * totalMs).round();
                        widget.onSeek(Duration(milliseconds: targetMs));
                        try {
                          HapticFeedback.lightImpact();
                        } catch (_) {}
                        setState(() {
                          _dragging = false;
                          _dragValue = null;
                        });
                      },
              ),
            );

            return AbsorbPointer(absorbing: totalMs == 0, child: slider);
          },
        );
      },
    );
  }
}
