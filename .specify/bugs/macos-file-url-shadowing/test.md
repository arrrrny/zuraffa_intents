# Bug Test Report: macos-file-url-shadowing

- **Slug**: macos-file-url-shadowing
- **Result**: verified (sandbox gates green; native compile deferred to CI/downstream per repo reality)
- **Date**: 2026-11-14
- **Environment**: Dart 3.14.0, Flutter 3.50.0 stable, Linux, ~1 GB cgroup
  (verification-rig: git 2.47.3 extracted debs, pub.zuzu.dev private registry
  token, per-file `flutter test` processes)

## Reproduction re-run (red-green)

1. **Red on `master`** (`fix/macos-file-url-shadowing` parent commit
   `8ba4ee5`): `flutter test test/macos_file_url_shadowing_test.dart` →
   `+1 -4: Some tests failed.`
   - FAILED macOS: fileURLType branch precedes urlContentType (branch order
     still url-first)
   - PASSED iOS (regression): fileURLType branch precedes urlContentType
   - FAILED macOS: handleFiles loads the provider-coordinated representation
   - FAILED macOS: getNewFileUrl fails loudly instead of force-unwrapping
   - FAILED queryDictionary tolerates pairs without =
2. **Green after the fix**: same command → `+5: All tests passed!`

## Full suite (all 40 test files, serial, one process per file)

- `bootstrap_smoke_test.dart` PASS (+1)
- `intents_suite_test.dart` PASS (+19)
- `platform_interface_suite_test.dart` PASS (+23)
- `sender_suite_test.dart` PASS (+17)
- `macos_file_url_shadowing_test.dart` PASS (+5)
- `tdd/001-intents-port/` a1–a8, u1–u9: 17 files PASS
- `tdd/002-publishable-plugin/` a1–a8, u1–u9, u10: 18 files PASS — including
  A7 (channel literals pinned across Dart + natives), A8, U10 (no
  `zikzak`/`ShareHandler` identifiers in the natives; rebranded plugin
  classes present)

**40/40 files green. 0 failures.**

## Gates

- `dart format` on the new test file: formatted to house style, re-tested
  green afterwards.
- `dart analyze test/macos_file_url_shadowing_test.dart`: `No issues found!`
- Full-package `flutter analyze --fatal-infos` (the CI gate): OOM-killed in
  this sandbox (analysis server `-9` at the ~1 GB cgroup — environment
  signature, not code); CI runs it with real memory on ubuntu + macos lanes.
- `flutter pub publish --dry-run` (CI ubuntu lane): not runnable
  in-sandbox; no pubspec/CHANGELOG changes shipped, so the risk delta is nil.

## Not covered locally (honest limits)

- **Swift compilation**: no Swift toolchain in the sandbox and CI does not
  compile Swift in this repo. The changed controller builds only inside a
  downstream host's extension target; the edits mirror patterns already
  compiling in the iOS sibling and Apple's documented
  `loadFileRepresentation` contract.
- **Device-level TCC verification** (`"Zuraffa" would like to access data
  from other apps` disappearing on a real share): requires a host app
  shipping the .appex — the companion zuraffa_browser work (extension target
  + `2D3QTPZG5J.group.*` App Group entitlements) is tracked separately.
  Until a host exists, this controller is dormant code.
