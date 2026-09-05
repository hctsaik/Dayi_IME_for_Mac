# RealVNC on Snapdragon is x64; Weasel's ARM64X stub crashes it (0xc0000428).
# Stop Weasel for this session, then start VNC. Restore Weasel afterwards with:
#   & "C:\Program Files\Rime\weasel-0.17.4\WeaselServer.exe"
$ErrorActionPreference = "SilentlyContinue"
$vnc = "C:\Program Files\RealVNC\RealVNC Connect\rvncconnect.exe"
$weasel = "C:\Program Files\Rime\weasel-0.17.4\WeaselServer.exe"
if (-not (Test-Path $vnc)) { Write-Error "RealVNC not found: $vnc"; exit 1 }

Stop-Process -Name WeaselServer -Force
Stop-Process -Name rvncconnect -Force
Start-Sleep -Seconds 1
Start-Process $vnc
Write-Output "Weasel temporarily stopped. RealVNC started."
Write-Output "When finished with VNC, restore Dayi:"
Write-Output "  Start-Process `"$weasel`""
