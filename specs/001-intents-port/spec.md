# Feature Specification: intents-port — the share-intent receiving suite

**Template Version**: `zuraffa-1.0`

**Feature Branch**: `001-intents-port`

**Created**: 2026-09-02

**Status**: Approved (greenfield: `zuraffa_intents` reimplements the
`zikzak_share_handler` plugin contract — receiving shared text/media into
the app and recording sent-message share suggestions — as a pure-Dart
Zuraffa port, built entirely under the repo's TDD discipline; refined
2026-09-09 to the zuraffa-1.0 grammar: Template Version, Type-routed
acceptance scenarios, FR traces, Layer Contracts, Key Entities, Lanes)

**Input**: Refinement of the approved 2026-09-02 spec to the latest
zuraffa spec version (`zuraffa-1.0`, zuraffa#1000 + zuraffa#1186); the
contract is unchanged — only the grammar is upgraded.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Receive the boot-time initial share, repeatably until reset (Priority: P1)

An app cold-starts because the user shared text/media into it from another
app. Through the port the app reads that boot-time share — the same stored
media on every read, so re-reads never lose it — and when it has finished
handling the share it calls the explicit reset, after which reads return
null and a second reset is harmless. On a fresh boot with nothing shared,
reads return null immediately.

**Why this priority**: the boot-time initial share is the plugin's primary
delivery path — without it the app never sees why it was started; the
read-repeatably + explicit-reset contract is the plugin's
anti-duplicate-handling guarantee this port must preserve exactly.

**Independent Test**: Can be fully tested by storing media in the
in-memory driver, reading it twice (identical), resetting, reading again
(null), resetting again (no throw), and reading a fresh driver (null).
Delivers: the whole initial-share lifecycle over the port seam.

**Acceptance Scenarios**:

1. **Given** an adapter with a stored initial share, **When**
   `getInitialSharedMedia` is called twice, **Then** both reads return the
   identical stored media (reads are repeatable until reset)
   **Type**: acceptance
2. **Given** a stored initial share that was cleared via
   `resetInitialSharedMedia`, **When** `getInitialSharedMedia` is called,
   **Then** it returns `null`, and a second reset call completes without
   error (idempotent)
   **Type**: acceptance
3. **Given** a fresh adapter that never stored a share, **When**
   `getInitialSharedMedia` is called, **Then** it returns `null`
   **Type**: acceptance

---

### User Story 2 - Record sent messages so the share menu can suggest conversations (Priority: P1)

The app shares content OUT to a conversation and records the suggestion:
the plugin's argument names map onto the wire carrier's field names
(`conversationName` → `speakableGroupName`,
`conversationImageFilePath` → `imageFilePath`,
`serviceName`/`conversationIdentifier` unchanged), every call appends one
record in call order (the share-suggestion history), and omitted optional
arguments are recorded as null — never dropped or defaulted.

**Why this priority**: `recordSentMessage` is the plugin's second
operation and the OS share-menu suggestion pipeline depends on the exact
argument→carrier mapping; a silent rename or reordering breaks
suggestions the user sees.

**Independent Test**: Can be fully tested by recording two sent messages
with different argument subsets through the in-memory driver and reading
back the accumulated records in order, asserting the mapped carrier fields
and the null optionals. Delivers: the sent-message suggestion history.

**Acceptance Scenarios**:

1. **Given** a `recordSentMessage` call with all four arguments, **When**
   **Type**: acceptance
   the record is read back from the adapter, **Then** the carrier fields
   carry the plugin's mapping (`conversationName` → `speakableGroupName`,
   `conversationImageFilePath` → `imageFilePath`,
   `serviceName` → `serviceName`, `conversationIdentifier` →
   `conversationIdentifier`)
2. **Given** two successive `recordSentMessage` calls (the second omitting
   the optional arguments), **When** the accumulated records are read,
   **Then** exactly two records exist in call order and the second carries
   `null` for every omitted optional
   **Type**: acceptance

---

