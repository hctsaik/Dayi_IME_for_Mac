# 多 agent 複審：從能開工到完整日用

日期：2026-09-05。三個獨立唯讀 reviewer 分別審查原生架構、引擎/詞庫/測試、產品/安裝發行；主 agent 核對來源並整合。

結論：原交接包足以啟動 prototype，但不足以保證另一個 AI 不猜需求就能完成日用版本。OpenSpec 格式通過，不等於產品需求完整或 Mac 行為已正確。

## 使用者已確認

| 項目 | 決策 |
|---|---|
| 產品 | 獨立 macOS 系統輸入法 App |
| 交付範圍 | 先完整做好自己使用的版本 |
| 硬體 | Mac M4 |
| 優先應用 | VS Code |
| 操作 | 預設沿用目前 Windows 大易習慣，提供 Mac 選項 |
| macOS 版本 | 尚未提供，可由 Mac 上的 AI 偵測 |
| 真機開發/測試可用性 | 尚未確認 |
| 反查/繁簡/Windows 個人詞庫遷移 | 尚未確認是否首版必需 |

「個人日用完成」與「公开發行完成」分開。此輪不以購買憑證或完成公證阻擋本機開發；但仍需實際驗證個人 Mac 安裝可用，不能以編譯成功代替。

## P0：實作前必須補齊

### 1. 兩套操作 profile 與組字狀態機

原稿自行採用 Tab 導航、Shift 不切英文、中英僅選單切換，與使用者現已確認的 Windows 預設不一致。KEYBOARD-CONTRACT 已標為 Mac profile 草案，不能直接照表當預設。

需要 Windows-compatible / Mac 兩套明確契約及設定持久化。Windows 快照明確含 Tab 切中英、數字作碼、八候選；其他事件不能憑 schema 註解猜測，須把 default preset/recognizer 的影響一起凍結。補 Shift+Enter、Shift+Space、Delete、Home/End、Cmd 快捷鍵、Option 字元、flagsChanged、key repeat、候選不足時選取、數字鍵盤。

Escape、Tab、切換欄位、切換 App、host 要求提交、選取既有文字後取消不能共用「全部清除」；需逐事件定義是否提交、保留、取消以及 replacement range。尤其不可讓取消還原原文的 API 意外把碼串送出。工程負責狀態機，使用者只需確認打字體驗。

### 2. 同步鍵事件交易與候選競態

原稿有 engine 序列執行與 UI 回主執行緒，但欠缺原生 callback 的同步 consumed 回傳契約。必须先判定事件歸屬，不能非同步算完後才決定原鍵是否交 host。同步處理、commit/context 快照、C 物件釋放、UI 套用順序須固定；maintenance 不能卡住輸入事件。

候選點擊需帶 client/session/generation/page token，避免更新頁面後舊 index 選到新內容。覆蓋同一 VS Code 的編輯器、終端機、搜尋及重新命名輸入框；不只測不同 App。

### 3. 獨立的正確性驗收

原 Windows article runner 按詞庫最長匹配切成詞/單字，每個 case 清 composition，跳過非漢字，並在 commit 空白時用第一候選計分。它是有限的字詞候選基準，不能代表整段連打或實際上屏成功率。

主 agent 與引擎 reviewer 都確認 dayi2.dict.yaml 有 18,637 筆資料，其中 86 筆一碼、18,551 筆兩碼。不得把「每兩碼切分」註解寫成硬規則。

新增至少 30 條人工可審閱的 golden keystroke traces：輸入鍵 → preedit/分段/候選 → 實際 commit/剩餘輸入。包含一二碼混合、奇數碼長、未知詞、姓名、整句、中英數標點、修改、分段選字、錯碼/尾碼和取消。關鍵案例全部正確才准凍結初版 baseline；候選可用與成功上屏分開計分。

相同 Mac schema 上的 headless/bridge parity 能測 bridge，不能測兩者共同使用的 schema 是否符合預期。歷史 85.871% 仍只作參考；不能讓任意低品質初版變成永久「達標基準」。

## P1：完整日用應補

| 缺口 | 建議補強 | 工程可直接處理的部分 |
|---|---|---|
| 誤學習只能全清 | 暫停學習、刪除單詞/撤除學習偏好、备份與還原 | 先定可觀察的引擎語意與合成詞測試，不猜刪除等於永久封鎖 |
| 升級只寫可恢復 | 分別記錄 app/resources/settings/userdb 版本和交易邊界 | 中斷、磁碟不足、migration 失敗、降版及還原驗收 |
| 還原與清除範圍模糊 | 備份數量、相容版本、重設是否保留備份要明列 | 清除只操作自身資料，停用相關 session 後進行 |
| 原生產品流程不全 | 首次安裝/加入輸入來源、設定、模式指示、錯誤、版本與移除 | 以使用者 Mac 上成功走完整流程為交付條件 |
| Mac 日用測試不足 | VS Code 編輯器/終端機/搜尋框、快速切換、睡眠喚醒、重登入 | 保留 TextEdit/browser 作對照，驗證原生 candidate 不搶焦點 |
| 依賴與資源未凍結 | 固定引擎/所有依賴、完整 preset 引用、runtime asset manifest | 缺 Sinica source 時採固定產物，明列不可完整重建部分 |
| 資料清單與日誌 | 列明個人使用快照及未核對散布項 | 正常引擎日誌及診斷包也要排除輸入原文/userdb |

公開發行、Intel/其他 OS 全範圍、自動更新不應擴大本輪個人日用目標。若將來需要分送，再把字典散布權利、正式身份及公證提升為交付 gate。

## 仍不清楚、值得使用者回答

1. 首版是否需要注音反查、繁簡切換、Windows 自訂/已學習詞搬移；已有快照中的自訂靜態詞和 live userdb 要分開，不可一概刪掉。
2. 接手 AI 是否可在 Mac M4 上編譯/測試；macOS 版本可偵測，不必使用者查技術細節。

鍵盤 layout、焦點離開時的提交習慣可由早期互動樣本確認；Bundle ID、bridge 語言、資料夾交易等工程細節由實作者負責，不需要逐項打擾使用者。

## 接手順序

先完成 tasks 第 0 節，將本報告的決策與缺口落入正式 requirements/scenarios。接著依原任務完成 IMK 原型 → 固定引擎/資產 → profiles 與 golden traces → 學習維護 → 真機日用驗收。不要先做完 UI 才發現按鍵或詞庫品質與日常習慣不同。

本輪已修正 README/AI-HANDOFF/設計/按鍵文件的相反預設，追加驗收準入要求與 6 項規格閉合任務；尚未宣稱全部缺口已關閉，所有實作任務仍未勾選。

## 技術依據

- [Apple IMKServerInput](https://developer.apple.com/documentation/inputmethodkit/imkserverinput)：原生輸入事件介面及 consumed 回傳。
- [Apple cancelComposition](https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller/cancelcomposition%28%29?language=objc)：取消與原文字串還原語意，不能假設等於無條件丟棄。
- [Apple IMKInputController](https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller)：client/controller 生命週期與候選介面。
- 本地來源：reference/windows-baseline/test/article_regression.py 的 build_cases、automatic_result 與空 commit fallback；reference/windows-baseline/dayi2.dict.yaml 及 dayi2.schema.yaml。
