# OpenWorker — 中文套件

*A fork of [andrewyng/openworker](https://github.com/andrewyng/openworker) adding **Traditional Chinese (繁體中文)** and **Simplified Chinese (简体中文)** localisation.*

OpenWorker is an open-source AI coworker that lives on your desktop and delivers finished work — not just chat: polished documents, Slack replies with numbers, amended calendars, triaged inboxes. It runs locally on your machine and is not tied to any single model.

---

## 🎯 這個套件提供什麼

此建構版內建 **三種語言**，隨時可切換：

- **English**
- **简体中文** (Simplified Chinese, `zh-Hans`)
- **繁體中文** (Traditional Chinese, `zh-Hant`)

切換方式：**設定 → 通用 → 語言**，三顆按鈕 `English` / `简体中文` / `繁體中文`，即時生效。

首次啟動時會偵測系統語言：繁體中文 macOS (台灣/港/澳) 預設繁體、簡體中文 macOS (大陸/新加坡) 預設簡體、其餘預設英文。

翻譯檔位於 `surfaces/gui/src/locales/` 的 `zhHans.ts`、`zhHant.ts`。Key 即英文原句；未翻譯回退英文，不留空白。專有名詞 — *OpenWorker*, *GitHub*, *Slack*, *HubSpot*, *MCP*, `@ocw`, `@ocw-agent`, *PAT*, *OAuth* — 於所有語言保留原文。

---

## 📥 快速下載 (最新 v0.1.10)

| 平台 | 檔案 | 大小 | 直連 |
|------|------|------|------|
| **macOS Apple Silicon** | `OpenWorker-macos-arm64.dmg` | 66 MB | [下載](https://github.com/PurryTam/openworker-chinese/releases/download/v0.1.10/OpenWorker-macos-arm64.dmg) |
| **Windows x64 (NSIS 安裝程式)** | `OpenWorker-windows-setup.exe` | 57 MB | [下載](https://github.com/PurryTam/openworker-chinese/releases/download/v0.1.10/OpenWorker-windows-setup.exe) |
| **Windows x64 (MSI)** | `OpenWorker-windows.msi` | 68 MB | [下載](https://github.com/PurryTam/openworker-chinese/releases/download/v0.1.10/OpenWorker-windows.msi) |
| **Linux x64 (AppImage)** | `OpenWorker-linux-x64.AppImage` | 155 MB | [下載](https://github.com/PurryTam/openworker-chinese/releases/download/v0.1.10/OpenWorker-linux-x64.AppImage) |
| **Linux x64 (deb)** | `OpenWorker-linux-x64.deb` | 91 MB | [下載](https://github.com/PurryTam/openworker-chinese/releases/download/v0.1.10/OpenWorker-linux-x64.deb) |

> 💡 所有檔案亦可在 [Releases 頁面](https://github.com/PurryTam/openworker-chinese/releases) 取得。  \
> 💡 自動更新：App 內建自動檢查更新，來源指向本 repo 的 `latest.json`。

---

## 🖥️ macOS 安裝步驟

1. 下載 `OpenWorker-macos-arm64.dmg`
2. 開啟磁碟映像，將 `OpenWorker.app` 拖入「應用程式」資料夾
3. **重要**：首次執行因無 Apple 開發者憑證（ad-hoc 簽名），請在終端機執行：
   ```bash
   xattr -cr /Applications/OpenWorker.app
   codesign --force --deep --sign - /Applications/OpenWorker.app
   ```
4. 啟動後：**設定 → 通用 → 語言** 選擇 `简体中文` 或 `繁體中文`

> 💡 原因：macOS 12+ Gatekeeper 會阻擋完全未簽名 App。ad-hoc 簽名允許用戶以終端機指令移除 quarantine 屬性後正常啟動。

---

## 🪟 Windows 安裝步驟

1. 下載 `OpenWorker-windows-setup.exe`（建議）或 `.msi`
2. 執行安裝程式，依嚮導操作；無需管理員權限（逐用戶安裝）
3. 若 SmartScreen 提示，選 **更多資訊 → 仍要執行**
4. 啟動後：**設定 → 通用 → 語言** 選擇 `简体中文` 或 `繁體中文`

---

## 🐧 Linux 安裝步驟

**AppImage（通用）：**
```bash
chmod +x OpenWorker-linux-x64.AppImage
./OpenWorker-linux-x64.AppImage
```

**Debian/Ubuntu (deb)：**
```bash
sudo apt install ./OpenWorker-linux-x64.deb
```

啟動後：**設定 → 通用 → 語言** 選擇 `简体中文` 或 `繁體中文`

---

## 🔨 從原始碼建構

桌面殼層為 Tauri (Rust) 包裝 React/TypeScript GUI；引擎為 Python sidecar。

```bash
# macOS / Linux
python3 -m venv .venv && .venv/bin/pip install -e '.[bedrock]' pyinstaller tzdata typer
cd surfaces/gui && npm ci
npm run tauri build -- --bundles app

# Windows (PowerShell)
python -m venv .venv; .venv\Scripts\pip install -e '.[bedrock]' pyinstaller tzdata typer
cd surfaces/gui; npm ci
npm run tauri build -- --bundles app
```

建構產物位於 `surfaces/gui/src-tauri/target/release/bundle/`。

---

## 🔍 專案發現性

- **上游 repo**: `andrewyng/openworker` (10.9k ⭐) — Forks 頁面可見本 repo
- **GitHub Topics**: `openworker`, `ai-coworker`, `chinese-localization`, `traditional-chinese`, `simplified-chinese`, `tauri`, `rust`, `python`, `desktop-app`, `macos`, `windows`, `linux`
- **搜尋關鍵字**: `openworker chinese`、`openworker 繁體中文`、`openworker 简体中文`、`AI coworker 中文版`
- **Issues / Discussions**: 已啟用，歡迎回報問題或貢獻翻譯

---

## 🙏 致謝

承蒙 Andrew Ng 及其團隊深思探究、無私開源。  
幸於 AI 助手領域窺見此提升工作率之利器。  
苦華文群眾愁外文苦澀不得此器要領，無從入手。  
私僅以學術交流之目的，攜 CodeBuddy 與 HY3 譯之。

---

## 📄 License

MIT — 見 [LICENSE](LICENSE)。  
商標 *OpenWorker* 及上游代碼版權歸原作者所有；本套件不更改原授權條款。