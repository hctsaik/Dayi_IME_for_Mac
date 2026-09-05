#!/bin/sh
set -eu
RIME="$HOME/Library/Rime"
SRC="/Users/heather/code/myDayi-Mac/squirrel-user"
DEPLOYER="/Library/Input Methods/Squirrel.app/Contents/MacOS/rime_deployer"
SHARED="/Library/Input Methods/Squirrel.app/Contents/SharedSupport"

cp -f "$SRC/dayi2.schema.yaml" "$RIME/dayi2.schema.yaml"
cp -f "$SRC/squirrel.custom.yaml" "$RIME/squirrel.custom.yaml"
perl -pi -e 's/\r//g' "$RIME/dayi2.schema.yaml" "$RIME/squirrel.custom.yaml"

killall Squirrel 2>/dev/null || true
sleep 1
"$DEPLOYER" --build "$RIME" "$SHARED"
open "/Library/Input Methods/Squirrel.app"
echo "redeployed dayi2 + squirrel.custom.yaml"
