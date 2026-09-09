# Engine Plan: 002-publishable-plugin (CORE + BOTH)

The engine lane (issue #1000): pure Dart — behaviors whose lane is CORE or BOTH. The noFlutter guard rejects any behavior that references Flutter at plan time, so this file stays engine-only.

## Inner loop: unit behaviors

One per functional requirement in `spec.md`.

| id | behavior | traces | state |
| -- | -------- | ------ | ----- |
| U2 | Wire-map fidelity — `sharedAttachmentWireMap` MUST produce | FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap | PENDING |

## Key entities

| entity | fields | purpose |
| ------ | ------ | ------- |
| SharedAttachment | path: String, type: SharedAttachmentType | a device file carried inside a share; wire form `{path, type: <index>}` (spec-001) |
| SharedMedia | attachments: List<SharedAttachment>?, recipientIdentifiers: List<String?>?, conversationIdentifier: String?, content: String?, speakableGroupName: String?, serviceName: String?, senderIdentifier: String?, imageFilePath: String?, subject: String? | the share payload carrier on the wire — method-channel replies, event-channel pushes, and sent-message records |
| PlatformException | code: String, message: String?, details: Object? | the pigeon error envelope shape surfaced verbatim from the method channels |

## Layer contracts

### Domain

- `MethodChannelShareIntentPort`: `getInitialSharedMedia() -> Future<SharedMedia?>`
- `MethodChannelShareIntentPort`: `recordSentMessage({required String conversationIdentifier, required String conversationName, String? conversationImageFilePath, String? serviceName}) -> Future<void>`
- `MethodChannelShareIntentPort`: `resetInitialSharedMedia() -> Future<void>`
- `MethodChannelShareIntentPort`: `sharedMediaStream() -> Stream<SharedMedia>`
- `ShareIntentService`: `platform({BinaryMessenger? binaryMessenger}) -> ShareIntentService`
- `registerShareIntentDependencies`: `register(GetIt getIt, {BinaryMessenger? binaryMessenger}) -> void`
### Function

- `sharedAttachmentWireMap`: `sharedAttachmentWireMap(SharedAttachment attachment) -> Map<Object?, Object?>`
- `sharedMediaWireMap`: `sharedMediaWireMap(SharedMedia media) -> Map<Object?, Object?>`
- `decodeSharedMedia`: `decodeSharedMedia(Object? message) -> SharedMedia`
- `ShareIntentsApiCodec`: `encodeMessage(Object? message) -> ByteData?`
- `ShareIntentsApiCodec`: `decodeMessage(ByteData? message) -> Object?`
- `defaultIsAppleLikeUriPath`: `defaultIsAppleLikeUriPath() -> bool`

## Routing provenance

Per-behavior routing decisions (issue #951): what each decision consulted — a declared marker/contract row, or the labeled legacy fallback to migrate.

route: U2 -> unit lane (func surface) [declared: contract row: sharedAttachmentWireMap, spec line 272]
route: contract:A1 -> contract lane [declared: MethodChannelShareIntentPort]
route: contract:A2 -> contract lane [declared: MethodChannelShareIntentPort]
route: contract:A3 -> contract lane [declared: MethodChannelShareIntentPort]
route: contract:A4 -> contract lane [declared: MethodChannelShareIntentPort]
route: contract:A5 -> contract lane [declared: ShareIntentService]
route: contract:A6 -> contract lane [declared: registerShareIntentDependencies]
route: contract:A7 -> contract lane [declared: sharedAttachmentWireMap]
route: contract:A8 -> contract lane [declared: sharedMediaWireMap]
route: contract:A9 -> contract lane [declared: decodeSharedMedia]
route: contract:A10 -> contract lane [declared: ShareIntentsApiCodec]
route: contract:A11 -> contract lane [declared: ShareIntentsApiCodec]
route: contract:A12 -> contract lane [declared: defaultIsAppleLikeUriPath]


