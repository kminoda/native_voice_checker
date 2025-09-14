// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Native Voice';

  @override
  String get menu => 'Menu';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get overwrite => 'Overwrite';

  @override
  String get confirmOverwriteTitle => 'Overwrite?';

  @override
  String get confirmOverwriteMessage =>
      'This will overwrite the existing audio file. Continue?';

  @override
  String get confirmDeleteAudioTitle => 'Delete?';

  @override
  String get confirmDeleteAudioMessage =>
      'Delete the audio file. Are you sure?';

  @override
  String get notGeneratedYet => 'No audio has been generated yet';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get inputHint => 'Enter text here...';

  @override
  String get languageSettings => 'Voice Settings';

  @override
  String currentVoice(Object language, Object gender) {
    return '$language / $gender';
  }

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get generating => 'Generating…';

  @override
  String get generate => 'Generate';

  @override
  String get untitled => '(Untitled)';

  @override
  String get noSessions => 'No sessions';

  @override
  String get searchSessionsHint => 'Search sessions';

  @override
  String get newSession => 'New';

  @override
  String get wordbookListen => 'Learn with Flashcard';

  @override
  String get openLinkFailed => 'Could not open link';

  @override
  String get settings => 'Settings';

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get subscribed => 'Subscribed';

  @override
  String get premiumSubtitlePremium => 'Subscribed';

  @override
  String get premiumSubtitleNot => 'Ad-free / Unlimited use';

  @override
  String get premiumDescription =>
      'Create the best environment to focus on native practice. No ads, unlimited audio generation.';

  @override
  String get featureNoAds => 'No ads';

  @override
  String get featureUnlimited => 'Unlimited audio generation';

  @override
  String get subscribeMonthly => 'Subscribe Monthly';

  @override
  String subscribeMonthlyWithPrice(Object price) {
    return 'Subscribe Monthly ($price/mo)';
  }

  @override
  String get processing => 'Processing…';

  @override
  String get thanksPremium => 'Thanks! Premium is now active';

  @override
  String get purchaseFailed => 'Purchase was canceled or failed';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get restoreSuccess => 'Purchases restored';

  @override
  String get restoreFailed => 'Could not restore';

  @override
  String get subscriptionNote => 'Cancel anytime.';

  @override
  String get upgradeTagline => 'Upgrade your learning experience comfortably';

  @override
  String get tokenLimitTitle => 'Limit reached';

  @override
  String get tokenLimitMessage =>
      'You\'ve reached the free plan limit. Upgrade to Premium for ad-free and unlimited audio generation.';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get appSettings => 'App Settings';

  @override
  String get defaultVoiceSettings => 'Default voice settings';

  @override
  String get labelLanguage => 'Language';

  @override
  String get labelVoice => 'Voice';

  @override
  String get languageModalTitle => 'Voice Settings';

  @override
  String get review => 'Rate the App';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get lang_en_US => 'English (US)';

  @override
  String get lang_en_GB => 'English (UK)';

  @override
  String get lang_ja_JP => 'Japanese';

  @override
  String get lang_zh_CN => 'Chinese (Simplified)';

  @override
  String get lang_zh_TW => 'Chinese (Traditional)';

  @override
  String get lang_es_ES => 'Spanish';

  @override
  String get lang_fr_FR => 'French';

  @override
  String get lang_de_DE => 'German';

  @override
  String get lang_ko_KR => 'Korean';

  @override
  String get lang_it_IT => 'Italian';

  @override
  String get lang_pt_BR => 'Portuguese (Brazil)';

  @override
  String get lang_ru_RU => 'Russian';

  @override
  String get lang_ar_XA => 'Arabic';

  @override
  String get lang_hi_IN => 'Hindi';

  @override
  String get lang_tr_TR => 'Turkish';

  @override
  String get lang_nl_NL => 'Dutch';

  @override
  String get lang_pl_PL => 'Polish';

  @override
  String get lang_sv_SE => 'Swedish';

  @override
  String get lang_vi_VN => 'Vietnamese';

  @override
  String get lang_th_TH => 'Thai';

  @override
  String get lang_id_ID => 'Indonesian';

  @override
  String get lang_he_IL => 'Hebrew';

  @override
  String get lang_da_DK => 'Danish';

  @override
  String get lang_el_GR => 'Greek';

  @override
  String get lang_fi_FI => 'Finnish';

  @override
  String get lang_nb_NO => 'Norwegian';
}
