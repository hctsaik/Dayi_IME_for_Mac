## ADDED Requirements

### Requirement: Native system input source
The application SHALL register as a native macOS input source and operate without Squirrel installed. The first verified target SHALL be the user's Mac M4 running its detected macOS version; unverified OS versions SHALL NOT be claimed as supported.

#### Scenario: Clean installation
- **GIVEN** a supported Mac has no Squirrel installation
- **WHEN** the user installs and enables myDayi Mac
- **THEN** TextEdit accepts composition and committed text through the system input source.

### Requirement: Dual keyboard profiles
The application SHALL implement `windows-compatible` as the default profile and `mac-optional` as a selectable persisted profile, following docs/KEYBOARD-CONTRACT.md. Switching profiles SHALL cancel the current composition without inserting raw codes.

#### Scenario: Default Windows Tab
- **GIVEN** the windows-compatible profile is active and the client is idle
- **WHEN** the user presses Tab
- **THEN** ascii_mode toggles and a Tab character is not inserted.

#### Scenario: Mac optional Tab
- **GIVEN** the mac-optional profile is active and composition is in progress
- **WHEN** the user presses Tab
- **THEN** composition is cancelled without commit and Tab is delivered to the host for navigation.

### Requirement: Synchronous event transaction
The application SHALL decide consumed, call the engine on the serialized engine queue, copy results, release C objects, apply insert/mark/candidates, and return from the IMK callback in one transaction as defined in docs/EVENT-CONTRACT.md. Asynchronous engine completion SHALL NOT change whether the original key is passed to the host.

#### Scenario: Key during maintenance
- **GIVEN** dictionary deployment is queued
- **WHEN** the user presses a Dayi key
- **THEN** the key transaction completes without waiting for deployment, and deployment runs only when no input transaction is active.

### Requirement: Composition and session lifetime
The application SHALL isolate each client's composition, submit each engine commit exactly once, convert engine UTF-8 offsets to valid Cocoa UTF-16 ranges, and treat Escape, client deactivate, input-source switch, host commit, host cancel, and selection change as distinct events per docs/EVENT-CONTRACT.md.

#### Scenario: Client switches
- **GIVEN** client A contains uncommitted text
- **WHEN** the user switches to client B or another input source
- **THEN** A's pending composition is cancelled, candidates disappear, and no pending text is committed to B.

#### Scenario: Host cancel does not leak codes
- **GIVEN** marked text shows Dayi codes or candidates
- **WHEN** the host calls cancelComposition
- **THEN** raw codes are not inserted and the document does not receive the preedit string as committed text.

### Requirement: Candidate tokens
The application SHALL tag candidate keyboard, mouse, and paging actions with client, session, generation, composition, epoch, page, and index. Stale tokens SHALL be ignored. At most eight candidates SHALL be shown per page. Digits SHALL be codes, not selection indices. Shift+A through Shift+H SHALL select the current page items.

#### Scenario: Stale mouse click
- **GIVEN** the candidate list has been replaced and epoch has advanced
- **WHEN** the user clicks a previous-page visual item or stale token
- **THEN** no commit occurs and the current composition remains consistent.

### Requirement: VS Code host scenes
The application SHALL pass composition, candidate placement without stealing focus, single commit, and client-switch cancellation on VS Code editor, integrated terminal, search field, and rename field, in addition to the broader A11 matrix.

#### Scenario: Editor to search
- **GIVEN** composition is active in the VS Code editor
- **WHEN** the user focuses the search field
- **THEN** no uncommitted codes are committed into the search field.

### Requirement: Deferred phonetic lookup and simplification
The first edition SHALL NOT offer phonetic reverse lookup or traditional/simplified switching. Unused reverse-lookup prefixes and simplification shortcuts SHALL pass through to the host.

#### Scenario: Tilde is not reverse lookup
- **GIVEN** Chinese mode is active
- **WHEN** the user types ~
- **THEN** the engine does not enter Phonetic_tw reverse lookup because that dependency is not shipped.