### User Story 3 - Receive live shares on a broadcast stream and consume it all through the facade + DI (Priority: P2)

While the app runs, shares arrive on `sharedMediaStream`: every listener
subscribed sees every share emitted after its subscription, no listener
gets events from before it subscribed, and repeated access yields the
identical stream instance. The app never touches the port directly —
`ShareIntentService` delegates all four operations to the registered port
(surfacing port errors verbatim) and `registerShareIntentDependencies`
binds the service in GetIt as a lazy singleton.

**Why this priority**: the live stream plus the facade/composition root is
how real apps consume the plugin day-to-day; the singleton stream contract
(`??=`) and verbatim error surfacing are the behavioral pins that keep the
port swappable.

**Independent Test**: Can be fully tested by emitting shares to a
two-listener broadcast stream (both receive; late subscriber gets no
replay; repeated access is identical), then driving the same four
operations through `ShareIntentService` (including a port-thrown error
surfaced unmodified) and resolving the GetIt singleton twice. Delivers:
the app-facing consumption surface.

**Acceptance Scenarios**:

1. **Given** two listeners on `sharedMediaStream`, **When** a share is
   emitted, **Then** each listener receives that share (broadcast)
   **Type**: acceptance
2. **Given** a subscriber that attached after an earlier share was
   emitted, **When** no new share arrives, **Then** the late subscriber
   received nothing (no pre-subscription replay), and repeated
   `sharedMediaStream` access yields the identical stream instance
   **Type**: acceptance
3. **Given** a `ShareIntentService` over an in-memory port, **When** all
   four operations run through the facade and the port throws, **Then**
   the facade delegates each call and surfaces the error verbatim (never
   wrapped, swallowed, or converted), and
   `registerShareIntentDependencies` resolves `ShareIntentService` as a
   lazy singleton (repeated resolution ⇒ identical instance)
   **Type**: acceptance

---

### Edge Cases

- What happens when `recordSentMessage` is called with only the two
  required arguments? Every optional is recorded as null (never a missing
  key or a default string).
- What happens when `resetInitialSharedMedia` is called twice, or on a
  fresh adapter? Both are no-ops — idempotent, never throwing.
- What happens when the entity JSON omits absent optional fields? A
  minimal `SharedMedia` round-trips equivalently and its JSON omits the
  absent fields; a `null` element inside `recipientIdentifiers` survives
  the round trip.
- What happens when a `SharedAttachment`'s `copyWith` is given only one
  field? Only that field changes; the other is preserved (and equality is
  field-based with matching hashCode).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `SharedAttachmentType` MUST expose exactly the four share
  attachment kinds — `image`, `video`, `audio`, `file` — in declaration
  order with stable indices 0..3 (the plugin's wire vocabulary; the Pigeon
  codec encodes attachment types by index, so reordering is a breaking
  change).
  traces: SharedAttachmentType
- **FR-002**: `SharedAttachment` MUST be an immutable entity carrying the
  device file `path` (String) and the attachment `type`; `copyWith` MUST
  replace only the given field, and equality MUST be field-based (same
  path + type ⇒ equal, with matching hashCode).
  traces: SharedAttachment
- **FR-003**: `SharedAttachment` MUST round-trip `toJson` → `fromJson`
  preserving path and type exactly.
  traces: SharedAttachment
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
  traces: SharedMedia
- **FR-005**: `SharedMedia.copyWith` MUST replace only the given fields
  (a new attachments list replaces wholesale — never merges) and MUST
  preserve untouched fields; scalar-field equality MUST be field-based
  with consistent hashCode.
  traces: SharedMedia
- **FR-006**: The initial-share lifecycle on `ShareIntentPort` MUST work
  exactly once per app boot but read repeatably: `getInitialSharedMedia`
  returns the stored media on every call until
  `resetInitialSharedMedia` clears it (the explicit anti-duplicate-handling
  reset the plugin API provides), returns `null` when nothing was stored
  (fresh state), and `resetInitialSharedMedia` is idempotent.
  traces: ShareIntentPort
