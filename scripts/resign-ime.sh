#!/bin/sh
set -eu
ID="Apple Development: hctsaik@gmail.com (VCR7B4FU3X)"
ROOT="/Users/heather/code/myDayi-Mac"
APP="$ROOT/build/myDayiMac.app"
DEST="$HOME/Library/Input Methods/myDayiMac.app"

cd "$ROOT"
sh scripts/build-dev.sh
codesign --force --sign "$ID" --timestamp=none "$APP"
echo "--- signed build ---"
codesign -dv --verbose=2 "$APP" 2>&1 | head -20

killall myDayiMac 2>/dev/null || true
sleep 1
mkdir -p "$HOME/Library/Input Methods"
rm -rf "$DEST"
cp -R "$APP" "$DEST"
codesign --force --sign "$ID" --timestamp=none "$DEST"
xattr -cr "$DEST" 2>/dev/null || true
open "$DEST" || true
sleep 1
echo "--- assess ---"
spctl --assess -v "$DEST" 2>&1 || true
echo "--- tis ---"
SDK="$(xcrun --sdk macosx --show-sdk-path)"
swiftc -sdk "$SDK" -target arm64-apple-macosx15.0 -framework Carbon -o /tmp/list-input-sources "$ROOT/scripts/list-input-sources.swift"
/tmp/list-input-sources
echo "--- proc ---"
pgrep -lf myDayiMac || true
