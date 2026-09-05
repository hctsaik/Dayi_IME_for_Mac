# 同步事件交易、組字狀態機、候選 token

本文件凍結 native-input 與 engine bridge 的執行契約。實作不得用非同步「算完再決定 consumed」的方式處理按鍵。

## 同步鍵事件交易

每個 `handleEvent`（或同等 IMK callback）是一筆交易，必須在函式回傳前完成：

1. 判定事件歸屬（本 IME / 交 host / 忽略）。
2. 若歸屬本 IME：在**同一序列執行環境**呼叫引擎（禁止與 maintenance 並行）。
3. 複製 commit text、composition、caret、候選列表到自有結構。
4. 釋放所有 C API 所有權物件。
5. 在主執行緒套用：`insertText` / `setMarkedText` / 候選 UI。每筆 engine commit 只經**一個**出口送出一次。
6. 回傳 consumed。回傳後不得再改寫該事件是否交給 host。

禁止：

- 先 `return true` 再背景算引擎。
- 先 `return false` 再補插入文字。
- maintenance（部署詞典、備份、重設）卡住這筆交易。maintenance 只能排隊，在沒有進行中的輸入交易時執行。
- 把過期 generation 的結果套用到新 client。

UTF-8 byte offset 必須轉成 Cocoa UTF-16 `NSRange`，含 emoji／非 BMP。禁止直接拿 byte offset 當 NSRange。

## 狀態

```text
Idle
Composing            有 marked text，未必有選單
ComposingWithMenu    有候選
Ascii                windows-compatible 的 ascii_mode
SecureInput          密碼欄，不進引擎
Suspended            client 已 deactivate，session 仍可能存在直到銷毀
```

合法轉換（摘要）：

| 從 | 事件 | 到 | 提交 | 取消 |
|---|---|---|---|---|
| Idle | 大易碼 | Composing / ComposingWithMenu | 否 | 否 |
| Composing* | Space/選字/Enter | Idle 或仍 Composing（剩餘碼） | 僅 engine commit | 否 |
| Composing* | Escape | Idle | 否 | 是 |
| Composing* | 空組字的 Backspace | Idle | 否 | 否 |
| 任一中文組字 | ClientDeactivate | Suspended | 否 | 是 |
| 任一中文組字 | InputSourceSwitch | Idle | 否 | 是 |
| 任一中文組字 | HostCommit | Idle | 是（當前可提交） | 否 |
| 任一中文組字 | HostCancel | Idle | 否 | 是，且不 insert 碼串 |
| 任一中文組字 | SelectionChanged | Idle | 否 | 是 |
| Idle/Composing | Tab（windows） | 依引擎 ascii_mode | 依引擎 | 否（前端不先 cancel） |
| Composing* | Tab（mac） | Idle | 否 | 是，然後 Tab 給 host |
| 任一 | SecureInput | SecureInput | 否 | 是（若有組字） |
| 任一 | ProfileSwitch | Idle | 否 | 是 |

`HostCancel` 對應 IMK `cancelComposition`。系統可能試圖還原 marked text；實作必須保證還原的是**原本被取代的文件文字**，不是碼串。若無法取得原文，清空 marked text 且不 insert。

## 物件與世代

| 欄位 | 用途 |
|---|---|
| `clientId` | 目前 IMK client |
| `sessionId` | librime session |
| `generation` | 每次 client 切換、cancel、reset 遞增 |
| `compositionId` | 一段連續組字 |
| `candidateEpoch` | 每次候選列表內容改變遞增 |
| `pageIndex` | 目前頁 |

UI 更新與滑鼠／鍵盤選字必須帶 token：

```text
CandidateToken = clientId + sessionId + generation + compositionId + candidateEpoch + pageIndex + indexInPage
```

過期 token（任何欄位不符）必須忽略：不提交、不移動選取、不崩潰。VS Code 編輯器、終端機、搜尋框、重新命名欄是不同 client（或同等隔離單位），token 不得跨欄位重用。

## VS Code 子場景

A11 除 App 矩陣外，VS Code 必測：

1. 文字編輯器
2. 內建終端機
3. 搜尋框
4. 重新命名輸入框

每個子場景獨立驗證：組字、候選不搶焦點、提交一次、快速切到另一子場景時不把碼串送出。

## 故障

引擎初始化失敗：不 consumed 一般文字鍵（讓 host 仍能打 ASCII），顯示一次不含原文的錯誤，允許回復到上一組有效資源。
Session 銷毀與 C 物件釋放必須有單元測試；不得在切 client 後使用舊 session 指標。
