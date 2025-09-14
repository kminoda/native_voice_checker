import {defineSecret} from "firebase-functions/params";

// Secret param for Google TTS API Key
export const googleTtsApiKeyParam = defineSecret("GOOGLE_TTS_API_KEY");

// Minimal language → Google TTS voice mapping
// Expand as needed.
export const GOOGLE_LANGUAGE_MAP: Record<string, {
  code: string;
  maleVoice: string;
  femaleVoice: string;
}> = {
  // English (US)
  "en-US": {
    code: "en-US",
    maleVoice: "en-US-Neural2-A",
    femaleVoice: "en-US-Neural2-F",
  },
  // English (UK)
  "en-GB": {
    code: "en-GB",
    maleVoice: "en-GB-Neural2-B",
    femaleVoice: "en-GB-Neural2-A",
  },
  // Japanese
  "ja-JP": {
    code: "ja-JP",
    maleVoice: "ja-JP-Neural2-B",
    femaleVoice: "ja-JP-Neural2-A",
  },
  // Chinese (Simplified)
  "zh-CN": {
    code: "zh-CN",
    maleVoice: "zh-CN-Wavenet-B",
    femaleVoice: "zh-CN-Wavenet-A",
  },
  // Chinese (Traditional)
  "zh-TW": {
    code: "zh-TW",
    maleVoice: "zh-TW-Wavenet-B",
    femaleVoice: "zh-TW-Wavenet-A",
  },
  // Spanish (Spain)
  "es-ES": {
    code: "es-ES",
    maleVoice: "es-ES-Polyglot-1",
    femaleVoice: "es-ES-Neural2-A",
  },
  // French (France)
  "fr-FR": {
    code: "fr-FR",
    maleVoice: "fr-FR-Neural2-B",
    femaleVoice: "fr-FR-Neural2-A",
  },
  // German
  "de-DE": {
    code: "de-DE",
    maleVoice: "de-DE-Neural2-B",
    femaleVoice: "de-DE-Neural2-A",
  },
  // Korean
  "ko-KR": {
    code: "ko-KR",
    maleVoice: "ko-KR-Neural2-B",
    femaleVoice: "ko-KR-Neural2-A",
  },
  // Italian
  "it-IT": {
    code: "it-IT",
    maleVoice: "it-IT-Neural2-B",
    femaleVoice: "it-IT-Neural2-A",
  },
  // Portuguese (Brazil)
  "pt-BR": {
    code: "pt-BR",
    maleVoice: "pt-BR-Neural2-B",
    femaleVoice: "pt-BR-Neural2-A",
  },
  // Russian
  "ru-RU": {
    code: "ru-RU",
    maleVoice: "ru-RU-Neural2-B",
    femaleVoice: "ru-RU-Neural2-A",
  },
  // Arabic (Gulf/Generic)
  "ar-XA": {
    code: "ar-XA",
    maleVoice: "ar-XA-Wavenet-B",
    femaleVoice: "ar-XA-Wavenet-A",
  },
  // Hindi
  "hi-IN": {
    code: "hi-IN",
    maleVoice: "hi-IN-Neural2-B",
    femaleVoice: "hi-IN-Neural2-A",
  },
  // Turkish
  "tr-TR": {
    code: "tr-TR",
    maleVoice: "tr-TR-Wavenet-B",
    femaleVoice: "tr-TR-Wavenet-A",
  },
  // Dutch
  "nl-NL": {
    code: "nl-NL",
    maleVoice: "nl-NL-Neural2-B",
    femaleVoice: "nl-NL-Neural2-A",
  },
  // Polish
  "pl-PL": {
    code: "pl-PL",
    maleVoice: "pl-PL-Neural2-B",
    femaleVoice: "pl-PL-Neural2-A",
  },
  // Swedish
  "sv-SE": {
    code: "sv-SE",
    maleVoice: "sv-SE-Neural2-B",
    femaleVoice: "sv-SE-Neural2-A",
  },
  // Vietnamese
  "vi-VN": {
    code: "vi-VN",
    maleVoice: "vi-VN-Neural2-B",
    femaleVoice: "vi-VN-Neural2-A",
  },
  // Thai
  "th-TH": {
    code: "th-TH",
    maleVoice: "th-TH-Neural2-B",
    femaleVoice: "th-TH-Neural2-A",
  },
  // Indonesian
  "id-ID": {
    code: "id-ID",
    maleVoice: "id-ID-Neural2-B",
    femaleVoice: "id-ID-Neural2-A",
  },
  // Hebrew
  "he-IL": {
    code: "he-IL",
    maleVoice: "he-IL-Wavenet-B",
    femaleVoice: "he-IL-Wavenet-A",
  },
  // Danish
  "da-DK": {
    code: "da-DK",
    maleVoice: "da-DK-Neural2-B",
    femaleVoice: "da-DK-Neural2-A",
  },
  // Greek
  "el-GR": {
    code: "el-GR",
    maleVoice: "el-GR-Neural2-B",
    femaleVoice: "el-GR-Neural2-A",
  },
  // Finnish
  "fi-FI": {
    code: "fi-FI",
    maleVoice: "fi-FI-Neural2-B",
    femaleVoice: "fi-FI-Neural2-A",
  },
  // Norwegian (Bokmål)
  "nb-NO": {
    code: "nb-NO",
    maleVoice: "nb-NO-Neural2-B",
    femaleVoice: "nb-NO-Neural2-A",
  },
};
