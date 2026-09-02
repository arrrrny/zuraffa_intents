---
feature: 002-publishable-plugin
loop: outside-in # the wire contract (pigeon channels + event channel + packaging) is the acceptance surface
profile: .specify/memory/tdd-profile.md # flutter stack profile (flutter test; converted from dart for this spec)
spec_criteria: 10 # the 10 FRs (FR-001..FR-010) act as the criteria
planned_at: 2384ab0 # short SHA the list was derived from (feat/002 harness commit)
updated_at: 2384ab0
suite_baseline: green # 20/20 at planning (bootstrap smoke + spec-001's U1..U19) under flutter test
---

# Test List: 002-publishable-plugin

> Derived from `spec.md`. The feature is **brownfield with a greenfield
> layer**: spec-001's 19 behaviors plus the bootstrap smoke test are the
> frozen baseline (20/20 under `flutter test`), and the platform-interface
> layer is built **test-first** in `test/platform_interface_suite_test.dart`
> (U20..U40). Red is observed as the suite failing against the absent API
> (compile failure for not-yet-written symbols, assertion failures for
> packaging/consistency checks that the harness commit already half-satisfies
> — recorded per-cycle in `tdd/cycle-log.md`). After green, each behavior is
> additionally validated against a deliberate mutant — the targeted test
> must FAIL via the profile's single command (`flutter test
> test/platform_interface_suite_test.dart --plain-name "<id>:"`) and the
> mutant must be reverted byte-identically (recorded in
> `tdd/mutant-run.md`).

## Outer loop: acceptance behaviors

The plugin surface — `sharedAttachmentWireMap`, `sharedMediaWireMap`,
`ShareIntentsApiCodec`, `MethodChannelShareIntentPort`,
`ShareIntentService.platform`, `registerShareIntentDependencies` (upgraded),
`pubspec.yaml` plugin declaration, and the ported native trees — is
exercised as the acceptance surface for every FR, over mocked
`BinaryMessenger` plumbing (`TestDefaultBinaryMessengerBinding`).

## Inner loop: unit behaviors

Grouped by the component from the platform-interface layer that owns them.

### `lib/src/platform/wire/share_intents_wire.dart` (FR-002, FR-003, FR-004)

| id | behavior                                                                                                                 | traces  | kind  | state   | test |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------- | ----- | ------- | ---- |
| U20 | sharedAttachmentWireMap produces exactly {path, type: index} for every vocabulary kind                                    | FR-002  | unit  | planned | `test('U20: …')` |
| U21 | sharedMediaWireMap carries all nine keys with nulls preserved, attachments serialized as wire maps                        | FR-002  | unit  | planned | `test('U21: …')` |
| U22 | the codec round-trips SharedMedia through ByteData (tag 129 envelope out, entity back in)                                 | FR-003  | unit  | planned | `test('U22: …')` |
| U23 | the codec decodes the native-emitted plain map (attachments as maps, nullable recipientIdentifiers) into entities         | FR-003  | unit  | planned | `test('U23: …')` |
| U24 | the codec decodes tags 128 (attachment) and 130 (legacy duplicate media tag) as well as 129                               | FR-003  | unit  | planned | `test('U24: …')` |
| U25 | decode applies Uri.decodeFull to attachment paths iff the apple-like predicate holds; predicate is injectable; default is !kIsWeb && (isIOS \|\| isMacOS) | FR-004 | unit | planned | `test('U25: …')` |

### `lib/src/platform/method_channel/method_channel_share_intent_port.dart` (FR-005..FR-008)

| id | behavior                                                                                                                 | traces  | kind  | state   | test |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------- | ----- | ------- | ---- |
| U26 | getInitialSharedMedia decodes a {result: wire map} reply into SharedMedia and a null result to null                        | FR-005  | unit  | planned | `test('U26: …')` |
| U27 | getInitialSharedMedia maps an {error: {code,message,details}} reply to PlatformException with those exact fields          | FR-005  | unit  | planned | `test('U27: …')` |
| U28 | a null reply (channel missing) surfaces PlatformException(code: channel-error) with the canonical message                  | FR-005  | unit  | planned | `test('U28: …')` |
| U29 | recordSentMessage sends the single-element SharedMedia envelope carrying the argument mapping; a {result: null} reply completes | FR-006 | unit | planned | `test('U29: …')` |
| U30 | recordSentMessage error and null replies follow the FR-005 semantics                                                       | FR-006  | unit  | planned | `test('U30: …')` |
| U31 | resetInitialSharedMedia sends a null payload and {result: null} completes; error and null replies follow FR-005            | FR-007  | unit  | planned | `test('U31: …')` |
| U32 | sharedMediaStream decodes native event maps into SharedMedia (quirk applied per the predicate)                             | FR-008  | unit  | planned | `test('U32: …')` |
| U33 | sharedMediaStream is a lazy singleton per port instance — repeated access yields the identical stream                      | FR-008  | unit  | planned | `test('U33: …')` |

### `lib/src/share_intent_service.dart` (FR-009)

| id | behavior                                                                                                                 | traces  | kind  | state   | test |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------- | ----- | ------- | ---- |
| U34 | ShareIntentService.platform() binds the method-channel driver (and accepts a BinaryMessenger); direct construction keeps the in-memory default | FR-009 | unit | planned | `test('U34: …')` |
| U35 | registerShareIntentDependencies binds ShareIntentPort to the method-channel driver and the service to that port, both lazy singletons | FR-009 | unit | planned | `test('U35: …')` |

### packaging & native consistency (FR-001, FR-010)

| id | behavior                                                                                                                 | traces  | kind  | state   | test |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------- | ----- | ------- | ---- |
| U36 | pubspec.yaml is publish-ready: six platforms declared with the rebranded classes, repository/issue_tracker present, description ≤ 180 chars, flutter floor present | FR-001 | unit | planned | `test('U36: …')` |
| U37 | every podspec/Package.swift/fileName path declared by pubspec.yaml exists on disk and CHANGELOG's head entry matches the package version | FR-001 | unit | planned | `test('U37: …')` |
| U38 | the event channel literal is identical in the Dart wire module and in the Android/iOS/macOS native plugins                 | FR-010  | unit  | planned | `test('U38: …')` |
| U39 | the three ZuraffaIntentsApi pigeon channel literals are identical in the Dart wire module, Pigeon Java, and both Swift APIs | FR-010 | unit | planned | `test('U39: …')` |
| U40 | the ported native trees carry the rebranded plugin classes and contain zero leftover zikzak/ShareHandler identifiers       | FR-010  | unit  | planned | `test('U40: …')` |
