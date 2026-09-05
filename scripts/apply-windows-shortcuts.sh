#!/bin/sh
# Use Karabiner so Ctrl+C/V/X/Z/A/S become Command equivalents.
# This works for local keys and typical remote-desktop Control events.
# Also removes the hidutil Control<->Command swap that fought Karabiner.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/scripts/karabiner-windows-shortcuts.json"
CFG="$HOME/.config/karabiner/karabiner.json"
CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

if [ ! -f "$SRC" ]; then
  echo "missing $SRC" >&2
  exit 1
fi

# Undo hidutil swap if present.
if [ -x "$ROOT/scripts/macos-windows-modifiers.sh" ]; then
  sh "$ROOT/scripts/macos-windows-modifiers.sh" undo || true
fi
hidutil property --set '{"UserKeyMapping":[]}' >/dev/null || true

mkdir -p "$HOME/.config/karabiner"
if [ -f "$CFG" ]; then
  cp "$CFG" "$CFG.bak-$(date +%Y%m%d-%H%M%S)"
fi
cp "$SRC" "$CFG"
perl -pi -e 's/\r//g' "$CFG"

if [ -x "$CLI" ]; then
  "$CLI" --reload-karabiner-json || "$CLI" --reload || true
fi
killall karabiner_console_user_server 2>/dev/null || true
open -a "Karabiner-Elements" || true
echo "Karabiner Windows shortcuts applied (Ctrl+C/V/X/Z/A/S/F/W, Ctrl+Y redo)."
echo "If prompted, allow Input Monitoring for Karabiner."
