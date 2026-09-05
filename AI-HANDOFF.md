# 給接手 AI 的工作指令

你是 myDayi Mac 的實作負責人。使用者明確要獨立 macOS 系統輸入法 App，不是鼠鬚管設定包，也不是只能在自己視窗內輸入的文字編輯器。

先閱讀 README、AGENTS、SCOPE、SOURCE-AUDIT、OpenSpec proposal/design/specs/tasks、KEYBOARD-CONTRACT、EVENT-CONTRACT、GOLDEN-TRACES、DATA-LIFECYCLE 及 ACCEPTANCE。從第一個未勾選任務開始（目前是 0.1 的 Mac 工具鏈偵測，然後 1.1），完成程式、相應測試及證據後才能勾選。不要直接開始重寫大易引擎；預設採用 librime 保留現有組句與詞庫行為。

## 已凍結

- 個人日用、Mac M4、VS Code 優先。
- 預設 Windows 鍵盤 profile，Mac 為可選。
- 不做注音反查、不做繁簡切換；Windows live userdb 遷移 deferred。
- 第 0.2–0.6 節規格文件已寫入 docs/。

## 起步

1. 依 docs/MAC-ACCESS.md 打通 SSH，偵測 macOS/Xcode/CPU，勾選 0.1。
2. 核對 reference/MANIFEST.json；reference 只讀，將需要的資產整理到新 Resources。
3. 先做 InputMethodKit + 假引擎的端到端原型：註冊成系統輸入來源、在 TextEdit 接收按鍵、顯示組字及提交。
4. 再整合固定版本 librime 與一個最小測試詞典；通過後才導入完整字詞庫。
5. 依任務完成相容性、學習、發行和說明文件。沒有真機時可以做可攜測試，但所有原生 gate 留待驗證。

## 需要判斷的地方

- 正式名稱、Bundle ID、簽章身分可先用開發 placeholder；禁止把他人的 ID 當作產品 ID。
- 依 docs/KEYBOARD-CONTRACT.md 實作，與 Windows 不同的預設已明列。
- 不把 Windows 文檔的 85.871% 當作本版本實測結果。
- Lua 規則在快照 schema 未啟用，第一版不默默啟用。
- 公開發行前核對每份字典及依賴授權。缺少 sinica_words.json 不阻止私人開發使用現有產物，不能假造重建成功。
- 若更換 librime 或改為自製引擎，先更新設計與相容性契約並取得使用者對範圍變更的確認。

每次交接留下：完成任務編號、修改檔案、實際執行命令/結果、未通過項與下一步。不要把需要 Mac 或簽章憑證的未驗證工作勾掉。
