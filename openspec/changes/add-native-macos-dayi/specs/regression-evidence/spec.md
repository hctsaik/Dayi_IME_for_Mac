## ADDED Requirements

### Requirement: Golden keystroke traces
The project SHALL keep at least thirty reviewable golden traces in docs/GOLDEN-TRACES.md and docs/fixtures/golden-traces.json covering mixed 1/2-code input, phrases, CJK/ASCII/punctuation, unknown codes, tails, segment selection, edits, cancel, focus change, and VS Code scenes. All `frontend` and `lexicon` traces SHALL pass before a ranking baseline may be frozen.

#### Scenario: Frontend gate
- **GIVEN** the golden fixture file is loaded
- **WHEN** native or headless harnesses execute traces with gate frontend or lexicon
- **THEN** every such trace matches expected consumed/commit/candidate visibility and none substitutes the first candidate for an empty commit.

### Requirement: Deterministic static engine fixtures
The project SHALL freeze corpus revision, variant, parsed cases, resource hashes and engine version and isolate learning when measuring static results.

#### Scenario: Repeated corpus run
- **GIVEN** the same frozen fixture and engine inputs exist
- **WHEN** static regression executes twice with clean profiles
- **THEN** case counts and results match and both reports identify all input hashes and continuous-code mode.

### Requirement: Bridge parity and calibrated baseline
The application bridge SHALL match the headless engine on identical fixtures, candidates and commits and report calibrated overall, phrase and character accuracy. Historical Windows percentages SHALL be reference-only. The first Mac full-run result SHALL NOT become the frozen baseline until golden gates pass and a quality review is recorded.

#### Scenario: Bridge comparison
- **GIVEN** the headless and bridge runners use identical engine assets and session policy
- **WHEN** the full fixture suite executes
- **THEN** results match per case and measured Mac KPIs are recorded without claiming historical Windows numbers as current evidence.

### Requirement: Native evidence and release gates
The project SHALL retain environment-specific results for docs/ACCEPTANCE.md and distinguish unavailable tests from passing tests. Absence of Mac SSH or Xcode SHALL leave native gates unchecked.

#### Scenario: No Mac runner
- **GIVEN** documentation and portable checks pass on Windows
- **WHEN** a handoff or completion report is produced
- **THEN** native input, installation, performance and notarization remain explicitly unverified until supported Mac evidence exists.
