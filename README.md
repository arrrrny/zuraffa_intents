# zuraffa_intents

The incoming-share seam for the Zuraffa ecosystem — a pure-Dart reimplementation of the `zikzak_share_handler` plugin contract. Receive shared text/media (a boot-time initial share plus a live stream while the app runs) and record sent messages so the share menu can suggest conversations.

## Usage

```dart
final intents = ShareIntentService();

final boot = await intents.getInitialSharedMedia();
if (boot != null) await intents.resetInitialSharedMedia(); // prevent duplicate handling

intents.sharedMediaStream.listen((media) {
  // live share while the app is running
  print(media.content);
});

await intents.recordSentMessage(
  conversationIdentifier: 'conv-9',
  conversationName: 'Mom',
);
```

## Design

- **ShareIntentPort** — one interface for whatever delivers share intents (the native plugin side on a device, the in-memory adapter in tests). The datasource pattern applied to share receiving.
- **InMemoryShareIntentAdapter** — pure-Dart default with the producer-side seam exposed for tests: `storeInitial`, `emit`, and the recorded `sentMessageRecords`.
- **ShareIntentService** — thin facade: initial-share lifecycle, live stream, and recordSentMessage; port errors surface verbatim.
- **SharedMedia / SharedAttachment** entities + **SharedAttachmentType** vocabulary via the zfa CLI (Zorphy), with JSON round-trips.
- **registerShareIntentDependencies** — GetIt composition root (lazy singleton).

The plugin's argument mapping is preserved: `conversationName` surfaces on the wire carrier as `speakableGroupName`, `conversationImageFilePath` as `imageFilePath`.
