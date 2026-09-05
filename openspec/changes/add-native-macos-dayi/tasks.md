## 0. Multi-agent review closure — before implementation

- [x] 0.1 已更新 proposal/specs；SSH `macmini4` 以 `heather` 登入，記錄於 docs/NATIVE-ENV.md（macOS 15.7.3 / M4 / Xcode 16.2）。
- [x] 0.2 凍結 Windows 預設與 Mac 可選 profile：docs/KEYBOARD-CONTRACT.md。
- [x] 0.3 同步 consumed 交易、狀態機、候選 token：docs/EVENT-CONTRACT.md。
- [x] 0.4 40 條 golden traces（G01–G40）及 frontend/lexicon commit gate：docs/GOLDEN-TRACES.md、docs/fixtures/golden-traces.json。
- [x] 0.5 app/resources/settings/userdb 版本、備份還原、誤學習修正：docs/DATA-LIFECYCLE.md。
- [x] 0.6 使用者確認不做注音反查、不做繁簡切換；Windows live userdb 遷移 deferred。docs/SCOPE.md。

## 1. Environment and source freeze

- [x] 1.1 核對 reference/MANIFEST.json（27/27 hash 相符，commit da938391…）；工具鏈見 docs/NATIVE-ENV.md。
- [ ] 1.2 固定 librime/依賴 commit 與 checksum，建立資產/授權清單；記錄私人版與公開版可用資料界線。
- [x] 1.3 建立 `MyDayiMac.xcodeproj`、placeholder Bundle ID `tw.mydayi.mac.dev`、`scripts/build-dev.sh` / `test-fake-engine.sh` / `install-dev.sh`；證據 `docs/evidence/T0.1-T2.1.md`。

## 2. Native input prototype

- [x] 2.1 假引擎 IMKServer/`MyDayiInputController`；Info.plist connection=`tw.mydayi.mac.dev_Connection`，行程已在 `~/Library/Input Methods/myDayiMac.app` 啟動。
- [ ] 2.2 在 Mac 測試帳號註冊輸入來源，TextEdit 完成 marked text/insertText；保存 A1 證據。
- [ ] 2.3 驗證 IMKCandidates；必要時選 AppKit panel，記錄決策，完成 A4 視窗定位與選取原型。

## 3. Engine and assets

- [ ] 3.1 實作 bridge，依正式 header 管理 ABI/字串/物件釋放、session 與序列呼叫。
- [ ] 3.2 用最小詞典驗證初始化、輸入、候選、commit、session 銷毀；故障路徑有測試。
- [ ] 3.3 導入固定字詞庫，建立專用 Mac schema；移除缺件反查、停用 Lua 及不適用全域按鍵。
- [ ] 3.4 完成所有 preset/資產引用 closure、版本 manifest 與 app 自有資料部署。
- [ ] 3.5 完成 mapping/weight 差異檢查、continuous phrase 整合測試及 A5/A6。

## 4. Native interaction and learning

- [ ] 4.1 實作鍵盤契約每一列及模式選單，完成 A2；數字作碼、Shift+A…H 選字。
- [ ] 4.2 完成單次 commit、UTF-8/UTF-16 範圍轉換、取消/切 client/過期事件處理，通過 A3。
- [ ] 4.3 完成候選鍵盤/滑鼠/翻頁/跨螢幕 A4，視窗不得搶焦點。
- [ ] 4.4 完成本機學習持久化、隔離、明確重設操作和 A7/A8。
- [ ] 4.5 完成 A11 應用程式矩陣、密碼欄位系統行為與效能/穩定性測試。

## 5. Reproducible regression

- [ ] 5.1 建立固定文章 fixture 取得/離線讀取流程、來源 attribution 與 hashes。
- [ ] 5.2 移植無 UI runner，新增 bridge runner；全新 profile/禁學習的 static 模式分離。
- [ ] 5.3 跑 A10 逐 case bridge parity，建立 Mac 全量三項 KPI 及凍結 baseline。
- [ ] 5.4 記錄與 Windows 歷史/可重建參考差異；不得用 spaced-code 或學習後結果冒充 static continuous。
- [ ] 5.5 將基準 gate 接入可重現命令/CI；無真機的環境明確 skip 原生驗證。

## 6. Development distribution

- [ ] 6.1 實作自身 bundle 安裝/更新/失敗回復/移除流程與 A9。
- [ ] 6.2 驗證無 Homebrew/鼠鬚管開發依賴的乾淨帳號可用；核對 dylib paths 與架構。
- [ ] 6.3 提供安裝、加入輸入來源、必要重新登入、故障處理、更新/移除與已知限制文件。
- [ ] 6.4 整理私人開發版產物、hash、全部測試證據與仍未完成的公開發行事項。

## 7. Public release (conditional on distribution scope)

- [ ] 7.1 核對全部資料/依賴散布權利，完成 notices；未解項不可列為通過。
- [ ] 7.2 正式 ID/Developer ID signing/hardened runtime/notarization，保存 A12 命令與結果。
- [ ] 7.3 在支援 OS 矩陣完成乾淨機發行安裝驗證，公布真實支援範圍。
- [ ] 7.4 若使用者確定只需私人開發版，明列第 7 節 deferred 並更新範圍，不將其假勾完成。
