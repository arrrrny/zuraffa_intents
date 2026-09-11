# zuraffa_intents example

A fully working share-intents app for **android, ios and macos**. It binds
the real platform driver through the plugin's composition root and exercises
every operation the plugin exposes:

| Plugin operation | Where in the app |
| --- | --- |
| `getInitialSharedMedia` | the "Boot-time initial share" card (read on start; refresh icon re-reads) |
| `resetInitialSharedMedia` | the sweep icon on that card |
| `sharedMediaStream` | the "Live share stream" feed — every incoming share is appended |
| `recordSentMessage` | the form — all four arguments (`conversationIdentifier`, `conversationName`, `conversationImageFilePath`, `serviceName`) |
| `PlatformException` | surfaced verbatim in the error banner (e.g. `channel-error`) |

The **in-memory demo** switch (app bar) swaps the platform driver for the
pure-Dart `InMemoryShareIntentAdapter`, whose producer side powers the
"Simulate boot share" / "Simulate live share" buttons — the full receive
flow, try-able without an OS share sheet.

## Run

```sh
flutter pub get
flutter run            # pick an android / ios / macos device
```

## Receiving real shares per platform

- **Android** — works out of the box: the app's manifest declares
  `ACTION_SEND` / `ACTION_SEND_MULTIPLE` intent filters, so the app appears
  in the share sheet; the plugin reads the activity intent on launch
  (boot-time share) and on `onNewIntent` (live shares while running).
- **iOS** — receiving from the share sheet requires a **Share Extension**
  target that hands the payload to the app (the standard
  `zikzak_share_handler` setup this plugin replaces). Add the extension in
  Xcode and forward to `ZuraffaIntentsPlugin`; then share into the app.
- **macOS** — same as iOS: add a Share Extension in
  `macos/Runner.xcodeproj`, or use the in-memory demo mode to explore the
  API surface.

The widget test (`test/`) drives the complete flow over the in-memory
driver — boot share → reset → live event → record — as the executable
documentation of the app.
