# Tasks: 001-intents-port

> Greenfield reimplementation of the `zikzak_share_handler` contract in
> pure Dart. Order honors the red→green discipline: the suite is written
> first (compiling against an absent API is the honest red), then the
> implementation lands, then the deliberate-mutant audit proves every test
> can fail.

## 1. Setup

- [x] 1.1 Repair tdd-init baseline: profile command bullets (stray trailing
      quotes) and Keys `--plain-name` alignment (upstream zuraffa#756);
      verify `mutation_test ^1.8.0` pin (already applied at scaffold time,
      zuraffa#755); confirm `dart test` green on the day-zero scaffold.
      → commit dae9003

## 2. Specification

- [x] 2.1 Write `specs/001-intents-port/spec.md` (9 FRs covering the
      plugin contract: attachment vocabulary, entity contracts + JSON
      round-trips, initial-share lifecycle, recordSentMessage mapping,
      stream semantics, service facade + composition root).
- [x] 2.2 Derive `specs/001-intents-port/tdd/test-list.md` (19 behaviors,
      U1–U19, grouped by owning component).

## 3. Red — failing suite first

- [x] 3.1 Write `test/intents_suite_test.dart` (U1–U19) importing the
      package barrel; run the profile's suite command and observe the red
      (compile failure against the not-yet-written API).
- [x] 3.2 Record the per-cycle red protocol in
      `specs/001-intents-port/tdd/cycle-log.md`.

## 4. Green — make the suite pass

- [x] 4.1 `SharedAttachmentType` enum + enums barrel (FR-001).
- [x] 4.2 `SharedAttachment` and `SharedMedia` zorphy entities
      (`@Zorphy(generateJson: true)`), run `dart run build_runner build
      --delete-conflicting-outputs`, commit generated `.zorphy.dart`/`.g.dart`
      (FR-002..FR-005).
- [x] 4.3 `ShareIntentPort` (domain seam) (FR-006..FR-009).
- [x] 4.4 `InMemoryShareIntentAdapter` (pure-Dart driver stand-in:
      initial-share store, sent-message records, broadcast controller)
      (FR-006..FR-008).
- [x] 4.5 `ShareIntentService` facade + `registerShareIntentDependencies`
      GetIt composition root (FR-009).
- [x] 4.6 Replace the scaffold barrel and placeholder (`Awesome`) and its
      test; refresh `example/zuraffa_intents_example.dart` and `README.md`.
- [x] 4.7 `dart test` green (19/19 suite + baseline smoke),
      `dart analyze` clean.

## 5. Mutant audit

- [x] 5.1 Deliberate-mutant matrix over `lib/` (one mutant per behavior;
      targeted test must fail via `--plain-name "<id>:"`; revert must be
      byte-identical). Require 0 SURVIVED.
- [x] 5.2 Record the matrix in `specs/001-intents-port/tdd/mutant-run.md`.

## 6. Verification

- [x] 6.1 `specs/001-intents-port/tdd/verification.md` with frontmatter
      (suite counts, mutant verdict) and the PASS/FAIL judgment against
      all 9 FRs.
