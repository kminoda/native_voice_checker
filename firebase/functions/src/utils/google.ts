import {TextToSpeechClient} from "@google-cloud/text-to-speech";
import {GOOGLE_LANGUAGE_MAP} from "./constants";

// Accept short language keys and map to our canonical BCP-47 codes
const LANGUAGE_NORMALIZATION: Record<string, string> = {
  en: "en-US",
  "en-US": "en-US",
  "en-GB": "en-GB",
  ja: "ja-JP",
  "ja-JP": "ja-JP",
  es: "es-ES",
  "es-ES": "es-ES",
  fr: "fr-FR",
  "fr-FR": "fr-FR",
  de: "de-DE",
  "de-DE": "de-DE",
  zh: "zh-CN",
  "zh-CN": "zh-CN",
  "zh-TW": "zh-TW",
  ko: "ko-KR",
  "ko-KR": "ko-KR",
  it: "it-IT",
  "it-IT": "it-IT",
  pt: "pt-BR",
  "pt-BR": "pt-BR",
  ru: "ru-RU",
  "ru-RU": "ru-RU",
  ar: "ar-XA",
  "ar-XA": "ar-XA",
  hi: "hi-IN",
  "hi-IN": "hi-IN",
  tr: "tr-TR",
  "tr-TR": "tr-TR",
  nl: "nl-NL",
  "nl-NL": "nl-NL",
  pl: "pl-PL",
  "pl-PL": "pl-PL",
  sv: "sv-SE",
  "sv-SE": "sv-SE",
  vi: "vi-VN",
  "vi-VN": "vi-VN",
  th: "th-TH",
  "th-TH": "th-TH",
  id: "id-ID",
  "id-ID": "id-ID",
  he: "he-IL",
  "he-IL": "he-IL",
  da: "da-DK",
  "da-DK": "da-DK",
  el: "el-GR",
  "el-GR": "el-GR",
  fi: "fi-FI",
  "fi-FI": "fi-FI",
  no: "nb-NO",
  "nb-NO": "nb-NO",
};

/**
 * 言語コードをGoogle Cloud TTS用のフォーマットに変換（後方互換性のため）
 * @param {string} lang 言語コード（例: en-US, ja-JP）
 * @return {{languageCode: string, name: string}} Google TTSのvoice設定
 */
export function getGoogleVoiceConfig(lang: string): {
  languageCode: string, name: string
} {
  const normalized = LANGUAGE_NORMALIZATION[lang] ?? lang;
  const voiceConfig = GOOGLE_LANGUAGE_MAP[normalized];
  if (!voiceConfig) {
    throw new Error(`Unsupported language: ${lang}`);
  }
  return {
    languageCode: voiceConfig.code,
    name: voiceConfig.maleVoice, // デフォルトは男性音声
  };
}

/**
 * 言語コードと性別をGoogle Cloud TTS用のフォーマットに変換
 * @param {string} lang 言語コード（例: en-US, ja-JP）
 * @param {("male"|"female")} gender 性別
 * @return {{languageCode: string, name: string}} Google TTSのvoice設定
 */
export function getGoogleVoiceConfigWithGender(
  lang: string,
  gender: "male" | "female" = "male",
): {
  languageCode: string, name: string
} {
  const normalized = LANGUAGE_NORMALIZATION[lang] ?? lang;
  const voiceConfig = GOOGLE_LANGUAGE_MAP[normalized];
  if (!voiceConfig) {
    throw new Error(`Unsupported language: ${lang}`);
  }
  return {
    languageCode: voiceConfig.code,
    name: gender === "female" ? voiceConfig.femaleVoice : voiceConfig.maleVoice,
  };
}

/**
 * Google Cloud Text-to-Speech APIを呼び出す（後方互換性のため）
 * @param {string} text 合成対象テキスト
 * @param {string} lang 言語コード
 * @param {string} apiKey APIキー（省略時はSecret）
 * @return {Promise<string>} base64エンコードされた音声（MP3）
 */
export async function callGoogleTTS(
  text: string,
  lang: string,
): Promise<string> {
  return callGoogleTTSWithGender(text, lang, "male");
}

/**
 * Google Cloud Text-to-Speech APIを性別指定で呼び出す
 * @param {string} text 合成対象テキスト
 * @param {string} lang 言語コード
 * @param {("male"|"female")} gender 性別
 * @param {string} apiKey APIキー（省略時はSecret）
 * @return {Promise<string>} base64エンコードされた音声（MP3）
 */
export async function callGoogleTTSWithGender(
  text: string,
  lang: string,
  gender: "male" | "female" = "male",
): Promise<string> {
  const startTime = Date.now();
  console.log(
    `Google TTS synthesize start: lang=${lang}, gender=${gender}, len=${text.length}`,
  );

  const client = new TextToSpeechClient();
  const voiceConfig = getGoogleVoiceConfigWithGender(lang, gender);

  const [response] = await client.synthesizeSpeech({
    input: {text},
    voice: {
      languageCode: voiceConfig.languageCode,
      name: voiceConfig.name,
    },
    audioConfig: {audioEncoding: "MP3"},
  });

  const executionTime = Date.now() - startTime;
  console.log(`Google TTS synthesize completed in ${executionTime}ms`);

  const audio = response.audioContent;
  if (!audio) {
    throw new Error("No audioContent returned from Google TTS");
  }
  // Convert to base64 string regardless of type (string | Uint8Array)
  if (typeof audio === "string") {
    return audio;
  }
  return Buffer.from(audio).toString("base64");
}
