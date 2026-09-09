# Cycle Log: 002-publishable-plugin

## Cycle 1 — red → green (U20..U40)

- **Red protocol (brownfield, greenfield layer)**: baseline re-verified green
  first (20/20 under the converted flutter runner, commit 2384ab0). Then
  `test/platform_interface_suite_test.dart` was written against the absent
  platform-interface API.
  - Observed red: compile failure — `sharedAttachmentWireMap`,
    `sharedMediaWireMap`, `ShareIntentsApiCodec`, `decodeSharedMedia`,
    `defaultIsAppleLikeUriPath`, `MethodChannelShareIntentPort`,
    `ShareIntentService.platform` not found (the greenfield honest red),
    plus the packaging/consistency groups not yet satisfiable.
  - Capture: `flutter test test/platform_interface_suite_test.dart` →
    Error: Method not found (×10+ shown above the fold).
- **Green**: implement in dependency order —
  1. `lib/src/platform/wire/share_intents_wire.dart`: channel constants,
     wire-map builders, `ShareIntentsApiCodec` (StandardMessageCodec
     subclass, tags 128/129/130), quirk predicate + `decodeSharedMedia`.
  2. `lib/src/platform/method_channel/method_channel_share_intent_port.dart`:
     the `ShareIntentPort` driver over the three pigeon
     `BasicMessageChannel`s (result / error / channel-error semantics) and
     the `EventChannel` lazy-singleton stream.
  3. `lib/src/platform/web/zuraffa_intents_web.dart`: `ZuraffaIntentsWeb`
     registration class (web is a documented stub, as in the source plugin).
  4. `lib/src/share_intent_service.dart`: `ShareIntentService.platform()`
     factory + `registerShareIntentDependencies` upgraded to bind
     `ShareIntentPort` → method-channel driver, service → that port (both
     lazy singletons); direct construction keeps the spec-001 in-memory
     default (U17 stays authoritative for the pure-Dart context).
- **Full suite**: baseline 20 + additive 21 = 41 behaviors, target green,
  `flutter analyze` clean.

## Fixture notes

- U22/U23/U24 encode through `WriteBuffer`/`ReadBuffer` with the real codec
  path (`writeValue` → `readValueOfType`), so the tag envelope is exercised
  byte-for-byte, not stubbed.
- U32 drives a genuine `handlePlatformMessage` through the messenger with a
  `StandardMessageCodec`-encoded plain map — the exact shape
  `EventSink.success(map)` puts on the wire from the ported Kotlin/Swift
  natives.
- U25 asserts the default predicate result on the VM host (false: not web,
  not iOS/macOS) without touching `Platform` on web — the web-safety fix
  over the source plugin is structural (kIsWeb short-circuit), not
  environmental.

## Green + mutation outcome (final)

- Green: 41/41 (bootstrap smoke + spec-001's 19 + spec-002's 21), `flutter
  analyze` clean, `dart format` clean, `flutter pub publish --dry-run` 0
  warnings (after packaging commit e0849a1).
- Fixture/protocol notes recorded during green:
  - The codec tests must drive the real messenger entry points
    (`encodeMessage`/`decodeMessage`, and for events a
    `StandardMethodCodec` success envelope through `handlePlatformMessage`)
    — hand-rolled `readValueOfType(tag, buffer)` calls double-consume the
    tag byte and do not model the framework.
  - `ByteData.buffer.asUint8List()` includes buffer padding; slices must use
    `offsetInBytes`/`lengthInBytes` (caught by decodeMessage's
    trailing-bytes `FormatException`).
  - The quirk tests feed wire maps (type-as-index), not zorphy JSON
    (type-as-name) — two different serializations, both pinned.
- Deliberate-mutant matrix: 21/21 KILLED, 0 SURVIVED, reverts byte-identical
  (`tdd/mutant-run.md`; harness: mutant_matrix_publishable.py in the agent
  workspace).
- zfa tooling probe on the converted plugin: `zfa doctor` 0 errors / 2 info
  (manual GetIt registrations — by design, the composition root is the
  port seam); `zfa build` green. No zfa misfires this cycle. The genuine
  tooling gap — no plugin/platform-conversion preset (`--platforms`), which
  forced the hand-written dart→flutter profile conversion — is filed as
  zuraffa#800.
## Cycle: U2 (red)

