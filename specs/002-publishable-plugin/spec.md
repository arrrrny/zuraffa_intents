# Feature Specification: publishable-plugin — the platform-interface layer

**Template Version**: `zuraffa-1.0`

**Feature Branch**: `002-publishable-plugin`

**Created**: 2026-09-02

**Status**: Approved (brownfield: `zuraffa_intents` grows from the merged
pure-Dart contract (spec-001) into a fully publishable pub.dev **Flutter
plugin** that replaces `zikzak_share_handler` end to end — the Dart
platform-interface layer is built test-first, and the native
implementations are ported from `zikzak_share_handler` (battle-tested code)
with systematic identifier rebranding; refined 2026-09-09 to the
zuraffa-1.0 grammar and to the repo's three-platform scope
(android/ios/macos — linux/windows/web were removed from master))

**Input**: Refinement of the approved 2026-09-02 spec to the latest
zuraffa spec version (`zuraffa-1.0`, zuraffa#1000 + zuraffa#1186) and to
the current platform matrix; the wire contract is unchanged.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The Dart↔native wire speaks the plugin's Pigeon shape (Priority: P1)

An app calls `getInitialSharedMedia`, `recordSentMessage`, or
`resetInitialSharedMedia` through the port. On the wire each operation owns
a `BasicMessageChannel` under `dev.flutter.pigeon.ZuraffaIntentsApi.*`,
carries type-tagged entity maps (`SharedAttachment` tag 128, `SharedMedia`
tags 129/130 — the pigeon sources register the payload under two tags, both
accepted), and replies in the pigeon envelope: `{result: <wire map>}` /
`{result: null}` complete normally, `{error: {code, message, details}}`
becomes a `PlatformException` with those exact fields, and a null reply
(channel missing) becomes `PlatformException(code: 'channel-error')`.
`recordSentMessage` sends the single-element `[SharedMedia]` envelope the
pigeon native handler casts.

**Why this priority**: this is the actual transport — every receive/record
on a device flows through these channels; a tag, key, or envelope drift
breaks the plugin against its native halves silently.

**Independent Test**: Can be fully tested by driving the port over a mocked
`BinaryMessenger` (`TestDefaultBinaryMessengerBinding`), replaying each
reply shape, and asserting the decoded entities/exceptions plus the exact
outbound envelopes and channel literals. Delivers: the method-channel
contract pinned on both directions.

**Acceptance Scenarios**:

1. **Given** a stored initial share on the native side, **When**
   `getInitialSharedMedia` runs over the pigeon channel with a mocked
   messenger, **Then** a `{result: <wire map>}` reply decodes into the
   `SharedMedia`, a null/absent result yields `null`, an
   `{error: {code, message, details}}` reply throws a `PlatformException`
   carrying those exact fields, and a null reply throws
   `PlatformException(code: 'channel-error')` with the canonical message
   **Type**: platform
2. **Given** a `recordSentMessage` call, **When** the port sends over its
   channel, **Then** the payload is the single-element `[SharedMedia]`
   envelope with the plugin's argument mapping
   (`conversationName` → `speakableGroupName`,
   `conversationImageFilePath` → `imageFilePath`,
   `serviceName` → `serviceName`, `conversationIdentifier` →
   `conversationIdentifier`), and a `{result: null}` reply completes
   normally
   **Type**: platform
3. **Given** `resetInitialSharedMedia`, **When** the port sends a null
   payload on its channel, **Then** it completes on `{result: null}` and
   error/null replies follow the FR-005 semantics
   **Type**: platform

---

### User Story 2 - Live shares arrive on the event channel with the Apple path quirk (Priority: P1)

While the app runs, the native side pushes shares to the
`EventChannel('dev.zuraffa.zuraffa_intents/sharedMediaStream')` as plain
maps; the Dart side decodes every event into a `SharedMedia`, running
attachment paths through `Uri.decodeFull` exactly when the platform
predicate says "apple-like" (injectable for tests, defaulting to
`!kIsWeb && (Platform.isIOS || Platform.isMacOS)` — short-circuiting before
`dart:io` so web never touches it). The stream is broadcast and a
per-port lazy singleton.

**Why this priority**: the live stream is the day-to-day receive path on
devices, and the `Uri.decodeFull` quirk is the #1 wire-compat hazard
against the source plugin — attachment paths that arrive percent-encoded
must decode exactly on iOS/macOS and nowhere else.

**Independent Test**: Can be fully tested by emitting native maps on the
event channel over a mocked messenger (percent-encoded and plain paths,
`recipientIdentifiers` with nullable elements) and asserting decoded
entities, predicate-gated decoding, and stream identity. Delivers: the
event-channel contract with the quirk pinned.

**Acceptance Scenarios**:

1. **Given** a native event carrying a wire map with percent-encoded
   attachment paths, **When** the apple-like predicate is true, **Then**
   the decoded `SharedAttachment` paths are `Uri.decodeFull`-expanded;
   **When** it is false, **Then** paths stay verbatim
   **Type**: platform
2. **Given** repeated access to `sharedMediaStream`, **When** two listeners
   are attached, **Then** each receives every post-subscription native
   event, pre-subscription events are not replayed, and repeated access
   yields the identical stream instance
   **Type**: platform

---

### User Story 3 - The plugin is wired, consistent with its natives, and publishable (Priority: P2)

`ShareIntentService.platform()` binds the method-channel driver (optionally
parameterized by a `BinaryMessenger`); `registerShareIntentDependencies`
binds the port to the driver and the service to that port as lazy
singletons while direct `ShareIntentService()` construction keeps the
spec-001 in-memory default. The ported native trees (android Kotlin +
Pigeon Java, iOS/macOS Swift over SPM + podspecs) carry exactly the channel
literals the Dart side uses, zero leftover `zikzak`/`ShareHandler`
identifiers, and payload keys matching the Dart wire maps — enforced by a
Dart-side consistency suite. The package declares exactly the three
platforms (android `dev.zuraffa.zuraffa_intents`/`ZuraffaIntentsPlugin`,
ios and macos podspecs that exist on disk) plus repository/issue_tracker, a
description ≤ 180 chars, BSD-3 LICENSE, and a CHANGELOG whose head entry
matches the package version.

**Why this priority**: without the wiring the plugin is unusable in a real
app; without the consistency suite a native rename desynchronizes the
halves silently; without publishability none of it ships.

**Independent Test**: Can be fully tested by resolving the DI bindings
(identical instances), scanning the native trees for the channel literals
and rebranded identifiers, validating payload-key parity against the Dart
wire maps, and checking the packaging contract. Delivers: a shippable,
drift-proof plugin.

**Acceptance Scenarios**:

1. **Given** `registerShareIntentDependencies` on a fresh `GetIt`,
   **When** `ShareIntentPort` and `ShareIntentService` are resolved
   repeatedly, **Then** each yields the identical lazy-singleton instance
   and the service's port is the method-channel driver, while direct
   `ShareIntentService()` construction still defaults to the in-memory
   adapter
   **Type**: acceptance
2. **Given** the ported native trees, **When** the consistency suite
   scans them, **Then** the three pigeon channel literals and the event
   channel literal match the Dart wire module, zero `zikzak`/`ShareHandler`
   identifiers remain, the rebranded plugin classes are declared, and every
   native payload key the Dart wire maps emit is present in each native
   toMap/toDictionary
   **Type**: acceptance
3. **Given** the package tree, **When** the publish contract is checked,
   **Then** `pubspec.yaml` declares the plugin for exactly android, ios,
   and macos with the rebranded package/class and existing podspec paths,
   carries `repository`/`issue_tracker`, a description ≤ 180 chars, and a
   `CHANGELOG.md` head entry matching the package version
   **Type**: acceptance

---

### Edge Cases

- What happens when the native side replies null on a method channel (the
  channel is missing)? A canonical `PlatformException(code:
  'channel-error')` — never a silent success.
- What happens when the pigeon sources decode a payload under tag 130
  instead of 129? Both tags decode into the same entity (wire
  compatibility).
- What happens when `recipientIdentifiers` contains a null element over
  the wire? The nullable element survives decode (cast through).
- What happens when the apple-like predicate is injected as always-false on
  iOS builds in tests? Paths stay verbatim — the predicate, not the
  platform, decides.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The package MUST be publish-ready for pub.dev: `pubspec.yaml`
  declares a Flutter plugin for exactly three platforms — android (package
  `dev.zuraffa.zuraffa_intents`, class `ZuraffaIntentsPlugin`), ios and
  macos (`pluginClass: ZuraffaIntentsPlugin` + podspec paths that exist on
  disk) — plus `repository`/`issue_tracker`, a description ≤ 180 chars,
  `LICENSE` (BSD-3), and a `CHANGELOG.md` whose head entry matches the
  package version. The package declares no web/linux/windows surface and
  carries no dead web registration code or `flutter_web_plugins`
  dependency.
  traces: publishability
- **FR-002**: Wire-map fidelity — `sharedAttachmentWireMap` MUST produce
  exactly `{path, type: <index>}` and `sharedMediaWireMap` MUST produce a
  map carrying **all nine** keys (`attachments`, `recipientIdentifiers`,
  `conversationIdentifier`, `content`, `speakableGroupName`, `serviceName`,
  `senderIdentifier`, `imageFilePath`, `subject`) with `null`s preserved
  (the native sides read by key; omitted keys vs null keys must not be
  distinguishable on the wire), attachments serialized as wire maps.
  traces: sharedAttachmentWireMap, sharedMediaWireMap
- **FR-003**: The wire codec MUST be a `StandardMessageCodec` subclass that
  (a) encodes `SharedMedia` under tag 129 wrapping the wire map and (b)
  decodes tags 128 (SharedAttachment), 129 and 130 (SharedMedia — the
  pigeon-generated sources register the same payload type under two tags;
  both are accepted for wire compatibility) back into the zorphy entities.
  Decoding MUST also accept the plain-map shape the native sides emit
  (attachments as a list of maps, `recipientIdentifiers` with nullable
  elements cast through).
  traces: ShareIntentsApiCodec
- **FR-004**: The iOS/macOS attachment-path quirk — attachment paths
  decoded from the wire MUST be run through `Uri.decodeFull` exactly when
  the platform predicate says "apple-like"; the predicate MUST be
  injectable for tests and MUST default to `!kIsWeb && (Platform.isIOS ||
  Platform.isMacOS)` (short-circuiting before `dart:io` so web never
  touches it — a latent web crash in the hand-rolled source this plugin
  replaces).
  traces: decodeSharedMedia
- **FR-005**: `getInitialSharedMedia` over the pigeon channel MUST map: a
  `{result: <wire map>}` reply to the decoded `SharedMedia`; a null/absent
  result to `null`; an `{error: {code, message, details}}` reply to a
  `PlatformException` carrying those exact fields; and a null reply
  (channel missing) to `PlatformException(code: 'channel-error')` with the
  canonical message.
  traces: MethodChannelShareIntentPort.getInitialSharedMedia
- **FR-006**: `recordSentMessage` MUST send the single-element envelope
  `[SharedMedia]` (the pigeon native handler casts argument 0, so the
  type-tagged envelope is mandatory) with the spec-001 argument mapping
  into the carrier (`conversationName` → `speakableGroupName`,
  `conversationImageFilePath` → `imageFilePath`, `serviceName` →
  `serviceName`, `conversationIdentifier` → `conversationIdentifier`); a
  `{result: null}` reply completes normally; error/null replies follow
  FR-005 semantics.
  traces: MethodChannelShareIntentPort.recordSentMessage
- **FR-007**: `resetInitialSharedMedia` MUST send a null payload on its
  pigeon channel and complete on `{result: null}`; error/null replies
  follow FR-005 semantics.
  traces: MethodChannelShareIntentPort.resetInitialSharedMedia
- **FR-008**: `sharedMediaStream` MUST be the `EventChannel
  ('dev.zuraffa.zuraffa_intents/sharedMediaStream')` broadcast stream with
  every event (a plain native map) decoded into `SharedMedia` under the
  FR-004 quirk, and MUST be a lazy singleton per port instance (repeated
  access yields the identical stream instance — the `??=` contract from
  spec-001 FR-008, now for the platform driver).
  traces: MethodChannelShareIntentPort.sharedMediaStream
- **FR-009**: Platform wiring — `ShareIntentService.platform()` MUST be a
  factory binding the method-channel driver (optionally parameterized by a
  `BinaryMessenger` for tests); `registerShareIntentDependencies` MUST bind
  `ShareIntentPort` to the method-channel driver as a lazy singleton and
  `ShareIntentService` to that port (also a lazy singleton) — while direct
  `ShareIntentService()` construction keeps the spec-001 in-memory default
  so pure-Dart/test contexts are unchanged.
  traces: ShareIntentService
- **FR-010**: Native port consistency — the ported native trees
  (android/ios/macos) MUST (a) carry the exact channel literals the Dart
  side uses (event channel in the Kotlin and both Swift plugins; the three
  `dev.flutter.pigeon.ZuraffaIntentsApi.*` channels in the Pigeon Java and
  both Swift APIs), (b) contain no leftover `zikzak`/`ShareHandler`
  identifiers, (c) declare the rebranded plugin classes, and (d) be
  declared by `pubspec.yaml` with podspec/Package.swift files that exist —
  enforced by a Dart test so future edits cannot silently desynchronize the
  halves.
  traces: native consistency

## Layer Contracts

**Domain**:
- `MethodChannelShareIntentPort`: `getInitialSharedMedia() -> Future<SharedMedia?>`
- `MethodChannelShareIntentPort`: `recordSentMessage({required String conversationIdentifier, required String conversationName, String? conversationImageFilePath, String? serviceName}) -> Future<void>`
- `MethodChannelShareIntentPort`: `resetInitialSharedMedia() -> Future<void>`
- `MethodChannelShareIntentPort`: `sharedMediaStream() -> Stream<SharedMedia>`
- `ShareIntentService`: `platform({BinaryMessenger? binaryMessenger}) -> ShareIntentService`
- `registerShareIntentDependencies`: `register(GetIt getIt, {BinaryMessenger? binaryMessenger}) -> void`

**Function**:
- `sharedAttachmentWireMap`: `sharedAttachmentWireMap(SharedAttachment attachment) -> Map<Object?, Object?>`
- `sharedMediaWireMap`: `sharedMediaWireMap(SharedMedia media) -> Map<Object?, Object?>`
- `decodeSharedMedia`: `decodeSharedMedia(Object? message) -> SharedMedia`
- `ShareIntentsApiCodec`: `encodeMessage(Object? message) -> ByteData?`
- `ShareIntentsApiCodec`: `decodeMessage(ByteData? message) -> Object?`
- `defaultIsAppleLikeUriPath`: `defaultIsAppleLikeUriPath() -> bool`

### Key Entities

| Entity | Fields | Purpose |
| -- | -- | -- |
| SharedAttachment | `path: String`, `type: SharedAttachmentType` | a device file carried inside a share; wire form `{path, type: <index>}` (spec-001) |
| SharedMedia | `attachments: List<SharedAttachment>?`, `recipientIdentifiers: List<String?>?`, `conversationIdentifier: String?`, `content: String?`, `speakableGroupName: String?`, `serviceName: String?`, `senderIdentifier: String?`, `imageFilePath: String?`, `subject: String?` | the share payload carrier on the wire — method-channel replies, event-channel pushes, and sent-message records |

(The pigeon error envelope is Flutter's own `PlatformException(code, message,
details)` surfaced verbatim — deliberately NOT a domain entity; declaring it
one makes the loop scaffold a dead duplicate of an SDK type.)

## Lanes *(include when the feature splits engine vs. skin)*

```yaml
Lanes:
  - lane: CORE
    behaviors: [U2]
    flutter_allowed: false
  - lane: SKIN
    behaviors: [A1-A8, U1, U3-U10]
    flutter_allowed: true
```

## Out of scope (v1)

- Compiling the native trees: this environment has no Android/iOS/macOS
  toolchains; the natives are a faithful port of the proven
  `zikzak_share_handler` implementations under systematic renames, pinned
  by the FR-010 consistency suite (and the deltas it enforces are exactly
  the ones a rename could break). Device bring-up is the maintainer's CI
  matrix.
- New native capability: the plugin does exactly what
  `zikzak_share_handler` does — no new native surface is invented here.
- Linux/Windows/web: removed from the product scope (commit 4c0e599); the
  spec declares exactly android/ios/macos and the dead web registration
  code and `flutter_web_plugins` dependency are dropped.
- App-facing migration tooling: the README carries the
  `zikzak_share_handler` → `zuraffa_intents` mapping table; automated
  codemods are out of scope.
