#!/bin/sh
set -e
echo "--- rustdesk procs ---"
pgrep -lf RustDesk || true
echo "--- open privacy panes ---"
open "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility" || true
sleep 1
open "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ListenEvent" || true
echo "--- screenshot ---"
screencapture -x /tmp/rustdesk-perm.png
ls -l /tmp/rustdesk-perm.png
echo "--- tcc user db ---"
sqlite3 "$HOME/Library/Application Support/com.apple.TCC/TCC.db" \
  "SELECT service, client, auth_value FROM access WHERE client LIKE '%RustDesk%' OR client LIKE '%carriez%';" \
  2>&1 || true
