# Engine Plan: 001-intents-port (CORE + BOTH)

The engine lane (issue #1000): pure Dart — behaviors whose lane is CORE or BOTH. The noFlutter guard rejects any behavior that references Flutter at plan time, so this file stays engine-only.

## Outer loop: acceptance behaviors

One per acceptance criterion in `spec.md`.

| id | behavior | traces | state |
| -- | -------- | ------ | ----- |
| A1 | both reads return the | AC-1 | PENDING |
| A2 | it returns `null`, and a second reset call completes without | AC-2 | PENDING |
| A3 | it returns `null` | AC-3 | PENDING |
| A4 | the carrier fields | AC-4 | PENDING |
| A5 | exactly two records exist in call order and the second carries | AC-5 | PENDING |
| A6 | each listener receives that share (broadcast) | AC-6 | PENDING |
| A7 | the late subscriber | AC-7 | PENDING |
| A8 | the facade delegates each call and surfaces the error verbatim (never | AC-8 | PENDING |

## Inner loop: unit behaviors

One per functional requirement in `spec.md`.

| id | behavior | traces | state |
| -- | -------- | ------ | ----- |
| U1 | `SharedAttachmentType` MUST expose exactly the four share | FR-001, SharedAttachmentType | PENDING |
| U2 | `SharedAttachment` MUST be an immutable entity carrying the | FR-002, SharedAttachment | PENDING |
| U3 | `SharedAttachment` MUST round-trip `toJson` → `fromJson` | FR-003, SharedAttachment | PENDING |
| U4 | `SharedMedia` MUST be an immutable entity with the plugin's | FR-004, SharedMedia | PENDING |
| U5 | `SharedMedia.copyWith` MUST replace only the given fields | FR-005, SharedMedia | PENDING |
| U6 | The initial-share lifecycle on `ShareIntentPort` MUST work | FR-006, ShareIntentPort.sharedMediaStream | PENDING |
| U7 | `recordSentMessage` MUST preserve the plugin's argument | FR-007, ShareIntentPort.sharedMediaStream | PENDING |
| U8 | `sharedMediaStream` MUST be a broadcast stream: every | FR-008, ShareIntentPort.sharedMediaStream | PENDING |
| U9 | `ShareIntentService` MUST be a thin facade over the port — | FR-009, ShareIntentService.sharedMediaStream | PENDING |

## Key entities

| entity | fields | purpose |
| ------ | ------ | ------- |
| SharedAttachmentType |  | the plugin's wire vocabulary of share attachment kinds (Pigeon encodes by index) |
| SharedAttachment | path: String, type: SharedAttachmentType | a device file carried inside a share (immutable, field-equal, JSON round-trippable) |
| SharedMedia | attachments: List<SharedAttachment>?, recipientIdentifiers: List<String?>?, conversationIdentifier: String?, content: String?, speakableGroupName: String?, serviceName: String?, senderIdentifier: String?, imageFilePath: String?, subject: String? | the share payload carrier — the boot-time initial share, the live stream event, and the sent-message record |

## Layer contracts

### Domain

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

## Routing provenance

Per-behavior routing decisions (issue #951): what each decision consulted — a declared marker/contract row, or the labeled legacy fallback to migrate.

route: A1 -> acceptance lane [declared: type marker, spec line 46]
route: A2 -> acceptance lane [declared: type marker, spec line 51]
route: A3 -> acceptance lane [declared: type marker, spec line 54]
route: A4 -> acceptance lane [declared: type marker, spec line 81]
route: A5 -> acceptance lane [declared: type marker, spec line 91]
route: A6 -> acceptance lane [declared: type marker, spec line 121]
route: A7 -> acceptance lane [declared: type marker, spec line 126]
route: A8 -> acceptance lane [declared: type marker, spec line 133]
route: U1 -> unit lane (entity pipeline: SharedAttachmentType) [declared: contract row: SharedAttachmentType, spec line 238]
route: U2 -> unit lane (entity pipeline: SharedAttachment) [declared: contract row: SharedAttachment, spec line 239]
route: U3 -> unit lane (entity pipeline: SharedAttachment) [declared: contract row: SharedAttachment, spec line 239]
route: U4 -> unit lane (entity pipeline: SharedMedia) [declared: contract row: SharedMedia, spec line 240]
route: U5 -> unit lane (entity pipeline: SharedMedia) [declared: contract row: SharedMedia, spec line 240]
route: U6 -> unit lane [declared: contract row: ShareIntentPort, spec line 223]
route: U7 -> unit lane [declared: contract row: ShareIntentPort, spec line 223]
route: U8 -> unit lane [declared: contract row: ShareIntentPort, spec line 223]
route: U9 -> unit lane [declared: contract row: ShareIntentService, spec line 227]
route: contract:A1 -> contract lane [declared: ShareIntentPort]
route: contract:A2 -> contract lane [declared: ShareIntentPort]
route: contract:A3 -> contract lane [declared: ShareIntentPort]
route: contract:A4 -> contract lane [declared: ShareIntentPort]
route: contract:A5 -> contract lane [declared: ShareIntentService]
route: contract:A6 -> contract lane [declared: ShareIntentService]
route: contract:A7 -> contract lane [declared: ShareIntentService]
route: contract:A8 -> contract lane [declared: ShareIntentService]
route: contract:A9 -> contract lane [declared: InMemoryShareIntentAdapter]
route: contract:A10 -> contract lane [declared: InMemoryShareIntentAdapter]
route: contract:A11 -> contract lane [declared: InMemoryShareIntentAdapter]
route: contract:A12 -> contract lane [declared: InMemoryShareIntentAdapter]
route: contract:A13 -> contract lane [declared: registerShareIntentDependencies]


