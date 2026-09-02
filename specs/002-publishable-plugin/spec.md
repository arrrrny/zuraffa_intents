# Feature Specification: publishable-plugin — the platform-interface layer

**Feature Branch**: `002-publishable-plugin`
**Created**: 2026-09-02
**Status**: Approved (brownfield: `zuraffa_intents` grows from the merged
pure-Dart contract (spec-001) into a fully publishable pub.dev **Flutter
plugin** that replaces `zikzak_share_handler` end to end — the Dart
platform-interface layer is built here test-first, and the native
implementations are ported from `zikzak_share_handler` (the code already
exists and is battle-tested) with systematic identifier rebranding)

## Summary

Spec-001 pinned the pure-Dart share-intent contract (entities, port,
in-memory driver, facade, composition root). Spec-002 completes the plugin:
the **platform-interface layer** that actually talks to devices. The wire
contract is the plugin's Pigeon shape — a `BasicMessageChannel` API
(`getInitialSharedMedia`, `recordSentMessage`, `resetInitialSharedMedia`
under `dev.flutter.pigeon.ZuraffaIntentsApi.*`) carrying type-tagged
`SharedMedia`/`SharedAttachment` maps through a `StandardMessageCodec`
subclass (tags 128/129/130), plus the `sharedMediaStream` `EventChannel`
(`dev.zuraffa.zuraffa_intents/sharedMediaStream`) whose events decode with
the iOS/macOS `Uri.decodeFull` attachment-path quirk. The Dart side is built
entirely test-first (red before green) and mutation-proven; the native sides
(Android Kotlin + Pigeon Java, iOS/macOS Swift over SPM + podspecs,
Linux/Windows C++ stubs, web registration) are ported from
`zikzak_share_handler` with rebranding (`wtf.zikzak.zikzak_share_handler` →
`dev.zuraffa.zuraffa_intents`, `ShareHandlerApi` → `ZuraffaIntentsApi`,
`ShareHandler*Platform` → `ZuraffaIntentsPlugin`) and are pinned by a
Dart-side consistency suite so channel drift between Dart and native is a
failing test, not a code review. The package ships publish-ready: plugin
declaration for all six platforms, LICENSE, CHANGELOG, migration README, and
a clean `flutter pub publish --dry-run`.

## Requirements

- **FR-001**: The package MUST be publish-ready for pub.dev: `pubspec.yaml`
  declares a Flutter plugin with all six platforms — android (package
  `dev.zuraffa.zuraffa_intents`, class `ZuraffaIntentsPlugin`), ios and macos
  (`pluginClass: ZuraffaIntentsPlugin` + podspec paths that exist on disk),
  linux and windows (`pluginClass: ZuraffaIntentsPlugin`), web
  (`pluginClass: ZuraffaIntentsWeb`, `fileName` that exists) — plus
  `repository`/`issue_tracker`, a description ≤ 180 chars, `LICENSE`
  (BSD-3), and a `CHANGELOG.md` whose head entry matches the package
  version.
- **FR-002**: Wire-map fidelity — `sharedAttachmentWireMap` MUST produce
  exactly `{path, type: <index>}` and `sharedMediaWireMap` MUST produce a
  map carrying **all nine** keys (`attachments`, `recipientIdentifiers`,
  `conversationIdentifier`, `content`, `speakableGroupName`, `serviceName`,
  `senderIdentifier`, `imageFilePath`, `subject`) with `null`s preserved
  (the native sides read by key; omitted keys vs null keys must not be
  distinguishable on the wire), attachments serialized as wire maps.
- **FR-003**: The wire codec MUST be a `StandardMessageCodec` subclass that
  (a) encodes `SharedMedia` under tag 129 wrapping the wire map and (b)
  decodes tags 128 (SharedAttachment), 129 and 130 (SharedMedia — the
  pigeon-generated sources register the same payload type under two tags;
  both are accepted for wire compatibility) back into the zorphy entities.
  Decoding MUST also accept the plain-map shape the native sides emit
  (attachments as a list of maps, `recipientIdentifiers` with nullable
  elements cast through).
