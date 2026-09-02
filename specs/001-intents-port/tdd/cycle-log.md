# Cycle Log: 001-intents-port

Append only. Newest last. The feature is **greenfield** — the package
reimplements the `zikzak_share_handler` plugin contract and no production
behavior existed at planning — so the cycles below follow the greenfield
shape: the whole 19-behavior suite is written first and its honest red is
the compile failure of the suite against the absent API (the compiler is
the oracle; no test ran green against an unimplemented contract), the
implementation then lands and the suite turns green, and each behavior's
teeth are separately proven with a deliberate mutant observed failing via
the profile's single command (`dart test test/intents_suite_test.dart
--plain-name "<id>:"`) and reverted byte-identically. Machine-readable
matrix: `tdd/mutant-run.md` (19/19 KILLED, 0 SURVIVED).

## Baseline

- suite: `dart test` -> 2 passed (init's bootstrap smoke + the day-zero
  scaffold placeholder test, the latter replaced by this feature)
- dependency state: resolves on a fresh clone — hosted `zuraffa ^6.1.0`
  (no path override needed; the `zikzak_session` conflict seen in
  `zuraffa_auth` does not apply), `analyzer: 14.1.0` override inherited
  from the scaffold, `mutation_test: ^1.8.0` already pinned by the
  maintainer at scaffold time following zuraffa#755 — confirmed, no
  change needed.
- baseline artifacts carried the inherited generator defect (stray-quote
  profile command bullets + `--name` Keys, per zuraffa#756): repaired
  first — commit `dae9003` precedes this feature's commits; the repair
  is the repo's misfire issue, cross-linked upstream.
- after repair: `dart pub get` resolves, `dart analyze` clean,
  `dart test` -> 2 passed, commit `cd0517a` tree + repair
- recorded: cycle 0, before any feature change

## Cycle 1: the red — 19-behavior suite against the absent API

- tests: `test/intents_suite_test.dart` U1–U19 (all new), importing the
  package barrel only
- red: `dart test test/intents_suite_test.dart` -> loading failure, 0
  run. First errors (abridged):
  - `Error: Type 'ShareIntentPort' not found.` (line 17)
  - `Error: Type 'SharedMedia' not found.` (lines 19/26/54/57)
  - `Error: Undefined name 'SharedAttachmentType'.` (line 60)
  - `Error: Method not found: 'SharedAttachment'.` (line 59)
- interpretation: every behavior references the contract it pins; the
  suite cannot compile, so no behavior can falsely pass before
  implementation exists. This is the greenfield honest red.
- spec/test-list/tasks committed alongside the suite in this state of
  the working tree; implementation started only after the red was
  recorded.

## Cycle 2: the green — implementation lands

- implementation: `SharedAttachmentType` (+ enums barrel), zorphy
  entities `SharedAttachment` / `SharedMedia`
  (`@Zorphy(generateJson: true)`, generated `.zorphy.dart`/`.g.dart`
  committed), `ShareIntentPort`, `InMemoryShareIntentAdapter`,
  `ShareIntentService` + `registerShareIntentDependencies`; scaffold
  placeholder (`Awesome`) and its test replaced; example and README
  refreshed; `get_it` promoted to a direct dependency (the composition
  root imports it; `depend_on_referenced_packages` under lints 6).
- fixture fix during green (recorded, not silently folded in): U19
  caught the scripted port returning a NEW stream view per access —
  `StreamController.stream` is a fresh view on every call. The port
  contract (FR-008) requires a stable per-port stream instance (the
  plugin's `_sharedMediaStream ??=`), so the fake now memoizes its
  stream with `late final`. The production adapter already honored this
  (U15); the fixture was the only invalid participant.
- green: `dart test` -> 20 passed (1 bootstrap smoke + 19 suite),
  `dart analyze` -> No issues found
- commit: `52186ac`

## Cycles 3–21: deliberate-mutant audit (one cycle per behavior, U1–U19)

Protocol per cycle: baseline targeted run must PASS on the clean tree →
inject the deliberate mutant (anchor must be unique in the subject
file) → targeted run via `--plain-name "<id>:"` must FAIL → revert via
`git checkout -- <file>` → byte-for-byte revert verification. Runner:
`scripts/mutant_matrix_intents.py` (agent workspace). All 19 rows:
baseline PASS | mutant KILLED | revert ok — full matrix and mutant
descriptions in `tdd/mutant-run.md`.

- U1 — enum name mutated (`audio` → `sound`): vocabulary assertion
  fails. KILLED.
- U2 — attachment `copyWith` ignores the new `type`: type-only
  replacement assertion fails. KILLED.
- U3 — attachment `==` drops the `type` check: different-type
  inequality assertion fails. KILLED.
- U4 — attachment `toJson` emits a constant path: round-trip path
  assertion fails. KILLED.
- U5 — media `toJson` emits a constant `senderIdentifier`:
  full-fidelity round-trip assertion fails. KILLED.
- U6 — media `toJson` loses the null-aware entry for `subject`:
  absent-field omission assertion fails. KILLED.
- U7 — media `copyWith` ignores the new `attachments`: wholesale
  replacement assertion fails. KILLED.
- U8 — media `==` drops the `conversationIdentifier` check:
  different-identifier inequality assertion fails. KILLED.
- U9 — adapter `getInitialSharedMedia` fabricates a default media:
  fresh-adapter null assertion fails. KILLED.
- U10 — adapter `storeInitial` stores null: verbatim serving assertion
  fails. KILLED.
- U11 — adapter `resetInitialSharedMedia` becomes a no-op:
  clear-after-reset assertion fails. KILLED.
- U12 — adapter maps `conversationIdentifier` into
  `speakableGroupName`: mapping assertion fails. KILLED.
- U13 — adapter prepends records instead of appending: call-order
  assertion fails. KILLED.
- U14 — adapter controller degrades from broadcast to
  single-subscription: second listener registration fails. KILLED.
- U15 — adapter stream getter rebuilds per access: stream-identity
  assertion fails. KILLED.
- U16 — adapter `emit` double-fires: event-sequence assertion fails.
  KILLED.
- U17 — service `getInitialSharedMedia` bypasses the port:
  delegation assertion fails. KILLED.
- U18 — service drops `serviceName` from the recordSentMessage
  pass-through: verbatim pass-through assertion fails. KILLED.
- U19 — service stream getter returns an empty stream instead of the
  port's: stream-identity assertion fails. KILLED.

Matrix: **19/19 KILLED, 0 SURVIVED**, all reverts byte-identical.
