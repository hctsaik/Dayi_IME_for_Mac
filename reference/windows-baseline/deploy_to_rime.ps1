# 將 user_setting 內所有檔案複製到 Rime 使用者目錄，方便重新部署後常見詞生效
# 使用：在 PowerShell 執行 .\deploy_to_rime.ps1

$RimeDir = "$env:APPDATA\Rime"
$Here = $PSScriptRoot

if (-not (Test-Path $RimeDir)) {
    Write-Host "找不到 Rime 目錄: $RimeDir" -ForegroundColor Red
    Write-Host "請先安裝小狼毫並至少執行過一次部署。" -ForegroundColor Yellow
    exit 1
}

$files = @(
    "default.custom.yaml",
    "dayi2.schema.yaml",
    "dayi2.dict.yaml",
    "dayi2.yaml",
    "common_words.dict.yaml",
    "common_words_import.dict.yaml"
)

foreach ($f in $files) {
    $src = Join-Path $Here $f
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination (Join-Path $RimeDir $f) -Force
        Write-Host "已複製: $f"
    } else {
        Write-Host "略過（不存在）: $f" -ForegroundColor Yellow
    }
}

$buildDayi2 = Join-Path $RimeDir "build\dayi2.table.bin"
Write-Host ""
Write-Host "複製完成。接下來請：" -ForegroundColor Cyan
Write-Host "  1. 到 開始選單 → 小狼毫輸入法 → 重新部署" -ForegroundColor White
Write-Host "  2. 常見詞已併入 dayi2（import_tables），部署會編譯 dayi2 與 common_words_import" -ForegroundColor Gray
if (-not (Test-Path (Join-Path $RimeDir "common_words_import.dict.yaml"))) {
    Write-Host ""
    Write-Host "警告：common_words_import.dict.yaml 未複製，常見詞不會生效。請先執行: python build_common_words_table.py" -ForegroundColor Red
}
