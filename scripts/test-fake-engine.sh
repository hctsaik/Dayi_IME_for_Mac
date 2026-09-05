#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="$ROOT/build/fake_engine_tests"
mkdir -p "$ROOT/build"
swiftc \
  -sdk "$(xcrun --sdk macosx --show-sdk-path)" \
  -target arm64-apple-macosx15.0 \
  -o "$OUT" \
  Sources/Engine/FakeEngine.swift \
  Tests/FakeEngineTests.swift
"$OUT"
