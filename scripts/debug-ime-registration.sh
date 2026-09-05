#!/bin/sh
set -e
APP="$HOME/Library/Input Methods/myDayiMac.app"
echo "=== user IM dir ==="
ls -la "$HOME/Library/Input Methods" || true
echo "=== system IM dir ==="
ls -la "/Library/Input Methods" || true
echo "=== sign ==="
codesign -dv --verbose=2 "$APP" 2>&1 | head -20
echo "=== spctl ==="
spctl --assess -v "$APP" 2>&1 || true
echo "=== entitlements ==="
codesign -d --entitlements - "$APP" 2>&1 | head -30
echo "=== plist keys ==="
plutil -p "$APP/Contents/Info.plist"
echo "=== proc ==="
pgrep -lf myDayiMac || echo NOT_RUNNING
echo "=== log imk ==="
log show --last 30m --style compact --predicate 'eventMessage CONTAINS "tw.mydayi" OR eventMessage CONTAINS "Input Method" AND eventMessage CONTAINS "mydayi"' 2>/dev/null | tail -20 || true
