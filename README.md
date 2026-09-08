# zuraffa_intents

The incoming-share seam for the Zuraffa ecosystem: receive shared text/media
(a boot-time initial share plus a live stream while the app runs) and record
sent messages so the OS share menu can suggest conversations.

`zuraffa_intents` is the drop-in replacement for `zikzak_share_handler`,
rebuilt on the Zuraffa port/adapter architecture and produced entirely under
the repo's zfa TDD discipline (spec-001: the pure-Dart contract, 19
behaviors; spec-002: the platform-interface layer + native ports, 22
behaviors; deliberate-mutant matrices 0 SURVIVED on both).

## Platform support

| Platform | Status | Implementation |
| -------- | ------ | -------------- |
| Android  | ✅ full | Kotlin plugin (`ZuraffaIntentsPlugin`) — share-sheet intents, shortcuts |
| iOS      | ✅ full | Swift plugin (SPM + CocoaPods) — URL-scheme shares, INSendMessageIntent donation |
| macOS    | ✅ full | Swift plugin (SPM + CocoaPods) — same wire contract |

## Getting started

```yaml
dependencies:
  zuraffa_intents: ^1.0.0
```

```dart
import 'package:zuraffa_intents/zuraffa_intents.dart';

final intents = ShareIntentService.platform();

// 1. Boot-time initial share (repeatable reads; reset when consumed).
final boot = await intents.getInitialSharedMedia();
if (boot != null) {
  handle(boot);
  await intents.resetInitialSharedMedia();
}

// 2. Live shares while the app runs.
intents.sharedMediaStream.listen(handle);

// 3. Record sent messages so share menus suggest conversations.
await intents.recordSentMessage(
  conversationIdentifier: 'conv-9',
  conversationName: 'Mom',
  conversationImageFilePath: '/tmp/mom.png',
  serviceName: 'WhatsApp',
);
```

Or through the composition root (binds the platform driver as the default
`ShareIntentPort`, both lazy singletons):

```dart
final getIt = GetIt.instance;
registerShareIntentDependencies(getIt);
final intents = getIt<ShareIntentService>();
```

To route platform channels over a custom `BinaryMessenger` (tests,
background isolates):

```dart
registerShareIntentDependencies(getIt, binaryMessenger: myMessenger);
final intents = getIt<ShareIntentService>();
```

`ShareIntentService()` (direct construction) keeps binding the pure-Dart
`InMemoryShareIntentAdapter` — the test/dev driver that plays the platform's
producer role (`storeInitial`, `emit`, `sentMessageRecords`).

## Migrating from zikzak_share_handler

| zikzak_share_handler | zuraffa_intents |
| -------------------- | --------------- |
| `ShareHandler.instance.getInitialSharedMedia()` | `ShareIntentService.platform().getInitialSharedMedia()` |
| `ShareHandler.instance.sharedMediaStream` | `ShareIntentService.platform().sharedMediaStream` |
| `ShareHandler.instance.recordSentMessage(...)` | same named arguments, same mapping |
| `ShareHandler.instance.resetInitialSharedMedia()` | same |
| `SharedMedia` / `SharedAttachment` / `SharedAttachmentType` | same names, same nine-field shape — now immutable zorphy entities with JSON round-trips |
| federated packages (`…_android`, `…_ios`, …) | not needed — one package, six platforms |
| `platform_interface` instance swap | `ShareIntentPort` binding in the GetIt composition root (or inject a port) |

The wire contract (pigeon `ZuraffaIntentsApi` channels, type-tagged codec,
`…/sharedMediaStream` event channel) is rebranded but shape-identical to the
source plugin, and the native implementations are a faithful port of its
proven Android/iOS/macOS code.

### iOS setup (same as the source plugin)

Register the share URL scheme in `Info.plist` and the share extension with
the `AppGroupId` entry — the plugin consumes `ShareMedia-<bundleId>` URLs.
See the source plugin's setup guide; the flow is unchanged.

### Android notes

`recordSentMessage` donates dynamic shortcuts (conversation id, label,
person icon from `conversationImageFilePath`); the receiving activity is
resolved as `<packageName>.MainActivity`.

## What the TDD evidence pins (specs/002-publishable-plugin)

- **Wire maps**: all nine `SharedMedia` keys always present, nulls preserved;
  attachment types ride as declaration-order indices.
- **Codec**: `StandardMessageCodec` subclass with tags 128/129/130; outgoing
  media under the 129 envelope; native-emitted plain maps decode cleanly.
- **Quirk**: iOS/macOS attachment paths run through `Uri.decodeFull` behind
  an injectable predicate that short-circuits on `kIsWeb` BEFORE touching
  `dart:io` (the source plugin crashed web builds here).
- **Channels**: result/error/channel-error pigeon semantics; EventChannel
  lazy-singleton stream.
- **Consistency**: the Dart channel literals and the ported native files are
  pinned equal by the suite — drift is a failing test (U38–U41).

## Development

```bash
flutter pub get
flutter test                 # 42 behaviors (spec-001: 19, spec-002: 22, bootstrap: 1)
flutter analyze
flutter pub publish --dry-run
```

Evidence chain per spec: `specs/<id>/spec.md`, `tasks.md`, and
`tdd/{test-list,cycle-log,mutant-run,verification}.md`.
