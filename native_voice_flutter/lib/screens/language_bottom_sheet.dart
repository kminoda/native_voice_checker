import 'package:flutter/material.dart';
import 'package:native_voice_flutter/l10n/app_localizations.dart';

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
            Builder(builder: (context) {
              return Text(
                AppLocalizations.of(context)!.languageModalTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              );
            }),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.labelLanguage, style: TextStyle(color: Colors.grey.shade300)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _language,
              menuMaxHeight: MediaQuery.of(context).size.height * 0.6,
              items: [
                DropdownMenuItem(value: 'en-US', child: Text(AppLocalizations.of(context)!.lang_en_US)),
                DropdownMenuItem(value: 'en-GB', child: Text(AppLocalizations.of(context)!.lang_en_GB)),
                DropdownMenuItem(value: 'ja-JP', child: Text(AppLocalizations.of(context)!.lang_ja_JP)),
                DropdownMenuItem(value: 'zh-CN', child: Text(AppLocalizations.of(context)!.lang_zh_CN)),
                DropdownMenuItem(value: 'zh-TW', child: Text(AppLocalizations.of(context)!.lang_zh_TW)),
                DropdownMenuItem(value: 'es-ES', child: Text(AppLocalizations.of(context)!.lang_es_ES)),
                DropdownMenuItem(value: 'fr-FR', child: Text(AppLocalizations.of(context)!.lang_fr_FR)),
                DropdownMenuItem(value: 'de-DE', child: Text(AppLocalizations.of(context)!.lang_de_DE)),
                DropdownMenuItem(value: 'ko-KR', child: Text(AppLocalizations.of(context)!.lang_ko_KR)),
                DropdownMenuItem(value: 'it-IT', child: Text(AppLocalizations.of(context)!.lang_it_IT)),
                DropdownMenuItem(value: 'pt-BR', child: Text(AppLocalizations.of(context)!.lang_pt_BR)),
                DropdownMenuItem(value: 'ru-RU', child: Text(AppLocalizations.of(context)!.lang_ru_RU)),
                DropdownMenuItem(value: 'ar-XA', child: Text(AppLocalizations.of(context)!.lang_ar_XA)),
                DropdownMenuItem(value: 'hi-IN', child: Text(AppLocalizations.of(context)!.lang_hi_IN)),
                DropdownMenuItem(value: 'tr-TR', child: Text(AppLocalizations.of(context)!.lang_tr_TR)),
                DropdownMenuItem(value: 'nl-NL', child: Text(AppLocalizations.of(context)!.lang_nl_NL)),
                DropdownMenuItem(value: 'pl-PL', child: Text(AppLocalizations.of(context)!.lang_pl_PL)),
                DropdownMenuItem(value: 'sv-SE', child: Text(AppLocalizations.of(context)!.lang_sv_SE)),
                DropdownMenuItem(value: 'vi-VN', child: Text(AppLocalizations.of(context)!.lang_vi_VN)),
                DropdownMenuItem(value: 'th-TH', child: Text(AppLocalizations.of(context)!.lang_th_TH)),
                DropdownMenuItem(value: 'id-ID', child: Text(AppLocalizations.of(context)!.lang_id_ID)),
                DropdownMenuItem(value: 'he-IL', child: Text(AppLocalizations.of(context)!.lang_he_IL)),
                DropdownMenuItem(value: 'da-DK', child: Text(AppLocalizations.of(context)!.lang_da_DK)),
                DropdownMenuItem(value: 'el-GR', child: Text(AppLocalizations.of(context)!.lang_el_GR)),
                DropdownMenuItem(value: 'fi-FI', child: Text(AppLocalizations.of(context)!.lang_fi_FI)),
                DropdownMenuItem(value: 'nb-NO', child: Text(AppLocalizations.of(context)!.lang_nb_NO)),
              ],
              onChanged: (v) => setState(() => _language = v ?? _language),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.labelVoice, style: TextStyle(color: Colors.grey.shade300)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.male),
                    selected: _gender == 'male',
                    onSelected: (_) => setState(() => _gender = 'male'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.female),
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
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(
                      LanguageSettings(language: _language, gender: _gender),
                    ),
                    child: Text(AppLocalizations.of(context)!.save),
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
