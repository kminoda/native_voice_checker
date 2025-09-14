import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Native Voice'**
  String get appTitle;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @overwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get overwrite;

  /// No description provided for @confirmOverwriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite?'**
  String get confirmOverwriteTitle;

  /// No description provided for @confirmOverwriteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite the existing audio file. Continue?'**
  String get confirmOverwriteMessage;

  /// No description provided for @confirmDeleteAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get confirmDeleteAudioTitle;

  /// No description provided for @confirmDeleteAudioMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete the audio file. Are you sure?'**
  String get confirmDeleteAudioMessage;

  /// No description provided for @notGeneratedYet.
  ///
  /// In en, this message translates to:
  /// **'No audio has been generated yet'**
  String get notGeneratedYet;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @inputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter text here...'**
  String get inputHint;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get languageSettings;

  /// No description provided for @currentVoice.
  ///
  /// In en, this message translates to:
  /// **'{language} / {gender}'**
  String currentVoice(Object language, Object gender);

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get generating;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'(Untitled)'**
  String get untitled;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions'**
  String get noSessions;

  /// No description provided for @searchSessionsHint.
  ///
  /// In en, this message translates to:
  /// **'Search sessions'**
  String get searchSessionsHint;

  /// No description provided for @newSession.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newSession;

  /// No description provided for @wordbookListen.
  ///
  /// In en, this message translates to:
  /// **'Learn with Flashcard'**
  String get wordbookListen;

  /// No description provided for @openLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get openLinkFailed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @premiumSubtitlePremium.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get premiumSubtitlePremium;

  /// No description provided for @premiumSubtitleNot.
  ///
  /// In en, this message translates to:
  /// **'Ad-free / Unlimited use'**
  String get premiumSubtitleNot;

  /// No description provided for @premiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Create the best environment to focus on native practice. No ads, unlimited audio generation.'**
  String get premiumDescription;

  /// No description provided for @featureNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get featureNoAds;

  /// No description provided for @featureUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited audio generation'**
  String get featureUnlimited;

  /// No description provided for @subscribeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Monthly'**
  String get subscribeMonthly;

  /// No description provided for @subscribeMonthlyWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Monthly ({price}/mo)'**
  String subscribeMonthlyWithPrice(Object price);

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @thanksPremium.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Premium is now active'**
  String get thanksPremium;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase was canceled or failed'**
  String get purchaseFailed;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore'**
  String get restoreFailed;

  /// No description provided for @subscriptionNote.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime.'**
  String get subscriptionNote;

  /// No description provided for @upgradeTagline.
  ///
  /// In en, this message translates to:
  /// **'Upgrade your learning experience comfortably'**
  String get upgradeTagline;

  /// No description provided for @tokenLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get tokenLimitTitle;

  /// No description provided for @tokenLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the free plan limit. Upgrade to Premium for ad-free and unlimited audio generation.'**
  String get tokenLimitMessage;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @defaultVoiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Default voice settings'**
  String get defaultVoiceSettings;

  /// No description provided for @labelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get labelLanguage;

  /// No description provided for @labelVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get labelVoice;

  /// No description provided for @languageModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get languageModalTitle;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get review;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @lang_en_US.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get lang_en_US;

  /// No description provided for @lang_en_GB.
  ///
  /// In en, this message translates to:
  /// **'English (UK)'**
  String get lang_en_GB;

  /// No description provided for @lang_ja_JP.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get lang_ja_JP;

  /// No description provided for @lang_zh_CN.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get lang_zh_CN;

  /// No description provided for @lang_zh_TW.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Traditional)'**
  String get lang_zh_TW;

  /// No description provided for @lang_es_ES.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get lang_es_ES;

  /// No description provided for @lang_fr_FR.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get lang_fr_FR;

  /// No description provided for @lang_de_DE.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get lang_de_DE;

  /// No description provided for @lang_ko_KR.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get lang_ko_KR;

  /// No description provided for @lang_it_IT.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get lang_it_IT;

  /// No description provided for @lang_pt_BR.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get lang_pt_BR;

  /// No description provided for @lang_ru_RU.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get lang_ru_RU;

  /// No description provided for @lang_ar_XA.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get lang_ar_XA;

  /// No description provided for @lang_hi_IN.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get lang_hi_IN;

  /// No description provided for @lang_tr_TR.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get lang_tr_TR;

  /// No description provided for @lang_nl_NL.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get lang_nl_NL;

  /// No description provided for @lang_pl_PL.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get lang_pl_PL;

  /// No description provided for @lang_sv_SE.
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get lang_sv_SE;

  /// No description provided for @lang_vi_VN.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get lang_vi_VN;

  /// No description provided for @lang_th_TH.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get lang_th_TH;

  /// No description provided for @lang_id_ID.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get lang_id_ID;

  /// No description provided for @lang_he_IL.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get lang_he_IL;

  /// No description provided for @lang_da_DK.
  ///
  /// In en, this message translates to:
  /// **'Danish'**
  String get lang_da_DK;

  /// No description provided for @lang_el_GR.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get lang_el_GR;

  /// No description provided for @lang_fi_FI.
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get lang_fi_FI;

  /// No description provided for @lang_nb_NO.
  ///
  /// In en, this message translates to:
  /// **'Norwegian'**
  String get lang_nb_NO;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
