#!/bin/sh
set -eu
RIME="$HOME/Library/Rime"
SRC="/Users/heather/code/myDayi-Mac/squirrel-user"
SHARED="/Library/Input Methods/Squirrel.app/Contents/SharedSupport"
DEPLOYER="/Library/Input Methods/Squirrel.app/Contents/MacOS/rime_deployer"
SQUIRREL="/Library/Input Methods/Squirrel.app"

mkdir -p "$RIME"
STAMP=$(date +%Y%m%d-%H%M%S)
cp -a "$RIME" "$HOME/Library/Rime.bak-$STAMP"
echo "backup $HOME/Library/Rime.bak-$STAMP"

cp -f "$SRC/mydayi_mac.schema.yaml" "$RIME/mydayi_mac.schema.yaml"
cp -f "$SRC/default.custom.yaml" "$RIME/default.custom.yaml"
cp -f "$SRC/dayi2.dict.yaml" "$RIME/dayi2.dict.yaml"
cp -f "$SRC/common_words_import.dict.yaml" "$RIME/common_words_import.dict.yaml"

perl -pi -e 's/\r//g' "$RIME/mydayi_mac.schema.yaml" "$RIME/default.custom.yaml"

killall Squirrel 2>/dev/null || true
sleep 1
"$DEPLOYER" --build "$RIME" "$SHARED"
open "$SQUIRREL"
echo "deployed mydayi_mac"
ls -l "$RIME/mydayi_mac.schema.yaml" "$RIME/dayi2.dict.yaml" "$RIME/common_words_import.dict.yaml"
