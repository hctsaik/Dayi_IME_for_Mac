# 連到 Mac Mini 4 編譯

Windows 主機已可 ping `192.168.28.83`（SSH host `macmini4`，使用者 `Daniel`），但先前沒有 SSH 私鑰，因此 Permission denied。

已在 Windows 產生專用金鑰：

- 私鑰：`%USERPROFILE%\.ssh\id_ed25519_macmini4`
- 公鑰：`%USERPROFILE%\.ssh\id_ed25519_macmini4.pub`
- `~/.ssh/config` 的 `Host macmini4` 已指向此金鑰（`IdentitiesOnly yes`）

## 請在 Mac 上做一次（約 1 分鐘）

1. 系統設定 → 一般 → 共享 → 開啟「遠端登入」，允許使用者 `Daniel`。
2. 在 Mac 終端機貼上（整段一次執行）：

```sh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsxrbm85VdWeoMLoZ52Png4x24xJpN68TDkpWA/NruZ myDayi-windows-to-macmini4' >> ~/.ssh/authorized_keys
```

3. 告訴接手 AI「金鑰已放好」。之後在 Windows 驗證：

```powershell
ssh -o BatchMode=yes macmini4 "sw_vers; uname -m; xcodebuild -version"
```

不要把登入密碼貼到聊天。公鑰可以公開；私鑰不要複製到 Mac 以外的地方。
