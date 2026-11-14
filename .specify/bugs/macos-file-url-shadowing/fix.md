# Bug Fix Report: macos-file-url-shadowing

- **Slug**: macos-file-url-shadowing
- **Branch**: `fix/macos-file-url-shadowing`
- **Status**: applied
- **Date**: 2026-11-14

## What changed

`macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift`

1. **`handleInputItems` — branch reorder (the core fix).** The
   `fileURLType` conformance check now precedes `urlContentType`. Because
   `public.file-url` conforms to `public.url`, the previous order matched
   every shared file in the URL branch, so `handleFiles` (and its App Group
   copy) was unreachable; the raw sender path traveled to the host as text.
   The macOS controller now matches the iOS sibling's precedence
   (`ShareIntentIosViewController.swift` checks files first).
2. **`handleFiles` — `loadItem` → `loadFileRepresentation`.** Wrapped in
   `withCheckedThrowingContinuation`; the copy into the App Group container
   happens inside the completion block, where the provider-vended URL is
   valid.
3. **`getNewFileUrl` — force-unwrap removed.** Returns `URL?` and logs a
   loud `[zuraffa_intents]` message when `containerURL` is nil (missing or
   non-team-prefixed `AppGroupId`); `handleFiles` skips the attachment
   instead of crashing the extension mid-share.
4. **`loadIds` — missing-`AppGroupId` warning.** The `group.<bundle-id>`
   fallback is iOS-shaped and never resolves on macOS; the extension now
   says so at load time instead of failing silently.

`macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift`

5. **`URL.queryDictionary` — `=`-less pairs guarded.** The split result is
   checked (`components.count > 1`) before indexing; previously any
   parameter without `=` crashed the host process with an index-out-of-range.

`test/macos_file_url_shadowing_test.dart` (new)

6. Textual-contract guard test (the repo's U-series pattern): pins the
   branch order on macOS and iOS, the `loadFileRepresentation` usage, the
   absent force-unwrap (`getNewFileUrl` signature), and the guarded query
   parsing. Runs in CI on both lanes — this repo's CI never compiles Swift,
   so this pin is the automated gate for the fix.

## TDD adaptation

`tdd_enabled` defaults to true for the bug extension, but the defect lives
in Swift that no Dart test can execute and no in-sandbox toolchain can
compile. Per the verification-rig's textual-contract recipe, the red-green
loop ran over the guard test instead: written first, run against unmodified
`master` — **red: 4 failed (the macOS pins), 1 passed (the iOS regression
pin)** — then the Swift remediation landed and the same test went green.
The kernel-dill escape was unnecessary (single-file `flutter test` fits the
~1 GB cgroup).

## Deviations / notes

- No wire-contract change: channel literals, pigeon codec, and the
  `SharedMedia` shape are untouched (A7/A8/U10 pins stay green).
- Full-package `flutter analyze` OOMs in this sandbox (analysis server
  killed at the ~1 GB cgroup); single-file `dart analyze` on the new test
  reports no issues, and CI runs `flutter analyze --fatal-infos` on both
  lanes as the definitive gate.
- Swift is not compiled by this repo's CI; the first downstream host build
  that links the SPM product gates the semantics.
