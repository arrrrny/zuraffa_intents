# Feature Specification: intents-port — the share-intent receiving suite

**Feature Branch**: `001-intents-port`
**Created**: 2026-09-02
**Status**: Approved (greenfield: `zuraffa_intents` reimplements the
`zikzak_share_handler` plugin contract — receiving shared text/media into
the app and recording sent-message share suggestions — as a pure-Dart
Zuraffa port, built entirely under the repo's TDD discipline)

## Summary

`zikzak_share_handler` is the ecosystem's Flutter plugin for the **incoming**
share direction: it receives shared text/media from the platform share sheet
(a boot-time initial share plus a live stream while the app runs) and it
records sent messages so the OS share menu can suggest conversations. Its
app-facing contract is three operations plus one stream
(`getInitialSharedMedia`, `recordSentMessage`, `resetInitialSharedMedia`,
`sharedMediaStream`) over two data carriers (`SharedMedia`,
`SharedAttachment` + the `SharedAttachmentType` vocabulary).
`zuraffa_intents` reimplements that contract as a pure-Dart package in the
Zuraffa style: the same domain vocabulary as zorphy entities with JSON
round-trips, the plugin's platform seam expressed as a swappable
`ShareIntentPort`, a pure-Dart `InMemoryShareIntentAdapter` as the test/dev
driver (the stand-in for the native plugin side), a thin `ShareIntentService`
facade, and a GetIt composition root — mirroring how `zuraffa_messaging`
ports messaging. Every behavior is written test-first (red before green) and
pinned against deliberate mutants before the implementation is accepted.

## Requirements

- **FR-001**: `SharedAttachmentType` MUST expose exactly the four share
  attachment kinds — `image`, `video`, `audio`, `file` — in declaration
  order with stable indices 0..3 (the plugin's wire vocabulary; the Pigeon
  codec encodes attachment types by index, so reordering is a breaking
  change).
- **FR-002**: `SharedAttachment` MUST be an immutable entity carrying the
  device file `path` (String) and the attachment `type`; `copyWith` MUST
  replace only the given field, and equality MUST be field-based (same
  path + type ⇒ equal, with matching hashCode).
- **FR-003**: `SharedAttachment` MUST round-trip `toJson` → `fromJson`
  preserving path and type exactly.
- **FR-004**: `SharedMedia` MUST be an immutable entity with the plugin's
  nine fields — `attachments` (List<SharedAttachment>?),
  `recipientIdentifiers` (List<String?>? — iOS recipient ids, nullable
  elements), `conversationIdentifier`, `content`, `speakableGroupName`,
  `serviceName`, `senderIdentifier`, `imageFilePath`, `subject` (String?)
  — and MUST round-trip `toJson` → `fromJson` with full fidelity: a
  fully-populated instance preserves every field including the nested
  attachment list and a `null` element inside `recipientIdentifiers`; a
  minimal instance (all optionals absent) round-trips equivalently and its
  JSON omits absent fields.
- **FR-005**: `SharedMedia.copyWith` MUST replace only the given fields
  (a new attachments list replaces wholesale — never merges) and MUST
  preserve untouched fields; scalar-field equality MUST be field-based
  with consistent hashCode.
- **FR-006**: The initial-share lifecycle on `ShareIntentPort` MUST work
  exactly once per app boot but read repeatably: `getInitialSharedMedia`
  returns the stored media on every call until
  `resetInitialSharedMedia` clears it (the explicit anti-duplicate-handling
  reset the plugin API provides), returns `null` when nothing was stored
  (fresh state), and `resetInitialSharedMedia` is idempotent.
- **FR-007**: `recordSentMessage` MUST preserve the plugin's argument
  mapping into the wire carrier — `conversationIdentifier` →
  `conversationIdentifier`, `conversationName` → `speakableGroupName`,
  `conversationImageFilePath` → `imageFilePath`, `serviceName` →
  `serviceName` — and MUST accumulate one record per call, in call order
  (the share-suggestion history), with omitted optional arguments recorded
  as null.
- **FR-008**: `sharedMediaStream` MUST be a broadcast stream: every
  listener receives every share emitted after it subscribed; the stream
  MUST be a per-port lazy singleton (repeated access yields the identical
  stream instance, as the plugin's `_sharedMediaStream ??=` does); and it
  MUST NOT replay pre-subscription emissions to later subscribers.
- **FR-009**: `ShareIntentService` MUST be a thin facade over the port —
  delegating all four operations, defaulting to the
  `InMemoryShareIntentAdapter` when no port is injected, surfacing
  port-thrown errors verbatim (never wrapped, swallowed, or converted),
  and re-exposing the port's stream instance identically;
  `registerShareIntentDependencies` MUST register `ShareIntentService` on
  the provided `GetIt` as a lazy singleton (repeated resolution yields the
  identical instance).

## Out of scope (v1)

- Native platform channels — the Pigeon codec, MethodChannel/EventChannel
  transport, and the iOS/macOS `Uri.decodeFull` wire quirk are the plugin
  layer's concern; the port seam replaces them, and JSON entity
  round-trips cover serialization.
- Platform-specific share-sheet presentation (iOS Share Extension, Android
  intent filters) — native driver work lives outside a pure-Dart package.
- Inbound-share persistence/queueing — the port streams what the platform
  delivers; durable history is an app-level concern (mirrors the plugin,
  which keeps only the boot-time initial share).
- Auto-consume semantics for the initial share — the plugin exposes an
  explicit reset rather than clearing on read; this port pins the same
  read-repeatably/reset-explicitly contract (FR-006).
