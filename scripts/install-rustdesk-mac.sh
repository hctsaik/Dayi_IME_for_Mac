#!/bin/sh
set -eu
DMG="/Users/heather/Downloads/rustdesk-1.4.9-aarch64.dmg"
xattr -dr com.apple.quarantine "$DMG" 2>/dev/null || true
ATTACH_OUT="$(hdiutil attach -nobrowse -readonly "$DMG")"
echo "$ATTACH_OUT"
MNT="$(printf '%s\n' "$ATTACH_OUT" | awk '/\/Volumes\//{print $NF; exit}')"
echo "MNT=$MNT"
ls -la "$MNT"
APP="$(find "$MNT" -maxdepth 2 -name 'RustDesk.app' -print -quit)"
echo "APP=$APP"
if [ -w /Applications ]; then
  DEST="/Applications/RustDesk.app"
else
  mkdir -p /Users/heather/Applications
  DEST="/Users/heather/Applications/RustDesk.app"
fi
rm -rf "$DEST"
ditto "$APP" "$DEST"
xattr -cr "$DEST" 2>/dev/null || true
hdiutil detach "$MNT" >/dev/null
echo "INSTALLED=$DEST"
ls -ld "$DEST"
codesign -dv "$DEST" 2>&1 | head -15
open "$DEST" || true
echo "opened"
