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
    maleVoice: "en-US-Standard-D",
    femaleVoice: "en-US-Standard-C",
  },
  // English (UK)
  "en-GB": {
    code: "en-GB",
    maleVoice: "en-GB-Standard-B",
    femaleVoice: "en-GB-Standard-A",
  },
  // Japanese
  "ja-JP": {
    code: "ja-JP",
    maleVoice: "ja-JP-Standard-C",
    femaleVoice: "ja-JP-Standard-B",
  },
  // Chinese (Simplified)
  "zh-CN": {
    code: "cmn-CN",
    maleVoice: "cmn-CN-Standard-B",
    femaleVoice: "cmn-CN-Standard-A",
  },
  // Chinese (Traditional)
  "zh-TW": {
    code: "cmn-TW",
    maleVoice: "cmn-TW-Standard-B",
    femaleVoice: "cmn-TW-Standard-A",
  },
  // Spanish (Spain)
  "es-ES": {
    code: "es-ES",
    maleVoice: "es-ES-Standard-B",
    femaleVoice: "es-ES-Standard-C",
  },
  // French (France)
  "fr-FR": {
    code: "fr-FR",
    maleVoice: "fr-FR-Standard-B",
    femaleVoice: "fr-FR-Standard-C",
  },
  // German
  "de-DE": {
    code: "de-DE",
    maleVoice: "de-DE-Standard-B",
    femaleVoice: "de-DE-Standard-C",
  },
  // Korean
  "ko-KR": {
    code: "ko-KR",
    maleVoice: "ko-KR-Standard-C",
    femaleVoice: "ko-KR-Standard-B",
  },
  // Italian
  "it-IT": {
    code: "it-IT",
    maleVoice: "it-IT-Standard-C",
    femaleVoice: "it-IT-Standard-B",
  },
  // Portuguese (Brazil)
  "pt-BR": {
    code: "pt-BR",
    maleVoice: "pt-BR-Standard-B",
    femaleVoice: "pt-BR-Standard-A",
  },
  // Russian
  "ru-RU": {
    code: "ru-RU",
    maleVoice: "ru-RU-Standard-B",
    femaleVoice: "ru-RU-Standard-A",
  },
  // Arabic (Gulf/Generic)
  "ar-XA": {
    code: "ar-XA",
    maleVoice: "ar-XA-Standard-B",
    femaleVoice: "ar-XA-Standard-A",
  },
  // Hindi
  "hi-IN": {
    code: "hi-IN",
    maleVoice: "hi-IN-Standard-B",
    femaleVoice: "hi-IN-Standard-A",
  },
  // Turkish
  "tr-TR": {
    code: "tr-TR",
    maleVoice: "tr-TR-Standard-B",
    femaleVoice: "tr-TR-Standard-A",
  },
  // Dutch
  "nl-NL": {
    code: "nl-NL",
    maleVoice: "nl-NL-Standard-B",
    femaleVoice: "nl-NL-Standard-A",
  },
  // Polish
  "pl-PL": {
    code: "pl-PL",
    maleVoice: "pl-PL-Standard-B",
    femaleVoice: "pl-PL-Standard-A",
  },
  // Swedish
  "sv-SE": {
    code: "sv-SE",
    maleVoice: "sv-SE-Standard-A",
    femaleVoice: "sv-SE-Standard-A",
  },
  // Vietnamese
  "vi-VN": {
    code: "vi-VN",
    maleVoice: "vi-VN-Standard-B",
    femaleVoice: "vi-VN-Standard-A",
  },
  // Thai
  "th-TH": {
    code: "th-TH",
    maleVoice: "th-TH-Standard-A",
    femaleVoice: "th-TH-Standard-A",
  },
  // Indonesian
  "id-ID": {
    code: "id-ID",
    maleVoice: "id-ID-Standard-B",
    femaleVoice: "id-ID-Standard-A",
  },
  // Hebrew
  "he-IL": {
    code: "he-IL",
    maleVoice: "he-IL-Standard-B",
    femaleVoice: "he-IL-Standard-A",
  },
  // Danish
  "da-DK": {
    code: "da-DK",
    maleVoice: "da-DK-Standard-C",
    femaleVoice: "da-DK-Standard-A",
  },
  // Greek
  "el-GR": {
    code: "el-GR",
    maleVoice: "el-GR-Standard-A",
    femaleVoice: "el-GR-Standard-A",
  },
  // Finnish
  "fi-FI": {
    code: "fi-FI",
    maleVoice: "fi-FI-Standard-A",
    femaleVoice: "fi-FI-Standard-A",
  },
  // Norwegian (Bokmål)
  "nb-NO": {
    code: "nb-NO",
    maleVoice: "nb-NO-Standard-B",
    femaleVoice: "nb-NO-Standard-A",
  },
};
