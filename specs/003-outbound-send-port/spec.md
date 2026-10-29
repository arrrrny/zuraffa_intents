# Feature Specification: outbound-send-port — the share-send suite

**Template Version**: `zuraffa-1.0`

**Feature Branch**: `003-outbound-send-port`

**Created**: 2026-10-30

**Status**: Approved (brownfield: `zuraffa_intents` grows the send side —
outbound text/file sharing behind the same port/adapter architecture the
inbound side already runs on, so the package covers both directions of
inter-app communication and `share_plus` becomes an internal implementation
detail of this package instead of an app dependency)

**Input**: Issue #9 (`spec` label) — zik_zak spec
`1205-zuraffa-outbound-share-fleet-hardening` (lives in `arrrrny/zik_zak`;
the contract below is the package-side port of it, self-contained). No
prior assessment artifact existed in this repo when work started; the
specification was authored directly from the issue contract.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Send text (with an optional subject) out through the same facade (Priority: P1)

An app hands text (a deep link, a barcode payload) to the send side with an
optional subject and gets back a simple success/failure outcome — "share
surface presented", not a delivery receipt: the caller learns whether the
share surface was presented, never what the user chose inside it. With no
subject the call still succeeds.

**Why this priority**: the text send is the migration target for zik_zak's
`PlatformDeepLinkDataSource` (its `Future<bool>` contract must survive the
move unchanged) and the smallest end-to-end proof that the send seam works.

**Independent Test**: Can be fully tested by sending text with and without
a subject through the in-memory driver and asserting the recorded request
carries both exactly as passed and the outcome is success. Delivers: the
text send path.

**Acceptance Scenarios**:

1. **Given** a text-only share with a subject, **When** sent through the
   port, **Then** the request is recorded with the text and subject
   exactly as passed and resolves to success
   **Type**: acceptance
2. **Given** a text-only share with no subject, **When** sent, **Then**
   the subject is recorded as `null` and the call still resolves to
   success
   **Type**: acceptance

---

### User Story 2 - Send files (with optional MIME hints) out through the same facade (Priority: P1)

An app offers one or more device file paths to the native share surface,
optionally hinting each file's MIME type so receiving apps can route them.
The paths and hints travel exactly as passed.

**Why this priority**: file send is the second outbound flow (barcode image
exports) and pins the file-path → share-file mapping, including the
per-file MIME hint pairing.

**Independent Test**: Can be fully tested by sending two paths with two
MIME hints and again with none, asserting the recorded requests carry
paths/hints (or empty hints) exactly as passed and resolve to success.
Delivers: the file send path.

**Acceptance Scenarios**:

1. **Given** one or more file paths with MIME hints, **When** sent,
   **Then** the files and their per-file MIME hints are recorded exactly
   as passed and the call resolves to success
   **Type**: acceptance
2. **Given** file paths with no MIME hints, **When** sent, **Then** the
   hints are recorded empty and the call still resolves to success
   **Type**: acceptance

---

### User Story 3 - Anchor the iPad popover (optional, both send kinds) (Priority: P2)

On iPad the share sheet is a popover that must anchor to the widget the
user interacted with; the caller passes an optional anchor `Rect` with
either send kind. Given no anchor, the call succeeds with the platform's
default presentation (centered popover).

**Why this priority**: the anchor is iPad-only polish, but a dropped or
distorted rect is a visible regression on iPad; recording it exactly keeps
the port honest without a device.

**Independent Test**: Can be fully tested by sending with an explicit
`Rect` and with none, asserting the recorded anchor matches exactly (or is
`null`) and both resolve to success. Delivers: the anchor contract.

**Acceptance Scenarios**:

1. **Given** a send with an iPad anchor rect, **When** sent, **Then** the
   anchor is recorded exactly as passed and the call resolves to success
   **Type**: acceptance
2. **Given** a send with no anchor, **When** sent, **Then** the anchor is
   recorded as `null` and the call resolves to success (platform default
   presentation)
   **Type**: acceptance

