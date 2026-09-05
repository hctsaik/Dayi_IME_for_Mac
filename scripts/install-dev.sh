#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/myDayiMac.app"
DEST="$HOME/Library/Input Methods/myDayiMac.app"

if [ ! -d "$APP" ]; then
  echo "missing $APP; run scripts/build-dev.sh first" >&2
  exit 1
fi

mkdir -p "$HOME/Library/Input Methods"
killall myDayiMac 2>/dev/null || true
rm -rf "$DEST"
cp -R "$APP" "$DEST"
open "$DEST" || true
echo "installed $DEST"
echo "Add 輸入來源：系統設定 → 鍵盤 → 輸入方式 → myDayi Mac"
echo "然後用 TextEdit 驗證組字（假引擎會把碼串上屏）。"
