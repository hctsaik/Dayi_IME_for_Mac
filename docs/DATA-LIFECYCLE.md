# 資料版本、備份還原、誤學習修正

資料根目錄（不可使用 `~/Library/Rime`）：

```text
~/Library/Application Support/myDayiMac/
  versions.json          # 四類版本與交易狀態
  settings.json          # profile、學習開關等
  resources/             # 目前有效的 schema/詞典部署
  engine/                # userdb / 學習
  cache/                 # 編譯產物
  backups/               # 編號備份
  logs/                  # 不得含輸入原文或 userdb 內容
```

## 四類版本

| 鍵 | 內容 | 不相容時 |
|---|---|---|
| `app` | bundle short version + build | 可開新資料；不得默默降級覆蓋 |
| `resources` | schema/dict/manifest SHA-256 | 部署失敗則保留上一組有效 resources |
| `settings` | settings schema integer | 未知欄位保留；不能解析則用備份 |
| `userdb` | 學習資料格式版本 | 遷移失敗則停用學習並提示，不刪靜態詞典 |

`versions.json` 另記 `tx`：`idle` | `deploying` | `backing-up` | `restoring` | `resetting`。啟動時若發現非 `idle`，視為中斷交易，回復到交易開始前的有效狀態。

## 部署交易

升級 resources：

1. 切換使用者到其他輸入來源（文件提示；程式能停用自身 session）。
2. 寫入暫存目錄並編譯。
3. 驗證 manifest closure（每個 import_preset／詞典／必要 runtime 檔都在）。
4. 原子切換 `resources/` 指標或目錄。
5. 失敗：刪暫存、保留舊 resources 與 userdb，`tx=idle`。
6. 磁碟不足、權限失敗、hash 不符都走失敗路徑。

降版：若新 app 的 `userdb` 版本較舊且無逆向遷移，拒絕覆蓋學習資料，改用只讀靜態模式並提示還原備份。

## 備份與還原

- 備份範圍可選：`settings`、`userdb`、兩者。不含系統其他 IME、不含 `~/Library/Rime`。
- 至少保留最近 5 份成功備份，超出刪最舊。
- 還原前必須停用相關 session。
- 還原只接受相同或文件記載相容的 `userdb` 版本。
- 重設學習預設**保留**備份。
- 解除安裝預設**保留** `Application Support/myDayiMac`；另提供「一併刪資料」。

## 誤學習修正（首版必做語意，UI 可最小）

引擎語意必須可測試，不把「刪除」猜成永久封鎖。

| 操作 | 觀察結果 |
|---|---|
| 暫停學習 | 之後的確認不上 userdb；已學習內容仍可用 |
| 恢復學習 | 新的確認恢復寫入 |
| 刪除單一學習詞 | 該詞不再因 userdb 排序靠前；靜態詞典仍可出該字詞 |
| 撤銷最近一次學習 | 只撤最後一筆確認寫入 |
| 重設全部學習 | 清空自身 userdb；靜態詞典與其他 IME 不變 |

以上操作都要有合成測試，不依賴使用者真的打過私密內容。

## 隱私

離線。診斷包與正常 log 不得含組字原文、commit 原文、userdb。可用事件類型、耗時、錯誤碼。
