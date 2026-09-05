# 備份大易兩碼 Rime 設定，方便日後還原或換電腦使用
# 使用：在 PowerShell 於本資料夾執行 .\backup_rime_settings.ps1
# 可加參數指定備份目錄，例如：.\backup_rime_settings.ps1 -OutDir "D:\MyBackup"

param(
    [string]$OutDir = ""
)

$Here = $PSScriptRoot
$Date = Get-Date -Format "yyyyMMdd_HHmm"
if ($OutDir -eq "") {
    $BackupRoot = Join-Path (Split-Path $Here -Parent) "backup"
    $OutDir = Join-Path $BackupRoot "rime_dayi2_$Date"
}

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

$copyItems = @(
    "default.custom.yaml",
    "dayi2.schema.yaml",
    "dayi2.dict.yaml",
    "dayi2.yaml",
    "common_words.dict.yaml",
    "build_common_words_table.py",
    "deploy_to_rime.ps1",
    "backup_rime_settings.ps1",
    "README.txt",
    "RESTORE.txt"
)
# 以下較大，可選：common_words_import.dict.yaml（建表產物）, luna_pinyin.practical.dict.yaml（詞庫）
$optionalItems = @("common_words_import.dict.yaml", "luna_pinyin.practical.dict.yaml")

$n = 0
foreach ($f in $copyItems) {
    $src = Join-Path $Here $f
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination (Join-Path $OutDir $f) -Force
        Write-Host "已複製: $f"
        $n++
    }
}
foreach ($f in $optionalItems) {
    $src = Join-Path $Here $f
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination (Join-Path $OutDir $f) -Force
        Write-Host "已複製（選用）: $f"
        $n++
    }
}

Write-Host ""
Write-Host "備份完成，共 $n 個檔案 → $OutDir" -ForegroundColor Green
Write-Host "日後還原請看該資料夾內的 RESTORE.txt" -ForegroundColor Cyan