---

### User Story 4 - One error path: failure result, never a thrown exception (Priority: P1)

When the underlying driver fails (channel error, plugin exception) or the
platform is unsupported (e.g. file sends on a platform without share-sheet
support), the send resolves to the failure outcome. No exception escapes
the facade — the caller has exactly one error path to handle, matching the
semantics the app already relies on (completion without throwing = success;
any throw = failure).

**Why this priority**: the migration replaces a try/catch data source; if
the port re-threw, every call site would need its own guard and the
`Future<bool>` contract could not survive unchanged.

**Independent Test**: Can be fully tested by scripting the platform driver's
share seam to throw (channel error, unsupported platform, invalid
arguments) and asserting each send resolves to the failure result, never
throwing. Delivers: the single error path.

**Acceptance Scenarios**:

1. **Given** a driver that throws when asked to share, **When** a send is
   made through the port, **Then** the call resolves to the failure
   result — no exception escapes
   **Type**: acceptance
2. **Given** a platform that does not support the send (unsupported
   platform error), **When** a send is made, **Then** the call resolves to
   the failure result — no exception escapes
   **Type**: acceptance
3. **Given** a driver whose share completes (any completion — the user
   finishing or dismissing the sheet), **When** a send is made, **Then**
   the call resolves to success: the outcome is "share surface presented",
   not a delivery receipt
   **Type**: acceptance

---

### User Story 5 - The facade, the composition root, and the pure-Dart record (Priority: P1)

The app never touches the send port directly: `ShareIntentService` exposes
`shareText`/`shareFiles` and delegates to the send port, keeping the
package's construction pattern — `.platform()` binds the platform driver,
direct construction binds the pure-Dart in-memory adapter, and there is no
second facade class. `registerShareIntentDependencies` binds the send port
alongside the inbound port so DI consumers get the platform driver too.
The in-memory adapter records every request (text, subject, files, MIME
hints, anchor) in call order so package and app tests assert in pure Dart
with no platform channel.

**Why this priority**: this is the consumption surface — FR-2 and FR-4 are
what make the send side usable from the app and testable without a device.

**Independent Test**: Can be fully tested by driving sends through
`ShareIntentService` (direct construction records through the in-memory
adapter; `.platform()` and `registerShareIntentDependencies` bind the
platform drivers) and reading the accumulated records back in call order.
Delivers: the app-facing send surface plus the pure-Dart test driver.

**Acceptance Scenarios**:

1. **Given** `ShareIntentService()` constructed directly, **When** sends
   are made through the facade, **Then** they delegate to the
   `InMemoryShareSenderAdapter` bound at construction and the records are
   readable from it
   **Type**: acceptance
2. **Given** `ShareIntentService.platform()` or
   `registerShareIntentDependencies`, **When** the wiring is inspected,
   **Then** the send port is the platform driver (`SharePlusShareSenderPort`)
   alongside the inbound method-channel driver, both bound as lazy
   singletons
   **Type**: acceptance
3. **Given** several sends of mixed kinds through the in-memory adapter,
   **When** the records are read, **Then** exactly one record exists per
   send in call order, each exposing text, subject, files, MIME hints, and
   anchor exactly as passed
   **Type**: acceptance

---

### Edge Cases

- What happens when `shareText` is called with an empty string? The
  platform driver rejects empty text (`ArgumentError` from the underlying
  share call) — which lands on the one error path: a failure result, never
  a thrown exception.
- What happens when the user dismisses the native sheet? The send already
  completed — the outcome is success (the surface was presented); dismissal
  is a delivery detail the port does not report.
- What happens when `registerShareIntentDependencies` runs in a pure-Dart
  test? It binds the platform drivers; tests that want the in-memory
  adapters construct `ShareIntentService` directly or register their own
  bindings first (unchanged from the inbound pattern).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The package MUST expose a send-side port `ShareSenderPort`
  alongside the inbound `ShareIntentPort`, with two methods — `shareText`
  (required text; optional subject, optional iPad anchor `Rect`) and
  `shareFiles` (required file paths; optional per-file MIME hints,
  optional subject, optional anchor) — each resolving to a simple
  success/failure outcome (`ShareSendResult`): whether the share surface
  was presented and returned, not a delivery receipt.
  traces: ShareSenderPort, ShareSendResult
