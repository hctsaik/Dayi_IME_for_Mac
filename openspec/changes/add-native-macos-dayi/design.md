## Context

2026-09-05 決策：個人完整日用版、Mac M4、VS Code 優先、Windows 操作預設及可選 Mac profile。使用者確認第一版不做注音反查、不做繁簡切換。Windows live userdb 遷移標為 deferred。範圍見 docs/SCOPE.md。

現有輸入邏輯依賴 Rime script_translator + fluency_editor；字詞排序由產物字典控制。直接自行重寫引擎會同時改變斷詞、選字與學習行為，增加移植的不確定性。
使用者確定要獨立 App；因此共享 librime 核心，但自行實作 Mac 前端與產品安裝流程。官方技術來源見 docs/SOURCES.md。

## Goals / Non-Goals

目標：系統任意支援輸入法的文字欄位可用、離線兩碼連打、候選/學習、可安裝開發版、可重現驗收。
不包含：鼠鬚管依賴、iOS、雲端 AI、自動更新、注音反查、繁簡切換、Windows live userdb 遷移、強制完整重建語料權重。

## Decisions

### 原生前端與 bridge

- Swift + AppKit/InputMethodKit；必要的 Objective-C runtime 入口與 class 名稱須由原型確認。
- App 主程式建立 IMKServer，Info.plist 提供一致的連線、controller class、輸入來源識別資訊。具體 key 與註冊流程須由目前 SDK/官方介面及真機驗證，不能只靠歷史範例。
- IMKInputController 管理 client 的 marked text/insertText；不以全域鍵盤監聽或輔助使用權限代替系統 IME。
- 候選 UI 優先評估 IMKCandidates。若無法滿足八候選、滑鼠選取及螢幕邊界需求，改用非搶焦點 AppKit panel；選擇及理由記入 ADR。
- 小型 C/Objective-C++ bridge 包装 rime_api.h，Swift 不自行猜 ABI struct。固定 librime commit/tag 及依賴 hash；每個支援架構獨立建置。
- 不複製 Squirrel 前端程式。若後續需要複用其他專案代码，先記錄來源與對應授權義務。

### 執行與資料模型

App process 一次初始化 engine runtime；每個 controller 有獨立 session。所有 engine 呼叫在同一序列執行環境完成，避免 maintenance 與輸入同時操作。UI 回到 main thread。
鍵事件交易、狀態機與 CandidateToken 見 docs/EVENT-CONTRACT.md。commit 僅透過一個出口送出一次。先核對 UTF-8 byte offset 與 Cocoa UTF-16 NSRange。

Bundle Resources 是唯讀 schema/詞庫來源。可寫資料與四類版本見 docs/DATA-LIFECYCLE.md。不使用 ~/Library/Rime。

### 資產策略

沿用 dayi2 的有效碼與權重，Mac schema ID 暫定 mydayi_mac；dict name 可以維持 dayi2。用獨立 Mac schema 刪除 Phonetic_tw、reverse lookup、simplifier 與 Windows 專用以外的全域綁定；Tab/Shift 行為由 app profile 實作，不部署舊 default.custom.yaml。
最小輸入資料為 dayi2.dict.yaml、common_words_import.dict.yaml 及新的 Mac schema；engine shared resources 必須對所有 import_preset 引用作 dependency closure。
繁體唯一；不包裝 OpenCC。Lua 不預設載入。
缺少 sinica 原始語料時使用 manifest 鎖定的現成字典。

### 輸入行為

docs/KEYBOARD-CONTRACT.md 為已凍結的兩套契約。
原生 event callback 必須在回傳前決定 consumed。
離開 client、host 要求提交、Escape、選取既有文字後取消屬不同事件。
正常 runtime 不需要網路，不收集原文輸入日誌。明確使用者選取/提交才交由引擎正常學習。

### 建議程式布局

```text
MyDayiMac.xcodeproj
Sources/InputMethod/   # IMK server/controller、event mapper、候選 UI
Sources/EngineBridge/  # header + Objective-C++ implementation
Sources/Settings/      # profile、學習控制、關於、備份還原
Resources/Rime/        # 產物及 manifest
Tests/Unit/
Tests/Engine/
Tests/Fixtures/
scripts/               # build、dependency、package
docs/evidence/
```

未建立上述程式檔，接手 AI 應在交接包根目錄開始建置；reference 保持只讀。

## Risks / Trade-offs

- librime 的重用保留行為，但需要包裝本機依賴、ABI 及 runtime resources；最小原型先驗證依賴載入。
- IMKCandidates 可能有客製限制；由真機原型决定 UI 實作。
- v5 同時是「我」與「程」；不能以單字首選取代 script_translator。
- 原文章 KPI 只供參考；golden frontend/lexicon 全過且經審閱才凍 Mac baseline。
- 正式公開交付依賴授權核對和開發者憑證；缺憑證仍能繼續本機開發。
- 原生運作必須 Mac 驗收。目前 Windows 可 ping Mac Mini，SSH 尚待放置公鑰。

## Migration Plan

1. 假引擎 IMK prototype；2. 最小 librime session；3. 導入凍結詞庫並驗證相容性；
4. 完成候選/生命週期/學習；5. 私人安裝版；6. 公開發行仍為條件式。
每階段產物可回退到前一版本。

## Open Questions

正式產品名稱/Bundle ID、Mac 上偵測到的實際 macOS/Xcode 版本、公開發行是否需要。開發以 myDayi Mac、arm64 推進。SSH 公鑰放置後立刻記錄工具鏈。
