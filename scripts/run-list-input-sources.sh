#!/bin/sh
set -eu
cd /Users/heather/code/myDayi-Mac
SDK="$(xcrun --sdk macosx --show-sdk-path)"
swiftc -sdk "$SDK" -target arm64-apple-macosx15.0 -framework Carbon -o /tmp/list-input-sources scripts/list-input-sources.swift
/tmp/list-input-sources