- behavior: U2
- kind: red
- classification: assertionFailure
- subject-hash: e9bd0ee2f779863d0d98a65d5f61a1a50fdb2cff2703208c0edd9852d604405d
- criterion: FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart --plain-name "Wire-map fidelity — `sharedAttachmentWireMap` MUST produce"`
- exit: 1
- at: 2026-09-09T19:51:23.452850Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:04 +0: U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce                          
00:04 +0 -1: U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce [E]                   
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: provide a representative argument for subject_u2 (declared param 0: SharedAttachment)>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u2_test.dart 36:7   main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart -p vm --plain-name 'U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce'

00:04 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: genesis
- hash: 7ab6230cc5ae8760b407d9c65505beb7e5757ef6a40eb64f7af39ddc9e140a70

## Cycle: U2 (red)

- behavior: U2
- kind: red
- classification: assertionFailure
- subject-hash: e9bd0ee2f779863d0d98a65d5f61a1a50fdb2cff2703208c0edd9852d604405d
- criterion: FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart --plain-name "Wire-map fidelity — `sharedAttachmentWireMap` MUST produce"`
- exit: 1
- at: 2026-09-09T19:55:18.897277Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:03 +0: U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce                          
00:03 +0 -1: U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce [E]                   
  Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: provide a representative argument for subject_u2 (declared param 0: SharedAttachment)>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u2_test.dart 36:7   main.<fn>.<fn>
  

To run this test again: /Users/arrrrny/flutter/bin/cache/dart-sdk/bin/dart test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart -p vm --plain-name 'U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce'

00:03 +0 -1: Some tests failed.
```

- schema: 1
- prev-hash: 7ab6230cc5ae8760b407d9c65505beb7e5757ef6a40eb64f7af39ddc9e140a70
- hash: 0611ad0e6fbdabade0a19bf7952abf157e8d46088536704fc0900271a2ac1ff2

## Cycle: A6 (red)

- behavior: A6
- kind: red
- classification: assertionFailure
- subject-hash: 9daa5b6e3a8cb6c1105bb2d6fb3d38a1d86efc08619cd5dafdcb0c349d107a90
- criterion: AC-6
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.224898Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a6 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/a6_test.dart 30:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: a80f323996119a5f57c4542b89ecc1808746872f1e078f5dde0c80efaf97f1d0

## Cycle: A7 (red)

- behavior: A7
- kind: red
- classification: assertionFailure
- subject-hash: 63a654e62eaf01e1cf86bb30ab88ea6175fb24d3a35f52cb375d30faef32586a
- criterion: AC-7
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.260777Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a7 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/a7_test.dart 30:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 7088c2b7f6f2e11428954de7b6f4e3816fe5c7289f3e9c6f71c84d40c5567a09

## Cycle: A8 (red)

- behavior: A8
- kind: red
- classification: assertionFailure
- subject-hash: 434c008b26464bb478e287544aef8ff259bb1d79fe7e20cf7870fc00b2bb8844
- criterion: AC-8
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.269488Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a8 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/a8_test.dart 30:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 10636e8acb53da4047d8ec49570427d04a00aad82b5da5d0be7c1d37fe221ffa

## Cycle: U1 (red)

- behavior: U1
- kind: red
- classification: assertionFailure
- subject-hash: c7760edda794c27904df183c9bea91b138362900ed19eca8528dc0af03689860
- criterion: FR-001, publishability
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.277938Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u1 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u1_test.dart 29:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: c7b3804ac85068a5464fb9635e77c91fd7215ec70146ffd2b90275fef9cbcb81

## Cycle: U3 (red)

- behavior: U3
- kind: red
- classification: assertionFailure
- subject-hash: 092140d1db3cf435196f48022168fb606c47b8f5a65fcac295d51011c15710e6
- criterion: FR-003, ShareIntentsApiCodec.decodeMessage
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.286010Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: provide a representative argument for subject_u3 (declared param 0: ByteData?)>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u3_test.dart 36:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 63acef84da9595a7b35e3338dea2085a55a5ee4ba6bacc40b58778e79ece2d49

## Cycle: U4 (red)

- behavior: U4
- kind: red
- classification: assertionFailure
- subject-hash: 0027d2f89db83ee21256c4b3a76b0014ef15c53e71dc9f7573234c363ce64099
- criterion: FR-004, decodeSharedMedia.decodeSharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.294924Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: provide a representative argument for subject_u4 (declared param 0: Object?)>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u4_test.dart 36:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 0558361c55de76791550bbf7da518838e62d4af9fa42ee730806e6024255e0fb

## Cycle: U5 (red)

- behavior: U5
- kind: red
- classification: assertionFailure
- subject-hash: 34706a8b4ee610543c6fb4ebac0386a94be5dd7fabce9a6347aa81976a7a70c1
- criterion: FR-005, MethodChannelShareIntentPort.getInitialSharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.304508Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u5 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u5_test.dart 29:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 46eb61da9f3c5c892aec409fa76dbfb1f55ba6969e0898e2a0b28767a880faad

## Cycle: U6 (red)

- behavior: U6
- kind: red
- classification: assertionFailure
- subject-hash: 90213f7b04838cf91584e81122b96bc61d47e3fab91fe82227220d9bb8b71062
- criterion: FR-006, MethodChannelShareIntentPort.recordSentMessage
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.314046Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u6 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u6_test.dart 29:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 6ee119a25cd33045daf36d251649f0c7520800cd455a03dfdeb1d7ff5e962882

## Cycle: U7 (red)

- behavior: U7
- kind: red
- classification: assertionFailure
- subject-hash: c64c4f3ecaaad8764024b25a6d90730d0812d6510c5e423e102aa9de7003f458
- criterion: FR-007, MethodChannelShareIntentPort.resetInitialSharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.323347Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u7 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u7_test.dart 29:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: d089a824be90ac2a2836e39d8d2bd89556ebfb84514fd7f12416e400d7c132f3

## Cycle: U8 (red)

- behavior: U8
- kind: red
- classification: assertionFailure
- subject-hash: f64e3af9a9f5e731b6298e21c8223532688e51c73d154311d248584d9f822a07
- criterion: FR-008, MethodChannelShareIntentPort.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.333524Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u8 not implemented: sharedMediaStream() -> Stream<SharedMedia>>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u8_test.dart 35:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 1fc2fddd3216b0716fe3c8268b27d15abc57ab0439af64b4d6b60c088ddd473b

## Cycle: U9 (red)

- behavior: U9
- kind: red
- classification: assertionFailure
- subject-hash: fc27cf92665dcd5f1ca2589c7c8de05e560c53d062700b272f283d8c24a40a88
- criterion: FR-009, ShareIntentService.platform
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.386893Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: provide a representative argument for subject_u9 (declared param 0: {BinaryMessenger? binaryMessenger})>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u9_test.dart 36:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: b27a3590c1dc857a85e7ab4ebbe8ca6dccdf561dbfc095fe231f86db4d855de7

## Cycle: U10 (red)

- behavior: U10
- kind: red
- classification: assertionFailure
- subject-hash: ed066717ed27c984718e2eca337d28379792e57c7cdc140e2182d6c85230e96c
- criterion: FR-010, native consistency
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart`
- exit: 1
- at: 2026-09-09T19:56:08.398129Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_u10 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/u10_test.dart 29:7  main.<fn>.<fn>
  

