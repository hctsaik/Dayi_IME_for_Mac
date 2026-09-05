# Implementation rules

- Product: standalone native macOS input method; no Squirrel installation dependency.
- Read openspec/changes/add-native-macos-dayi/ before implementation.
- Treat reference/windows-baseline as immutable input. Do not edit the original Windows repository.
- Keep tasks unchecked until implementation, required validation, and evidence are complete.
- Do not read, upload, or package live user dictionaries or personal typing logs.
- Keep runtime offline and use an app-specific data directory.
- Do not overwrite another input method's files or user settings.
- Record actual macOS test environment and distinguish development builds from notarized releases.
- All product explanations and handoff notes should use Traditional Chinese.

