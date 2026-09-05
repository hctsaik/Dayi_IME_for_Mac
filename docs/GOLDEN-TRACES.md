# Golden keystroke traces

至少 30 條。機器可讀副本：`docs/fixtures/golden-traces.json`。

## 准入

- **前端／生命週期 traces**（`gate: frontend`）：實作後必須 100% 符合，否則不得合併。
- **詞典可見性 traces**（`gate: lexicon`）：列出的字詞必須出現在候選中（不要求一定是 top1，除非 `require_top1`）。來源為凍結的 `dayi2.dict.yaml` / `common_words_import.dict.yaml`。
- **排序 traces**（`gate: ranking`）：只作觀察，**不得**在首次跑出任意低分後就凍成永久達標。須人工審閱後才寫入 baseline。
- 禁止：空 commit 時用第一候選冒充成功；用 spaced-code 或已學習 userdb 冒充 static continuous。

Profile 預設 `windows-compatible`。`mac-optional` 只出現在標了該 profile 的 traces。

碼表已知事實（私人開發資產，不是公開散布授權）：

| 碼 | 字/詞 | 來源 |
|---|---|---|
| `a` | 人 | dayi2.dict.yaml 權重 922302 |
| `v5` | 我 918508、程 740107 | 同碼多字 |
| `e5` | 式 | 750316 |
| `v5e5` / `v5 e5` | 程式 | common_words_import |
| `/.` | 的 | 1050026 |
| `at` | 你 | 826016 |
| `d9` | 是 | 966502 |
| `;oxb` | 台灣 | ;o=台 xb=灣；詞 ;o xb |
| `o1kx` | 中文 | o1=中 kx=文 |

---

## 清單

| ID | gate | profile | 輸入 | 必須觀察 |
|---|---|---|---|---|
| G01 | frontend | both | Idle Space | consumed=false，無組字 |
| G02 | frontend | both | Idle Enter | consumed=false，host 換行 |
| G03 | frontend | both | Idle Escape | consumed=false |
| G04 | frontend | both | Idle Backspace | consumed=false |
| G05 | frontend | both | Idle Cmd+S | consumed=false，原樣回 host |
| G06 | lexicon | both | `a` | 候選含「人」；數字/字母當碼 |
| G07 | lexicon | both | `v5` | 候選同時能見到「我」與「程」（可翻頁） |
| G08 | lexicon | both | `v5e5` 無空格 | 候選含詞「程式」，可經選字提交「程式」 |
| G09 | lexicon | both | `v5 e5` 有空格 | 不得把詞典空格當成使用者必打；若引擎當分隔，仍須能得到「程式」或「程」「式」連續提交。**產品主路徑是 G08 無空格連打** |
| G10 | lexicon | both | `/.` | 候選含「的」 |
| G11 | lexicon | both | `at` | 候選含「你」 |
| G12 | lexicon | both | `;oxb` | 候選含「台灣」 |
| G13 | lexicon | both | `o1kx` | 候選含「中文」 |
| G14 | lexicon | both | `v5/.` | 一二碼混合：可組出「我的」或先選「我」再出「的」；不得因奇數碼長丟棄已確認字 |
| G15 | frontend | both | 未知碼 `qqqq` 後 Escape | 無提交；組字清空；不把 `qqqq` 插入文件 |
| G16 | frontend | both | `a` 後 Backspace 到空 | 回到 Idle；下一 Space 交 host |
| G17 | frontend | both | `a` 後 Enter | 提交引擎當前可提交文字；**不**插入換行 |
| G18 | frontend | windows | Idle Tab | toggle ascii_mode；不把 Tab 當縮排送出 |
| G19 | frontend | windows | 組字中 Tab | 前端不先 cancel；交引擎 ascii_mode；文件不得留下碼串除非引擎 commit |
| G20 | frontend | mac | 組字中 Tab | 取消組字、不提交、Tab 給 host 導航 |
| G21 | frontend | windows | Idle Shift 輕點 | toggle ascii_mode |
| G22 | frontend | mac | Idle Shift 輕點 | 不切模式 |
| G23 | frontend | both | 組字中 Shift+A | 提交本頁第 1 候選（若存在） |
| G24 | frontend | both | 僅 1 個候選時 Shift+B | 不提交；維持組字 |
| G25 | frontend | both | 組字中數字 `1` | 當碼追加，不當選第 1 候選 |
| G26 | frontend | both | PageDown 後 Shift+A | 選**新頁**第 1 項；舊頁 index 不得套用 |
| G27 | frontend | both | 候選 epoch 變更後點舊滑鼠 token | 忽略 |
| G28 | frontend | both | 組字中切到另一 client | 不提交到 B；A 的候選消失 |
| G29 | frontend | both | host cancelComposition | 不插入碼串 |
| G30 | frontend | both | 組字中選取既有文字 | 取消組字；選取區不被碼串覆蓋 |
| G31 | frontend | both | VS Code 編輯器 → 搜尋框 | 同 G28 |
| G32 | frontend | both | VS Code 終端機組字提交 | 字只出現一次 |
| G33 | frontend | both | 密碼欄 | 不組字、不學習 |
| G34 | frontend | both | key repeat Backspace | 每下刪一個碼／字，同步交易 |
| G35 | frontend | both | Option+2 等 Option 字元 | 不當大易碼追加 |
| G36 | frontend | windows | Shift+Enter 於有碼無候選 | 允許上屏輸入碼（引擎行為）；有候選時不得誤插入換行 |
| G37 | lexicon | both | `v5a6` | 候選含「我們」 |
| G38 | frontend | both | 中文模式 Shift+,（`<`） | 走 punctuation「，」類，不與碼 `,` 混淆（`,` 是碼表字元「力」） |
| G39 | ranking | both | 短句 `atlg`（你好） | 記錄 top1/實際 commit；首次只觀察 |
| G40 | ranking | both | 整句：我是中文（`v5d9o1kx`） | 記錄分段與 commit；首次只觀察 |

G01–G38 中所有 `frontend` 與 `lexicon` 必須全過，才允許凍結 ranking baseline。歷史 Windows 85.871% 不得寫成 Mac 已達標。
