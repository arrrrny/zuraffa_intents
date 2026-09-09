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
## Cycle: A1 (error)

- behavior: A1
- kind: error
- outcome: runner-error
- criterion: AC-1
- test: test/
- command: `/Users/arrrrny/.local/bin/zfa tdd verify-red A1 --feature 001-intents-port --project /Users/arrrrny/Developer/zuraffa_intents`
- exit: 1
- at: 2026-09-09T18:17:23.708379Z
- output:
```
zfa tdd verify-red: behavior A1
   feature: 001-intents-port
   test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart
   command: flutter test {file} --plain-name "{name}"
   runner exit: -1
   classification: runner-error
verify-red: behavior=A1 classification=runner-error certified=false feature=001-intents-port

zfa tdd verify-red: classification runner-error — the runner did not execute exactly the target test; check the tdd-profile `single` command and the toolchain, then re-run `zfa tdd verify-red <behavior-id>`
   no evidence written
```

- schema: 1
- prev-hash: genesis
- hash: d1c0cca6e6f88eb33b6e8e8320c102835dc0fcca9380141ef384e797523bfede

## Cycle: A1 (red)

- behavior: A1
- kind: red
- classification: assertionFailure
- subject-hash: f737a445969e3046f192aaedcff0548ef6d2ac24515defa31644dbf7a58f62a7
- criterion: AC-1
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart --plain-name "both reads return the"`
- exit: 1
- at: 2026-09-09T18:21:33.570296Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart                                                                                                      
00:02 +0: A1 (AC-1) A1 — both reads return the                                                                                                                                                         
00:02 +0 -1: A1 (AC-1) A1 — both reads return the [E]                                                                                                                                                  
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a1 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/a1_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart -p vm --plain-name 'A1 (AC-1) A1 — both reads return the'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: d1c0cca6e6f88eb33b6e8e8320c102835dc0fcca9380141ef384e797523bfede
- hash: 475044b1d583f4b43bcd27443037485e96f5bfa796d0d585b71ceddfe35c80e7

## Cycle: A1 (green)

- behavior: A1
- kind: green
- subject-hash: f0561331f2bd00c7bb570709c9efd487a7ce7717c14d22c15e062d78696172ad
- criterion: AC-1
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart --plain-name "both reads return the"`
- exit: 0
- at: 2026-09-09T18:23:37.333236Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a1_test.dart                                                                                                      
00:02 +0: A1 (AC-1) A1 — both reads return the                                                                                                                                                         
00:02 +1: A1 (AC-1) A1 — both reads return the                                                                                                                                                         
00:02 +1: All tests passed!
```
- generation:
  - step: /Users/arrrrny/.local/bin/zfa tdd func A1 --feature 001-intents-port
    exit: 0
    purpose: scaffold the return function for behavior A1 from its description
  - step: /Users/arrrrny/.local/bin/zfa build
    exit: 0
    purpose: build generated code for behavior A1
- suite: baseline=1 guard=0 new=(none)

- schema: 1
- prev-hash: 475044b1d583f4b43bcd27443037485e96f5bfa796d0d585b71ceddfe35c80e7
- hash: 87d55c6df3daa6f26fee01453c980260c7f915c73e894984825a3811cbc71ee5

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-008
- test: test/
- command: `flutter test`
- exit: 0
- at: 2026-09-09T18:24:01.583956Z
- no-op: true
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:04 +39: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... path declared by pubspec.yaml exists on disk and CHANGELOG head entry matches the package version     
00:04 +39: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:04 +40: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:04 +40: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:04 +41: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:04 +41: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:04 +42: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:04 +42: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:04 +43: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:04 +43: All tests passed!
re-proof: full
applied: 0 actions.
```

- schema: 1
- prev-hash: genesis
- hash: 40c969270f9c8c604e1556cc6abbbbb8e2611364b9261dc40cbb6ad04066663b

## Cycle: A2 (red)

- behavior: A2
- kind: red
- classification: assertionFailure
- subject-hash: e6fd00649a7930649ea189596bd80dda56556e11c0255001360e90bda18ea3fd
- criterion: AC-2
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart --plain-name "it returns `null`, and a second reset call completes without"`
- exit: 1
- at: 2026-09-09T18:24:06.260476Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart                                                                                                      
00:02 +0: A2 (AC-2) A2 — it returns `null`, and a second reset call completes without                                                                                                                  
00:02 +0 -1: A2 (AC-2) A2 — it returns `null`, and a second reset call completes without [E]                                                                                                           
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a2 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/a2_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart -p vm --plain-name 'A2 (AC-2) A2 — it returns `null`, and a second reset call completes without'

00:02 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 5c66521d7f096f917e847173218b785be9bf0825ed010a2183e012d8516dd650

## Cycle: A2 (green)

- behavior: A2
- kind: green
- subject-hash: 4b66034e513b5f3c77fed21a0fa7238f912cc6bd70425eaedd75243723e7c5c5
- criterion: AC-2
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart --plain-name "it returns `null`, and a second reset call completes without"`
- exit: 0
- at: 2026-09-09T18:24:31.376073Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a2_test.dart                                                                                                      
00:04 +0: A2 (AC-2) A2 — it returns `null`, and a second reset call completes without                                                                                                                  
00:04 +1: A2 (AC-2) A2 — it returns `null`, and a second reset call completes without                                                                                                                  
00:04 +1: All tests passed!
```
- generation:
  - step: /Users/arrrrny/.local/bin/zfa tdd func A2 --feature 001-intents-port
    exit: 0
    purpose: scaffold the return function for behavior A2 from its description
  - step: /Users/arrrrny/.local/bin/zfa build
    exit: 0
    purpose: build generated code for behavior A2
- suite: baseline=1 guard=0 new=(none)

- schema: 1
- prev-hash: 5c66521d7f096f917e847173218b785be9bf0825ed010a2183e012d8516dd650
- hash: 311b8c594a9bc8513492e9c63cea63491a020fa83444d0c5a0eb60b2a2790cad

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-008
- test: test/
- command: `flutter test`
- exit: 0
- at: 2026-09-09T18:24:53.582644Z
- no-op: true
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:04 +40: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... path declared by pubspec.yaml exists on disk and CHANGELOG head entry matches the package version     
00:04 +40: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:04 +41: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:04 +41: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:04 +42: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:04 +42: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:04 +43: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:04 +43: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:04 +44: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:04 +44: All tests passed!
re-proof: full
applied: 0 actions.
```

- schema: 1
- prev-hash: 40c969270f9c8c604e1556cc6abbbbb8e2611364b9261dc40cbb6ad04066663b
- hash: 75f49745f7581d70a9f82b59214e8537b8d9d9152f03f6281d9eb647a4eb663e

## Cycle: A3 (red)

