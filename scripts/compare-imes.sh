#!/bin/sh
set -e
echo "=== OpenVanilla sign ==="
codesign -dv "$HOME/Library/Input Methods/OpenVanilla.app" 2>&1 | head -12 || true
echo "=== Squirrel sign ==="
codesign -dv "/Library/Input Methods/Squirrel.app" 2>&1 | head -12 || true
echo "=== DayiInputMethod sign ==="
codesign -dv "/Library/Input Methods/DayiInputMethod.app" 2>&1 | head -12 || true
echo "=== OpenVanilla plist ==="
plutil -p "$HOME/Library/Input Methods/OpenVanilla.app/Contents/Info.plist" | head -80
echo "=== Squirrel plist keys ==="
plutil -p "/Library/Input Methods/Squirrel.app/Contents/Info.plist" | grep -E "CFBundleIdentifier|InputMethod|TISIntended|Script|LSUI|LSBack|Controller|Delegate|Component|tsInput" 
echo "=== DayiInputMethod plist keys ==="
plutil -p "/Library/Input Methods/DayiInputMethod.app/Contents/Info.plist" | grep -E "CFBundleIdentifier|InputMethod|TISIntended|Script|LSUI|LSBack|Controller|Delegate|Component|tsInput|CFBundleName"
echo "=== dayi cin ==="
ls -l "$HOME/Library/Input Methods/dayi2.cin"
echo "=== compile dump ==="
SDK=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
swiftc -sdk "$SDK" -target arm64-apple-macosx15.0 -framework Carbon -o /tmp/dump-im /tmp/dump-im-sources.swift
/tmp/dump-im | grep -iE "openvanilla|squirrel|dayi|mydayi|rime|ovim" || true
echo "=== im method count ==="
/tmp/dump-im | grep "^IM " | wc -l
