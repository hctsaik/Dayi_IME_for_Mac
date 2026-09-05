#!/bin/sh
# Map Mac modifiers to Windows habits:
# physical Control -> Command (Ctrl+C copy)
# physical Command -> Control
# Persists via LaunchAgent. Undo: macos-windows-modifiers.sh undo
set -eu

MAPPING='{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x7000000E0,"HIDKeyboardModifierMappingDst":0x7000000E3},{"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E0},{"HIDKeyboardModifierMappingSrc":0x7000000E4,"HIDKeyboardModifierMappingDst":0x7000000E7},{"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x7000000E4}]}'
EMPTY='{"UserKeyMapping":[]}'
PLIST="$HOME/Library/LaunchAgents/local.mydayi.windows-modifiers.plist"
LABEL="local.mydayi.windows-modifiers"
UID_NUM="$(id -u)"

undo() {
  hidutil property --set "$EMPTY" >/dev/null
  launchctl bootout "gui/${UID_NUM}/${LABEL}" 2>/dev/null || true
  rm -f "$PLIST"
  echo "restored Mac default modifiers (Command is copy again)"
}

if [ "${1:-}" = "undo" ]; then
  undo
  exit 0
fi

mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>${LABEL}</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/bin/hidutil</string>
		<string>property</string>
		<string>--set</string>
		<string>${MAPPING}</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF

hidutil property --set "$MAPPING" >/dev/null
launchctl bootout "gui/${UID_NUM}/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/${UID_NUM}" "$PLIST"
echo "Control and Command swapped. Ctrl+C/V/X/Z/A/S now follow Windows."
echo "Undo: sh scripts/macos-windows-modifiers.sh undo"
