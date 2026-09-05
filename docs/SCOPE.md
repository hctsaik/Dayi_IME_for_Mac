# 第一版範圍凍結

日期：2026-09-05。來源：使用者對接手 AI 的確認，以及既有多 agent 複審決策。

## 產品

獨立 macOS 系統輸入法 App（myDayi Mac）。不依賴鼠鬚管。目標為個人完整日用，硬體為使用者 Mac M4，優先應用為 VS Code。

## 操作

- 預設 profile：`windows-compatible`（沿用目前 Windows 大易習慣）。
- 可選 profile：`mac-optional`。
- 兩套契約見 [KEYBOARD-CONTRACT.md](KEYBOARD-CONTRACT.md)；事件語意見 [EVENT-CONTRACT.md](EVENT-CONTRACT.md)。

## 首版包含

- 繁體大易兩碼連打、八候選、本機學習。
- librime 固定版本 + 凍結詞庫。
- 私人開發安裝版（本機可用）。
- VS Code 編輯器／終端機／搜尋／重新命名欄位驗收。

## 首版不做（deferred，不得假勾完成）

| 項目 | 狀態 | 說明 |
|---|---|---|
| 注音反查 | 使用者確認不做 | 不部署 Phonetic_tw，不處理 `~` 反查前綴 |
| 繁簡切換 | 使用者確認不做 | 不掛 simplifier / OpenCC，不提供 Ctrl+Shift+4 |
| Windows 個人詞庫／userdb 遷移 | 未要求，標 deferred | 快照內靜態自訂詞可作資產；live userdb 不讀、不搬 |
| Intel、App Store、自動更新、自製引擎 | deferred | 不阻擋私人日用 |
| 公開簽章／公證 | 有憑證再做 | 不阻擋本機開發版 |

## 環境

- 交付環境：使用者 Mac M4 的實際 macOS（開工時偵測，不預先承諾 macOS 13+ 全範圍）。
- 目前接手環境：Windows。`macmini4`（192.168.28.83）可 ping，SSH 金鑰已產生，尚待把公鑰放到 Mac。步驟見 [MAC-ACCESS.md](MAC-ACCESS.md)。
- 未取得 Mac 工具鏈紀錄前，不得勾選需要真機的任務。
