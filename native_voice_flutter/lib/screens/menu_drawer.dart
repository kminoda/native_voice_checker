import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:native_voice_flutter/l10n/app_localizations.dart';
import 'package:native_voice_flutter/services/session_store.dart';
import 'package:native_voice_flutter/screens/premium_bottom_sheet.dart';
import 'package:native_voice_flutter/services/premium_service.dart';
import 'package:native_voice_flutter/screens/settings_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:native_voice_flutter/ui/review_prompt.dart';
import 'package:native_voice_flutter/services/review_tracker.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({
    super.key,
    required this.onSelectSession,
    this.currentSessionId,
  });

  final Future<void> Function(String id, String text) onSelectSession;
  final String? currentSessionId;

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final SessionStore _store = SessionStore();
  String _query = '';
  final Uri _ankiAppUri = Uri.parse('https://apps.apple.com/jp/app/id6740526880');
  final PremiumService _premium = PremiumService.instance;
  final ReviewTracker _reviewTracker = ReviewTracker();

  Future<void> _createNewSession() async {
    final id = 'session_${DateTime.now().millisecondsSinceEpoch}';
    if (mounted) Navigator.of(context).pop();
    await widget.onSelectSession(id, '');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const double topOverlayPadding = 12; // visual spacing in the top overlay
    const double topOverlayHeight = 64; // slightly tighter search bar height
    const double bottomOverlayHeight = 200; // tighter: dense tiles + smaller paddings

    return Drawer(
      width: width * 0.85,
      child: SafeArea(
        child: Stack(
          children: [
            // Session list layer
            Positioned.fill(
              child: FutureBuilder<List<SessionData>>(
                future: _store.listAll(),
                builder: (context, snapshot) {
                  final sessions = (snapshot.data ?? [])
                      .where((s) => s.text.toLowerCase().contains(_query.toLowerCase()))
                      .toList();
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (sessions.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.noSessions,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(
                      top: topOverlayPadding + topOverlayHeight,
                      bottom: bottomOverlayHeight + 12,
                    ),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
                    itemBuilder: (context, index) {
                      final s = sessions[index];
                      final l10n = AppLocalizations.of(context)!;
                      final display = s.text.isEmpty ? l10n.untitled : s.text;
                      return ListTile(
                        title: Text(
                          display,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          l10n.currentVoice(_langName(context, s.language), s.gender == 'male' ? l10n.male : l10n.female),
                          style: const TextStyle(color: Colors.white54),
                        ),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop();
                              widget.onSelectSession(s.id, s.text);
                            },
                            onLongPress: () {
                              HapticFeedback.selectionClick();
                              _showActions(s);
                            },
                          );
                    },
                  );
                },
              ),
            ),

            // Top translucent search overlay (no white divider)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    color: Colors.black.withOpacity(0.65),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searchSessionsHint,
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: AppLocalizations.of(context)!.newSession,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _createNewSession();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom translucent premium/review overlay (no white divider)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    color: Colors.black.withOpacity(0.65),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            minVerticalPadding: 6,
                            leading: const Icon(Icons.menu_book_outlined),
                            title: Text(AppLocalizations.of(context)!.wordbookListen),
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              try {
                                if (!await launchUrl(_ankiAppUri, mode: LaunchMode.externalApplication)) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.openLinkFailed)),
                                  );
                                }
                              } catch (_) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.openLinkFailed)),
                                );
                              }
                            },
                          ),
                          AnimatedBuilder(
                            animation: _premium,
                            builder: (context, _) {
                              final isPremium = _premium.isPremium;
                              return ListTile(
                                minVerticalPadding: 6,
                                leading: const Icon(Icons.workspace_premium_outlined),
                                title: Text(AppLocalizations.of(context)!.premiumPlan),
                                subtitle: Text(
                                  isPremium
                                      ? AppLocalizations.of(context)!.premiumSubtitlePremium
                                      : AppLocalizations.of(context)!.premiumSubtitleNot,
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                trailing: isPremium
                                    ? const Icon(Icons.verified_rounded, color: Colors.greenAccent)
                                    : null,
                                onTap: () async {
                                  HapticFeedback.selectionClick();
                                  await showPremiumBottomSheet(context);
                                },
                              );
                            },
                          ),
                          ListTile(
                            minVerticalPadding: 6,
                            leading: const Icon(Icons.star_border_rounded),
                            title: Text(AppLocalizations.of(context)!.review),
                            subtitle: Text(
                              Localizations.localeOf(context).languageCode == 'ja'
                                  ? 'レビューを書いて応援する'
                                  : 'Support us with a review',
                              style: const TextStyle(color: Colors.white54),
                            ),
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              final rated = await showReviewFlow(context);
                              if (rated) {
                                await _reviewTracker.markReviewed();
                              }
                            },
                          ),
                          ListTile(
                            minVerticalPadding: 6,
                            leading: const Icon(Icons.settings_outlined),
                            title: Text(AppLocalizations.of(context)!.settings),
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              Navigator.of(context).pop();
                              // open settings bottom sheet on the root scaffold
                              await Future.delayed(const Duration(milliseconds: 100));
                              // ignore: use_build_context_synchronously
                              final rootContext = context;
                              await showSettingsBottomSheet(rootContext);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Review dialog is provided by shared UI in ui/review_prompt.dart

  Future<void> _showActions(SessionData s) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(AppLocalizations.of(context)!.delete),
              onTap: () async {
                Navigator.of(context).pop();
                await _deleteSession(s);
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSession(SessionData s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(AppLocalizations.of(context)!.confirmDeleteAudioTitle),
        content: Text(AppLocalizations.of(context)!.confirmDeleteAudioMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      // delete json
      await _store.delete(s.id);
      // delete audio file if exists
      try {
        final docs = await getApplicationDocumentsDirectory();
        final audio = File('${docs.path}/tts/${s.id}.mp3');
        if (await audio.exists()) {
          await audio.delete();
        }
      } catch (_) {}

      // If the deleted session is the one currently open, auto-create a new one
      if (widget.currentSessionId != null && widget.currentSessionId == s.id) {
        await _createNewSession();
      }
    }
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
