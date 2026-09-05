# 鼠鬚管日用詞庫（複製到 `~/Library/Rime`）

| 檔案 | 用途 |
|---|---|
| `dayi2.schema.yaml` | 大易兩碼方案（連打、數字當碼、不做反查／繁簡） |
| `dayi2.dict.yaml` | 單字碼表，並 import 下面兩份詞庫 |
| `common_words_import.dict.yaml` | 常用詞（音節用空白分隔，給 script_translator） |
| `common_words_table.dict.yaml` | 常用詞（含無空白碼，給 table_translator） |
| `common_words.dict.yaml` | 常用詞原文／權重 |
| `mydayi_boost.dict.yaml` | 文章＋essay 加權後的詞，讓「感覺」等詞壓過誤組句 |
| `mydayi_mac.schema.yaml` | 備用方案 ID |
| `default.custom.yaml` | 方案列表 |
| `squirrel.custom.yaml` | 橫排候選、蘋方字體 |
| `dayi2.userdb.export.txt` | 已學習詞匯出（不含誤學的「感兒」） |

部署：

```sh
cp squirrel-user/*.yaml ~/Library/Rime/
# 可選：匯入學習詞
# cd ~/Library/Rime && rime_dict_manager -i dayi2 dayi2.userdb.export.txt
sh scripts/redeploy-dayi2.sh
```
