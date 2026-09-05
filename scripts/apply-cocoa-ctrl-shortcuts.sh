#!/bin/sh
# Cocoa menu shortcuts: Ctrl+C/V/X/Z/A/S like Windows.
# This layer sees Control even when hidutil/Karabiner miss remote-desktop events.
set -eu
defaults write -g NSUserKeyEquivalents -dict-add \
  "Undo" "^z" \
  "Redo" "^y" \
  "Copy" "^c" \
  "Paste" "^v" \
  "Cut" "^x" \
  "Select All" "^a" \
  "Save" "^s" \
  "Save As..." "^\$s" \
  "Find..." "^f" \
  "Find" "^f" \
  "Close" "^w" \
  "復原" "^z" \
  "還原" "^z" \
  "重做" "^y" \
  "複製" "^c" \
  "拷貝" "^c" \
  "貼上" "^v" \
  "剪下" "^x" \
  "全選" "^a" \
  "儲存" "^s" \
  "關閉" "^w" \
  "關閉視窗" "^w" \
  "尋找" "^f" \
  "尋找..." "^f" \
  "尋找…" "^f"
# Show current
defaults read -g NSUserKeyEquivalents
echo "Cocoa Ctrl shortcuts written. Reopen apps (TextEdit) to pick them up."