- **FR-004**: The iOS/macOS attachment-path quirk — attachment paths
  decoded from the wire MUST be run through `Uri.decodeFull` exactly when
  the platform predicate says "apple-like"; the predicate MUST be
  injectable for tests and MUST default to `!kIsWeb && (Platform.isIOS ||
  Platform.isMacOS)` (short-circuiting before `dart:io` so web never
  touches it — a latent web crash in the hand-rolled source this plugin
  replaces).
- **FR-005**: `getInitialSharedMedia` over the pigeon channel MUST map: a
  `{result: <wire map>}` reply to the decoded `SharedMedia`; a null/absent
  result to `null`; an `{error: {code, message, details}}` reply to a
  `PlatformException` carrying those exact fields; and a null reply
  (channel missing) to `PlatformException(code: 'channel-error')` with the
  canonical message.
- **FR-006**: `recordSentMessage` MUST send the single-element envelope
  `[SharedMedia]` (the pigeon native handler casts argument 0, so the
  type-tagged envelope is mandatory) with the spec-001 argument mapping
  into the carrier (`conversationName` → `speakableGroupName`,
  `conversationImageFilePath` → `imageFilePath`, `serviceName` →
  `serviceName`, `conversationIdentifier` → `conversationIdentifier`); a
  `{result: null}` reply completes normally; error/null replies follow
  FR-005 semantics.
- **FR-007**: `resetInitialSharedMedia` MUST send a null payload on its
  pigeon channel and complete on `{result: null}`; error/null replies
  follow FR-005 semantics.
- **FR-008**: `sharedMediaStream` MUST be the `EventChannel
  ('dev.zuraffa.zuraffa_intents/sharedMediaStream')` broadcast stream with
  every event (a plain native map) decoded into `SharedMedia` under the
  FR-004 quirk, and MUST be a lazy singleton per port instance (repeated
  access yields the identical stream instance — the `??=` contract from
  spec-001 FR-008, now for the platform driver).
- **FR-009**: Platform wiring — `ShareIntentService.platform()` MUST be a
  factory binding the method-channel driver (optionally parameterized by a
  `BinaryMessenger` for tests); `registerShareIntentDependencies` MUST bind
  `ShareIntentPort` to the method-channel driver as a lazy singleton and
  `ShareIntentService` to that port (also a lazy singleton) — while direct
  `ShareIntentService()` construction keeps the spec-001 in-memory default
  so pure-Dart/test contexts are unchanged.
- **FR-010**: Native port consistency — the ported native trees
  (android/ios/macos/linux/windows) MUST (a) carry the exact channel
  literals the Dart side uses (event channel in the Kotlin and both Swift
  plugins; the three `dev.flutter.pigeon.ZuraffaIntentsApi.*` channels in
  the Pigeon Java and both Swift APIs), (b) contain no leftover
  `zikzak`/`ShareHandler` identifiers, (c) declare the rebranded plugin
  classes, and (d) be declared by `pubspec.yaml` with podspec/Package.swift
  files that exist — enforced by a Dart test so future edits cannot
  silently desynchronize the halves.

## Out of scope (v1)

- Compiling the native trees: this environment has no Android/iOS/macOS
  toolchains; the natives are a faithful port of the proven
  `zikzak_share_handler` implementations under systematic renames, pinned
  by the FR-010 consistency suite (and the deltas it enforces are exactly
  the ones a rename could break). Device bring-up is the maintainer's CI
  matrix.
- New native capability: the plugin does exactly what
  `zikzak_share_handler` does — no new native surface is invented here.
- Web share-target receive flow: the web side is (as in the source plugin)
  a registration stub; receiving on web requires an app-level PWA
  `share_target` manifest and is documented, not implemented.
- App-facing migration tooling: the README carries the
  `zikzak_share_handler` → `zuraffa_intents` mapping table; automated
  codemods are out of scope.
