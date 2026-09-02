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
