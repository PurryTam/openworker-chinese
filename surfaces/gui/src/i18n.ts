// i18n core for OpenWorker (en / zh-Hans / zh-Hant).
//
// Strategy: the translation *key* IS the English source string. The `en` bundle is
// therefore empty, so `t("Open at login")` returns "Open at login" for English users,
// and the `zh-Hans` / `zh-Hant` bundles map that same English string to its Simplified /
// Traditional Chinese translation. Untranslated strings fall back to the English key — never blank.
//
// UI text is wrapped with react-i18next's `t(...)`. The active language is persisted to
// localStorage (mirrors the theme module) and exposed on <html data-lang> for CSS if needed.
import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import { invoke } from "@tauri-apps/api/core";
import en from "./locales/en";
import zhHant from "./locales/zhHant";
import zhHans from "./locales/zhHans";

export type Lang = "en" | "zh-Hans" | "zh-Hant";

const KEY = "openwork-lang";
export const LANG_PREF_EVENT = "openwork:lang-pref";

export function getLang(): Lang {
  try {
    const v = localStorage.getItem(KEY);
    if (v === "zh-Hant" || v === "zh-Hans" || v === "en") return v;
  } catch {
    /* ignore */
  }
  // No explicit choice yet → follow the OS locale (set once on first launch).
  return detectSystemLang();
}

// Default to 繁體中文 when the OS is Traditional Chinese (zh-Hant / zh-TW / zh-HK / zh-MO),
// 简体中文 for Simplified Chinese (zh-Hans / zh-CN / zh-SG), and English otherwise. An
// explicit choice stored via setLangPref always wins.
function detectSystemLang(): Lang {
  if (typeof navigator === "undefined") return "en";
  const langs: string[] =
    navigator.languages && navigator.languages.length
      ? Array.from(navigator.languages)
      : navigator.language
        ? [navigator.language]
        : [];
  const isHant = langs.some((l) => {
    const s = l.toLowerCase();
    if (s.startsWith("zh-hant")) return true;
    return /^zh-(tw|hk|mo)$/.test(s);
  });
  if (isHant) return "zh-Hant";
  const isHans = langs.some((l) => {
    const s = l.toLowerCase();
    if (s.startsWith("zh-hans")) return true;
    return /^zh-(cn|sg)$/.test(s) || s === "zh" || s.startsWith("zh-");
  });
  return isHans ? "zh-Hans" : "en";
}

export function setLangPref(lang: Lang) {
  try {
    localStorage.setItem(KEY, lang);
  } catch {
    /* private mode etc. — still applies for this session */
  }
  document.documentElement.dataset.lang = lang;
  // Drive react-i18next so every component using `useTranslation()` re-renders with the
  // new language (t() reads from the live instance). The CustomEvent is the fallback for
  // any non-react listeners (mirrors the theme module's event broadcast).
  i18n.changeLanguage(lang).catch(() => {});
  syncTrayLocale(lang);
  window.dispatchEvent(new CustomEvent(LANG_PREF_EVENT));
}

// Keep the Rust/Tauri native shell (system-tray menu) in sync with the UI language.
// Only meaningful inside the desktop shell — a no-op (guarded) in plain browser dev.
export function syncTrayLocale(lang: Lang) {
  if (typeof window !== "undefined" && "__TAURI_INTERNALS__" in window) {
    invoke("set_ui_locale", { lang }).catch(() => {});
  }
}

if (!i18n.isInitialized) {
  i18n.use(initReactI18next).init({
    resources: {
      en: { translation: en },
      "zh-Hans": { translation: zhHans },
      "zh-Hant": { translation: zhHant },
    },
    lng: getLang(),
    fallbackLng: "en",
    interpolation: { escapeValue: false },
    returnNull: false,
  });
  document.documentElement.dataset.lang = getLang();
}

export default i18n;
