## ADDED Requirements

### Requirement: Persistent local learning
The application SHALL retain engine-supported user learning across restarts in its own application data directory as defined in docs/DATA-LIFECYCLE.md.

#### Scenario: Confirmed choice
- **GIVEN** a clean test profile offers multiple candidates
- **WHEN** the user repeatedly confirms a chosen test phrase then restarts
- **THEN** the learning entry remains available and engine learning behavior is verified separately from static regression.

### Requirement: Data and privacy isolation
The application SHALL keep user data separate from other IMEs, perform typing offline and omit typed text from diagnostic logs.

#### Scenario: Existing Rime data
- **GIVEN** another IME already has user data
- **WHEN** myDayi Mac learns words or records an engine error
- **THEN** the other IME files remain unchanged and no typed text or user dictionary is uploaded or logged.

### Requirement: Learning controls
The application SHALL provide pause/resume learning, deletion of a single learned phrase, undo of the latest learned write, and a confirmed full reset. Deleting a learned phrase SHALL NOT permanently ban the static dictionary form of that text. Reset SHALL close affected sessions first and SHALL keep backups by default.

#### Scenario: Delete one learned phrase
- **GIVEN** a test phrase exists only because it was learned
- **WHEN** the user deletes that learned phrase
- **THEN** it no longer ranks from userdb, bundled static dictionaries still work, and other IME data is untouched.

#### Scenario: Pause learning
- **GIVEN** learning is paused
- **WHEN** the user confirms candidates
- **THEN** userdb is not updated and previously learned entries remain usable.

### Requirement: Backup and restore
The application SHALL store numbered backups of settings and userdb, restore only compatible versions, refuse to clobber data on interrupted transactions, and preserve learned data on default uninstall.

#### Scenario: Interrupted restore
- **GIVEN** a valid backup and a restore transaction that fails mid-way
- **WHEN** the app next starts
- **THEN** the previous valid settings and userdb are recovered and `versions.json` returns to idle.

### Requirement: Windows live userdb migration deferred
The first edition SHALL NOT read or import a live Windows Weasel userdb. Bundled static custom phrases in the reference snapshot MAY be used as assets.

#### Scenario: No live import
- **GIVEN** a machine also has Windows Rime user data available over the network or disk
- **WHEN** myDayi Mac starts
- **THEN** it does not copy that live userdb into its application directory.
