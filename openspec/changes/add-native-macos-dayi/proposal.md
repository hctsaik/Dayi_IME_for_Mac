## Why

既有 myDayi_IME 是 Windows 小狼毫設定與詞庫，缺少獨立 Mac 輸入法應用、原生組字介面及安裝交付流程。使用者要求可交給其他 AI 執行的 Mac 版開發規格，且已選擇獨立 App。

## What Changes

- 新建可註冊為 macOS 系統輸入來源的原生 App，內含引擎與大易資料。目標為個人完整日用：Mac M4、優先 VS Code。
- 用 InputMethodKit 處理組字、提交與候選互動，保留現有單字碼、詞組連打與本機學習。
- 預設 `windows-compatible` 鍵盤 profile，另提供 `mac-optional`；同步事件交易與候選 token 見 EVENT-CONTRACT。
- 新建可重現建置、獨立資料目錄（四類版本與備份還原）、安裝/更新/移除與真機驗收。
- 注音反查、繁簡切換、Windows live userdb 遷移、跨裝置同步、自動更新、Intel、App Store、自製引擎均不在第一版。

## Capabilities

### New Capabilities

- `native-input`: 系統輸入來源、組字生命週期、候選與快捷鍵。
- `dayi-engine`: 大易詞庫、連續輸入及引擎資源處理。
- `local-learning`: 本機學習、資料隔離、誤學習修正及清除。
- `mac-distribution`: 可重現建置、安裝、更新、移除和發行。
- `regression-evidence`: golden traces、可重現測試及真機驗收證據。

### Modified Capabilities

無；新專案，不改動 Windows 既有行為。

## Impact

新增 Mac Xcode 專案、librime bridge、資產整理、單元/整合測試、包裝流程與操作文件。主要風險是 InputMethodKit 事件生命週期、引擎 ABI/依賴、字典授權與真機驗證。第一版優先提供私人開發版；公開發行另有來源與簽章 gate。
