import 'package:flutter/material.dart';
import 'package:native_voice_flutter/screens/language_bottom_sheet.dart';
import 'package:native_voice_flutter/services/defaults_store.dart';

Future<bool?> showSettingsBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: false,
    builder: (context) => const _SettingsBottomSheet(),
  );
}

class _SettingsBottomSheet extends StatefulWidget {
  const _SettingsBottomSheet();

  @override
  State<_SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<_SettingsBottomSheet> {
  final DefaultsStore _store = DefaultsStore();
  DefaultSettings? _defaults;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await _store.load();
    if (!mounted) return;
    setState(() => _defaults = d);
  }

  @override
  Widget build(BuildContext context) {
    final defaults = _defaults;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: defaults == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'アプリ設定',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('デフォルトの音声設定', style: TextStyle(color: Colors.grey.shade300)),
                  const SizedBox(height: 12),
                  _DefaultVoiceEditor(
                    language: defaults.language,
                    gender: defaults.gender,
                    onChanged: (lang, gen) => _defaults = DefaultSettings(language: lang, gender: gen),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('キャンセル'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final d = _defaults!;
                            await _store.save(d);
                            if (!mounted) return;
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('保存'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
      ),
    );
  }
}

class _DefaultVoiceEditor extends StatefulWidget {
  const _DefaultVoiceEditor({
    required this.language,
    required this.gender,
    required this.onChanged,
  });
  final String language;
  final String gender;
  final void Function(String language, String gender) onChanged;

  @override
  State<_DefaultVoiceEditor> createState() => _DefaultVoiceEditorState();
}

class _DefaultVoiceEditorState extends State<_DefaultVoiceEditor> {
  late String _language = widget.language;
  late String _gender = widget.gender;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('言語', style: TextStyle(color: Colors.grey.shade300)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _language,
          items: const [
            DropdownMenuItem(value: 'en-US', child: Text('英語 (米国)')),
            DropdownMenuItem(value: 'en-GB', child: Text('英語 (英国)')),
            DropdownMenuItem(value: 'ja-JP', child: Text('日本語')),
            DropdownMenuItem(value: 'zh-CN', child: Text('中国語 (簡体字)')),
            DropdownMenuItem(value: 'zh-TW', child: Text('中国語 (繁体字)')),
            DropdownMenuItem(value: 'es-ES', child: Text('スペイン語')),
            DropdownMenuItem(value: 'fr-FR', child: Text('フランス語')),
            DropdownMenuItem(value: 'de-DE', child: Text('ドイツ語')),
            DropdownMenuItem(value: 'ko-KR', child: Text('韓国語')),
            DropdownMenuItem(value: 'it-IT', child: Text('イタリア語')),
            DropdownMenuItem(value: 'pt-BR', child: Text('ポルトガル語 (ブラジル)')),
            DropdownMenuItem(value: 'ru-RU', child: Text('ロシア語')),
            DropdownMenuItem(value: 'ar-XA', child: Text('アラビア語')),
            DropdownMenuItem(value: 'hi-IN', child: Text('ヒンディー語')),
            DropdownMenuItem(value: 'tr-TR', child: Text('トルコ語')),
            DropdownMenuItem(value: 'nl-NL', child: Text('オランダ語')),
            DropdownMenuItem(value: 'pl-PL', child: Text('ポーランド語')),
            DropdownMenuItem(value: 'sv-SE', child: Text('スウェーデン語')),
            DropdownMenuItem(value: 'vi-VN', child: Text('ベトナム語')),
            DropdownMenuItem(value: 'th-TH', child: Text('タイ語')),
            DropdownMenuItem(value: 'id-ID', child: Text('インドネシア語')),
            DropdownMenuItem(value: 'he-IL', child: Text('ヘブライ語')),
            DropdownMenuItem(value: 'da-DK', child: Text('デンマーク語')),
            DropdownMenuItem(value: 'el-GR', child: Text('ギリシャ語')),
            DropdownMenuItem(value: 'fi-FI', child: Text('フィンランド語')),
            DropdownMenuItem(value: 'nb-NO', child: Text('ノルウェー語')),
          ],
          onChanged: (v) {
            setState(() => _language = v ?? _language);
            widget.onChanged(_language, _gender);
          },
        ),
        const SizedBox(height: 16),
        Text('ボイス', style: TextStyle(color: Colors.grey.shade300)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('男性'),
                selected: _gender == 'male',
                onSelected: (_) {
                  setState(() => _gender = 'male');
                  widget.onChanged(_language, _gender);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Text('女性'),
                selected: _gender == 'female',
                onSelected: (_) {
                  setState(() => _gender = 'female');
                  widget.onChanged(_language, _gender);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

