// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Native Voice';

  @override
  String get menu => 'メニュー';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get close => '閉じる';

  @override
  String get overwrite => '上書き';

  @override
  String get confirmOverwriteTitle => '上書きしますか？';

  @override
  String get confirmOverwriteMessage => '既存の音声ファイルを上書きします。よろしいですか？';

  @override
  String get confirmDeleteAudioTitle => '削除しますか？';

  @override
  String get confirmDeleteAudioMessage => '音声ファイルを削除します。よろしいですか？';

  @override
  String get notGeneratedYet => '音声はまだ生成されていません';

  @override
  String get play => '再生';

  @override
  String get pause => '一時停止';

  @override
  String get inputHint => 'ここにテキストを入力...';

  @override
  String get languageSettings => '言語設定';

  @override
  String currentVoice(Object language, Object gender) {
    return '$language / $gender';
  }

  @override
  String get male => '男性';

  @override
  String get female => '女性';

  @override
  String get generating => '生成中…';

  @override
  String get generate => '生成';

  @override
  String get untitled => '(無題)';

  @override
  String get noSessions => 'セッションがありません';

  @override
  String get searchSessionsHint => 'セッションを検索';

  @override
  String get newSession => '新規作成';

  @override
  String get wordbookListen => '単語帳で聞き流し学習';

  @override
  String get openLinkFailed => 'リンクを開けませんでした';

  @override
  String get settings => '設定';

  @override
  String get premiumPlan => 'プレミアムプラン';

  @override
  String get subscribed => '購読中';

  @override
  String get premiumSubtitlePremium => '購読中';

  @override
  String get premiumSubtitleNot => '広告なし / 無制限で利用';

  @override
  String get premiumDescription =>
      'ネイティブの練習に集中できる最適な環境を。広告なしで快適、音声生成は回数制限なく使い放題。';

  @override
  String get featureNoAds => '広告なし';

  @override
  String get featureUnlimited => '音声回数制限なし';

  @override
  String get subscribeMonthly => '月額プランに登録';

  @override
  String subscribeMonthlyWithPrice(Object price) {
    return '月額プランに登録 ($price/月)';
  }

  @override
  String get processing => '処理中…';

  @override
  String get thanksPremium => 'ありがとうございます！プレミアムが有効になりました';

  @override
  String get purchaseFailed => '購入がキャンセルまたは失敗しました';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get restoreSuccess => '購入を復元しました';

  @override
  String get restoreFailed => '復元できませんでした';

  @override
  String get subscriptionNote => 'サブスクリプションのみ対応（単発購入は非対応）。いつでもキャンセル可能。';

  @override
  String get upgradeTagline => '快適な学習体験をアップグレード';

  @override
  String get tokenLimitTitle => '上限に達しました';

  @override
  String get tokenLimitMessage =>
      '無料プランの上限に達しました。プレミアムに登録すると広告なし＆音声生成は無制限でご利用いただけます。';

  @override
  String get goPremium => 'プレミアムに登録';

  @override
  String get appSettings => 'アプリ設定';

  @override
  String get defaultVoiceSettings => 'デフォルトの音声設定';

  @override
  String get labelLanguage => '言語';

  @override
  String get labelVoice => 'ボイス';

  @override
  String get languageModalTitle => '言語設定';

  @override
  String get review => 'アプリを評価する';

  @override
  String get lang_en_US => '英語 (米国)';

  @override
  String get lang_en_GB => '英語 (英国)';

  @override
  String get lang_ja_JP => '日本語';

  @override
  String get lang_zh_CN => '中国語 (簡体字)';

  @override
  String get lang_zh_TW => '中国語 (繁体字)';

  @override
  String get lang_es_ES => 'スペイン語';

  @override
  String get lang_fr_FR => 'フランス語';

  @override
  String get lang_de_DE => 'ドイツ語';

  @override
  String get lang_ko_KR => '韓国語';

  @override
  String get lang_it_IT => 'イタリア語';

  @override
  String get lang_pt_BR => 'ポルトガル語 (ブラジル)';

  @override
  String get lang_ru_RU => 'ロシア語';

  @override
  String get lang_ar_XA => 'アラビア語';

  @override
  String get lang_hi_IN => 'ヒンディー語';

  @override
  String get lang_tr_TR => 'トルコ語';

  @override
  String get lang_nl_NL => 'オランダ語';

  @override
  String get lang_pl_PL => 'ポーランド語';

  @override
  String get lang_sv_SE => 'スウェーデン語';

  @override
  String get lang_vi_VN => 'ベトナム語';

  @override
  String get lang_th_TH => 'タイ語';

  @override
  String get lang_id_ID => 'インドネシア語';

  @override
  String get lang_he_IL => 'ヘブライ語';

  @override
  String get lang_da_DK => 'デンマーク語';

  @override
  String get lang_el_GR => 'ギリシャ語';

  @override
  String get lang_fi_FI => 'フィンランド語';

  @override
  String get lang_nb_NO => 'ノルウェー語';
}
