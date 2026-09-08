## 1.0.0

- Initial release: the incoming-share seam for the Zuraffa ecosystem.
- Replaces `zikzak_share_handler` end to end: receive shared text/media
  (boot-time initial share + live broadcast stream) and record sent messages
  for share-menu suggestions, with the same argument mapping and wire
  contract.
- Pure-Dart core (spec-001): `SharedAttachmentType` / `SharedAttachment` /
  `SharedMedia` zorphy entities with JSON round-trips, `ShareIntentPort`,
  `InMemoryShareIntentAdapter`, `ShareIntentService`, GetIt composition root
  — 19 TDD behaviors, deliberate-mutant matrix 0 SURVIVED.
- Platform-interface layer (spec-002): Pigeon-shaped `ZuraffaIntentsApi`
  channels (result/error/channel-error semantics), type-tagged
  `ShareIntentsApiCodec` (128/129/130), iOS/macOS `Uri.decodeFull`
  attachment-path quirk behind a `kIsWeb`-short-circuited injectable
  predicate, `sharedMediaStream` EventChannel lazy singleton, platform
  composition-root wiring — 22 TDD behaviors (U20–U41), deliberate-mutant
  matrix 0 SURVIVED.
- Native implementations ported from the proven `zikzak_share_handler`
  sources: Android (Kotlin + Pigeon Java), iOS/macOS (Swift, SPM
  `Package.swift` **and** CocoaPods podspecs — the source shipped only a
  dangling podspec reference).
- Platform support: Android, iOS, macOS only. Linux/Windows/web stubs removed
  to focus on proven mobile+desktop platforms where share intents have OS-level
  support.
- Publish-ready: BSD-3 license, migration README, `flutter pub publish
  --dry-run` clean.
