import 'package:flutter/material.dart';

class LanguageSettings {
  LanguageSettings({
    required this.language,
    required this.gender,
  });

  String language; // e.g., en-US, ja-JP
  String gender; // male | female
}

Future<LanguageSettings?> showLanguageBottomSheet(
  BuildContext context, {
  required LanguageSettings initial,
}) {
  return showModalBottomSheet<LanguageSettings>(
    context: context,
    isScrollControlled: false,
    builder: (context) => _LanguageBottomSheet(initial: initial),
  );
}

class _LanguageBottomSheet extends StatefulWidget {
  const _LanguageBottomSheet({required this.initial});
  final LanguageSettings initial;

  @override
  State<_LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<_LanguageBottomSheet> {
  late String _language = widget.initial.language;
  late String _gender = widget.initial.gender;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '言語設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
              onChanged: (v) => setState(() => _language = v ?? _language),
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
                    onSelected: (_) => setState(() => _gender = 'male'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('女性'),
                    selected: _gender == 'female',
                    onSelected: (_) => setState(() => _gender = 'female'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(
                      LanguageSettings(language: _language, gender: _gender),
                    ),
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
