# Mac 建置與交付計畫

這是接手者要實作的流程，不是已存在的 build 指令。

## 開發環境與相依

記錄 macOS、CPU、Xcode/SDK、deployment target、Swift/C++ compiler、librime 及其全部啟用依賴版本。
本輪確認以使用者 Mac M4 實際 macOS 版本為交付環境，開工時偵測並記錄。macOS 13+ 全範圍支援不再作為首版承諾；欲擴充支援範圍時再增加對應真機驗收。
固定依賴 commit/checksum 與取得方式，避免 moving master。以正式 rime_api.h 建 bridge。
依賴可靜態或動態連結；若 dylib，檢查 @rpath/install_name、架構、內嵌簽章，乾淨機不得依賴 Homebrew/Xcode library 搜尋路徑。

## 開發版

可重現命令（在 Mac 專案根目錄 `/Users/heather/code/myDayi-Mac` 或交接包根目錄）：

```sh
sh scripts/test-fake-engine.sh
sh scripts/build-dev.sh
sh scripts/install-dev.sh
```

Xcode 專案為 `MyDayiMac.xcodeproj`（placeholder Bundle ID `tw.mydayi.mac.dev`）。目前以 `swiftc` 腳本產開發 bundle，避免本機路徑手工修補。
先安裝到 ~/Library/Input Methods/myDayiMac.app，再請使用者加入輸入來源。
實際是否需重新登入，以當前 macOS 真機結果寫進使用者說明；普通雙擊 .app 不等同完成輸入法安裝。
Installer 預設單使用者範圍，檢查目的路徑與既有 app identity，只替換自身 app。
Settings 可為 app 內視窗或 companion target；先求可靠，不增加不必要 background service。

## 更新與移除

更新：切換其他輸入來源 → 停用自身程序 → 備份自身 app 與必要資料 → 驗證新 bundle → 替換 → 重新啟用驗證。
部署詞典在暫存區編譯完成再切換；失敗保留上一版本，記錄不含輸入文字的診斷。
移除只刪自身 bundle，預設保留學習資料；另提供清除資料操作及明確範圍。絕不刪 ~/Library/Rime。
提供安裝、重新登入、故障回復及移除指南，包含被 Gatekeeper 阻擋時的官方處理方式，不要求關閉全域安全機制。

## 公開發行 gate

- 字典、依賴、圖示、引用原始碼來源/授權完整；權利未明產物不公開。
- 正式唯一 Bundle ID，Developer ID 簽章、hardened runtime 與最少所需 entitlements。
- 依選擇的 zip/dmg/pkg 形式完成正確簽章；使用 notarytool 公證、適用產物 staple；保存驗證命令與結果。
- 在沒有開發依賴、沒有鼠鬚管的乾淨 Mac/帳號安裝使用。
- 無簽章憑證時交付明確標記的本機開發成果，public release 保持未完成。

## 建議交付物

原始碼、固定依賴清單、可重現命令、開發安裝產物、測試 JSON/真機紀錄、已知限制、第三方 notices、回復/移除說明。
公開發行產物另附版本與 SHA-256、公證/簽章證據。自動更新與公證服務費用不列本次實作前提。
