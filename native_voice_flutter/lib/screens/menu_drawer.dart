import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:native_voice_flutter/services/session_store.dart';
import 'package:native_voice_flutter/screens/premium_bottom_sheet.dart';
import 'package:native_voice_flutter/screens/settings_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key, required this.onSelectSession});

  final Future<void> Function(String id, String text) onSelectSession;

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final SessionStore _store = SessionStore();
  String _query = '';
  final Uri _reviewUri = Uri.parse('https://example.com/app-review');

  Future<void> _createNewSession() async {
    final id = 'session_${DateTime.now().millisecondsSinceEpoch}';
    if (mounted) Navigator.of(context).pop();
    await widget.onSelectSession(id, '');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const double topOverlayPadding = 12; // visual spacing in the top overlay
    const double topOverlayHeight = 72; // approx TextField height + paddings
    const double bottomOverlayHeight = 180; // approx 3 ListTiles + paddings

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
                    return const Center(
                      child: Text(
                        'セッションがありません',
                        style: TextStyle(color: Colors.white54),
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
                      final display = s.text.isEmpty ? '(無題)' : s.text;
                      return ListTile(
                        title: Text(
                          display,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${s.language} / ${s.gender == 'male' ? '男性' : '女性'}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onSelectSession(s.id, s.text);
                        },
                        onLongPress: () => _showActions(s),
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
                            decoration: const InputDecoration(
                              hintText: 'セッションを検索',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: '新規作成',
                          onPressed: _createNewSession,
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
                            leading: const Icon(Icons.workspace_premium_outlined),
                            title: const Text('プレミアムプラン'),
                            onTap: () async {
                              await showPremiumBottomSheet(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.rate_review_outlined),
                            title: const Text('レビューを書く'),
                            onTap: () async {
                              try {
                                if (!await launchUrl(_reviewUri, mode: LaunchMode.externalApplication)) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('リンクを開けませんでした')),
                                  );
                                }
                              } catch (_) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('リンクを開けませんでした')),
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.settings_outlined),
                            title: const Text('設定'),
                            onTap: () async {
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
              title: const Text('削除'),
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
        title: const Text('削除しますか？'),
        content: const Text('セッションのデータと音声ファイルを削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
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
    }
  }
}
