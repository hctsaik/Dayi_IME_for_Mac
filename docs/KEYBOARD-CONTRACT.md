# 鍵盤與組字契約（已凍結）

預設 profile：`windows-compatible`。可選 profile：`mac-optional`。
profile 必須可設定、寫入 app settings、重啟後仍有效。切換 profile 前必須安全結束當前組字（見 EVENT-CONTRACT：`ProfileSwitch`）。

除系統修飾鍵外，文字映射先以標準 Latin/US 鍵盤實測；JIS 或其他 layout 標為未測，不得 silently 假設。
大易 alphabet：`0123456789/.,;abcdefghijklmnopqrstuvwxyz`。數字與 `,` `.` `/` `;` 可能是碼，禁止無條件改成選字或標點。

選字：每頁最多 8 項。選字鍵為本頁 `Shift+A…H`（對應 schema `alternative_select_keys` 的 A–H；I/J 超出 page_size，忽略且不提交）。項目不足時，對空槽的選字鍵維持組字、不提交、不吞與該鍵無關的 host 快捷鍵。

數字 `0…9` 永遠當大易碼，不作候選序號。

---

## 共同規則（兩套 profile 都遵守）

| 按鍵/事件 | 無組字 | 有組字/候選 |
|---|---|---|
| 大易有效碼 | 送引擎 | 追加；支援不逐字空格的連打 |
| Space | 交回 host | 選定目前候選／分段；最終提交由 engine commit 決定。前端不得在滿兩碼時自行提交 |
| Enter | 交回 host | 明確完成當前可提交組字；**不**額外插入換行 |
| Escape | 交回 host | 取消整段未提交組字，不刪已提交字，replacement range 不把碼串送出 |
| Backspace | 交回 host | 交給引擎編輯；組字空了之後下一鍵依「無組字」 |
| Delete | 交回 host | 交給引擎刪游標後字元；空組字後下一鍵依「無組字」 |
| 上/下 | 交回 host | 移動本頁 highlighted item |
| 左/右 | 交回 host | 引擎組字游標 |
| Home/End | 交回 host | 引擎組字游標到開頭/結尾；無組字則交回 host |
| PageUp/PageDown | 交回 host | 候選翻頁；無更多頁則維持當頁、consumed |
| Shift+A…H | 交回 host | 選本頁第 1…8 項；空槽：consumed=false 僅當該事件在無組字時本就會回 host，有組字時 consumed=true、不提交 |
| 數字 0…9（含數字鍵盤，NumLock 開） | 大易碼 | 大易碼，不作選字序號 |
| Cmd 快捷鍵 | 原樣回 host | 原樣回 host；後續 `deactivate` 依生命週期處理 |
| Ctrl 快捷鍵 | 原樣回 host | 原樣回 host；首版不自設攔截 |
| Option 產生的字元 | 原樣回 host | 有組字時不把 Option 字元當大易碼；交回 host 或忽略，見 EVENT-CONTRACT，不得當碼追加 |
| Caps Lock | 尊重系統輸入來源 | 系統切來源造成 deactivate 時走 `InputSourceSwitch` |
| 滑鼠選候選 | 無動作 | 等價於選定該 token；焦點留在原 client |
| key repeat | 交回 host | 對 Backspace／碼鍵：每個 repeat 視為一次獨立同步交易 |

英數模式狀態必須在輸入法選單可見。輸入來源切換使用系統快捷鍵。
中文模式下 `Shift+<` / `Shift+>` 等標點走 schema punctuation；須區分 literal key 與碼表字元。
首選、候選索引、分段與一次提交由 golden traces 定義。

首版不提供繁簡切換、注音反查。`~` 不當反查前綴；`Ctrl+Shift+4` 交回 host。

---

## Profile：`windows-compatible`（預設）

來源：`reference/windows-baseline/dayi2.schema.yaml` 已寫明的綁定，以及 Rime `ascii_composer` / `key_binder` 預設對該 schema 的影響。未在快照出現的行為不自行發明。

| 按鍵/事件 | 無組字 | 有組字/候選 |
|---|---|---|
| Tab | 切 `ascii_mode`（schema `when: always`） | **不得**先取消再交 host。把 Tab 交給引擎 `toggle: ascii_mode`。組字結果（提交或保留）以引擎 ascii_composer 為準，前端只套用一次 commit／context |
| Shift+Tab | 交回 host | 交回 host；不自訂反向切換 |
| Shift 輕點（flagsChanged，無其他鍵） | 切 `ascii_mode`（Rime ascii_composer 預設 Shift） | 同左；交引擎處理，前端不先 cancel |
| Shift+Space | 切 `full_shape`（Rime 預設） | 交引擎；不當作選字 |
| Shift+Enter | 交回 host | 若引擎將輸入碼上屏（schema 註解：Shift+Enter 可上屏輸入碼），套用該 commit；否則完成組字且不換行 |
| 英數模式字母 | 交回 host（直出 ASCII） | 不應停留在中文組字；若仍有殘留，先結束交易再直出 |

切回中文後可重新組字。Shift 按住當修飾鍵選 `A…H` 時**不是**輕點切模式：chord 期間不 toggle ascii_mode。

---

## Profile：`mac-optional`

與 Windows 預設不同之處僅下列；其餘同共同規則。

| 按鍵/事件 | 無組字 | 有組字/候選 |
|---|---|---|
| Tab / Shift+Tab | host 導航 | 先 `CancelComposition`（不提交碼串），再把 Tab 交回 host 導航 |
| Shift 輕點 | 不切換模式 | 不切換模式 |
| Shift+Space | 交回 host（不切全形） | 交回 host，維持組字 |
| Shift+Enter | 交回 host | 與 Enter 相同：完成組字、不換行、不上屏原始碼 |
| 英數模式 | 僅由輸入法選單切換 | 從中文切入時先 `CancelComposition` |

---

## 焦點與 host 生命週期（兩套相同，語意不同事件不得合併）

| 事件 | 提交未完成組字？ | 候選 | replacement / 新 client |
|---|---|---|---|
| Escape | 否，取消 | 隱藏 | 不把碼串插入 |
| Tab（windows） | 由引擎 ascii_mode 決定 | 依引擎 | 留在原 client |
| Tab（mac） | 否，取消 | 隱藏 | 不把碼串插入，Tab 給 host |
| 切換輸入欄／App（deactivate client） | 否，取消 | 隱藏 | 不把未提交文字送到新 client |
| 切換輸入來源 | 否，取消 | 隱藏 | 不殘留 session |
| host `commitComposition` | 是，提交引擎當前可提交文字 | 隱藏 | 原 client |
| host `cancelComposition` | 否；**禁止**把 marked text／碼串當「還原原文」送出 | 隱藏 | 見 EVENT-CONTRACT |
| 使用者選取既有文字 | 取消組字，不提交碼串 | 隱藏 | 不覆蓋選取區為碼串 |
| 密碼／secure input | 不組字、不學習 | 無 | 交系統 |

「一律取消」只適用上表標記為取消的列，不是 Windows 相容模式的萬用預設。
