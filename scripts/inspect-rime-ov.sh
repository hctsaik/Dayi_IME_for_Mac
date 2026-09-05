#!/bin/sh
echo "=== enabled input sources ==="
defaults read com.apple.HIToolbox AppleEnabledInputSources
echo "=== ~/Library/Rime ==="
ls -la "$HOME/Library/Rime" 2>/dev/null || echo "NO_RIME_DIR"
echo "=== squirrel shared ==="
ls "/Library/Input Methods/Squirrel.app/Contents/SharedSupport" 2>/dev/null | head
echo "=== OV userdata ==="
find "$HOME/Library/Application Support/OpenVanilla" "$HOME/Library/OpenVanilla" -maxdepth 3 -type d 2>/dev/null
ls -la "$HOME/Library/Application Support/OpenVanilla" 2>/dev/null | head
echo "=== default.yaml if any ==="
ls "$HOME/Library/Rime/"*.yaml 2>/dev/null | head -40
