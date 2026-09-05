## ADDED Requirements

### Requirement: Reproducible self contained build
The project SHALL document pinned toolchain and dependency inputs and produce a self-contained arm64 development build for the verified Mac M4 macOS version. Detection of that OS/Xcode SHALL be recorded before native gates are checked.

#### Scenario: Clean development build
- **GIVEN** a supported Mac has the documented build prerequisites
- **WHEN** the documented build procedure runs from a clean checkout
- **THEN** the app builds without undocumented absolute paths or unbundled runtime dependencies.

### Requirement: Versioned app resources settings and userdb
The installer and runtime SHALL track app, resources, settings and userdb versions separately, deploy resources transactionally, and recover the last valid set after failed updates, disk-full errors or crashes as specified in docs/DATA-LIFECYCLE.md.

#### Scenario: Interrupted update
- **GIVEN** a working prior version and learning data exist
- **WHEN** a new app or resource deployment fails validation
- **THEN** the previous valid version and user learning remain recoverable and other input methods are unchanged.

### Requirement: Uninstall data retention
The application SHALL document removal of its own input source and bundle and preserve learned data by default.

#### Scenario: Default uninstall
- **GIVEN** the app contains learned data
- **WHEN** the user follows the standard uninstall procedure
- **THEN** the app is removed and learning data remains unless the user separately requests its deletion.

### Requirement: Public release evidence
A public release SHALL include applicable dictionary and dependency permission records, correct Developer ID signing and notarization evidence, and clean-machine validation. Private daily-use development builds MAY proceed without notarization.

#### Scenario: Credentials or rights unavailable
- **GIVEN** a development build works locally
- **WHEN** public signing credentials or distribution rights are unresolved
- **THEN** the artifact is labelled development-only and the public release gate remains incomplete.
