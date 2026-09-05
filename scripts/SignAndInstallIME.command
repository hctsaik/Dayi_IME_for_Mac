#!/bin/sh
set -e
ID="Apple Development: hctsaik@gmail.com (VCR7B4FU3X)"
APP="/Users/heather/code/myDayi-Mac/build/myDayiMac.app"
DEST="$HOME/Library/Input Methods/myDayiMac.app"

cd /Users/heather/code/myDayi-Mac
echo "Building..."
sh scripts/build-dev.sh
echo "Signing with $ID ..."
codesign --force --sign "$ID" --options runtime --timestamp=none --entitlements /Users/heather/code/myDayi-Mac/Resources/myDayiMac.entitlements "$APP" || \
  codesign --force --sign "$ID" --options runtime --timestamp=none "$APP"
codesign -dv --verbose=2 "$APP"

killall myDayiMac 2>/dev/null || true
sleep 1
mkdir -p "$HOME/Library/Input Methods"
rm -rf "$DEST"
cp -R "$APP" "$DEST"
xattr -cr "$DEST" || true
open "$DEST"
sleep 1
echo "Installed $DEST"
echo "Now reopen: System Settings → Keyboard → Input Sources → Add"
echo "Look for myDayi Mac (Traditional Chinese)."
read -p "Press Enter to close..."