- behavior: A3
- kind: red
- classification: assertionFailure
- subject-hash: f0db62b8bb1cbf65eeec5360bea7b15ae3dcb869b4199321bc626b73c37b27a3
- criterion: AC-3
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart --plain-name "it returns `null`"`
- exit: 1
- at: 2026-09-09T18:24:57.701928Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart                                                                                                      
00:02 +0: A3 (AC-3) A3 — it returns `null`                                                                                                                                                             
00:02 +0 -1: A3 (AC-3) A3 — it returns `null` [E]                                                                                                                                                      
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a3 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/a3_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart -p vm --plain-name 'A3 (AC-3) A3 — it returns `null`'

00:02 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 495f64185dabc03279d1b4e464a0b09ce3be8eaca0cf4e3f29dc3f5c4de4f9ca

## Cycle: A3 (green)

- behavior: A3
- kind: green
- subject-hash: 78adc91146e6d3c3eef44b998c7245e3d60268a60488447d647ce0fc1c180762
- criterion: AC-3
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart --plain-name "it returns `null`"`
- exit: 0
- at: 2026-09-09T18:25:21.912602Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a3_test.dart                                                                                                      
00:02 +0: A3 (AC-3) A3 — it returns `null`                                                                                                                                                             
00:03 +0: A3 (AC-3) A3 — it returns `null`                                                                                                                                                             
00:03 +1: A3 (AC-3) A3 — it returns `null`                                                                                                                                                             
00:03 +1: All tests passed!
```
- generation:
  - step: /Users/arrrrny/.local/bin/zfa tdd func A3 --feature 001-intents-port
    exit: 0
    purpose: scaffold the return function for behavior A3 from its description
  - step: /Users/arrrrny/.local/bin/zfa build
    exit: 0
    purpose: build generated code for behavior A3
- suite: baseline=1 guard=0 new=(none)

- schema: 1
- prev-hash: 495f64185dabc03279d1b4e464a0b09ce3be8eaca0cf4e3f29dc3f5c4de4f9ca
- hash: 5acca814c5455732af52bb5b2661c5af58d883057c89a8c1239abf648c5cb95f

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-008
- test: test/
- command: `flutter test`
- exit: 0
- at: 2026-09-09T18:25:44.420451Z
- no-op: true
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:06 +41: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... path declared by pubspec.yaml exists on disk and CHANGELOG head entry matches the package version     
00:06 +41: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:06 +42: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:06 +42: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:06 +43: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:06 +43: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:06 +44: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:06 +44: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:06 +45: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:06 +45: All tests passed!
re-proof: full
applied: 0 actions.
```

- schema: 1
- prev-hash: 75f49745f7581d70a9f82b59214e8537b8d9d9152f03f6281d9eb647a4eb663e
- hash: 117449d635f4e02c172ee6ddbb98293668486ad303d9321f9b99dfec7398685f

## Cycle: A4 (red)

- behavior: A4
- kind: red
- classification: assertionFailure
- subject-hash: 346e6e39a0059baea68dcd308b3a9f960234dbeb44299e8cdea67a6d3afcc284
- criterion: AC-4
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart --plain-name "the carrier fields"`
- exit: 1
- at: 2026-09-09T18:25:52.706325Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:04 +0: A4 (AC-4) A4 — the carrier fields                                                                                                                                                            
00:04 +0 -1: A4 (AC-4) A4 — the carrier fields [E]                                                                                                                                                     
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a4 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/a4_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart -p vm --plain-name 'A4 (AC-4) A4 — the carrier fields'

00:04 +0 -1: Some tests failed.                                                                                                                                                                        
Waiting for another flutter command to release the startup lock...
```

- schema: 1
- prev-hash: genesis
- hash: 4ea81d3b8effed8cf79671ca3ba77124d762f08bed568c941f20207e9e9b9609

## Cycle: A5 (red)

- behavior: A5
- kind: red
- classification: assertionFailure
- subject-hash: efe23da4e3ee4778edb29efcad64b7ae50c2e1f1a74f9c2af1ad1c87c89b80af
- criterion: AC-5
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart --plain-name "exactly two records exist in call order and the second carries"`
- exit: 1
- at: 2026-09-09T18:26:09.060752Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:05 +0: A5 (AC-5) A5 — exactly two records exist in call order and the second carries                                                                                                                
00:05 +0 -1: A5 (AC-5) A5 — exactly two records exist in call order and the second carries [E]                                                                                                         
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a5 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/a5_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart -p vm --plain-name 'A5 (AC-5) A5 — exactly two records exist in call order and the second carries'

00:05 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: a07c3e41f444fa2da125a1c8e73fb58f2e44163ff80aeae33d938934cead055c

## Cycle: A6 (red)

- behavior: A6
- kind: red
- classification: assertionFailure
- subject-hash: 976ea3dc6dec661f12c97eef5f777fa7b53ce5d2499ccfa7be1be90480295d8b
- criterion: AC-6
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart --plain-name "each listener receives that share (broadcast)"`
- exit: 1
- at: 2026-09-09T18:26:31.358944Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:05 +0: A6 (AC-6) A6 — each listener receives that share (broadcast)                                                                                                                                 
00:05 +0 -1: A6 (AC-6) A6 — each listener receives that share (broadcast) [E]                                                                                                                          
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a6 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/a6_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart -p vm --plain-name 'A6 (AC-6) A6 — each listener receives that share (broadcast)'

00:06 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 30ee0e98258a18e0871eba4175d46172375146fe4a0d484f18f93a304ee6570b

## Cycle: A7 (red)

