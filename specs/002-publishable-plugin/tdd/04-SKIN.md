# Skin Plan: 002-publishable-plugin (SKIN + BOTH)

The skin lane (issue #1000): Flutter allowed — behaviors whose lane is SKIN or BOTH, plus the AdaptiveViewSlots the spec declares (the adaptive-layout contract slots the skin must provide).

## Outer loop: acceptance behaviors

One per acceptance criterion in `spec.md`.

| id | behavior | traces | state |
| -- | -------- | ------ | ----- |
| A1 | a `{result: <wire map>}` reply decodes into the | AC-1 | PENDING |
| A2 | the payload is the single-element `[SharedMedia]` | AC-2 | PENDING |
| A3 | it completes on `{result: null}` and | AC-3 | PENDING |
| A4 | the decoded `SharedAttachment` paths are `Uri.decodeFull`-expanded; | AC-4 | PENDING |
| A5 | each receives every post-subscription native | AC-5 | PENDING |
| A6 | each yields the identical lazy-singleton instance | AC-6 | PENDING |
| A7 | the three pigeon channel literals and the event | AC-7 | PENDING |
| A8 | `pubspec.yaml` declares the plugin for exactly android, ios, | AC-8 | PENDING |

## Inner loop: unit behaviors

One per functional requirement in `spec.md`.

| id | behavior | traces | state |
| -- | -------- | ------ | ----- |
| U1 | The package MUST be publish-ready for pub.dev: `pubspec.yaml` | FR-001, publishability | PENDING |
| U3 | The wire codec MUST be a `StandardMessageCodec` subclass that | FR-003, ShareIntentsApiCodec.decodeMessage | PENDING |
| U4 | The iOS/macOS attachment-path quirk — attachment paths | FR-004, decodeSharedMedia.decodeSharedMedia | PENDING |
| U5 | `getInitialSharedMedia` over the pigeon channel MUST map: a | FR-005, MethodChannelShareIntentPort.getInitialSharedMedia | PENDING |
| U6 | `recordSentMessage` MUST send the single-element envelope | FR-006, MethodChannelShareIntentPort.recordSentMessage | PENDING |
| U7 | `resetInitialSharedMedia` MUST send a null payload on its | FR-007, MethodChannelShareIntentPort.resetInitialSharedMedia | PENDING |
| U8 | `sharedMediaStream` MUST be the `EventChannel | FR-008, MethodChannelShareIntentPort.sharedMediaStream | PENDING |
| U9 | Platform wiring — `ShareIntentService.platform()` MUST be a | FR-009, ShareIntentService.platform | PENDING |
| U10 | Native port consistency — the ported native trees | FR-010, native consistency | PENDING |

## Routing provenance

Per-behavior routing decisions (issue #951): what each decision consulted — a declared marker/contract row, or the labeled legacy fallback to migrate.

route: A1 -> platform lane [declared: type marker, spec line 57]
route: A2 -> platform lane [declared: type marker, spec line 66]
route: A3 -> platform lane [declared: type marker, spec line 70]
route: A4 -> platform lane [declared: type marker, spec line 102]
route: A5 -> platform lane [declared: type marker, spec line 107]
route: A6 -> acceptance lane [declared: type marker, spec line 145]
route: A7 -> acceptance lane [declared: type marker, spec line 152]
route: A8 -> acceptance lane [declared: type marker, spec line 158]
route: U1 -> refused [danglingReference: behavior "U1" traces to "publishability", which names no declared contract row (Key Entities, Layer Contracts, or External Dependencies).]
route: U3 -> unit lane (func surface) [declared: contract row: ShareIntentsApiCodec, spec line 276]
route: U4 -> unit lane (func surface) [declared: contract row: decodeSharedMedia, spec line 274]
route: U5 -> refused [danglingReference: contract row "MethodChannelShareIntentPort" declares no signature named "getInitialSharedMedia" (trace "MethodChannelShareIntentPort.getInitialSharedMedia").]
route: U6 -> refused [danglingReference: contract row "MethodChannelShareIntentPort" declares no signature named "recordSentMessage" (trace "MethodChannelShareIntentPort.recordSentMessage").]
route: U7 -> refused [danglingReference: contract row "MethodChannelShareIntentPort" declares no signature named "resetInitialSharedMedia" (trace "MethodChannelShareIntentPort.resetInitialSharedMedia").]
route: U8 -> unit lane [declared: contract row: MethodChannelShareIntentPort, spec line 267]
route: U9 -> unit lane [declared: contract row: ShareIntentService, spec line 268]
route: U10 -> refused [danglingReference: behavior "U10" traces to "native consistency", which names no declared contract row (Key Entities, Layer Contracts, or External Dependencies).]


