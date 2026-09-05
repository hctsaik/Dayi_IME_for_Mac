# 驗收與證據矩陣

所有原生項目目前未執行。測試名稱是接手者需建立的測試契約；證據存 docs/evidence/，記錄日期、commit、OS/架構、工具链、資產 hash、命令、結果。不得只附「測試通過」文字。

契約已凍結：docs/KEYBOARD-CONTRACT.md、EVENT-CONTRACT.md、GOLDEN-TRACES.md（G01–G40）。frontend/lexicon traces 全過才能凍 ranking baseline。VS Code 編輯器、內建終端機、搜尋/重新命名輸入框必測。Windows 預設與 Mac 可選 profile 分開驗收。不得以第一候選替代空 commit。A/B parity 只驗 bridge，不足以證明共同 schema 正確。歷史 Windows KPI 只供比較。

| Gate | 對應能力 | 驗證內容 | 通過條件 |
|---|---|---|---|
| A1 IMKSmoke | native-input | 安裝、輸入來源、TextEdit 組字提交 | 無鼠鬚管可用，字只提交一次 |
| A2 KeyboardContract | native-input | KEYBOARD-CONTRACT 每列及模式 | 按鍵矩陣全過，數字碼不被選字攔截 |
| A3 SessionLifecycle | native-input | 切 client、deactivate、快速切換、emoji/非 BMP offset | 無跨 app 誤提交、範圍錯誤或幽靈候選 |
| A4 CandidateUI | native-input | 八候選、翻頁、滑鼠、螢幕邊緣、雙螢幕縮放 | 不抢焦點、不超出可見區、選到正確項 |
| A5 DictionaryParity | dayi-engine | 完整 mapping/weights/import closure；v5e5 程式案例 | mapping/weights 無未說明差異，連打可形成程式候選 |
| A6 EngineFailures | dayi-engine | 資源缺件、初始化/編譯失敗、重啟 | 清楚失敗、host 可繼續輸入、可恢復有效版本 |
| A7 LearningIsolation | local-learning | 選取學習、重啟、兩 session、重設 | 指定測試詞學習持續存在、沒有跨 client composition |
| A8 Privacy | local-learning | 斷網運作、日誌檢查 | 核心全離線，無輸入原文紀錄 |
| A9 InstallLifecycle | mac-distribution | 乾淨帳號安裝、升級失敗、移除/保留資料 | 不改其他 IME，自身資料依契約保留 |
| A10 EngineRegression | regression-evidence | 下述凍結 corpus、連打、static userdb | 產出可比結果與 manifest |
| A11 HostMatrix | native-input | TextEdit、Safari textarea/contenteditable、Chrome、VS Code、Terminal | 全部完成組字/候選/提交/切換；記錄版本 |
| A12 ReleaseAudit | mac-distribution | dependency/license、簽章、公證、乾淨機 | 私人開發版與公開版 gate 分開報告 |

密碼/secure input 欄位遵守系統限制，不強制接管或學習。不支援的 host 必須列為已知限制，不能據此宣稱 A11 全過。

## 引擎基準

1. 快照的文章 runner 原先使用 live Windows Rime、Windows DLL 與共用 data；不能直接在 Mac 執行。
2. 建立 fixture generator：固定 Wikipedia revision 93857310、zh-tw、解析版本、文章 hash、case 列表 hash、字典 hash。測試可在取得 fixture 後離線重跑，保留 attribution；網路失敗屬 fixture 準備失敗，不能算 pass。
3. Engine A：固定相同版本 librime 與凍結 Mac schema/assets 的無 UI runner；Engine B：App bridge runner。相同 fixtures、全新隔離 userdb、禁用學習（或每 case 重建狀態）、連續碼輸入，共用 commit 契約。
4. A/B 預期文字、候選序列/分段、commit 結果逐 case 完全一致；差異逐項分析，不能只以總分掩蓋 bridge 錯誤。
5. 再用 Windows 快照 schema（只處理缺件，記錄 patch）重建可比較參考；報告因 schema/版本改動而產生差異。不得假裝已有 Windows 成對實測。
6. 記錄 top1、phrase_top1、character_top1、case_count、unsupported_hanzi、mode、是否含 userdb。首次有效 Mac 全量結果建立新 baseline。
7. 後續變更對凍結 baseline 三項 KPI 均不得下降，除非有使用者接受的理由與新規格。歷史 85.871% / 96.338% / 76.934% 只供比較，不是已達標或未校準的硬門檻。
8. 另外測試會學習的互動流程；不可用已學習 fixture 作 static 成績。spaced-code 僅診斷，不能替代 continuous KPI。

## 穩定性與效能

在指定 arm64 真機、固定字典與暖機條件下，量測 1,000 次按鍵到候選可更新的延遲；目標 p95 ≤ 50ms，報告硬體與原始分佈。首次詞庫编譯另外報告，不混入互動延遲。
連續 10,000 次鍵事件以及 100 次 client 切換不得崩潰、重複提交或留下 session；記錄記憶體趨勢，單獨檢查 C 物件及 session 釋放。
