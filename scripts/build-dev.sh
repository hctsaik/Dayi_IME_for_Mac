#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
BUILD="$ROOT/build"
APP="$BUILD/myDayiMac.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RES="$CONTENTS/Resources"

rm -rf "$BUILD"
mkdir -p "$MACOS" "$RES"

python3 - <<'PY'
from pathlib import Path
ppm = Path("build/icon.ppm")
ppm.write_bytes(b"P6\n16 16\n255\n" + bytes([0x1A, 0x3A, 0x6B] * (16 * 16)))
PY
sips -s format tiff "$BUILD/icon.ppm" --out "$RES/AppIcon.tiff" >/dev/null

swiftc \
  -module-name myDayiMac \
  -O \
  -sdk "$(xcrun --sdk macosx --show-sdk-path)" \
  -target arm64-apple-macosx15.0 \
  -framework AppKit \
  -framework Carbon \
  -framework InputMethodKit \
  -o "$MACOS/myDayiMac" \
  Sources/Engine/FakeEngine.swift \
  Sources/InputMethod/EventMapper.swift \
  Sources/InputMethod/InputController.swift \
  Sources/InputMethod/main.swift

cp Resources/Info.plist "$CONTENTS/Info.plist"
printf 'APPL????' > "$CONTENTS/PkgInfo"
codesign --force --sign - "$APP" >/dev/null

echo "built $APP"
plutil -p "$CONTENTS/Info.plist" | grep -E "CFBundleIdentifier|InputMethodConnectionName|InputMethodServerControllerClass"
