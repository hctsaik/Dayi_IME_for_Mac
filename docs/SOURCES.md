# 官方參考來源

查閱日期：2026-09-05。實作時仍需固定 SDK 和依賴版本，文件連結不代表已驗證二進位行為。

- [Apple IMKInputController](https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller)：InputMethodKit controller 與候選介面的官方入口。
- [Apple Developer ID](https://developer.apple.com/support/developer-id/)：站外散布簽章與公證。
- [Apple notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)：發行公證工作流程。
- [librime repository](https://github.com/rime/librime)：引擎、授權及依賴盤點來源。
- [librime macOS build](https://github.com/rime/librime/blob/master/README-mac.md)：原生編譯參考，實作須固定版本。
- [OpenSpec spec-driven](https://openspec.dev/docs/schemas/spec-driven)：本交接包使用 proposal/specs/design/tasks 結構。

架構決策屬本專案規劃：InputMethodKit 原生前端搭配 librime；這不是 Apple 指定的大易實作方式。