- **FR-007**: `recordSentMessage` MUST preserve the plugin's argument
  mapping into the wire carrier — `conversationIdentifier` →
  `conversationIdentifier`, `conversationName` → `speakableGroupName`,
  `conversationImageFilePath` → `imageFilePath`, `serviceName` →
  `serviceName` — and MUST accumulate one record per call, in call order
  (the share-suggestion history), with omitted optional arguments recorded
  as null.
  traces: ShareIntentPort
- **FR-008**: `sharedMediaStream` MUST be a broadcast stream: every
  listener receives every share emitted after it subscribed; the stream
  MUST be a per-port lazy singleton (repeated access yields the identical
  stream instance, as the plugin's `_sharedMediaStream ??=` does); and it
  MUST NOT replay pre-subscription emissions to later subscribers.
  traces: ShareIntentPort
- **FR-009**: `ShareIntentService` MUST be a thin facade over the port —
  delegating all four operations, defaulting to the
  `InMemoryShareIntentAdapter` when no port is injected, surfacing
  port-thrown errors verbatim (never wrapped, swallowed, or converted),
  and re-exposing the port's stream instance identically;
  `registerShareIntentDependencies` MUST register `ShareIntentService` on
  the provided `GetIt` as a lazy singleton (repeated resolution yields the
  identical instance).
  traces: ShareIntentService

## Layer Contracts

**Domain**:
- `ShareIntentPort`: `getInitialSharedMedia() -> Future<SharedMedia?>`
- `ShareIntentPort`: `recordSentMessage({required String conversationIdentifier, required String conversationName, String? conversationImageFilePath, String? serviceName}) -> Future<void>`
- `ShareIntentPort`: `resetInitialSharedMedia() -> Future<void>`
- `ShareIntentPort`: `sharedMediaStream() -> Stream<SharedMedia>`
- `ShareIntentService`: `getInitialSharedMedia() -> Future<SharedMedia?>`
- `ShareIntentService`: `recordSentMessage({required String conversationIdentifier, required String conversationName, String? conversationImageFilePath, String? serviceName}) -> Future<void>`
- `ShareIntentService`: `resetInitialSharedMedia() -> Future<void>`
- `ShareIntentService`: `sharedMediaStream() -> Stream<SharedMedia>`
- `InMemoryShareIntentAdapter`: `getInitialSharedMedia() -> Future<SharedMedia?>`
- `InMemoryShareIntentAdapter`: `recordSentMessage({required String conversationIdentifier, required String conversationName, String? conversationImageFilePath, String? serviceName}) -> Future<void>`
- `InMemoryShareIntentAdapter`: `resetInitialSharedMedia() -> Future<void>`
- `InMemoryShareIntentAdapter`: `sharedMediaStream() -> Stream<SharedMedia>`
- `registerShareIntentDependencies`: `register(GetIt getIt, {ShareIntentPort? port}) -> void`

### Key Entities

| Entity | Fields | Purpose |
| -- | -- | -- |
| SharedAttachmentType | `image`, `video`, `audio`, `file` (declaration order, stable indices 0..3) | the plugin's wire vocabulary of share attachment kinds (Pigeon encodes by index) |
| SharedAttachment | `path: String`, `type: SharedAttachmentType` | a device file carried inside a share (immutable, field-equal, JSON round-trippable) |
| SharedMedia | `attachments: List<SharedAttachment>?`, `recipientIdentifiers: List<String?>?`, `conversationIdentifier: String?`, `content: String?`, `speakableGroupName: String?`, `serviceName: String?`, `senderIdentifier: String?`, `imageFilePath: String?`, `subject: String?` | the share payload carrier — the boot-time initial share, the live stream event, and the sent-message record |

## Lanes *(include when the feature splits engine vs. skin)*

```yaml
Lanes:
  - lane: CORE
    behaviors: [A1-A8, U1-U9]
    flutter_allowed: false
```

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
