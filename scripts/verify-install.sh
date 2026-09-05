#!/bin/sh
set -eu
APP="$HOME/Library/Input Methods/myDayiMac.app"
echo "APP=$APP"
ls -l "$APP/Contents/MacOS"
echo "----sign----"
codesign -dv --verbose=2 "$APP" 2>&1 | head -20
echo "----plist----"
plutil -p "$APP/Contents/Info.plist"
echo "----process----"
pgrep -lf myDayiMac || true
echo "----disk----"
df -h /System/Volumes/Data | tail -1