(batched red — one runner invocation for 12 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: b11eb1ea7874be7729878dca247851cf5d23d2d4920c7013e660a7f89becc49a

## Cycle: U2 (green)

- behavior: U2
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 933fe1f412d2ef12d58efe2bdd4560d158eec9f8cad65162b1b82cb79957c5fa
- criterion: FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart --plain-name "Wire-map fidelity — `sharedAttachmentWireMap` MUST produce"`
- exit: 0
- at: 2026-09-09T20:07:44.087070Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:04 +0: U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce                          
00:04 +1: U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce                          
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 0611ad0e6fbdabade0a19bf7952abf157e8d46088536704fc0900271a2ac1ff2
- hash: 7b1de51041a2db013f1eacc6b62045ff4adb3401b2903633665513d5384edb3a

## Cycle: U1 (green)

- behavior: U1
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 9775dbad864970b0cd5ba1d25725432e1ac859236b64dd7ca36e8e51ed18beab
- criterion: FR-001, publishability
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart --plain-name "The package MUST be publish-ready for pub.dev: `pubspec.yaml`"`
- exit: 0
- at: 2026-09-09T20:07:50.207031Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u1_test.dart                                                                                                
00:03 +0: U1 (FR-001, publishability) U1 — The package MUST be publish-ready for pub.dev: `pubspec.yaml`                                                                                               
00:03 +1: U1 (FR-001, publishability) U1 — The package MUST be publish-ready for pub.dev: `pubspec.yaml`                                                                                               
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: c7b3804ac85068a5464fb9635e77c91fd7215ec70146ffd2b90275fef9cbcb81
- hash: 162f27a3b9eaf519d527bbdad98a7a4ae1872d4340cd391e72ca66a4035951db

## Cycle: U3 (green)

- behavior: U3
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 59967b5d39bd23c27e4c8e6fd66d4d7be7b4cb8f67359609378dc50f62132d94
- criterion: FR-003, ShareIntentsApiCodec.decodeMessage
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart --plain-name "The wire codec MUST be a `StandardMessageCodec` subclass that"`
- exit: 0
- at: 2026-09-09T20:07:57.473600Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart                                                                                                
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u3_test.dart                                                                                                
00:04 +0: U3 (FR-003, ShareIntentsApiCodec.decodeMessage) U3 — The wire codec MUST be a `StandardMessageCodec` subclass that                                                                           
00:04 +1: U3 (FR-003, ShareIntentsApiCodec.decodeMessage) U3 — The wire codec MUST be a `StandardMessageCodec` subclass that                                                                           
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 63acef84da9595a7b35e3338dea2085a55a5ee4ba6bacc40b58778e79ece2d49
- hash: 402fdb4ae377dac04ccbdc760d996ad7a8efe0f1e40e758fd86c7e17a35544a0

## Cycle: U4 (green)

- behavior: U4
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: fc1ca1a7c54f69e6b886d7463538dd7dfaf57e610c5a21e1aaf5b43d30fcb0cc
- criterion: FR-004, decodeSharedMedia.decodeSharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart --plain-name "The iOS/macOS attachment-path quirk — attachment paths"`
- exit: 0
- at: 2026-09-09T20:08:09.769691Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart                                                                                                
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart                                                                                                
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart                                                                                                
00:06 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart                                                                                                
00:07 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart                                                                                                
00:07 +0: U4 (FR-004, decodeSharedMedia.decodeSharedMedia) U4 — The iOS/macOS attachment-path quirk — attachment paths                                                                                 
00:07 +1: U4 (FR-004, decodeSharedMedia.decodeSharedMedia) U4 — The iOS/macOS attachment-path quirk — attachment paths                                                                                 
00:07 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 0558361c55de76791550bbf7da518838e62d4af9fa42ee730806e6024255e0fb
- hash: 8f76c862e71890ef9d2e109dcc4101b59ca6e9215a3423f55605d1125936569f

## Cycle: U5 (green)

- behavior: U5
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: d9a93bb28197c6949b42096f9f6f5e305277de5acf585b92f5d74ba8970da4fc
- criterion: FR-005, MethodChannelShareIntentPort.getInitialSharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart --plain-name "`getInitialSharedMedia` over the pigeon channel MUST map: a"`
- exit: 0
- at: 2026-09-09T20:08:20.786334Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart                                                                                                
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart                                                                                                
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart                                                                                                
00:06 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u5_test.dart                                                                                                
00:06 +0: U5 (FR-005, MethodChannelShareIntentPort.getInitialSharedMedia) U5 — `getInitialSharedMedia` over the pigeon channel MUST map: a                                                             
00:06 +1: U5 (FR-005, MethodChannelShareIntentPort.getInitialSharedMedia) U5 — `getInitialSharedMedia` over the pigeon channel MUST map: a                                                             
00:06 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 46eb61da9f3c5c892aec409fa76dbfb1f55ba6969e0898e2a0b28767a880faad
- hash: 6e9a73226457b2bb31066aaae2fad2e317f90cddf6855d60a9533aa570d9a4cb

## Cycle: U6 (green)

- behavior: U6
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: f977dae5f279a6ad502ec5763ad281b6f896d848f2610fd4a252d148afa441d1
- criterion: FR-006, MethodChannelShareIntentPort.recordSentMessage
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart --plain-name "`recordSentMessage` MUST send the single-element envelope"`
- exit: 0
- at: 2026-09-09T20:08:31.072945Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart                                                                                                
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart                                                                                                
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u6_test.dart                                                                                                
00:05 +0: U6 (FR-006, MethodChannelShareIntentPort.recordSentMessage) U6 — `recordSentMessage` MUST send the single-element envelope                                                                   
00:06 +0: U6 (FR-006, MethodChannelShareIntentPort.recordSentMessage) U6 — `recordSentMessage` MUST send the single-element envelope                                                                   
00:06 +1: U6 (FR-006, MethodChannelShareIntentPort.recordSentMessage) U6 — `recordSentMessage` MUST send the single-element envelope                                                                   
00:06 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 6ee119a25cd33045daf36d251649f0c7520800cd455a03dfdeb1d7ff5e962882
- hash: 3f874dfee1221e4a98b1441101b1e009af6d827195c7c6128cda5a905f46d71f

## Cycle: U7 (green)

- behavior: U7
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 764a3d9086fd2c1f8eb8003f7e0201fc414a99f6936fbd6dd49601ea3f54851c
- criterion: FR-007, MethodChannelShareIntentPort.resetInitialSharedMedia
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart --plain-name "`resetInitialSharedMedia` MUST send a null payload on its"`
- exit: 0
- at: 2026-09-09T20:08:40.778403Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart                                                                                                
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart                                                                                                
00:05 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u7_test.dart                                                                                                
00:05 +0: U7 (FR-007, MethodChannelShareIntentPort.resetInitialSharedMedia) U7 — `resetInitialSharedMedia` MUST send a null payload on its                                                             
00:05 +1: U7 (FR-007, MethodChannelShareIntentPort.resetInitialSharedMedia) U7 — `resetInitialSharedMedia` MUST send a null payload on its                                                             
00:05 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: d089a824be90ac2a2836e39d8d2bd89556ebfb84514fd7f12416e400d7c132f3
- hash: c06a63ff9a0d7a0c8f108b9906cb00dcd9575bddb4ee953981665ac1d4975b6a

## Cycle: U8 (green)

- behavior: U8
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: a067a1de2704af27ceaef2704ef6fac3dfd64bcd519050db0afa5e930a564501
- criterion: FR-008, MethodChannelShareIntentPort.sharedMediaStream
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart --plain-name "`sharedMediaStream` MUST be the `EventChannel"`
- exit: 0
- at: 2026-09-09T20:08:47.992606Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart                                                                                                
00:03 +0: U8 (FR-008, MethodChannelShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be the `EventChannel                                                                               
00:03 +1: U8 (FR-008, MethodChannelShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be the `EventChannel                                                                               
00:04 +1: U8 (FR-008, MethodChannelShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be the `EventChannel                                                                               
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 1fc2fddd3216b0716fe3c8268b27d15abc57ab0439af64b4d6b60c088ddd473b
- hash: 63837266515d8b2f0b13c8d2d56a9b709706321969ade68399a8cc70a2ada7c5

## Cycle: U9 (green)

- behavior: U9
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 468ea501980822e2ade20fbebb8e19f96498140c2f3acf4a521969aa3c820f8b
- criterion: FR-009, ShareIntentService.platform
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart --plain-name "Platform wiring — `ShareIntentService.platform()` MUST be a"`
- exit: 0
- at: 2026-09-09T20:08:54.667149Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u9_test.dart                                                                                                
00:03 +0: U9 (FR-009, ShareIntentService.platform) U9 — Platform wiring — `ShareIntentService.platform()` MUST be a                                                                                    
00:03 +1: U9 (FR-009, ShareIntentService.platform) U9 — Platform wiring — `ShareIntentService.platform()` MUST be a                                                                                    
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: b27a3590c1dc857a85e7ab4ebbe8ca6dccdf561dbfc095fe231f86db4d855de7
- hash: dc07e76a928ad706a86ac75bbfd57e4d6ca8c6e28e569e762a12ffc079861341

## Cycle: U10 (green)

- behavior: U10
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 5370f0a5c144d1d890ab8f3ef01ad506b21d8a55e16554c88d8c626c51225562
- criterion: FR-010, native consistency
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart --plain-name "Native port consistency — the ported native trees"`
- exit: 0
- at: 2026-09-09T20:09:00.205963Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart                                                                                               
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart                                                                                               
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u10_test.dart                                                                                               
00:02 +0: U10 (FR-010, native consistency) U10 — Native port consistency — the ported native trees                                                                                                     
00:02 +1: U10 (FR-010, native consistency) U10 — Native port consistency — the ported native trees                                                                                                     
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: b11eb1ea7874be7729878dca247851cf5d23d2d4920c7013e660a7f89becc49a
- hash: 860b909d8d5493889236af66769f92720fe3abb17e71dd68aae837d4077f2ac5

## Cycle: A6 (green)

- behavior: A6
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 8fddd4659b3395916e4679c1b70a5c8958020209295987b7d2f8e04119b660c4
- criterion: AC-6
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart --plain-name "each yields the identical lazy-singleton instance"`
- exit: 0
- at: 2026-09-09T20:09:05.796161Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a6_test.dart                                                                                                
00:02 +0: A6 (AC-6) A6 — each yields the identical lazy-singleton instance                                                                                                                             
00:02 +1: A6 (AC-6) A6 — each yields the identical lazy-singleton instance                                                                                                                             
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: a80f323996119a5f57c4542b89ecc1808746872f1e078f5dde0c80efaf97f1d0
- hash: 030e373b66235432e413a4759f6bb873dc8dc9de91667a8d1920f0122c24a3d7

## Cycle: A7 (green)

- behavior: A7
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 839397a81b287b0a1112e55f36b2292d0900e4accbe59b487ea55a4641521c7f
- criterion: AC-7
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart --plain-name "the three pigeon channel literals and the event"`
- exit: 0
- at: 2026-09-09T20:09:11.811303Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a7_test.dart                                                                                                
00:03 +0: A7 (AC-7) A7 — the three pigeon channel literals and the event                                                                                                                               
00:03 +1: A7 (AC-7) A7 — the three pigeon channel literals and the event                                                                                                                               
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 7088c2b7f6f2e11428954de7b6f4e3816fe5c7289f3e9c6f71c84d40c5567a09
- hash: d76ebbdc91d73f03b3a6d31bac745251c502f45bf3830c63e2ff5637cc83928b

## Cycle: A8 (green)

- behavior: A8
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: b8abe79916c447ab10fa017899d615ff90fa7430317e794b889fe966b28bd8ac
- criterion: AC-8
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart --plain-name "`pubspec.yaml` declares the plugin for exactly android, ios,"`
- exit: 0
- at: 2026-09-09T20:09:18.120894Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a8_test.dart                                                                                                
00:03 +0: A8 (AC-8) A8 — `pubspec.yaml` declares the plugin for exactly android, ios,                                                                                                                  
00:03 +1: A8 (AC-8) A8 — `pubspec.yaml` declares the plugin for exactly android, ios,                                                                                                                  
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 10636e8acb53da4047d8ec49570427d04a00aad82b5da5d0be7c1d37fe221ffa
- hash: 39f3910ac7473e49c2d3f06b2aa64f7d22d45ea2dffb042bc3bf69d5a2801018

## Cycle: U2 (green)

- behavior: U2
- kind: green
- subject-hash: 933fe1f412d2ef12d58efe2bdd4560d158eec9f8cad65162b1b82cb79957c5fa
- criterion: FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart --plain-name "Wire-map fidelity — `sharedAttachmentWireMap` MUST produce"`
- exit: 0
- at: 2026-09-09T20:09:55.574340Z
- output:
```
Resolving dependencies...
Downloading packages...
  ansi_escape_codes 2.2.1 (4.0.1 available)
  gql_dedupe_link 2.0.4-alpha+1715521079596 (4.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:04 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart                                                                                                
00:04 +0: U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce                          
00:04 +1: U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap) U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce                          
00:04 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 7b1de51041a2db013f1eacc6b62045ff4adb3401b2903633665513d5384edb3a
- hash: 2adde2df6bcdbec9776f5ea238e7f5d0443d62fb82973b16d6d4824e76af5009

## Cycle: 002-publishable-plugin-refactor (refactor)

- behavior: 002-publishable-plugin-refactor
- kind: refactor
- criterion: FR-007
- test: test/
- command: `flutter test "test/tdd/002-publishable-plugin/a7_test.dart" "test/tdd/002-publishable-plugin/u10_test.dart" "test/tdd/002-publishable-plugin/u1_test.dart" "test/tdd/002-publishable-plugin/u2_test.dart" "test/tdd/002-publishable-plugin/u4_test.dart" "test/tdd/002-publishable-plugin/u8_test.dart"`
- exit: 0
- at: 2026-09-09T20:10:45.452531Z
- output:
```
preflight: green
re-proof: green
re-proof verdict: green (exit 0)
re-proof retries: 0
re-proof output tail (stdout+stderr, truncated):
...(truncated)
00:03 +4: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart: ... U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce                                   
00:04 +4: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u2_test.dart: ... U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce                                   
00:04 +4: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart                                                                                                
00:04 +4: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart: ... decodeSharedMedia.decodeSharedMedia) U4 — The iOS/macOS attachment-path quirk — attachment paths  
00:04 +5: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u4_test.dart: ... decodeSharedMedia.decodeSharedMedia) U4 — The iOS/macOS attachment-path quirk — attachment paths  
00:04 +5: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart                                                                                                
00:04 +5: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart: ... MethodChannelShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be the `EventChannel
00:05 +5: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart: ... MethodChannelShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be the `EventChannel
00:05 +6: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/u8_test.dart: ... MethodChannelShareIntentPort.sharedMediaStream) U8 — `sharedMediaStream` MUST be the `EventChannel
00:05 +6: All tests passed!
re-proof: scoped (6 covering test(s) for 6 changed file(s); spec 069 T001 — the full gate runs at feature completion + nightly)
receipts refreshed: 6 receipted artifact(s) re-hashed (sanctioned refactor provenance, issue #1311)
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
  changed: lib/tdd/002-publishable-plugin/a7_subject.dart, lib/tdd/002-publishable-plugin/u10_subject.dart, lib/tdd/002-publishable-plugin/u1_subject.dart, lib/tdd/002-publishable-plugin/u2_subject.dart, lib/tdd/002-publishable-plugin/u4_subject.dart, lib/tdd/002-publishable-plugin/u8_subject.dart
- action: fix
  command: `dart fix --apply lib/`
  exit: 0
  changed: (none)

- schema: 1
- prev-hash: genesis
- hash: dc7be12521a169439a6b13fa010d044af88ba450bdc023115ff88a1d574e3d66

## Two-cycle run: 002-publishable-plugin

- feature: 002-publishable-plugin
- engine-receipt: 04-engine-receipt.json (verdict: green)
- skin-receipt: 04-skin-receipt.json (verdict: green)
- at: 2026-09-09T20:10:45.493542Z

## Cycle: A1 (red)

- behavior: A1
- kind: red
- classification: assertionFailure
- subject-hash: 0f0ec1cae1c3243ff45134b4e74cdc14d4f8c6ca0af72f7e3926713ef2966304
- criterion: AC-1
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart`
- exit: 1
- at: 2026-09-09T20:12:25.632008Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a1 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/a1_test.dart 30:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 5 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: a120034aa0318d4ac042763c0322097f13aae0cab133dc27a34bf096ec9f667e

## Cycle: A2 (red)

- behavior: A2
- kind: red
- classification: assertionFailure
- subject-hash: bec9a6dc7a2b792a41cdcc915ee276881727978f0093db1e8cff9566f182c5f8
- criterion: AC-2
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart`
- exit: 1
- at: 2026-09-09T20:12:25.644881Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a2 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/a2_test.dart 30:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 5 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: a77db1dcb811b5d7ba59de16403f6fdf6782325dc225b90f2407e64e4abae503

## Cycle: A3 (red)

- behavior: A3
- kind: red
- classification: assertionFailure
- subject-hash: bcaac43b117ef3187070fc6d2a99d7891c96c120f62965076856f951a713fe66
- criterion: AC-3
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart`
- exit: 1
- at: 2026-09-09T20:12:25.655495Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a3 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/a3_test.dart 30:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 5 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 724a1005174036fd54dafbfe015f2d87edec955b2093a1d2bd588105bfdd5a19

## Cycle: A4 (red)

- behavior: A4
- kind: red
- classification: assertionFailure
- subject-hash: 2a2e3e55a100d0da49e7080fb108c47d3f456595d23ddeefb4078380ad7143c6
- criterion: AC-4
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart`
- exit: 1
- at: 2026-09-09T20:12:25.665975Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a4 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/a4_test.dart 30:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 5 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 511cd3bffd599eaabed0caa10a8ba305d3e0be983379b58d4cb4893e21d2c11c

## Cycle: A5 (red)

- behavior: A5
- kind: red
- classification: assertionFailure
- subject-hash: d5355c0b7ea74225a27169d31a9c2d529ed37d2195eefb6dd6a064a89a748cdd
- criterion: AC-5
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart`
- exit: 1
- at: 2026-09-09T20:12:25.677505Z
- output:
```
Expected: not <Instance of 'UnimplementedError'>
    Actual: UnimplementedError:<UnimplementedError: subject_a5 not implemented>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tdd/002-publishable-plugin/a5_test.dart 30:7   main.<fn>.<fn>
  

(batched red — one runner invocation for 5 behavior(s), spec 069 T002)
```

- schema: 1
- prev-hash: genesis
- hash: 55d17435583e7e277129a248fe6946b024ddda46c3617d15a51ca7bb98902958

## Cycle: A1 (green)

- behavior: A1
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 659c9911170296eaca92edc590a99b41e72f480d48d66c31dae47f46c06f385b
- criterion: AC-1
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart --plain-name "a `{result: <wire map>}` reply decodes into the"`
- exit: 0
- at: 2026-09-09T20:14:33.127920Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a1_test.dart                                                                                                
00:03 +0: A1 (AC-1) A1 — a `{result: <wire map>}` reply decodes into the                                                                                                                               
00:03 +1: A1 (AC-1) A1 — a `{result: <wire map>}` reply decodes into the                                                                                                                               
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: a120034aa0318d4ac042763c0322097f13aae0cab133dc27a34bf096ec9f667e
- hash: 3ce177738bbdf1d3a511ba8e47d83c06d278774cbdaa4393e83cb74f90299957

## Cycle: A2 (green)

- behavior: A2
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: c45eb0f47e71b8ecce150c9835213a393c9139d5a8a392a5c14bff8d6d4305cd
- criterion: AC-2
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart --plain-name "the payload is the single-element `[SharedMedia]`"`
- exit: 0
- at: 2026-09-09T20:14:38.480045Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a2_test.dart                                                                                                
00:02 +0: A2 (AC-2) A2 — the payload is the single-element `[SharedMedia]`                                                                                                                             
00:03 +0: A2 (AC-2) A2 — the payload is the single-element `[SharedMedia]`                                                                                                                             
00:03 +1: A2 (AC-2) A2 — the payload is the single-element `[SharedMedia]`                                                                                                                             
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: a77db1dcb811b5d7ba59de16403f6fdf6782325dc225b90f2407e64e4abae503
- hash: 500924ac340b555171b4ca7f6d23d379df4f3941551992b1c9b566fec36bc3b7

## Cycle: A3 (green)

- behavior: A3
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: e304db1908133a5f62cee14a6b58d91893763f91bf1d000b80b6cd5570e1ff24
- criterion: AC-3
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart --plain-name "it completes on `{result: null}` and"`
- exit: 0
- at: 2026-09-09T20:14:43.626932Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart                                                                                                
00:03 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a3_test.dart                                                                                                
00:03 +0: A3 (AC-3) A3 — it completes on `{result: null}` and                                                                                                                                          
00:03 +1: A3 (AC-3) A3 — it completes on `{result: null}` and                                                                                                                                          
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 724a1005174036fd54dafbfe015f2d87edec955b2093a1d2bd588105bfdd5a19
- hash: 9942bb380eb5228a91e5d313a14da04ea0a1817145963fa229152912e024b737

## Cycle: A4 (green)

- behavior: A4
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 363b7b8264d5a7a3a7128a62031c689103eba48af50360f2943c5cfadac36253
- criterion: AC-4
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart --plain-name "the decoded `SharedAttachment` paths are `Uri.decodeFull`-expanded;"`
- exit: 0
- at: 2026-09-09T20:14:48.179150Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a4_test.dart                                                                                                
00:02 +0: A4 (AC-4) A4 — the decoded `SharedAttachment` paths are `Uri.decodeFull`-expanded;                                                                                                           
00:02 +1: A4 (AC-4) A4 — the decoded `SharedAttachment` paths are `Uri.decodeFull`-expanded;                                                                                                           
00:02 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 511cd3bffd599eaabed0caa10a8ba305d3e0be983379b58d4cb4893e21d2c11c
- hash: 02f4dcc7a4f2b7e0c1d54eee6d5269c869cada06e00440933a22871f64b82bfc

## Cycle: A5 (green)

- behavior: A5
- kind: green
- evidence: issue #1162 re-certification — the subject was hand-implemented after the certified red; this green evidence binds the NEW subject shape with the passing transcript
- subject-hash: 4d035bd868d2b63b1087730385d8eb4b7ce723ddd8f7c692a0260f06ec438fb1
- criterion: AC-5
- test: /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart
- command: `flutter test /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart --plain-name "each receives every post-subscription native"`
- exit: 0
- at: 2026-09-09T20:14:53.244556Z
- output:
```
00:00 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart                                                                                                
00:01 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart                                                                                                
00:02 +0: loading /Users/arrrrny/Developer/zuraffa_intents/test/tdd/002-publishable-plugin/a5_test.dart                                                                                                
00:02 +0: A5 (AC-5) A5 — each receives every post-subscription native                                                                                                                                  
00:03 +0: A5 (AC-5) A5 — each receives every post-subscription native                                                                                                                                  
00:03 +1: A5 (AC-5) A5 — each receives every post-subscription native                                                                                                                                  
00:03 +1: All tests passed!
```
- generation:
  (none)
- suite: baseline=0 guard=0 new=(none)

- schema: 1
- prev-hash: 55d17435583e7e277129a248fe6946b024ddda46c3617d15a51ca7bb98902958
- hash: 54fd61e76056d66c57ea93e1a8e695bf6c2fe893ace69ab3de1f5e0b2453c920

