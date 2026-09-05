# 原生測試環境（已偵測）

日期：2026-09-05。執行者：接手 AI 經 Windows SSH `macmini4`。帳號：本機 `heather`（SSH 設定曾寫 `Daniel`，實際 Unix 使用者為 `heather`，家目錄 `/Users/heather`）。

| 項目 | 值 |
|---|---|
| 主機 | `Mac` / 192.168.28.83 |
| 晶片 | Apple M4（`arm64`，`hw.optional.arm64=1`） |
| macOS | 15.7.3（Build 24G419，Darwin 24.6.0） |
| Xcode | 16.2（Build 16C5032a） |
| 開發者目錄 | `/Applications/Xcode.app/Contents/Developer` |
| macOS SDK | 15.2（`macosx15.2`） |
| Swift | Apple Swift 6.0.3（swift-driver 1.115.1，clang 1600.0.30.1） |
| 目標 triple | `arm64-apple-macosx15.0` |
| Git | 2.39.5 (Apple Git-154) |
| Python | 3.9.6（系統） |
| InputMethodKit | 系統框架存在 |
| Homebrew / CMake | 未在 PATH |
| 建議 deployment target | macOS 15.2（與已安裝 SDK 對齊；不承諾更舊系統） |

## 磁碟（阻擋完整編譯）

Data 卷在清理前約 **1.2–1.4 GiB**。已清三包可再生快取後約 **13 GiB** 可用。Xcode DerivedData 幾乎為空。開發版已安裝到 `~/Library/Input Methods/myDayiMac.app`。

可再生快取（未刪，需你同意才清）：

| 路徑 | 約略大小 |
|---|---|
| `~/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt`（Cursor 更新） | 4.7G |
| `~/Library/Caches/com.lemon.lvoverseas` | 3.3G |
| `~/Library/Caches/pip` | 3.2G |

合計約 11G。不碰 `Documents`（58G）與 `Downloads`（7.7G）。

## 尚未具備

- 本專案尚未複製到 Mac（`~/code` 目前只有 `myStock_v1`）
- librime 尚未固定版本／尚未編譯
- 真機輸入法安裝與 A1 證據尚未執行
