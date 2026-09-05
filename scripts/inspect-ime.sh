#!/bin/sh
set -e
APP="$HOME/Library/Input Methods/myDayiMac.app"
echo "APP=$APP"
ls -ld "$APP" "$APP/Contents" "$APP/Contents/MacOS" "$APP/Contents/Resources" || true
echo "--- files ---"
find "$APP" -type f -print
echo "--- plist ---"
plutil -p "$APP/Contents/Info.plist"
echo "--- sign ---"
codesign -dv --verbose=2 "$APP" 2>&1 | head -25
echo "--- quarantine ---"
xattr -l "$APP" || true
echo "--- proc ---"
pgrep -lf myDayiMac || echo NOT_RUNNING
echo "--- lsregister ---"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump 2>/dev/null | grep -A4 tw.mydayi.mac.dev || echo "not in lsregister dump"
echo "--- log ---"
log show --last 10m --style compact --predicate 'eventMessage CONTAINS[c] "myDayi" OR eventMessage CONTAINS[c] "mydayi" OR process == "myDayiMac"' 2>/dev/null | tail -30 || true
