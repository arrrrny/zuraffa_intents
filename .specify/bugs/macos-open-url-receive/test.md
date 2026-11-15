# Bug Test Report: macos-open-url-receive (review follow-up on PR #12)

- **Slug**: macos-open-url-receive
- **Result**: verified (Swift package compiles on host; Dart gate green; runtime selector probe conclusive)
- **Date**: 2026-11-15
- **Environment**: macOS 26.7.3, Swift 6.2.4 (swiftlang-6.2.4.1.4), Flutter 3.50.0 stable /
  Dart 3.14.0, engine `FlutterMacOS.xcframework` (darwin-x64 artifacts), `dart test`
  concurrency 2

## Red → green (U42, the regression pin)

The old U42 pinned the *bug*: it searched for `func handleOpen(_ urls: [URL]) -> Bool`
and passed on a method the engine could never call. Rewritten to pin the ObjC
selector, it is red on the parent commit and green after the fix.

1. **Red** — master's `ZuraffaIntentsPlugin.swift` restored over the fixed one:

   ```
   flutter test test/platform_interface_suite_test.dart --concurrency=2
   00:01 +22 -1: U42: the macOS plugin exports the lifecycle-delegate open-URL
     selector handleOpenURLs: and routes it through handleUrl (issue #11) [E]
     Expected: a value greater than or equal to <0>
       Actual: <-1>
   00:01 +22 -1: Some tests failed.
   ```

   (`-1` = `indexOf('@objc(handleOpenURLs:)')` found nothing.)

2. **Green** — same command after the fix: `00:01 +23: All tests passed!`

## Runtime selector evidence (the finding's core claim, re-verified on this host)

Compiled probes against the real engine framework and the host Swift 6.2.4:

| Variant | `responds(to: Selector("handleOpenURLs:"))` | `Selector("handleOpen:")` |
| --- | --- | --- |
| bare `func handleOpen(_ urls: [URL]) -> Bool` | `false` | `true` |
| `@objc(handleOpenURLs:) func handleOpen(_ urls: [URL]) -> Bool` | `true` | `false` |
| `func handleOpenURLs(_ urls: [URL]) -> Bool` (review's rename) | `true` | `false` |

The rename does export the right selector, but it does not compile once the
plugin declares `FlutterAppLifecycleDelegate` conformance — the importer's
generated interface obsoletes that Swift name:

```
error: 'handleOpenURLs' has been renamed to 'handleOpen(_:)'
note: 'handleOpenURLs' was obsoleted in Swift 3
```

so the shipped fix is the `@objc` pin. The conformance extension itself was also
checked for strength: a probe class declaring conformance while implementing only
the *wrong* selector compiles clean — every requirement of
`FlutterAppLifecycleDelegate` is `@optional`, so conformance documents the role and
does not enforce the name. `fix.md` records that.

## Swift compile gate (the repo's CI never compiles Swift)

```
cd macos/zuraffa_intents
swift build --target zuraffa_intents -Xswiftc -F -Xswiftc <engine>/FlutterMacOS.xcframework/macos-arm64_x86_64
[3/4] Compiling zuraffa_intents ZuraffaIntentsPlugin.swift
[4/4] Emitting module zuraffa_intents
Build of target: 'zuraffa_intents' complete!
exit=0
```

Only pre-existing `MainActor` isolation warnings from
`zuraffa_intents_models/ShareIntentMacosViewController.swift` (untouched here);
no errors from the changed file.

## Full Dart suite

`flutter test --concurrency=2` (all 40 test files, default path = `test/`):
`00:50 +102: All tests passed!` — exit 0. Includes U38–U41 (native channel/wire
pins), U36/U37 (packaging: CHANGELOG head still matches pubspec 7.4.2), and the
`tdd/001-intents-port` + `tdd/002-publishable-plugin` acceptance/unit sets.

## Gates

- `dart format test/platform_interface_suite_test.dart`: 1 file changed, re-run
  green afterwards.
- `dart analyze test/platform_interface_suite_test.dart`: `No issues found!`
- `flutter pub publish --dry-run`: not run — no `pubspec.yaml`/version change in
  this branch (U37's CHANGELOG-head pin stays satisfied at 7.4.2).

## Not covered locally (honest limits)

- **No end-to-end macOS hand-off.** Nothing here proves a live
  `open -a <host> <file>` delivers through `handleOpenURLs:`; that needs a host app
  that ships the plugin and a cold launch. What is proven is the exact mechanism
  the finding named: the selector the engine probes is now the selector this class
  exports, checked at runtime rather than by reading a header.
- **`applicationDidFinishLaunching(_:)` and the partial-batch `latestMedia` reset**
  (the review's minor notes) are deliberately unchanged; see `fix.md`.
- **Downstream version**: the fix rides the next fleet release (mono-version
  policy, `PUBLISH.md`) — no version bump in this branch.