- **FR-002**: `ShareIntentService` MUST expose the send methods and
  delegate to the send port, preserving the package's construction
  pattern: `.platform()` binds the platform drivers, direct construction
  binds the pure-Dart in-memory adapters, and there is no second facade
  class; `registerShareIntentDependencies` MUST bind the send port
  alongside the inbound port (both lazy singletons) so DI consumers get
  the platform drivers.
  traces: ShareIntentService
- **FR-003**: The platform driver MUST live behind the existing seams —
  plan-phase decision: **wrap `share_plus` as an internal implementation
  detail** (all three plugin platforms covered, lowest risk; a first-party
  method channel — ACTION_SEND / UIActivityViewController /
  NSSharingServicePicker — is the recorded alternative, deferred). The
  driver is testable without a device through the `SharePlus.custom` /
  `SharePlatform` test seam; driver failures and unsupported-platform
  errors MUST resolve to the failure result — no exception escapes the
  facade (one error path for callers).
  traces: SharePlusShareSenderPort
- **FR-004**: `InMemoryShareSenderAdapter` MUST record every send request
  — text, subject, files, MIME hints, anchor — one record per call in call
  order, with omitted optionals recorded as null/empty, so package and app
  tests assert in pure Dart.
  traces: InMemoryShareSenderAdapter
- **FR-5 (cross-link, lives in zik_zak)**: the app migrates
  `PlatformDeepLinkDataSource` onto this API and drops `share_plus` from
  its pubspec, keeping its `Future<bool>` contract unchanged. Out of scope
  here — tracked in `arrrrny/zik_zak` (spec 1205).
- **FR-006**: The send suite MUST cover the port contract (adapter fully;
  platform driver as far as testable without a device — param mapping,
  result mapping, error mapping over the scripted seam) and `test.yml`
  MUST stay green on the ubuntu + macos matrix.
  traces: test/sender_suite_test.dart

## Layer Contracts

**Domain**:
- `ShareSenderPort`: `shareText({required String text, String? subject, Rect? anchor}) -> Future<ShareSendResult>`
- `ShareSenderPort`: `shareFiles({required List<String> files, String? subject, Map<String, String>? mimeHints, Rect? anchor}) -> Future<ShareSendResult>`
- `ShareIntentService`: `shareText(...) -> Future<ShareSendResult>` (delegates)
- `ShareIntentService`: `shareFiles(...) -> Future<ShareSendResult>` (delegates)
- `InMemoryShareSenderAdapter`: same two methods, recording each request
- `SharePlusShareSenderPort`: same two methods over `share_plus`

### Key Entities

| Entity | Fields | Purpose |
| -- | -- | -- |
| ShareSendResult | `success`, `failure` | the send outcome — "share surface presented" vs the one error path (never a delivery receipt) |
| ShareSendRecord | `text: String?`, `subject: String?`, `files: List<String>`, `mimeHints: Map<String, String>`, `anchor: Rect?` | one recorded send request (the adapter's test witness) |

## Out of scope (v1)

- The zik_zak app migration (`PlatformDeepLinkDataSource` → this API,
  dropping the app's `share_plus` dependency) — FR-5 lives in
  `arrrrny/zik_zak`.
- A first-party send method channel (ACTION_SEND /
  UIActivityViewController / NSSharingServicePicker) — the recorded
  alternative to the share_plus wrap; revisit only if share_plus cannot
  carry a requirement.
- Delivery receipts / share-sheet completion analytics — the outcome is
  deliberately "share surface presented", not what the user chose.
- Fleet release mechanics — the release itself happens only via the mono
  bump (`../zuraffa/scripts/update_fleet.sh`); this change ships no
  version bump.
