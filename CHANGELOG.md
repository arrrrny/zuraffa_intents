## 7.6.0 - 2026-11-19

Fleet release 7.6.0: zuraffa_observability moves its OTel base to dartastic_opentelemetry with a sealed test-capture seam + facade re-exports (issue #4); zuraffa_vendure + zuraffa_graphql adopt graphql_plus ^5.3.0; fleet-wide zorphy/zorphy_annotation raised to ^2.5.1 with all entities regenerated from scratch.

## 7.5.1 - 2026-11-17

- **iOS share VC hardening (arrrrny/zik_zak#893, fixed there in zik_zak#892)**:
  `ShareIntentIosViewController.saveSharedMedia()` no longer calls
  `NSExtensionContext.intent` off the share extension point — the property
  THROWS an uncaught ObjC exception from extension points that don't declare
  it (documented only for Share/Intents), SIGSEGV-ing the extension process
  on iOS 26 before the handoff ever ran (observed as a dead Action-extension
  row in a consumer app). The extension point is read from the bundle's
  `NSExtension` → `NSExtensionPointIdentifier` dictionary (the documented
  location; the flat key stays as a fallback) and `.intent` is called only
  for `com.apple.share-services`. Also hardened both platforms'
  `handleInputItems()` against an empty/late `inputItems` array (the
  `extensionContext!.inputItems[0]` force-subscript crashed the same way) —
  and that path now fails LOUDLY (an error alert on iOS, an os_log error plus
  `completeRequest` on macOS) instead of leaving the share sheet up with no
  feedback.

## 7.5.0 - 2026-11-15

Release 7.5.0: Signal-backed view-state migration template with SignalScope ownership (#2076); signal listener/subscription cleanup on eager-delivery throw (#2081, #2083); UseCase/StreamUseCase catch-all SEVERE logs now carry the cause (#2077, #2079); dependencies upgraded and pinned to latest resolvable.

## 7.4.2 - 2026-11-13

- Mono-version fleet alignment to 7.4.2; internal dependencies refreshed; xml override 7.1.0.

## 7.4.1 - 2026-11-11

Fleet release 7.4.1: core adds zfa tunnel (Cloudflare-hosted MCP servers), MCP streamable-HTTP transport with usecase tools, blocking lifecycle hooks (#2032), typed tool param coercion (#2061); whole fleet mono-aligned to 7.4.1.

## 7.3.6 - 2026-11-02

- Mono-version fleet alignment to 7.3.6; internal dependencies refreshed; xml override 7.1.0.

## 7.3.2 - 2026-10-31

- **Outbound send port (spec 1205, issue #9, PR #10)**: `ShareSenderPort`
  + `ShareSendResult` in `lib/src/domain/outbound/`, `InMemoryShareSenderAdapter`
  in `lib/src/data/outbound/`, and the `share_plus`-wrapping
  `SharePlusShareSenderPort` platform driver in `lib/src/platform/share_plus/`.
  `ShareIntentService` exposes `shareText`/`shareFiles` (optional subject,
  per-path MIME hints, optional iPad anchor rect) over the same facade and
  construction pattern as the receiving seam; the outcome is the share surface
  being presented, not a delivery receipt, and the one error path resolves
  failure instead of throwing. `share_plus` is now an internal implementation
  detail of this package.
- Mono-version fleet alignment: the whole zuraffa family ships at 7.3.2.
- `zuraffa` dependency constraint unified to ^7.3.2; README install guide
  refreshed to 7.3.2.

## 7.3.0 - 2026-10-28

- Mono-version fleet alignment: the whole zuraffa family ships at 7.3.0 together with the core.
- `zuraffa` dependency constraints unified to ^7.3.0; cross-family constraints move with the release.
- Fleet-wide `dependency_overrides: xml: 7.1.0`; README install guides refreshed to 7.3.0.

## 7.2.0 - 2026-10-28

- Mono-version fleet alignment: the whole zuraffa family now ships at the same version as the core.
- `zuraffa` dependency constraint unified to ^7.2.0 across the fleet.
- zuraffa_storage now wraps the maintained `zuraffa_minio` fork instead of the abandoned `minio` package (xml 7 compatible).
- Fleet-wide `dependency_overrides: xml: 7.1.0` policy; README install guides refreshed to the release version.

## 1.0.3

- Constraint-only refresh: `get_it` `^9.3.0`, `build_runner` `^2.16.2`,
  `mutation_test` `^1.8.1`. No code changes.

## 1.0.2

- Widen `zuraffa` to `^7.0.0` — the package imports no zuraffa symbols
  (constraint-only change, no code changes); keeps the fleet resolvable on
  zuraffa 7 without an override.

## 1.0.1

- **Built on the published `zuraffa` framework (^6.2.2)** — fleet-wide
  constraint sync.
- **Relicensed BSD-3-Clause → MIT** to match the Zuraffa fleet standard.
- Spec re-certification: full zfa TDD cycle re-run on both specs
  (spec-001 19 behaviors, spec-002 18 behaviors, mutation 1.0).

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
