// English bundle. Per the key=English strategy (see ../i18n.ts), the English UI text IS the
// translation key, so this bundle is intentionally almost empty: t("Open at login") resolves to
// the key itself for English users. The zh-Hant and zh-Hans bundles carry real mappings. The
// only entry here overrides an English string that was changed to introduce a distinct Chinese
// key (so English keeps its original wording).
const en: Record<string, string> = {
  "Your automations": "Automations",
};

export default en;
