## ADDED Requirements

### Requirement: Bundled offline engine
The application SHALL bundle a version-pinned librime engine and complete runtime resources and SHALL NOT require an external Rime installation.

#### Scenario: Offline first use
- **GIVEN** the application and its resources are installed
- **WHEN** the machine is offline and the user activates the input source
- **THEN** the engine initializes and generates candidates without external downloads.

### Requirement: Preserved dictionary semantics
The application SHALL preserve frozen Dayi character mappings, weights and phrase imports and support continuous multi-character input without per-character confirmation. One-code and two-code syllables MAY mix in one composition; the implementation SHALL NOT hard-code a “always split every two codes” rule.

#### Scenario: Continuous phrase
- **GIVEN** the frozen dictionaries are loaded
- **WHEN** the user enters v5e5 without intervening spaces
- **THEN** 程式 is available as a phrase candidate and can be committed through normal candidate selection.

#### Scenario: Mixed code length
- **GIVEN** the frozen dictionaries are loaded
- **WHEN** the user enters v5 followed by /.
- **THEN** 我 and 的 remain reachable in the same composition path and already committed text is not discarded because the remaining code length is odd.

### Requirement: Explicit first-edition resource closure
The first edition SHALL omit Phonetic_tw reverse lookup, omit simplifier/OpenCC switching, omit disabled legacy Lua rules, and SHALL validate every referenced preset, dictionary and runtime resource. Missing sinica sources SHALL NOT block using the frozen dictionary artifacts for private development.

#### Scenario: Missing dependency
- **GIVEN** a packaged resource is missing or corrupt
- **WHEN** initialization or compilation runs
- **THEN** the app reports a resource error, does not use a partial deployment, and allows recovery to the prior valid resources.

### Requirement: Engine ownership and maintenance
The application SHALL serialize engine lifecycle operations, release engine-owned objects and keep maintenance from corrupting active sessions.

#### Scenario: Maintenance with an active client
- **GIVEN** an engine session exists
- **WHEN** a dictionary deployment is requested
- **THEN** the app safely suspends or defers deployment and creates valid sessions only after deployment completes.
