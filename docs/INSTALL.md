# 安裝與部署指南（人＋AI 必讀）

> **給接手 AI：** 使用者要在 Mac 上「能打大易」時，**先讀完本檔再動手**。  
> 日用交付是 **鼠鬚管（Squirrel）+ 本 repo 的 `squirrel-user/` 詞庫**。  
> 不要一開始就重寫引擎、不要以為 clone 完獨立 App 就能出現在系統輸入清單。  
> 獨立 InputMethodKit App 仍缺 Developer ID，macOS 15 不會列出。  
> 本檔優先於 README 裡較舊的「尚未實作」敘述。

GitHub：https://github.com/hctsaik/Dayi_IME_for_Mac

---

## 1. 這份 repo 能做什麼、不能做什麼

| 可以 | 不可以 |
|---|---|
| 在已裝 **官方鼠鬚管** 的 Mac 上，部署大易兩碼詞庫與方案 | 雙擊一個獨立 `.app` 就變成系統輸入法 |
| 給**同一使用者的其他 Apple Silicon Mac** 私人日用 | 當成已公證、可任意公開散布的產品 |
| 用 `scripts/redeploy-dayi2.sh` 重編詞庫 | 覆蓋 `/Library/Input Methods/Squirrel.app` 本體 |
| 匯入 `dayi2.userdb.export.txt` 還原學習詞 | 把 Windows 小狼毫 live userdb 直接拷過來 |

測過環境：**Mac Mini M4、macOS 15.7.3、Squirrel 1.0.3**。其他版本未保證。

產品長期目標仍是獨立 App（見 OpenSpec）。**現在能用的是 Squirrel 路徑。**

---

## 2. 目標 Mac 事前條件

- Apple Silicon（arm64）為主
- 已能上網或已有 Squirrel 安裝檔
- 管理員權限（裝鼠鬚管時）
- 不要用本 repo 裡的 `Sources/` 假引擎 App 當日用（清單裡不會出現）

---

## 3. 整合安裝步驟（給另一台 Mac）

### 步驟 A — 安裝官方鼠鬚管

1. 從 https://rime.im 或 https://github.com/rime/squirrel/releases 下載 **已簽章** 的 Squirrel `.pkg` / `.dmg`。
2. 安裝後若選單列還沒有松鼠圖示：  
   **系統設定 → 鍵盤 → 輸入方式 → 編輯 → ＋ → 繁體中文 → 鼠鬚管 / Squirrel**。
3. 先確認切到鼠鬚管時，系統預設拼音／注音方案能打字。這證明 IME 本身可用。

**不要**用本專案編譯的 `myDayiMac.app` 取代鼠鬚管。

### 步驟 B — 取得本 repo

在目標 Mac 的終端機：

```sh
git clone https://github.com/hctsaik/Dayi_IME_for_Mac.git
cd Dayi_IME_for_Mac
```

或把整個資料夾拷到該機。工作目錄就是 repo 根（內有 `squirrel-user/` 與 `scripts/`）。

### 步驟 C — 部署大易詞庫

```sh
sh scripts/redeploy-dayi2.sh
```

腳本會：

1. 把 `squirrel-user/` 的 schema／詞庫拷到 `~/Library/Rime/`
2. 結束舊的 Squirrel 行程
3. 用 `rime_deployer --build` 編譯 `dayi2`
4. 若存在 `squirrel-user/dayi2.userdb.export.txt`，匯入學習詞
5. 重新打開 Squirrel

**空白學習（對方不要你的用詞習慣）：** 部署前把 `squirrel-user/dayi2.userdb.export.txt` 暫時移走，或改腳本略過 `-i` 匯入。

若沒有 `rime_deployer`：代表鼠鬚管沒裝好，回到步驟 A。路徑應為：

`/Library/Input Methods/Squirrel.app/Contents/MacOS/rime_deployer`

### 步驟 D — 讓系統載入新行程

macOS 常抓住舊 IME 行程，看起來像沒更新：

