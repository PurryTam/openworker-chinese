// i18n core for OpenWorker (zh-Hant / en).
//
// Strategy: the translation *key* IS the English source string. The `en` bundle is
// therefore empty, so `t("Open at login")` returns "Open at login" for English users,
// and the `zh-Hant` bundle maps that same English string to its Traditional Chinese
// translation. Untranslated strings fall back to the English key — never blank.
//
// UI text is wrapped with react-i18next's `t(...)`. The active language is persisted to
// localStorage (mirrors the theme module) and exposed on <html data-lang> for CSS if needed.
import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import en from "./locales/en";
import zhHant from "./locales/zhHant";

export type Lang = "en" | "zh-Hant";

const KEY = "openwork-lang";
export const LANG_PREF_EVENT = "openwork:lang-pref";

export function getLang(): Lang {
  try {
    const v = localStorage.getItem(KEY);
    return v === "zh-Hant" ? "zh-Hant" : "en";
  } catch {
    return "en";
  }
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
  window.dispatchEvent(new CustomEvent(LANG_PREF_EVENT));
}

if (!i18n.isInitialized) {
  i18n.use(initReactI18next).init({
    resources: {
      en: { translation: en },
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
