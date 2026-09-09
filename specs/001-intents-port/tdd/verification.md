# TDD Verification — feature `001-intents-port`

Generated fresh by `zfa tdd verify --feature 001-intents-port`.

## Gate

- gate: `pass`

## Mutation buckets (FR-014)

- killed: 44
- survived: 0
- timed_out: 0

## Behavior scope (FR-018)

- `A1` — traces: `AC-1`
- `A2` — traces: `AC-2`
- `A3` — traces: `AC-3`
- `A4` — traces: `AC-4`
- `A5` — traces: `AC-5`
- `A6` — traces: `AC-6`
- `A7` — traces: `AC-7`
- `A8` — traces: `AC-8`
- `U1` — traces: `FR-001, SharedAttachmentType`
- `U2` — traces: `FR-002, SharedAttachment`
- `U3` — traces: `FR-003, SharedAttachment`
- `U4` — traces: `FR-004, SharedMedia`
- `U5` — traces: `FR-005, SharedMedia`
- `U6` — traces: `FR-006, ShareIntentPort.sharedMediaStream`
- `U7` — traces: `FR-007, ShareIntentPort.sharedMediaStream`
- `U8` — traces: `FR-008, ShareIntentPort.sharedMediaStream`
- `U9` — traces: `FR-009, ShareIntentService.sharedMediaStream`

## Behavior kinds (issue #1376)

- presence: 0
- absence: 0
- route-outcome: 0
- enabled-state: 0
- sequence: 0

- `A1` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart
- `A2` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart
- `A3` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart
- `A4` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart
- `A5` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart
- `A6` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart
- `A7` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart
- `A8` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart
- `U1` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart
- `U2` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart
- `U3` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart
- `U4` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart
- `U5` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart
- `U6` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart
- `U7` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart
- `U8` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart
- `U9` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart

## Restoration (FR-021)

- restoration_verified: true
- restoration_scope_count: 17
- restoration_scope (subjects only, never tests):
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a1_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a2_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a3_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a4_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a5_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a6_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a7_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a8_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u1_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u2_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u3_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u4_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u5_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u6_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u7_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u8_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u9_subject.dart`

## Repro diagnostics (FR-020, non-sensitive)

- runner_command: `dart run mutation_test`
- exit_code: 0
- elapsed_seconds: 786
- report_path: `/Users/arrrrny/Developer/zuraffa_intents/.dart_tool/zfa/tdd-verify-report/mutation-test-report.md`
- preflight_scope_ran (bug #924, per-behavior):
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart`

## Mutation run

- mutation_was_run: true
- mutation_score: 1.0000

## Evidence binding (bug #837)

- spec_hash: 116f05f952dc1b50e305041eb00fe248025367c316cd694ee43ef75452ebc647
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a1_subject.dart` f0561331f2bd00c7bb570709c9efd487a7ce7717c14d22c15e062d78696172ad
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a2_subject.dart` 4b66034e513b5f3c77fed21a0fa7238f912cc6bd70425eaedd75243723e7c5c5
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a3_subject.dart` 78adc91146e6d3c3eef44b998c7245e3d60268a60488447d647ce0fc1c180762
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a4_subject.dart` 5e357d65dbb808669687752f5ad40924b9e3116b7a31d4f524ff9486a2c84c8f
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a5_subject.dart` 7c0dce1d15339b8ead212f9244f94995cec0683653e0fd147d3abd6fa05d1f57
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a6_subject.dart` 96ea1ff5195c8ee082cf2a4faded934f77f048bdfe683e428f930cafb44da862
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a7_subject.dart` 380cd12cd5d5c2ed87a179748322ae9a168bf79333ea2c296404826f44a09328
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/a8_subject.dart` 1beaeb65fd87c431fbd3900017d3341583a01cd4d78c0d9ede8e73ff3a12bc94
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u1_subject.dart` 65725f6960ebc78ed2746c606397dabbe052511395340eaf2f756b1afe5d2f28
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u2_subject.dart` ab82d0fa254a0c23347d1b38aebdea2b3ccd3cf0b83f2e741bd5f97ad2ca6c69
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u3_subject.dart` d0f34ffee061ca33debb799c7134f85649481fd0514e6e2533bdba253aa1ff87
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u4_subject.dart` e288cb6959e1152e47f7b0be456d9722ae9bca11e61b938034679d304eb0067e
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u5_subject.dart` 6cbfd983650c6c4cf2928f125d183632b5998c61e949da92fb561999bf46cd1c
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u6_subject.dart` 3282bc2c0e38e42d8751c0dbe72a6d49bd759521fafe91190ca4ef553673beaa
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u7_subject.dart` 028f35143436254c194ad4bd3cdeda881037206b01a44b1ab0a18f0ad42ca22b
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u8_subject.dart` 154078d75df2fda85e0f6195af92f879baa91e81246cee48812ecc3df43a0dc5
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/001-intents-port/u9_subject.dart` a970090b446a2f7fb1d56064a56bb62b73f9e0ffbf449fe5678fe93b97a0eb7d