1. 選單列先切到 **ABC**
2. 再切回 **鼠鬚管**
3. 點松鼠圖示，確認方案是 **大易兩碼**（`dayi2`）  
   不是就按 **F4** 或 Control+` 選「大易兩碼」或「大易兩碼（myDayi）」

### 步驟 E — 驗收（必做）

在 TextEdit：

| 輸入 | 期望第一候選／上屏 |
|---|---|
| `v5e5` 再空白 | **程式** |
| `hzwq` 再空白 | **感覺**（不應是「感兒」） |
| `at` | **你** |
| 數字 `1` | 當碼，不是選第 1 候選 |
| `Tab` | 切中／英（Windows 習慣） |

通過後才算這台 Mac 部署完成。

---

## 4. 詞庫檔對照（`squirrel-user/`）

完整說明見 [squirrel-user/README.md](../squirrel-user/README.md)。最少必要：

- `dayi2.schema.yaml` — 方案（連打、`enable_sentence: false`、數字當碼）
- `dayi2.dict.yaml` — 單字；`import_tables` 含 `common_words_import` 與 `mydayi_boost`
- `common_words_import.dict.yaml` / `common_words_table.dict.yaml` / `common_words.dict.yaml`
- `mydayi_boost.dict.yaml` — 文章／essay 加權，詞優先於誤組句
- `squirrel.custom.yaml` — 橫排候選、蘋方繁體
- `default.custom.yaml` — 方案列表
- `dayi2.userdb.export.txt` — 可選，學習詞匯出

`reference/windows-baseline/` 是 Windows 快照，**只讀**，不要改。部署請只用 `squirrel-user/`。

---

## 5. 故障排除

| 現象 | 處理 |
|---|---|
| 輸入方式清單沒有鼠鬚管 | 用官方已簽章安裝檔；不要用本 repo 的 `myDayiMac.app` |
| 清單沒有 myDayi Mac | 正常。獨立 App 要 Developer ID。日用走鼠鬚管 |
| 改了詞庫但行為沒變 | `killall -9 Squirrel`，切 ABC 再切回鼠鬚管 |
| 第一候選是「感兒」不是「感覺」 | 學習詞庫記住錯誤。匯出 userdb、刪掉 `感兒` 那行再匯入。參考 `scripts/strip_ganer.py` |
| 必須打空格才能出詞 | 用了舊 schema。確認 `~/Library/Rime/dayi2.schema.yaml` 沒有 `delimiter: " "`，且 `enable_sentence: false` |
| `rime_deployer` 失敗、缺 `.table.bin` | 確認 yaml 在 `~/Library/Rime`，再跑一次 redeploy；看終端機錯誤 |
| 候選直排、字體怪 | 確認已拷 `squirrel.custom.yaml` 並重新部署 |
| 誤學一直回來 | 選對的候選再上屏；不要連續空白把錯詞學進去 |

查引擎實際第一候選（鼠鬚管須先關掉以免鎖 userdb）：

```sh
killall Squirrel
python3 scripts/query_rime_candidates.py hzwq dayi2
```

第一行應為「感覺」。若腳本是「感覺」、畫面上不是，就是舊行程或學錯詞，不是 yaml 沒拷到。

---

## 6. 更新已部署的 Mac

```sh
cd Dayi_IME_for_Mac
git pull
sh scripts/redeploy-dayi2.sh
```

再切 ABC → 鼠鬚管。  
`git pull` 不會自動清對方機器上新學的錯詞。

重新訓練詞權重（維基＋essay）：

```sh
python3 scripts/train_from_article.py
sh scripts/redeploy-dayi2.sh
```

訓練完應把新的 `squirrel-user/mydayi_boost.dict.yaml` commit 回 GitHub。

---

## 7. 給接手 AI 的硬規則

1. **安裝／部署任務 → 只遵循本檔。** 不要發明另一套路徑。
2. **日用問題先查 Squirrel + `~/Library/Rime`，** 不要先改 `Sources/` 裡的假引擎。
3. **不要改 `reference/windows-baseline/`。** 要改方案就改 `squirrel-user/`。
4. **不要覆蓋** `/Library/Input Methods/Squirrel.app` 或 `~/Library/Rime` 裡與大易無關的方案，除非使用者明確要求。
5. **不要把 live `*.userdb/` LevelDB 目錄 commit 進 git。** 只提交 `dayi2.userdb.export.txt` 這類匯出。
6. **不要宣稱獨立 App 已可給他人安裝。** 除非已有 Developer ID 簽章，且真機加入輸入來源成功。
7. **公開大量散布詞庫前** 先讀 `docs/SOURCE-AUDIT.md` 授權；私人拷到自己的 Mac 可以。
8. 產品說明用**繁體中文**。
9. 改詞庫或 schema 後：編譯 → 殺行程 → 查 `query_rime_candidates.py` → 請使用者切 ABC 再切回 → 才算驗證。
10. 獨立 App 後續工作仍讀 OpenSpec `openspec/changes/add-native-macos-dayi/`，但**不得**把未完成的 IMK 當成目前安裝方式。

---

## 8. 相關文件

| 文件 | 何時再讀 |
|---|---|
| [squirrel-user/README.md](../squirrel-user/README.md) | 詞庫每個檔做什麼 |
| [KEYBOARD-CONTRACT.md](KEYBOARD-CONTRACT.md) | 按鍵該怎樣（Windows 預設） |
| [SCOPE.md](SCOPE.md) | 不做反查、繁簡 |
| [SOURCE-AUDIT.md](SOURCE-AUDIT.md) | 詞庫來源與授權 |
| [AI-HANDOFF.md](../AI-HANDOFF.md) | 獨立 App 長期實作 |
| OpenSpec `tasks.md` | IMK 任務清單（未完成不要假勾） |
