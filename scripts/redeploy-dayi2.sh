#!/bin/sh
set -eu
RIME="$HOME/Library/Rime"
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/squirrel-user"
DEPLOYER="/Library/Input Methods/Squirrel.app/Contents/MacOS/rime_deployer"
SHARED="/Library/Input Methods/Squirrel.app/Contents/SharedSupport"
DICT_MGR="/Library/Input Methods/Squirrel.app/Contents/MacOS/rime_dict_manager"

mkdir -p "$RIME"
for f in \
  dayi2.schema.yaml \
  dayi2.dict.yaml \
  mydayi_mac.schema.yaml \
  mydayi_boost.dict.yaml \
  common_words.dict.yaml \
  common_words_import.dict.yaml \
  common_words_table.dict.yaml \
  default.custom.yaml \
  squirrel.custom.yaml
do
  cp -f "$SRC/$f" "$RIME/$f"
  perl -pi -e 's/\r//g' "$RIME/$f"
done

killall Squirrel 2>/dev/null || true
sleep 1
"$DEPLOYER" --build "$RIME" "$SHARED"
if [ -f "$SRC/dayi2.userdb.export.txt" ]; then
  perl -pi -e 's/\r//g' "$SRC/dayi2.userdb.export.txt"
  (cd "$RIME" && "$DICT_MGR" -i dayi2 "$SRC/dayi2.userdb.export.txt") || true
fi
open "/Library/Input Methods/Squirrel.app"
echo "redeployed squirrel-user dictionaries"
