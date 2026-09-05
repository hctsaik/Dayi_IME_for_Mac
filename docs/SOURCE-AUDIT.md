# Windows 原始專案盤點

來源實際路徑：C:\code\claude\IME\myDayi_IME（不是 myDayi\_IME）。
commit：da9383918ff8ab3af4e0919373b871a595c7bf49；讀取時 git status clean。
本次只讀取並複製追蹤檔案，不修改原專案、不讀取 %APPDATA% 的個人資料。

| 項目 | 已觀察事實 | Mac 處理 |
|---|---|---|
| dayi2.schema.yaml | script_translator、fluency_editor、組句、common_words userdb | 建立專用 Mac schema 保留核心 |
| dayi2.dict.yaml | by_weight，import common_words_import | 保留碼與權重，hash 固定 |
| common_words.dict.yaml | 人工整理詞/權重來源 | 開發資產 |
| build_common_words_table.py | 產生空格分碼 import 與另一 table 版本 | 不把詞典空格當成使用者必須敲空格 |
| build_dayi2_single_char_weights.py | Sinica/TBCL/MOE/Essay 混合字頻 | 缺 sinica_words.json，不能宣稱可完整重建 |
| dayi2_base.dict.yaml | 原始字表 | 比對 mapping，避免只看生成權重 |
| dayi2.yaml | msapple_dayi2 舊 schema，停用組句/學習 | 不作 Mac 主方案 |
| Phonetic_tw | schema 引用但快照沒有檔案 | MVP 明確移除引用，反查延後 |
| Lua filter | 阻擋「它股」「端的」user_phrase、工後 a3 優先作 | schema 未掛載，維持停用 |
| deploy_to_rime.ps1 | 複製部分檔到 APPDATA，仍需手動重新部署 | 不移植/執行；Mac 自有 installer |
| README | 稱 Lua active | 與 schema 不一致，不據此啟用 |
| SOURCES.md | 提到 build_common_words_40k.py | 快照缺該程式，不能假設可重建 40k 來源 |
| article_regression.py | ctypes 載入 Windows dll，預設 live Rime snapshot | 重作可指定 engine/assets 的跨平台 runner |

文章文件記錄：連打 top1 85.871%、詞組 96.338%、單字 76.934%，Wikipedia revision 93857310。
以上是歷史文件數字，本次未執行，沒有原 run manifest，不能保證快照重現。

## 快照與權利

reference/MANIFEST.json 記錄相對檔名及 hash。快照包含 repository 追蹤檔案，不含 .git、cache、live userdb、sinica_words.json。
來源文檔稱 Sinica 僅個人研究使用；原碼表/衍生詞庫的公開再散布權利也尚未逐項核對。
reference 僅供此私人專案接手。公開 release 必須列出字典來源、授權及可散布判定；權利不清的資料不能只換檔名就發行。