- behavior: A7
- kind: red
- classification: assertionFailure
- subject-hash: 288bf7736f947adabe3d1058d4c8befb3f63f70dad5017a933ec0193763e7a8f
- criterion: AC-7
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart --plain-name "the late subscriber"`
- exit: 1
- at: 2026-09-09T18:26:44.854042Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart                                                                                                      
00:03 +0: A7 (AC-7) A7 — the late subscriber                                                                                                                                                           
00:03 +0 -1: A7 (AC-7) A7 — the late subscriber [E]                                                                                                                                                    
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a7 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/a7_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart -p vm --plain-name 'A7 (AC-7) A7 — the late subscriber'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 5f37aff25d951be28657bbfafefca0737aa9ed0810385f3c4aefb35f3277715e

## Cycle: A8 (red)

- behavior: A8
- kind: red
- classification: assertionFailure
- subject-hash: 50ac3f7ac78cd48c0b6211ff36187a873e0e6f780a484835453186ad05bbb5ea
- criterion: AC-8
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart --plain-name "the facade delegates each call and surfaces the error verbatim (never"`
- exit: 1
- at: 2026-09-09T18:26:54.746986Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart                                                                                                      
00:02 +0: A8 (AC-8) A8 — the facade delegates each call and surfaces the error verbatim (never                                                                                                         
00:02 +0 -1: A8 (AC-8) A8 — the facade delegates each call and surfaces the error verbatim (never [E]                                                                                                  
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a8 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/a8_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart -p vm --plain-name 'A8 (AC-8) A8 — the facade delegates each call and surfaces the error verbatim (never'

00:02 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: c30a350e0d2b9f7fc134b3701dba51e8bf3eacc1c0355d13e2ff183d671f8c90

## Cycle: U1 (red)

- behavior: U1
- kind: red
- classification: assertionFailure
- subject-hash: d40aa91763728e3121591c0114f72ef2e4821be51277e5ef5ea722540cff9c44
- criterion: FR-001, SharedAttachmentType
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart --plain-name "`SharedAttachmentType` MUST expose exactly the four share"`
- exit: 1
- at: 2026-09-09T18:27:04.724788Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:02 +0: U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share                                                                                             
00:03 +0: U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share                                                                                             
00:03 +0 -1: U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share [E]                                                                                      
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u1 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u1_test.dart 29:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart -p vm --plain-name 'U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: df00c0ce113245d463311ce6f8fcde2f96a7424a9315e92565549c91fc0c7af7

## Cycle: U1 (green)

- behavior: U1
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 65725f6960ebc78ed2746c606397dabbe052511395340eaf2f756b1afe5d2f28
- criterion: FR-001, SharedAttachmentType
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart --plain-name "`SharedAttachmentType` MUST expose exactly the four share"`
- exit: 0
- at: 2026-09-09T18:33:20.517524Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:06 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:06 +0: U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share                                                                                             
00:06 +1: U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share                                                                                             
00:06 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: df00c0ce113245d463311ce6f8fcde2f96a7424a9315e92565549c91fc0c7af7
- hash: a33a284ee74beaa0db24b6a4b02073d7b8528a879e281701f397d0e887d13a98

## Cycle: A4 (green)

- behavior: A4
- kind: green
- subject-hash: eba20e720ded8c8474a44ef83c96419c0613e63c03168d2aa0b067bd333c39a2
- criterion: AC-4
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart --plain-name "the carrier fields"`
- exit: 0
- at: 2026-09-09T18:34:11.210181Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a4_test.dart                                                                                                      
00:04 +0: A4 (AC-4) A4 — the carrier fields                                                                                                                                                            
00:04 +1: A4 (AC-4) A4 — the carrier fields                                                                                                                                                            
00:04 +1: All tests passed!
```
- generation:
  - step: /Users/arrrrny/.local/bin/zfa tdd compose A4 --feature 001-intents-port
    exit: 0
    purpose: compose subject of behavior A4 against 1 green unit subject(s)
  - step: /Users/arrrrny/.local/bin/zfa build
    exit: 0
    purpose: build composed code for behavior A4
- suite: baseline=1 guard=0 new=(none)

- schema: 1
- prev-hash: 4ea81d3b8effed8cf79671ca3ba77124d762f08bed568c941f20207e9e9b9609
- hash: 80e9665c977363ac4a82d8355338aba7b5716a58f3522d1f384af6e30df974de

## Cycle: A5 (green)

- behavior: A5
- kind: green
- subject-hash: af688978195a5f239a5c64f3853981d42c9141e315169e3623b591dba2279a71
- criterion: AC-5
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart --plain-name "exactly two records exist in call order and the second carries"`
- exit: 0
- at: 2026-09-09T18:34:53.817912Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a5_test.dart                                                                                                      
00:05 +0: A5 (AC-5) A5 — exactly two records exist in call order and the second carries                                                                                                                
00:05 +1: A5 (AC-5) A5 — exactly two records exist in call order and the second carries                                                                                                                
00:05 +1: All tests passed!
```
- generation:
  - step: /Users/arrrrny/.local/bin/zfa tdd compose A5 --feature 001-intents-port
    exit: 0
    purpose: compose subject of behavior A5 against 1 green unit subject(s)
  - step: /Users/arrrrny/.local/bin/zfa build
    exit: 0
    purpose: build composed code for behavior A5
- suite: baseline=1 guard=0 new=(none)

- schema: 1
- prev-hash: a07c3e41f444fa2da125a1c8e73fb58f2e44163ff80aeae33d938934cead055c
- hash: 7e1065a81de2298f236cbd3e79c1edc08721a0898ea72f66950be32c64d1c175

## Cycle: A6 (green)

- behavior: A6
- kind: green
- subject-hash: 64514a210d90777a8a2e32eaca96397276ec30cd3b4935faa0c2e26b87a9c4b9
- criterion: AC-6
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart --plain-name "each listener receives that share (broadcast)"`
- exit: 0
- at: 2026-09-09T18:35:25.212748Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:03 +0: A6 (AC-6) A6 — each listener receives that share (broadcast)                                                                                                                                 
00:03 +1: A6 (AC-6) A6 — each listener receives that share (broadcast)                                                                                                                                 
00:03 +1: All tests passed!
```
- generation:
  - step: /Users/arrrrny/.local/bin/zfa tdd compose A6 --feature 001-intents-port
    exit: 0
    purpose: compose subject of behavior A6 against 1 green unit subject(s)
  - step: /Users/arrrrny/.local/bin/zfa build
    exit: 0
    purpose: build composed code for behavior A6
- suite: baseline=1 guard=0 new=(none)

- schema: 1
- prev-hash: 30ee0e98258a18e0871eba4175d46172375146fe4a0d484f18f93a304ee6570b
- hash: edd046813cf0c051de737ae2c853ec4ee9917ffbec0424412aed8254cd555d7c

## Cycle: A7 (green)

- behavior: A7
- kind: green
- subject-hash: 13c864929eb10bb7f2a503bf6101439d9d63f8bbf1192779d0a3b527c7ea866a
- criterion: AC-7
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart --plain-name "the late subscriber"`
- exit: 0
- at: 2026-09-09T18:35:52.671853Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart                                                                                                      
00:03 +0: A7 (AC-7) A7 — the late subscriber                                                                                                                                                           
00:03 +1: A7 (AC-7) A7 — the late subscriber                                                                                                                                                           
00:03 +1: All tests passed!
```
- generation:
  - step: /Users/arrrrny/.local/bin/zfa tdd compose A7 --feature 001-intents-port
    exit: 0
    purpose: compose subject of behavior A7 against 1 green unit subject(s)
  - step: /Users/arrrrny/.local/bin/zfa build
    exit: 0
    purpose: build composed code for behavior A7
- suite: baseline=1 guard=0 new=(none)

- schema: 1
- prev-hash: 5f37aff25d951be28657bbfafefca0737aa9ed0810385f3c4aefb35f3277715e
- hash: 28298e822ae61707bfda6f136179a428d5d83d4403ed92903faffc01a3429c8d

## Cycle: A8 (green)

- behavior: A8
- kind: green
- subject-hash: f887f3344275264f32a0117aba4cb2fb0e2f20f1f035e460a73a11a9d297f855
- criterion: AC-8
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart --plain-name "the facade delegates each call and surfaces the error verbatim (never"`
- exit: 0
- at: 2026-09-09T18:36:19.192256Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart                                                                                                      
00:03 +0: A8 (AC-8) A8 — the facade delegates each call and surfaces the error verbatim (never                                                                                                         
00:03 +1: A8 (AC-8) A8 — the facade delegates each call and surfaces the error verbatim (never                                                                                                         
00:03 +1: All tests passed!
```
- generation:
  - step: /Users/arrrrny/.local/bin/zfa tdd compose A8 --feature 001-intents-port
    exit: 0
    purpose: compose subject of behavior A8 against 1 green unit subject(s)
  - step: /Users/arrrrny/.local/bin/zfa build
    exit: 0
    purpose: build composed code for behavior A8
- suite: baseline=1 guard=0 new=(none)

- schema: 1
- prev-hash: c30a350e0d2b9f7fc134b3701dba51e8bf3eacc1c0355d13e2ff183d671f8c90
- hash: ce76ae8c361cbe274cc3a707728da82b376bc680b4c72a66f1ff6baa01b9b46a

## Cycle: U1 (green)

- behavior: U1
- kind: green
- subject-hash: 65725f6960ebc78ed2746c606397dabbe052511395340eaf2f756b1afe5d2f28
- criterion: FR-001, SharedAttachmentType
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart --plain-name "`SharedAttachmentType` MUST expose exactly the four share"`
- exit: 0
- at: 2026-09-09T18:36:25.354107Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:03 +0: U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share                                                                                             
00:03 +1: U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share                                                                                             
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: a33a284ee74beaa0db24b6a4b02073d7b8528a879e281701f397d0e887d13a98
- hash: 2f9b1f83c8fa55b334755354e6c039558abe2b3d9f968f4598d160d3dc4b720a

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-007
- test: test/
- command: `flutter test "test/tdd/001-intents-port/a4_test.dart" "test/tdd/001-intents-port/a5_test.dart" "test/tdd/001-intents-port/a6_test.dart" "test/tdd/001-intents-port/a7_test.dart" "test/tdd/001-intents-port/a8_test.dart"`
- exit: 0
- at: 2026-09-09T18:36:53.079364Z
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:03 +2: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart                                                                                                      
00:03 +2: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a6_test.dart: A6 (AC-6) A6 — each listener receives that share (broadcast)                                                
00:03 +3: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart: A7 (AC-7) A7 — the late subscriber                                                                          
00:03 +4: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart: A7 (AC-7) A7 — the late subscriber                                                                          
00:04 +4: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart: A7 (AC-7) A7 — the late subscriber                                                                          
00:05 +4: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a7_test.dart: A7 (AC-7) A7 — the late subscriber                                                                          
00:05 +4: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart                                                                                                      
00:05 +4: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart: A8 (AC-8) A8 — the facade delegates each call and surfaces the error verbatim (never                        
00:05 +5: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/a8_test.dart: A8 (AC-8) A8 — the facade delegates each call and surfaces the error verbatim (never                        
00:05 +5: All tests passed!
re-proof: scoped (5 covering test(s) for 5 changed file(s); spec 069 T001 — the full gate runs at feature completion + nightly)
receipts refreshed: 5 receipted artifact(s) re-hashed (sanctioned refactor provenance, issue #1311)
applied: 3 action(s), 1 with file changes.
```
actions:
- action: build
  command: `/Users/arrrrny/.local/bin/zfa build`
  exit: 0
  changed: (none)
- action: format
  command: `dart format lib/`
  exit: 0
  changed: lib/tdd/001-intents-port/a4_subject.dart, lib/tdd/001-intents-port/a5_subject.dart, lib/tdd/001-intents-port/a6_subject.dart, lib/tdd/001-intents-port/a7_subject.dart, lib/tdd/001-intents-port/a8_subject.dart
- action: fix
  command: `dart fix --apply lib/`
  exit: 0
  changed: (none)

- schema: 1
- prev-hash: 117449d635f4e02c172ee6ddbb98293668486ad303d9321f9b99dfec7398685f
- hash: ccc1db50aa309f3dbc9fedf47dcdd44cac279853f36ea3a28471bbe794a59bfb

## Cycle: U2 (red)

- behavior: U2
- kind: red
- classification: assertionFailure
- subject-hash: 0ea4ba65d065710a70365b0e4eb4948a18c4dea2307bc478b408f334bc512a1f
- criterion: FR-002, SharedAttachment
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart --plain-name "`SharedAttachment` MUST be an immutable entity carrying the"`
- exit: 1
- at: 2026-09-09T18:36:58.907379Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:03 +0: U2 (FR-002, SharedAttachment) U2 — `SharedAttachment` MUST be an immutable entity carrying the                                                                                               
00:03 +0 -1: U2 (FR-002, SharedAttachment) U2 — `SharedAttachment` MUST be an immutable entity carrying the [E]                                                                                        
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u2 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u2_test.dart 29:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart -p vm --plain-name 'U2 (FR-002, SharedAttachment) U2 — `SharedAttachment` MUST be an immutable entity carrying the'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 26d77c14c69cd255d1bfa8c368ecd7b93b06231b5039321b737a95b10288c204

## Cycle: U3 (red)

- behavior: U3
- kind: red
- classification: assertionFailure
- subject-hash: 7497d87f5378273a5a68c7c30284e1d3b8b4e71aa766f44ed64019222c873b12
- criterion: FR-003, SharedAttachment
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart --plain-name "`SharedAttachment` MUST round-trip `toJson` → `fromJson`"`
- exit: 1
- at: 2026-09-09T18:41:43.688022Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:03 +0: U3 (FR-003, SharedAttachment) U3 — `SharedAttachment` MUST round-trip `toJson` → `fromJson`                                                                                                  
00:03 +0 -1: U3 (FR-003, SharedAttachment) U3 — `SharedAttachment` MUST round-trip `toJson` → `fromJson` [E]                                                                                           
  Expected: <Instance of 'SharedAttachment'>
    Actual: UnimplementedError:<UnimplementedError: subject_u3 not implemented>
     Which: is not an instance of 'SharedAttachment'
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u3_test.dart 28:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart -p vm --plain-name 'U3 (FR-003, SharedAttachment) U3 — `SharedAttachment` MUST round-trip `toJson` → `fromJson`'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: cc53de1ff3f37225d618ccd330711445ebd2355ba473aa5528031c52203525d9

## Cycle: U4 (red)

- behavior: U4
- kind: red
- classification: assertionFailure
- subject-hash: 3410a5e0422b5bb5cc9af6a59317cd8eefc8ba8d7945dc2e875fb2e783d0d6fd
- criterion: FR-004, SharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart --plain-name "`SharedMedia` MUST be an immutable entity with the plugin's"`
- exit: 1
- at: 2026-09-09T18:41:48.440690Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:02 +0: U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin's                                                                                                    
00:02 +0 -1: U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin's [E]                                                                                             
  Expected: <Instance of 'SharedMedia'>
    Actual: UnimplementedError:<UnimplementedError: subject_u4 not implemented>
     Which: is not an instance of 'SharedMedia'
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u4_test.dart 31:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart -p vm --plain-name 'U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin'\''s'

00:02 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 94d7cb9b1ae13b65c950c692d6cf23496fb86805d22e77b79f7c9824beb55813

## Cycle: U5 (red)

- behavior: U5
- kind: red
- classification: assertionFailure
- subject-hash: 799ab74edd642dfbe9d93cc4fc96503009cf6f0799fb45b8df2cd2851834cca8
- criterion: FR-005, SharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart --plain-name "`SharedMedia.copyWith` MUST replace only the given fields"`
- exit: 1
- at: 2026-09-09T18:41:52.846571Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:02 +0: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields                                                                                                      
00:02 +0 -1: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields [E]                                                                                               
  Expected: <Instance of 'SharedMedia'>
    Actual: UnimplementedError:<UnimplementedError: subject_u5 not implemented>
     Which: is not an instance of 'SharedMedia'
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u5_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart -p vm --plain-name 'U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields'

00:02 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 8a7e4fe14a62e1194683f5ce5a24578c0bf7ca40abb57a42810320b42fc3792e

## Cycle: U2 (green)

- behavior: U2
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: ab82d0fa254a0c23347d1b38aebdea2b3ccd3cf0b83f2e741bd5f97ad2ca6c69
- criterion: FR-002, SharedAttachment
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart --plain-name "`SharedAttachment` MUST be an immutable entity carrying the"`
- exit: 0
- at: 2026-09-09T18:42:03.016013Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:03 +0: U2 (FR-002, SharedAttachment) U2 — `SharedAttachment` MUST be an immutable entity carrying the                                                                                               
00:03 +1: U2 (FR-002, SharedAttachment) U2 — `SharedAttachment` MUST be an immutable entity carrying the                                                                                               
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 26d77c14c69cd255d1bfa8c368ecd7b93b06231b5039321b737a95b10288c204
- hash: 2ca613b9a0b86dfe267cb4d2c44bb2add37eae440611960662d8081fefc5a921

## Cycle: U3 (green)

- behavior: U3
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: b2cd8c643e39ccea2ea4e9bed8b172ec36817adecd6beebe4bccfaa5e0363a76
- criterion: FR-003, SharedAttachment
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart --plain-name "`SharedAttachment` MUST round-trip `toJson` → `fromJson`"`
- exit: 0
- at: 2026-09-09T18:42:09.926275Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:04 +0: U3 (FR-003, SharedAttachment) U3 — `SharedAttachment` MUST round-trip `toJson` → `fromJson`                                                                                                  
00:04 +1: U3 (FR-003, SharedAttachment) U3 — `SharedAttachment` MUST round-trip `toJson` → `fromJson`                                                                                                  
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: cc53de1ff3f37225d618ccd330711445ebd2355ba473aa5528031c52203525d9
- hash: 7e8333c5a53cec46f2de0e1747f7c7e8013bf7d47e2d55638da0568eda998c9a

## Cycle: U5 (red)

- behavior: U5
- kind: red
- classification: assertionFailure
- subject-hash: aa19ab2da815ba7e1df426fddd73ba4a81cbc8928fa84f5fa1047ccdfe0e3d13
- criterion: FR-005, SharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart --plain-name "`SharedMedia.copyWith` MUST replace only the given fields"`
- exit: 1
- at: 2026-09-09T18:42:20.207056Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:03 +0: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields                                                                                                      
00:03 +0 -1: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields [E]                                                                                               
  Expected: SharedMedia:<SharedMedia(attachments: [SharedAttachment(path: /tmp/a.png, type: SharedAttachmentType.image)], recipientIdentifiers: null, conversationIdentifier: null, content: original, speakableGroupName: Mom, serviceName: null, senderIdentifier: null, imageFilePath: null, subject: null)>
    Actual: SharedMedia:<SharedMedia(attachments: [SharedAttachment(path: /tmp/a.png, type: SharedAttachmentType.image)], recipientIdentifiers: null, conversationIdentifier: null, content: original, speakableGroupName: Mom, serviceName: null, senderIdentifier: null, imageFilePath: null, subject: null)>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u5_test.dart 56:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart -p vm --plain-name 'U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: 8a7e4fe14a62e1194683f5ce5a24578c0bf7ca40abb57a42810320b42fc3792e
- hash: db8c97a15ef16df3e39b73398c051261092085af250a25489fc69ed145bcd785

## Cycle: U4 (red)

- behavior: U4
- kind: red
- classification: assertionFailure
- subject-hash: 3410a5e0422b5bb5cc9af6a59317cd8eefc8ba8d7945dc2e875fb2e783d0d6fd
- criterion: FR-004, SharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart --plain-name "`SharedMedia` MUST be an immutable entity with the plugin's"`
- exit: 1
- at: 2026-09-09T18:44:32.337566Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:04 +0: U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin's                                                                                                    
00:04 +0 -1: U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin's [E]                                                                                             
  Expected: <Instance of 'SharedMedia'>
    Actual: UnimplementedError:<UnimplementedError: subject_u4 not implemented>
     Which: is not an instance of 'SharedMedia'
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u4_test.dart 31:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart -p vm --plain-name 'U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin'\''s'

00:05 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: 94d7cb9b1ae13b65c950c692d6cf23496fb86805d22e77b79f7c9824beb55813
- hash: 0a840e11d9e282a6ce94b6cafe5a0acbb69e2937538436146988d02cce422921

## Cycle: U5 (red)

- behavior: U5
- kind: red
- classification: assertionFailure
- subject-hash: 799ab74edd642dfbe9d93cc4fc96503009cf6f0799fb45b8df2cd2851834cca8
- criterion: FR-005, SharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart --plain-name "`SharedMedia.copyWith` MUST replace only the given fields"`
- exit: 1
- at: 2026-09-09T18:44:40.755729Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:05 +0: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields                                                                                                      
00:05 +0 -1: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields [E]                                                                                               
  Expected: <Instance of 'SharedMedia'>
    Actual: UnimplementedError:<UnimplementedError: subject_u5 not implemented>
     Which: is not an instance of 'SharedMedia'
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u5_test.dart 30:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart -p vm --plain-name 'U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields'

00:05 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: db8c97a15ef16df3e39b73398c051261092085af250a25489fc69ed145bcd785
- hash: a552bd915b10a199e564c25e3b79c993c887e46a3517f11ff3d6a767881ac2e2

## Cycle: U4 (green)

- behavior: U4
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 85741b0daf943d5ed535caee6f46767b7c41b6f679446ecc8312c16e24d325ba
- criterion: FR-004, SharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart --plain-name "`SharedMedia` MUST be an immutable entity with the plugin's"`
- exit: 0
- at: 2026-09-09T18:44:48.542808Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart                                                                                                      
00:04 +0: U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin's                                                                                                    
00:04 +1: U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin's                                                                                                    
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 0a840e11d9e282a6ce94b6cafe5a0acbb69e2937538436146988d02cce422921
- hash: 84bb0a9613f8e463797b34978f0632de4de409d425fcfe626e5e8098e3332592

## Cycle: U5 (green)

- behavior: U5
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: aa19ab2da815ba7e1df426fddd73ba4a81cbc8928fa84f5fa1047ccdfe0e3d13
- criterion: FR-005, SharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart --plain-name "`SharedMedia.copyWith` MUST replace only the given fields"`
- exit: 0
- at: 2026-09-09T18:44:55.674234Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:04 +0: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields                                                                                                      
00:04 +1: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields                                                                                                      
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: a552bd915b10a199e564c25e3b79c993c887e46a3517f11ff3d6a767881ac2e2
- hash: 4f7ea908caa006eee9b30bb8f7502aeea8d689a3a335147ecf5ee7556adb58a2

## Cycle: U2 (green)

- behavior: U2
- kind: green
- subject-hash: ab82d0fa254a0c23347d1b38aebdea2b3ccd3cf0b83f2e741bd5f97ad2ca6c69
- criterion: FR-002, SharedAttachment
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart --plain-name "`SharedAttachment` MUST be an immutable entity carrying the"`
- exit: 0
- at: 2026-09-09T18:45:10.467779Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u2_test.dart                                                                                                      
00:05 +0: U2 (FR-002, SharedAttachment) U2 — `SharedAttachment` MUST be an immutable entity carrying the                                                                                               
00:05 +1: U2 (FR-002, SharedAttachment) U2 — `SharedAttachment` MUST be an immutable entity carrying the                                                                                               
00:05 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 2ca613b9a0b86dfe267cb4d2c44bb2add37eae440611960662d8081fefc5a921
- hash: 0da3536c15328dd7b3da57bb257fa0083b67c8a71b283fd6f50c5e2913dedf15

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-007
- test: test/
- command: `flutter test "test/tdd/001-intents-port/u3_test.dart" "test/tdd/001-intents-port/u4_test.dart" "test/tdd/001-intents-port/u5_test.dart"`
- exit: 0
- at: 2026-09-09T18:45:46.726932Z
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart                                                                                                      
00:02 +0: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u3_test.dart: U3 (FR-003, SharedAttachment) U3 — `SharedAttachment` MUST round-trip `toJson` → `fromJson`                 
00:02 +1: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart: U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin's                   
00:02 +2: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u4_test.dart: U4 (FR-004, SharedMedia) U4 — `SharedMedia` MUST be an immutable entity with the plugin's                   
00:02 +2: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart                                                                                                      
00:02 +2: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields                     
00:02 +3: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields                     
00:03 +3: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u5_test.dart: U5 (FR-005, SharedMedia) U5 — `SharedMedia.copyWith` MUST replace only the given fields                     
00:03 +3: All tests passed!
re-proof: scoped (3 covering test(s) for 3 changed file(s); spec 069 T001 — the full gate runs at feature completion + nightly)
receipts refreshed: 3 receipted artifact(s) re-hashed (sanctioned refactor provenance, issue #1311)
applied: 3 action(s), 1 with file changes.
```
actions:
- action: build
  command: `/Users/arrrrny/.local/bin/zfa build`
  exit: 0
  changed: (none)
- action: format
  command: `dart format lib/`
  exit: 0
  changed: lib/tdd/001-intents-port/u3_subject.dart, lib/tdd/001-intents-port/u4_subject.dart, lib/tdd/001-intents-port/u5_subject.dart
- action: fix
  command: `dart fix --apply lib/`
  exit: 0
  changed: (none)

- schema: 1
- prev-hash: ccc1db50aa309f3dbc9fedf47dcdd44cac279853f36ea3a28471bbe794a59bfb
- hash: 909b843549be87941683bab0f20fbb73ae752fd3727a054b70ceb13cec35e5c5

## Cycle: U6 (red)

- behavior: U6
- kind: red
- classification: assertionFailure
- subject-hash: bfe2bee6ce2c7e44d5b88bc18d95d0e4001949f7e17f3d10183cfcaf8a31cf62
- criterion: FR-006, ShareIntentPort.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart --plain-name "The initial-share lifecycle on `ShareIntentPort` MUST work"`
- exit: 1
- at: 2026-09-09T18:45:51.842637Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:02 +0: U6 (FR-006, ShareIntentPort.sharedMediaStream) U6 — The initial-share lifecycle on `ShareIntentPort` MUST work                                                                               
00:03 +0 -1: U6 (FR-006, ShareIntentPort.sharedMediaStream) U6 — The initial-share lifecycle on `ShareIntentPort` MUST work                                                                            
00:03 +0 -1: U6 (FR-006, ShareIntentPort.sharedMediaStream) U6 — The initial-share lifecycle on `ShareIntentPort` MUST work [E]                                                                        
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u6 not implemented: sharedMediaStream() -> Stream<SharedMedia>>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u6_test.dart 35:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart -p vm --plain-name 'U6 (FR-006, ShareIntentPort.sharedMediaStream) U6 — The initial-share lifecycle on `ShareIntentPort` MUST work'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 6496af13a1ec17629a0ba13260bb0616b9923cb21ca3fccecab0f28a7e94212e

## Cycle: U7 (red)

- behavior: U7
- kind: red
- classification: assertionFailure
- subject-hash: ca2023618545da24e19c8be9fb64045124bd7edde1af67a4b5c6f7433c473612
- criterion: FR-007, ShareIntentPort.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart --plain-name "`recordSentMessage` MUST preserve the plugin's argument"`
- exit: 1
- at: 2026-09-09T18:49:22.251417Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:03 +0: U7 (FR-007, ShareIntentPort.sharedMediaStream) U7 — `recordSentMessage` MUST preserve the plugin's argument                                                                                  
00:03 +0 -1: U7 (FR-007, ShareIntentPort.sharedMediaStream) U7 — `recordSentMessage` MUST preserve the plugin's argument [E]                                                                           
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u7 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u7_test.dart 16:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart -p vm --plain-name 'U7 (FR-007, ShareIntentPort.sharedMediaStream) U7 — `recordSentMessage` MUST preserve the plugin'\''s argument'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 9d0dbed0bae362cdd2ebfeb0650554ee24fc752cbed081c869c2f2f3241d3819

## Cycle: U8 (red)

- behavior: U8
- kind: red
- classification: assertionFailure
- subject-hash: d2e6c7db9eb1e1d6675e56541fe7c0e3751b72457821a72c80e526606a8f3129
- criterion: FR-008, ShareIntentPort.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart --plain-name "`sharedMediaStream` MUST be a broadcast stream: every"`
- exit: 1
- at: 2026-09-09T18:49:27.258006Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart                                                                                                      
00:02 +0: U8 (FR-008, ShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be a broadcast stream: every                                                                                    
00:03 +0: U8 (FR-008, ShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be a broadcast stream: every                                                                                    
00:03 +0 -1: U8 (FR-008, ShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be a broadcast stream: every [E]                                                                             
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u8 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u8_test.dart 16:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart -p vm --plain-name 'U8 (FR-008, ShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be a broadcast stream: every'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 8c40bde37fd0e418d4743c80dba76e27444b499faabbdd230a8c304d991ee00f

## Cycle: U9 (red)

- behavior: U9
- kind: red
- classification: assertionFailure
- subject-hash: ede5bdd6d2ebf8eff15bae3a95f357fe3372b8885449e35ecf0c299f7cd51025
- criterion: FR-009, ShareIntentService.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart --plain-name "`ShareIntentService` MUST be a thin facade over the port —"`
- exit: 1
- at: 2026-09-09T18:49:33.171580Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:03 +0: U9 (FR-009, ShareIntentService.sharedMediaStream) U9 — `ShareIntentService` MUST be a thin facade over the port —                                                                            
00:03 +0 -1: U9 (FR-009, ShareIntentService.sharedMediaStream) U9 — `ShareIntentService` MUST be a thin facade over the port — [E]                                                                     
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u9 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/001-intents-port/u9_test.dart 16:7         main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart -p vm --plain-name 'U9 (FR-009, ShareIntentService.sharedMediaStream) U9 — `ShareIntentService` MUST be a thin facade over the port —'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 1ee56dd721a0744688928aac197c46e248e354634a3c5a4e26d14e09bcdcb5cc

## Cycle: U7 (green)

- behavior: U7
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 028f35143436254c194ad4bd3cdeda881037206b01a44b1ab0a18f0ad42ca22b
- criterion: FR-007, ShareIntentPort.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart --plain-name "`recordSentMessage` MUST preserve the plugin's argument"`
- exit: 0
- at: 2026-09-09T18:49:41.487768Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u7_test.dart                                                                                                      
00:05 +0: U7 (FR-007, ShareIntentPort.sharedMediaStream) U7 — `recordSentMessage` MUST preserve the plugin's argument                                                                                  
00:05 +1: U7 (FR-007, ShareIntentPort.sharedMediaStream) U7 — `recordSentMessage` MUST preserve the plugin's argument                                                                                  
00:05 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 9d0dbed0bae362cdd2ebfeb0650554ee24fc752cbed081c869c2f2f3241d3819
- hash: adf3b1931bf2154ab90f91af5d65aa47e2bcdfbe9e845089e523282b7dca7eec

## Cycle: U8 (green)

- behavior: U8
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 154078d75df2fda85e0f6195af92f879baa91e81246cee48812ecc3df43a0dc5
- criterion: FR-008, ShareIntentPort.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart --plain-name "`sharedMediaStream` MUST be a broadcast stream: every"`
- exit: 0
- at: 2026-09-09T18:49:48.834551Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u8_test.dart                                                                                                      
00:04 +0: U8 (FR-008, ShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be a broadcast stream: every                                                                                    
00:04 +1: U8 (FR-008, ShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be a broadcast stream: every                                                                                    
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 8c40bde37fd0e418d4743c80dba76e27444b499faabbdd230a8c304d991ee00f
- hash: 17530556e3af49bc7a8a37b4f2b4a5e925efac7439bdbdfd2735562b6c900e11

## Cycle: U9 (green)

- behavior: U9
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 227a7bbf04a07c886b0664a590fabc13ec54cee06b5cce29616eeb3ccbb874bd
- criterion: FR-009, ShareIntentService.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart --plain-name "`ShareIntentService` MUST be a thin facade over the port —"`
- exit: 0
- at: 2026-09-09T18:49:56.519779Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:04 +0: U9 (FR-009, ShareIntentService.sharedMediaStream) U9 — `ShareIntentService` MUST be a thin facade over the port —                                                                            
00:04 +1: U9 (FR-009, ShareIntentService.sharedMediaStream) U9 — `ShareIntentService` MUST be a thin facade over the port —                                                                            
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 1ee56dd721a0744688928aac197c46e248e354634a3c5a4e26d14e09bcdcb5cc
- hash: 00124c20d2c00d552443f9e669985684d19ff41489680dbf1289a7d6581a6fd6

## Cycle: U6 (green)

- behavior: U6
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 3282bc2c0e38e42d8751c0dbe72a6d49bd759521fafe91190ca4ef553673beaa
- criterion: FR-006, ShareIntentPort.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart --plain-name "The initial-share lifecycle on `ShareIntentPort` MUST work"`
- exit: 0
- at: 2026-09-09T18:50:08.587705Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:03 +0: U6 (FR-006, ShareIntentPort.sharedMediaStream) U6 — The initial-share lifecycle on `ShareIntentPort` MUST work                                                                               
00:03 +1: U6 (FR-006, ShareIntentPort.sharedMediaStream) U6 — The initial-share lifecycle on `ShareIntentPort` MUST work                                                                               
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 6496af13a1ec17629a0ba13260bb0616b9923cb21ca3fccecab0f28a7e94212e
- hash: 526c11a2afe374a9c6ccec5439cfc47cb588ead118751471d60190153298596d

## Cycle: U6 (green)

- behavior: U6
- kind: green
- subject-hash: 3282bc2c0e38e42d8751c0dbe72a6d49bd759521fafe91190ca4ef553673beaa
- criterion: FR-006, ShareIntentPort.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart --plain-name "The initial-share lifecycle on `ShareIntentPort` MUST work"`
- exit: 0
- at: 2026-09-09T18:50:14.058152Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u6_test.dart                                                                                                      
00:03 +0: U6 (FR-006, ShareIntentPort.sharedMediaStream) U6 — The initial-share lifecycle on `ShareIntentPort` MUST work                                                                               
00:03 +1: U6 (FR-006, ShareIntentPort.sharedMediaStream) U6 — The initial-share lifecycle on `ShareIntentPort` MUST work                                                                               
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 526c11a2afe374a9c6ccec5439cfc47cb588ead118751471d60190153298596d
- hash: c7a41bfa4b31ff156b9be6456e98eea7befaae3a223a0b1e419b4a7cb6bd474c

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-007
- test: test/
- command: `flutter test "test/tdd/001-intents-port/u9_test.dart"`
- exit: 0
- at: 2026-09-09T18:50:53.527043Z
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u9_test.dart                                                                                                      
00:05 +0: U9 (FR-009, ShareIntentService.sharedMediaStream) U9 — `ShareIntentService` MUST be a thin facade over the port —                                                                            
00:05 +1: U9 (FR-009, ShareIntentService.sharedMediaStream) U9 — `ShareIntentService` MUST be a thin facade over the port —                                                                            
00:05 +1: All tests passed!
re-proof: scoped (1 covering test(s) for 1 changed file(s); spec 069 T001 — the full gate runs at feature completion + nightly)
receipts refreshed: 1 receipted artifact(s) re-hashed (sanctioned refactor provenance, issue #1311)
applied: 3 action(s), 1 with file changes.
```
actions:
- action: build
  command: `/Users/arrrrny/.local/bin/zfa build`
  exit: 0
  changed: (none)
- action: format
  command: `dart format lib/`
  exit: 0
  changed: (none)
- action: fix
  command: `dart fix --apply lib/`
  exit: 0
  changed: lib/tdd/001-intents-port/u9_subject.dart

- schema: 1
- prev-hash: 909b843549be87941683bab0f20fbb73ae752fd3727a054b70ceb13cec35e5c5
- hash: 180282c939b540191947469566f33a36805f454a9af75045215ba8a53bd06d0d

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-008
- test: test/
- command: `flutter test`
- exit: 0
- at: 2026-09-09T18:51:47.063541Z
- no-op: true
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:11 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... path declared by pubspec.yaml exists on disk and CHANGELOG head entry matches the package version     
00:11 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:11 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:11 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:11 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:11 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:11 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:11 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:11 +59: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:11 +59: All tests passed!
re-proof: full
applied: 0 actions.
```

- schema: 1
- prev-hash: 180282c939b540191947469566f33a36805f454a9af75045215ba8a53bd06d0d
- hash: fc6c0fce1ac897ac8ed8b2f19d9183d15cc7fce961c227d16d0fd7e3792677dd

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-008
- test: test/
- command: `flutter test`
- exit: 0
- at: 2026-09-09T18:52:22.165902Z
- no-op: true
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:12 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... path declared by pubspec.yaml exists on disk and CHANGELOG head entry matches the package version     
00:12 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:12 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:12 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:12 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:12 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:12 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:12 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:12 +59: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:12 +59: All tests passed!
re-proof: full
applied: 0 actions.
```

- schema: 1
- prev-hash: fc6c0fce1ac897ac8ed8b2f19d9183d15cc7fce961c227d16d0fd7e3792677dd
- hash: 788ee6072069564ed8920e94d17f299fdbee0e15feb7336bfb870e7dc146ea36

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-008
- test: test/
- command: `flutter test`
- exit: 0
- at: 2026-09-09T18:53:19.049196Z
- no-op: true
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:17 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... path declared by pubspec.yaml exists on disk and CHANGELOG head entry matches the package version     
00:17 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:17 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:17 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:17 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:17 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:17 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:17 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:17 +59: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:17 +59: All tests passed!
re-proof: full
applied: 0 actions.
```

- schema: 1
- prev-hash: 788ee6072069564ed8920e94d17f299fdbee0e15feb7336bfb870e7dc146ea36
- hash: 7739b592d16fce4c74e57d3b10b03b7d5283289cc17bbacb46edfc84bbbf32e4

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-008
- test: test/
- command: `flutter test`
- exit: 0
- at: 2026-09-09T18:54:05.494572Z
- no-op: true
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:12 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... path declared by pubspec.yaml exists on disk and CHANGELOG head entry matches the package version     
00:12 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:12 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:12 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:12 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:12 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:12 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:12 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:12 +59: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:12 +59: All tests passed!
re-proof: full
applied: 0 actions.
```

- schema: 1
- prev-hash: 7739b592d16fce4c74e57d3b10b03b7d5283289cc17bbacb46edfc84bbbf32e4
- hash: 0c83c6659937f6b90c4a2332933c0f6cb65a6d470cecd3974bf13db897dea778

## Cycle: 001-intents-port-refactor (refactor)

- behavior: 001-intents-port-refactor
- kind: refactor
- criterion: FR-008
- test: test/
- command: `flutter test`
- exit: 0
- at: 2026-09-09T18:54:52.478636Z
- no-op: true
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:19 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... path declared by pubspec.yaml exists on disk and CHANGELOG head entry matches the package version     
00:19 +55: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:19 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins
00:19 +56: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:19 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs       
00:19 +57: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:19 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers    
00:19 +58: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:19 +59: /Users/arrrrny/Developer/zuraffa_intents/test/platform_interface_suite_test.dart: ... key set matches sharedMediaWireMap (every Dart wire key is present in each native toMap/toDictionary) 
00:19 +59: All tests passed!
re-proof: full
applied: 0 actions.
```

- schema: 1
- prev-hash: 0c83c6659937f6b90c4a2332933c0f6cb65a6d470cecd3974bf13db897dea778
- hash: 24cb82848a31f9c9f46ac8c3835756c810950f366398027d6c443f5da36c7954

## Two-cycle run: 001-intents-port

- feature: 001-intents-port
- engine-receipt: 04-engine-receipt.json (verdict: green)
- skin-receipt: 04-skin-receipt.json (verdict: green)
- at: 2026-09-09T18:54:52.593288Z

## Cycle: U1 (green)

- behavior: U1
- kind: green
- subject-hash: 65725f6960ebc78ed2746c606397dabbe052511395340eaf2f756b1afe5d2f28
- criterion: FR-001, SharedAttachmentType
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart --plain-name "`SharedAttachmentType` MUST expose exactly the four share"`
- exit: 0
- at: 2026-09-09T18:57:06.887135Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/001-intents-port/u1_test.dart                                                                                                      
00:04 +0: U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share                                                                                             
00:04 +1: U1 (FR-001, SharedAttachmentType) U1 — `SharedAttachmentType` MUST expose exactly the four share                                                                                             
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 2f9b1f83c8fa55b334755354e6c039558abe2b3d9f968f4598d160d3dc4b720a
- hash: 8ac2a6f1cc3c0f9336add67aeb3c9897505ed3e42235ec0fc963a5aef4621c67

