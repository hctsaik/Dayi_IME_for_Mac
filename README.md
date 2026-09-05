# Dayi IME for Mac（myDayi）

GitHub：https://github.com/hctsaik/Dayi_IME_for_Mac

## 現況（2026-09-05）

**安裝、部署到其他 Mac、給 AI 的操作說明：先讀 [docs/INSTALL.md](docs/INSTALL.md)。**

獨立 InputMethodKit App 因 macOS 15 需要 **Developer ID** 簽章才能出現在「加入輸入方式」清單，目前日用改走已簽章的 **鼠鬚管（Squirrel）** + `squirrel-user/` 詞庫。

詞庫訓練腳本：`scripts/train_from_article.py`（維基百科 + rime-essay）。

---

# 獨立輸入法 App 交接包

狀態：規格已凍結；Mac M4 / macOS 15.7.3 / Xcode 16.2 已偵測。假引擎 App 可編譯安裝，但未進系統輸入來源清單（adhoc / Apple Development 會被 Gatekeeper 拒絕）。日用請用上方 Squirrel 路徑。
使用者目標仍是 **獨立 macOS 系統輸入法 App**；Squirrel 是目前可打字的過渡方案。
暫定名稱 myDayi Mac；開發 Bundle ID `tw.mydayi.mac.dev`。

最新確認：個人完整日用版、Mac M4、VS Code 優先；預設 Windows 大易操作、可選 Mac profile。第一版不做注音反查、不做繁簡切換；Windows live userdb 遷移 deferred。原生環境見 [NATIVE-ENV](docs/NATIVE-ENV.md)。範圍以 [SCOPE](docs/SCOPE.md) 為準。

## 閱讀順序

1. **[安裝與部署指南（人＋AI 必讀）](docs/INSTALL.md)**
2. [AI 接手指令](AI-HANDOFF.md)
3. [範圍凍結](docs/SCOPE.md)
4. [現況盤點](docs/SOURCE-AUDIT.md)
5. [OpenSpec 提案](openspec/changes/add-native-macos-dayi/proposal.md)
6. [架構設計](openspec/changes/add-native-macos-dayi/design.md)
7. [實作任務](openspec/changes/add-native-macos-dayi/tasks.md)
8. [鍵盤契約](docs/KEYBOARD-CONTRACT.md)／[事件契約](docs/EVENT-CONTRACT.md)／[golden traces](docs/GOLDEN-TRACES.md)
9. [驗收矩陣](docs/ACCEPTANCE.md)
10. [建置與交付](docs/BUILD-RELEASE.md)
11. [連 Mac 編譯](docs/MAC-ACCESS.md)

## 交付內容

- openspec/：spec-driven 格式，五個能力規格與未勾選任務。
- docs/：原始碼盤點、鍵盤契約、驗收、建置、風險與官方來源。
- reference/windows-baseline/：原 Windows 專案的追蹤檔案快照，供私人開發比對；不是 Mac 可執行版本。
- reference/MANIFEST.json：來源 commit、檔案 SHA-256。
- docs/VALIDATION.md：本次文件檢查結果。

整個資料夾可搬到 Mac 交給其他 AI，不需要存取原 Windows 絕對路徑。參考快照不可直接視為公開發行素材；來源授權與缺件見盤點。

## 第一版界線

Swift/AppKit + InputMethodKit 原生前端，透過 C/Objective-C++ bridge 使用 librime。
第一個實測目標為使用者 Mac M4 與其實際 macOS 版本；不承諾未測試的 macOS 13+ 全範圍。
Intel 與其他未測環境不列第一版承諾。保留繁體大易連打、候選與本機學習；注音反查、繁簡切換與 Windows live userdb 遷移不在第一版。
先產生可在測試 Mac 安裝的開發版，再處理對外簽章與公證發行版。

## 驗證規格

在本資料夾執行：

```sh
openspec validate add-native-macos-dayi --strict --no-interactive
```

沒有 OpenSpec CLI 的 AI 仍可直接讀取 Markdown。App 編譯、輸入事件及公證必須在 Mac 上驗證；本次沒有宣稱已通過。
