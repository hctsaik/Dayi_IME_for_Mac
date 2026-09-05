#!/bin/sh
set -eu
cd /tmp
curl -fsSL -o AppleWWDRCAG3.cer "https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer"
curl -fsSL -o AppleRootCA-G3.cer "https://www.apple.com/certificateauthority/AppleRootCA-G3.cer"
security add-certificates AppleWWDRCAG3.cer 2>/dev/null || true
security add-certificates AppleRootCA-G3.cer 2>/dev/null || true
# Trust WWDR G3 for code signing in the user domain (no sudo).
security add-trusted-cert -r unspecified -p codeSign AppleWWDRCAG3.cer 2>/dev/null || \
  security add-trusted-cert -d -r unspecified -p codeSign AppleWWDRCAG3.cer 2>/dev/null || true
echo "--- verify after import ---"
security find-certificate -c "Apple Development: hctsaik@gmail.com" -p > /tmp/dev.pem
security verify-cert -c /tmp/dev.pem 2>&1 || true
echo "--- identities ---"
security find-identity -v -p codesigning
