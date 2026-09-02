---
feature: 001-intents-port
loop: outside-in # greenfield reimplementation; the plugin contract is the acceptance surface
profile: .specify/memory/tdd-profile.md # dart stack profile (dart test)
spec_criteria: 9 # the 9 FRs (FR-001..FR-009) act as the criteria
planned_at: cd0517a # short SHA the list was derived from (master)
updated_at: dae9003
suite_baseline: green # 2/2 at planning (init's bootstrap smoke + scaffold placeholder test, the latter replaced by this feature)
---

# Test List: 001-intents-port

> Derived from `spec.md`. The feature is **greenfield**: the package is the
> pure-Dart reimplementation of the `zikzak_share_handler` plugin contract,
> and no production behavior exists yet. Every behavior below is written
> **test-first** in `test/intents_suite_test.dart`; the day-zero scaffold
> (`lib/src/zuraffa_intents_base.dart` + its placeholder test) is replaced
> by the real API in the green phase. Red is observed as a compile failure
> of the suite against the absent API (per-cycle protocol in
> `tdd/cycle-log.md`); after green, each behavior is additionally validated
> against a deliberate mutant — the targeted test must FAIL via the
> profile's single command (`dart test test/intents_suite_test.dart
> --plain-name "<id>:"`) and the mutant must be reverted byte-identically
> (recorded in `tdd/mutant-run.md`).

## Outer loop: acceptance behaviors

The public API — `SharedAttachmentType`, `SharedAttachment`, `SharedMedia`,
`ShareIntentPort`, `InMemoryShareIntentAdapter`, `ShareIntentService`,
`registerShareIntentDependencies` — is exported through the package barrel
and exercised as the acceptance surface for every FR.

## Inner loop: unit behaviors

Grouped by the component from the reimplementation that owns them.

### `lib/src/domain/entities/enums/shared_attachment_type.dart` (FR-001)

| id | behavior                                                                                                                 | traces  | kind  | state   | test |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------- | ----- | ------- | ---- |
| U1 | the type vocabulary is exactly image, video, audio, file in declaration order with stable indices 0..3                     | FR-001  | unit  | planned | `test('U1: …')` |

### `lib/src/domain/entities/shared_attachment/shared_attachment.dart` (FR-002, FR-003)

| id | behavior                                                                                                                 | traces  | kind  | state   | test |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------- | ----- | ------- | ---- |
| U2 | copyWith replaces only the given field — type-only and path-only replacements each leave the other field untouched         | FR-002  | unit  | planned | `test('U2: …')` |
| U3 | equality is field-based: same path+type ⇒ equal with matching hashCode; a different path or a different type ⇒ unequal     | FR-002  | unit  | planned | `test('U3: …')` |
| U4 | toJson → fromJson round-trip preserves path and type exactly                                                               | FR-003  | unit  | planned | `test('U4: …')` |

### `lib/src/domain/entities/shared_media/shared_media.dart` (FR-004, FR-005)

| id | behavior                                                                                                                 | traces  | kind  | state   | test |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------- | ----- | ------- | ---- |
| U5 | a fully-populated SharedMedia round-trips toJson → fromJson preserving all nine fields incl. the nested attachment list and a null element inside recipientIdentifiers | FR-004 | unit | planned | `test('U5: …')` |
| U6 | a minimal SharedMedia (all optionals absent) round-trips equivalently and its JSON omits the absent fields                  | FR-004  | unit  | planned | `test('U6: …')` |
| U7 | copyWith replaces only the given fields — a replacement attachments list substitutes wholesale, untouched fields survive    | FR-005  | unit  | planned | `test('U7: …')` |
| U8 | scalar-field equality is field-based with consistent hashCode (two instances built from identical scalar arguments)         | FR-005  | unit  | planned | `test('U8: …')` |

### `lib/src/data/intents/in_memory_share_intent_adapter.dart` (FR-006, FR-007, FR-008)

| id | behavior                                                                                                                 | traces  | kind  | state   | test |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------- | ----- | ------- | ---- |
| U9 | a fresh adapter reports null for getInitialSharedMedia                                                                     | FR-006  | unit  | planned | `test('U9: …')` |
| U10 | a stored initial share is served verbatim and repeatably across reads until reset                                          | FR-006  | unit  | planned | `test('U10: …')` |
| U11 | resetInitialSharedMedia clears the stored share (subsequent get ⇒ null) and is idempotent                                  | FR-006  | unit  | planned | `test('U11: …')` |
| U12 | recordSentMessage maps conversationName → speakableGroupName, conversationImageFilePath → imageFilePath, serviceName → serviceName, conversationIdentifier → conversationIdentifier | FR-007 | unit | planned | `test('U12: …')` |
| U13 | recordSentMessage accumulates one record per call in call order, with omitted optionals recorded as null                    | FR-007  | unit  | planned | `test('U13: …')` |
| U14 | sharedMediaStream is broadcast — two listeners each receive the same emitted share                                          | FR-008  | unit  | planned | `test('U14: …')` |
| U15 | sharedMediaStream is a per-adapter lazy singleton — repeated access yields the identical stream instance                    | FR-008  | unit  | planned | `test('U15: …')` |
| U16 | the stream does not replay pre-subscription emissions to a later subscriber                                                 | FR-008  | unit  | planned | `test('U16: …')` |

### `lib/src/share_intent_service.dart` (FR-009)

| id | behavior                                                                                                                 | traces  | kind  | state   | test |
| -- | ------------------------------------------------------------------------------------------------------------------------ | ------- | ----- | ------- | ---- |
| U17 | the service defaults to the InMemoryShareIntentAdapter and delegates the initial-media lifecycle (store ⇒ get ⇒ reset ⇒ get) | FR-009 | unit | planned | `test('U17: …')` |
| U18 | recordSentMessage arguments pass through verbatim and a port-thrown error surfaces unmodified (never wrapped or swallowed)  | FR-009  | unit  | planned | `test('U18: …')` |
| U19 | sharedMediaStream re-exposed by the service IS the port's stream instance; registerShareIntentDependencies registers a lazy singleton (repeated resolution ⇒ identical instance) | FR-009 | unit | planned | `test('U19: …')` |
