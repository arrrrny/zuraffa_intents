# TDD Verification — feature `002-publishable-plugin`

Generated fresh by `zfa tdd verify --feature 002-publishable-plugin`.

## Gate

- gate: `pass`

## Mutation buckets (FR-014)

- killed: 7
- survived: 0
- timed_out: 0

## Behavior scope (FR-018)

- `U2` — traces: `FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap`
- `A6` — traces: `AC-6`
- `A7` — traces: `AC-7`
- `A8` — traces: `AC-8`
- `U1` — traces: `FR-001, publishability`
- `U3` — traces: `FR-003, ShareIntentsApiCodec.decodeMessage`
- `U4` — traces: `FR-004, decodeSharedMedia.decodeSharedMedia`
- `U5` — traces: `FR-005, MethodChannelShareIntentPort.getInitialSharedMedia`
- `U6` — traces: `FR-006, MethodChannelShareIntentPort.recordSentMessage`
- `U7` — traces: `FR-007, MethodChannelShareIntentPort.resetInitialSharedMedia`
- `U8` — traces: `FR-008, MethodChannelShareIntentPort.sharedMediaStream`
- `U9` — traces: `FR-009, ShareIntentService.platform`
- `U10` — traces: `FR-010, native consistency`
- `A1` — traces: `AC-1`
- `A2` — traces: `AC-2`
- `A3` — traces: `AC-3`
- `A4` — traces: `AC-4`
- `A5` — traces: `AC-5`

## Behavior kinds (issue #1376)

- presence: 0
- absence: 0
- route-outcome: 0
- enabled-state: 0
- sequence: 0

- `U2` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart
- `A6` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart
- `A7` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart
- `A8` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart
- `U1` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart
- `U3` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart
- `U4` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart
- `U5` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart
- `U6` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart
- `U7` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart
- `U8` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart
- `U9` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart
- `U10` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart
- `A1` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart
- `A2` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart
- `A3` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart
- `A4` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart
- `A5` — not traced: no scenario-assertions header in /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart

## Restoration (FR-021)

- restoration_verified: true
- restoration_scope_count: 18
- restoration_scope (subjects only, never tests):
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a1_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a2_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a3_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a4_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a5_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a6_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a7_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a8_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u10_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u1_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u2_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u3_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u4_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u5_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u6_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u7_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u8_subject.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u9_subject.dart`

## Repro diagnostics (FR-020, non-sensitive)

- runner_command: `dart run mutation_test`
- exit_code: 0
- elapsed_seconds: 146
- report_path: `/Users/arrrrny/Developer/zuraffa_intents/.dart_tool/zfa/tdd-verify-report/mutation-test-report.md`
- preflight_scope_ran (bug #924, per-behavior):
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart`
  - `/Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart`

## Mutation run

- mutation_was_run: true
- mutation_score: 1.0000

## Evidence binding (bug #837)

- spec_hash: 2ca10373f68814d349851c090317f0fec72f2894ccb339fd4e752b61a1ed003f
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a1_subject.dart` 659c9911170296eaca92edc590a99b41e72f480d48d66c31dae47f46c06f385b
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a2_subject.dart` c45eb0f47e71b8ecce150c9835213a393c9139d5a8a392a5c14bff8d6d4305cd
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a3_subject.dart` e304db1908133a5f62cee14a6b58d91893763f91bf1d000b80b6cd5570e1ff24
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a4_subject.dart` c897311870caa207a9955dd537beba47710e65de9527ce18f297cbbf73214d78
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a5_subject.dart` 4d035bd868d2b63b1087730385d8eb4b7ce723ddd8f7c692a0260f06ec438fb1
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a6_subject.dart` 8fddd4659b3395916e4679c1b70a5c8958020209295987b7d2f8e04119b660c4
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a7_subject.dart` 7742dc04f9b03de0ac0b3bb1c1311d74e779ba1f81853c9031d62d4dbaf528a8
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/a8_subject.dart` b8abe79916c447ab10fa017899d615ff90fa7430317e794b889fe966b28bd8ac
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u10_subject.dart` 5054d5137dc50a65f6b37ebbeb4d125d9eff2551b4a78b08184993c2a6a5269d
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u1_subject.dart` ad2859c43ce1e6f0e0545be6c7a8a99a4d0355585806b11d1ba49cc5cf0a9155
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u2_subject.dart` 1341c9197aa2555c0ffee99699aadd90a86f65ded5e21237c51a640f2830e516
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u3_subject.dart` 59967b5d39bd23c27e4c8e6fd66d4d7be7b4cb8f67359609378dc50f62132d94
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u4_subject.dart` a6b52b035c20f75cca16942e0f90dd73fa9b87743dd6fda3616047c285a5e36f
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u5_subject.dart` d9a93bb28197c6949b42096f9f6f5e305277de5acf585b92f5d74ba8970da4fc
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u6_subject.dart` f977dae5f279a6ad502ec5763ad281b6f896d848f2610fd4a252d148afa441d1
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u7_subject.dart` 764a3d9086fd2c1f8eb8003f7e0201fc414a99f6936fbd6dd49601ea3f54851c
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u8_subject.dart` 6ddbb8a3c09a8df3efd6614aa3253d2e8cabebdeea293475ccf30f7ff3e9c3bd
- subject_hash: `/Users/arrrrny/Developer/zuraffa_intents/lib/tdd/002-publishable-plugin/u9_subject.dart` 468ea501980822e2ade20fbebb8e19f96498140c2f3acf4a521969aa3c820f8b
