# Bug Assessment: macOS receive path never fires (wrong delegate selector)

- **Slug**: macos-open-url-receive
- **Created**: 2026-11-13
- **Source**: https://github.com/arrrrny/zuraffa_intents/issues/11 (allowlisted: `github.com`)
- **Verdict**: valid
- **Severity**: high

## Report (verbatim or summarized)

Issue title: "macOS receive path never fires: plugin implements
NSApplicationDelegate methods instead of handleOpen(_:)".

Reported symptom: on macOS `getInitialSharedMedia()` always returns nothing and
`sharedMediaStream` never emits, even when the app is opened with a shared file
or a custom-scheme URL.

The reporter's diagnosis: the receive path is implemented as
**NSApplicationDelegate** methods
(`application(_:open urls:)`, `application(_:openFile:)`,
`application(_:openFiles:)`). In a Flutter macOS app `NSApplication.delegate` is
the `FlutterAppDelegate`, not the plugin; plugins are registered as *lifecycle
delegates* through `registrar.addApplicationDelegate`, and `FlutterAppDelegate`
fans `application:openURLs:` out to them via the Objective-C selector
`handleOpenURLs:` (first-YES-wins), which imports into Swift as
`handleOpen(_:)`.

Evidence supplied by the reporter: live check against `zuraffa_browser` #909 —
with stock pub.dev 7.4.1, `open -a Zuraffa <image>` produced no
`sharedMediaStream` event; patching the pub-cache copy with a `handleOpen(_:)`
implementation that mirrors `handleUrl(url:setInitialData:)` made both cold-start
and warm delivery work.

## Symptom

A share-intake event (custom-scheme URL or `file://` drop/`open -a`) delivered
to a macOS host never reaches Dart: neither the cold-start buffer
(`getInitialSharedMedia()`) nor the live `sharedMediaStream` event channel ever
carries the payload, so the receive half of the plugin is inert on macOS.

## Reproduction

1. Build and run a macOS Flutter app that depends on `zuraffa_intents` (e.g. the
   packaged `example/macos`).
2. With the app closed: `open -a <App> /path/to/image.png` (or drop the file on
   the app icon).
3. Call `getInitialSharedMedia()` from Dart and listen to
   `sharedMediaStream`.
4. Observed: no media is returned and no event is emitted. With the app already
   running, invoking the custom scheme (`open "ShareMedia-<bundle-id>?key=..."`)
   likewise produces no event.

Not reproducible on iOS/Android — the plugin's `UIApplicationDelegate`
`application(_:open url:options:)` path is a real delegate method there.

## Suspected Code Paths

- `macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift:57` —
  `application(_:open urls:)`: an `NSApplicationDelegate` method that a plugin
  lifecycle delegate is never asked to implement.
- `macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift:65`
  and `:73` — `application(_:openFile:)` / `application(_:openFiles:)`: same
  problem (file-open path).
- `macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift:28` —
  `registrar.addApplicationDelegate(instance)`: this is what registers the plugin
  as a **lifecycle** delegate, i.e. the only receive route the engine will call.
- `macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift:97` —
  `handleUrl(url:setInitialData:)`: the working payload machinery (UserDefaults
  `key=` decode and `file://` attachment wrap, `initialMedia` buffer and
  `eventSink` emission). It is fine; nothing reaches it.
- `macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift:43` —
  `hasMatchingSchemePrefix(url:)`: the guard the new selector must reuse.

## Root Cause Hypothesis

Confidence: high. The macOS receive path is registered on the wrong delegate
protocol. `FlutterAppDelegate` (the real `NSApplication.delegate`) forwards
open-URL events to registered lifecycle delegates through the selector
`handleOpenURLs:`, so a plugin that only implements
`application(_:open urls:)` never receives the callback. Because both the
cold-start buffer and the live `eventSink` emission live behind
`handleUrl(url:setInitialData:)`, and the only callers of it are those dead
delegate methods, the whole macOS receive path is unreachable.

## Proposed Remediation

**Preferred**: implement the lifecycle selector on the macOS plugin:

```swift
public func handleOpen(_ urls: [URL]) -> Bool {
    var handled = false
    for url in urls {
        if hasMatchingSchemePrefix(url: url) {
            handled = true
            _ = handleUrl(url: url, setInitialData: true)
        }
    }
    return handled
}
```

Reusing `hasMatchingSchemePrefix` / `handleUrl` keeps the payload contract
identical to the (working) iOS/Android paths — the UserDefaults `key=` decode
and the `file://` attachment wrap both keep working — and `setInitialData: true`
preserves the cold-start buffer that `getInitialSharedMedia()` reads. The return
value answers the engine's first-YES-wins fan-out: `true` for a URL the plugin
claimed, so the event is not also offered to another handler.

Keep the existing `application(_:open urls:)` methods (they remain correct if a
host ever wires the plugin as its own `NSApplication.delegate`) — the smallest
diff that unblocks the receive path.

**Alternatives**:
- Convert the plugin to be the app's `NSApplication.delegate` — rejected: the
  app owns that delegate (`FlutterAppDelegate`), and stealing it breaks Flutter.
- Have the host app forward open-URL events to the plugin manually — rejected:
  the plugin must work with zero host wiring, like the other platforms.

**Files likely to change**:
- `macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift`
- `test/platform_interface_suite_test.dart` (the repo's native-consistency
  regression suite)

**Tests to add or update**:
- A regression test in the native-consistency group asserting the macOS plugin
  implements the lifecycle selector `handleOpen(_ urls: [URL]) -> Bool` and that
  it routes through `handleUrl` (so a future refactor cannot silently re-break
  the receive path). This repo tests native sources at source level in Dart — it
  has no XCTest target for the plugin package.

## Risks & Considerations

- `handleOpenURLs:` fan-out is first-YES-wins: returning `true` for a URL the
  plugin matched but failed to decode suppresses other delegates. Accepted —
  that URL belongs to this plugin's scheme/file space.
- The `file://` branch of `hasMatchingSchemePrefix` matches any file URL, so a
  host dropping an unrelated file into the app will have it claimed as an
  attachment. That is the pre-existing behaviour of the file-open path and is
  unchanged by this fix.
- No API/Dart-surface change, no migration, no generated code touched.

## Open Questions

- None blocking. Whether the plugin should also implement the newer macOS 13+
  `application:openURLs:` reopen notification path is out of scope: the engine's
  fan-out is the single sanctioned route.