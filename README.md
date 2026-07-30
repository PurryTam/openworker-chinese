# OpenWorker — Chinese Localisation

*A fork of [andrewyng/openworker](https://github.com/andrewyng/openworker) that addeth the tongues of the Middle Kingdom — Simplified (简体中文) and Traditional (繁體中文) — unto the original English tongue.*

OpenWorker is an open-source AI coworker that dwelleth upon thy desktop and delivereth finished work, not mere converse: a polished document, a Slack reply with the numbers, an amended calendar, a triaged inbox. It runneth upon thine own machine and bindeth itself to no single model.

## What this edition addeth

This build speaketh in **three languages**, selectable at will:

- **English**
- **简体中文** (Simplified Chinese, `zh-Hans`)
- **繁體中文** (Traditional Chinese, `zh-Hant`)

The language is chosen thus: open **Settings → 通用 (General) → 語言 (Language)**, where three buttons are set before thee — `English` / `简体中文` / `繁體中文` — and the change taketh effect forthwith.

Upon first launch the app discerneth thy system tongue: a Traditional-Chinese macOS (Taiwan, Hong Kong, Macau) defaulteth to 繁體中文; a Simplified one (Mainland, Singapore) to 简体中文; all else to English.

The translations abide in `surfaces/gui/src/locales/` as `zhHans.ts` and `zhHant.ts`. The key *is* the English sentence; aught untranslated falleth back to the English original, never to blank. Brand and proper nouns — *OpenWorker*, *GitHub*, *Slack*, *HubSpot*, *MCP*, `@ocw`, `@ocw-agent`, *PAT*, *OAuth* — are left verbatim in every tongue.

## Installation upon macOS

1. Download `OpenWorker_*.dmg` from the [Releases](../../releases) page.
2. Open the disk image and drag *OpenWorker* into the Applications folder.
3. At first launching, if Gatekeeper protest an unsigned build, right-click the app and choose **Open**.
4. Launch it, then open **Settings → 通用 → 語言** and choose 简体中文 or 繁體中文.

## Installation upon Windows

1. Download `OpenWorker_*_x64-setup.exe` from the [Releases](../../releases) page.
2. Run the installer and follow the wizard; no administrator right is required (it installteth per user).
3. If SmartScreen raise a warning, choose **More info → Run anyway**.
4. Launch it, open **Settings → 通用 → 語言**, and choose thy tongue.

## Building from source

The desktop shell is Tauri (Rust) wrapped about a React/TypeScript GUI; the engine is a Python sidecar.

```bash
python3 -m venv .venv && .venv/bin/pip install -e '.[bedrock]' pyinstaller tzdata typer
cd surfaces/gui && npm ci
npm run tauri build -- --bundles app
```

The compiled app awaiteth in `surfaces/gui/src-tauri/target/release/bundle/`.

## Acknowledgement

> To Andrew Ng, and to the company he leadeth, we owe the debt —
> Whose studious mind and open hand this work in freedom set.
> Right glad were we, amid the aids that artificial wit doth lend.
> To mark this instrument that raiseth labour to its end.
> Yet sorrow'd we for China's folk, by nonlocal speech confined.
> Who, tasting not its inward worth, no entrance could they find.
> For love of learning only — with CodeBuddy and HY3 —
> Have we turned it to their own tongue, that they the freer be.

> 承蒙Andrew君及其團隊，深思探究，無私開源。
> 幸於人工智能助手層面窺見此提升工作率之利器。
> 苦華文群眾愁外文苦澀不得此器要領，無從入手。
> 私僅以學術交流之目的，攜CodeBuddy與HY3譯之。

## License

MIT — see [LICENSE](LICENSE). The mark *OpenWorker* and the upstream code remain the property of their several authors; this edition altereth naught of the grant.
