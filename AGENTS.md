# Implementation rules

- **必讀 [docs/INSTALL.md](docs/INSTALL.md)。** 安裝、部署到其他 Mac、日用打字問題，一律先照該指南。那是給人與 AI 的正式安裝說明。
- 目前可交付的日用路徑是 **Squirrel + `squirrel-user/`**，不是獨立 InputMethodKit App。
- 獨立原生輸入法仍是長期目標（無 Squirrel 依賴）；未完成 Developer ID 前，不得當成已可安裝產品。
- Read openspec/changes/add-native-macos-dayi/ before IMK implementation.
- Treat reference/windows-baseline as immutable input. Do not edit the original Windows snapshot; change Dayi behaviour in `squirrel-user/`.
- Keep tasks unchecked until implementation, required validation, and evidence are complete.
- Do not commit live `*.userdb/` LevelDB directories. Export text (`dayi2.userdb.export.txt`) only.
- Keep runtime offline. Do not overwrite unrelated IME app bundles (`Squirrel.app`, OpenVanilla, etc.).
- Record actual macOS test environment and distinguish development builds from notarized releases.
- All product explanations and handoff notes should use Traditional Chinese.
