import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_voice_flutter/l10n/app_localizations.dart';
import 'package:native_voice_flutter/screens/language_bottom_sheet.dart';
import 'package:native_voice_flutter/services/defaults_store.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool?> showSettingsBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: const _SettingsBottomSheet(),
    ),
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
  final Uri _termsUri = Uri.parse('https://www.notion.so/Native-Voice-Check-Terms-of-Use-26d2e1f4abd28093973ff15f985b71cc?source=copy_link');
  final Uri _privacyUri = Uri.parse('https://www.notion.so/Native-Voice-Check-Privacy-Policy-26d2e1f4abd2809b8758eb3b42a5aa97?source=copy_link');

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
            : ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    AppLocalizations.of(context)!.appSettings,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.defaultVoiceSettings, style: TextStyle(color: Colors.grey.shade300)),
                  const SizedBox(height: 12),
                  _DefaultVoiceEditor(
                    language: defaults.language,
                    gender: defaults.gender,
                    onChanged: (lang, gen) {
                      final nd = DefaultSettings(language: lang, gender: gen);
                      _defaults = nd;
                      _store.save(nd);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppLocalizations.of(context)!.termsOfUse),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      final ok = await launchUrl(_termsUri, mode: LaunchMode.externalApplication);
                      if (!ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.openLinkFailed)),
                        );
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppLocalizations.of(context)!.privacyPolicy),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      final ok = await launchUrl(_privacyUri, mode: LaunchMode.externalApplication);
                      if (!ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.openLinkFailed)),
                        );
                      }
                    },
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
          onChanged: (v) {
            HapticFeedback.selectionClick();
            setState(() => _language = v ?? _language);
            widget.onChanged(_language, _gender);
          },
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
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() => _gender = 'male');
                  widget.onChanged(_language, _gender);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: Text(AppLocalizations.of(context)!.female),
                selected: _gender == 'female',
                onSelected: (_) {
                  HapticFeedback.selectionClick();
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
