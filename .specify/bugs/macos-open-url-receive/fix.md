# Bug Fix Report: macos-open-url-receive (review follow-up on PR #12)

- **Slug**: macos-open-url-receive
- **Branch**: `fix/macos-handle-open-urls-selector`
- **Status**: applied
- **Date**: 2026-11-15
- **Source**: review findings on
  https://github.com/arrrrny/zuraffa_intents/pull/12 (PR closed before the fixes
  round could be pushed), tracked as issue #20 and forklift task
  `8028bbaf-3684-4193-b674-bdae396eea51`

## What changed

`macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift`

1. **Critical — the open-URL hook was dead on arrival.** `handleOpen(_:)` was
   exported to the Objective-C runtime as `handleOpen:` and
   `FlutterAppDelegate` only ever probes `handleOpenURLs:`
   (`FlutterAppDelegate.mm`, `application:openURLs:` →
   `respondsToSelector:@selector(handleOpenURLs:)`), so the method added by #11
   never ran and the macOS receive path stayed unreachable. The method now pins
   its selector explicitly:

   ```diff
   -    public func handleOpen(_ urls: [URL]) -> Bool {
   +    @objc(handleOpenURLs:)
   +    public func handleOpen(_ urls: [URL]) -> Bool {
   ```

   **Why the pin and not the rename the review suggested.** The review proposed
   renaming the method to `handleOpenURLs(_:)`, arguing that no macOS header
   carries an `NS_SWIFT_NAME`. That premise is wrong in the way that matters:
   Swift's importer *renames the protocol requirement itself* — in the engine's
   generated interface the requirement is
   `@available(swift, obsoleted: 3, renamed: "handleOpen(_:)") optional func
   handleOpenURLs(_ urls: [URL]) -> Bool` (Swift 3 omit-needless-words drops the
   type-repeating "URLs"). Declaring `func handleOpenURLs(_:)` alongside the
   protocol therefore fails to compile — verified on this host (Swift 6.2.4,
   `-F FlutterMacOS.xcframework`): `error: 'handleOpenURLs' has been renamed to
   'handleOpen(_:)'`. The ObjC *selector* is the only part that was wrong, so
   the selector is what the fix pins.

   The `@objc` pin keeps the Swift spelling the importer uses and exports the
   selector the engine probes: verified on this host with a runtime probe —
   a bare `handleOpen(_:)` answers `responds(to: Selector("handleOpenURLs:"))`
   `false` / `Selector("handleOpen:")` `true`; with the pin, `handleOpenURLs:`
   `true` / `handleOpen:` `false`.

2. **`FlutterAppLifecycleDelegate` conformance declared.** The plugin is
   registered as a lifecycle delegate (`registrar.addApplicationDelegate(instance)`),
   and `addApplicationDelegate:` is declared as taking
   `NSObject<FlutterAppLifecycleDelegate>*`
   (`FlutterPluginRegistrarMacOS.h:83`) — so the plugin now says so:

   ```diff
   +extension ZuraffaIntentsPlugin: FlutterAppLifecycleDelegate {}
   ```

   Worth stating plainly: every requirement of that protocol is `@optional`, so
   conformance is documentation, not a compiler check. Confirmed by compiling a
   probe class that declares conformance while implementing the wrong selector
   (`handleOpen(_:)` bare) — it compiles clean. The `@objc` pin above is what
   actually fixes the contract.

3. **Cold-start buffer comment.** `setInitialData: true` on the open-URL path
   already matches the finding (the review's `setInitialData: false` was the PR
   head; the merged master version had already moved to `true`). The reasoning is
   now recorded next to the call instead of living in a PR body: on a cold launch
   the URL arrives before the Dart isolate subscribes to `sharedMediaStream`, so
   `eventSink` is nil and the live event is dropped — the buffer is the only
   thing `getInitialSharedMedia()` can hand back. The live emit fires either way.

`test/platform_interface_suite_test.dart`

4. **U42 rewritten to pin the selector, not the Swift name.** The old assertion
   searched for `func handleOpen(_ urls: [URL]) -> Bool` and passed on a version
   that could never be called — it pinned the bug. It now asserts the
   `@objc(handleOpenURLs:)` pin directly precedes the declaration, that the body
   reuses the prefix guard and `handleUrl(url:setInitialData: true)`, and that the
   conformance extension exists.

## Not changed (deliberately)

- **`application(_:open urls:)` / `openFile` / `openFiles` stay.** They are
  unreachable while `FlutterAppDelegate` owns `NSApplication.delegate`, but they
  remain correct for a host that wires the plugin as its own app delegate — the
  same reasoning recorded in the assessment. Removing them is not needed for #11
  and would change the plugin's surface.
- **`applicationDidFinishLaunching(_:)` (the launch-userInfo path).** The review
  flagged it as dead for the same class of reason — the lifecycle registrar
  forwards `handleDidFinishLaunching:`, not the `NSApplicationDelegate` spelling.
  It is a minor, non-blocking note, and the notification-userInfo path is a
  different delivery mechanism (launch notifications), not the open-URL route
  #11 is about. Left as-is; filed here so the next reader knows it was seen.
- **Partial-batch honesty (`handleUrl` clearing `latestMedia`).** The review's
  🔵 note (a batch `[good, unmatched]` returns `false` and clears media an
  earlier URL delivered). `latestMedia` is write-only today and no finding in
  issue #20 asks for it, so the behaviour is unchanged; noted as a follow-up.
- **Version bump.** This repo is mono-versioned with the zuraffa fleet
  (`PUBLISH.md`): bump the fleet with `../zuraffa/scripts/update_fleet.sh`, never
  one package alone. 7.4.2 is already published (2026-11-13), so the fix rides the
  next fleet release rather than a hand-rolled 7.4.3.

## Verification

- `swift build --target zuraffa_intents` (the package's own SPM manifest, with
  `-F` on the engine's `FlutterMacOS.xcframework`): **exit 0**. This repo's CI
  never compiles Swift, so this is the only local compile gate the plugin has.
- U42 red → green: on the parent commit the rewritten test fails
  (`Expected: a value greater than or equal to <0>`, `Actual: <-1>` — no pin),
  after the fix `+23: All tests passed!`.
- Selector evidence: `responds(to:)` probe (above), plus the compiler check that
  the rename variant does not build.

## Follow-up (review notes on PR #18 shape)

None — this branch is the follow-up itself.
