# Bug Test Report: macos-open-prompt-suppression

- **Slug**: macos-open-prompt-suppression
- **Result**: verified at the gate this repo can run — guard test red → green,
  negative control conclusive, full Dart suite green. Runtime proof deferred to
  the host appex rebuild (zuraffa_browser#996).
- **Date**: 2026-11-15
- **Environment**: Linux host, Flutter 3.47.9 stable / Dart 3.13.7,
  `flutter test --concurrency=2` (fleet cap), shared `~/.pub-cache`
- **Gate**: `test/macos_open_prompt_test.dart` — a textual contract pin over
  `macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift`

## Why a textual pin

This repo's CI never compiles Swift (`flutter test` does not build native code),
and the changed code runs inside the host's Share Extension `.appex` — not in the
Dart test process. So the automated gate for a Swift-only behaviour change is a
source contract pin, exactly as `test/macos_file_url_shadowing_test.dart` does for
the sibling macOS fixes. Three assertions, closing the three ways this fix can be
undone:

| # | Assertion | Failure mode it catches |
|---|---|---|
| 1 | source contains `openConfiguration.promptsUserIfNeeded = false` | the flag is never set (the bug) |
| 2 | source does **not** contain `NSWorkspace.shared.open(url, configuration: NSWorkspace.OpenConfiguration())` | the inline default is reintroduced |
| 3 | source contains `NSWorkspace.shared.open(url, configuration: openConfiguration)` | a configuration is prepared but a *different* one is passed to the open |

Assertion 3 is the one that stops the pin being decorative: hoisting the
configuration without switching the call argument would pass a naive "flag is set"
check while the prompt stayed.

## Green

```
flutter test test/macos_open_prompt_test.dart --concurrency=2
00:00 +3: All tests passed!
```

## Red → green, and the negative control

Re-verified on this host (the review reported the same result independently):

1. **Red** — the fixed hunk reverted to the pre-fix inline default
   (`NSWorkspace.shared.open(url, configuration: NSWorkspace.OpenConfiguration())`),
   guard unchanged:

   ```
   flutter test test/macos_open_prompt_test.dart --concurrency=2
   00:00 +0 -3: Some tests failed.

   Failing tests:
     … macOS redirect no longer opens with an inline default configuration
     … macOS redirect opens the host app without a user confirmation
     … macOS redirect opens through the prepared configuration
   ```

   **All three fail**, so the guard is a real gate and not a test that passes
   vacuously against the bug. The Swift file was then restored byte-for-byte
   (`git diff` on it: empty).

2. **Green** — same command after restoring the fix: `00:00 +3: All tests passed!`

## Full Dart suite

`flutter test --concurrency=2` (all test files, default path = `test/`):

```
00:16 +105: All tests passed!
```

105 passed, 0 failed, 0 skipped — including `test/macos_open_prompt_test.dart`
(+3) and the pre-existing `test/macos_file_url_shadowing_test.dart` /
`test/platform_interface_suite_test.dart` native-consistency pins. Matches the
count the review reported for the same branch head.

No `dart format` / `dart analyze` delta is recorded: this change set adds
Markdown under `.specify/bugs/` only — the Swift hunk and the Dart guard were
already on the branch at commit `3ba77d0` and are untouched by the review-fix
commit.

## Not covered locally (honest limits)

- **The prompt is not observed disappearing.** Nothing in this repo can show it:
  CI never compiles Swift, and the open happens in the host `.appex`, which no
  host app currently builds from these sources. The evidence chain is: the AppKit
  default (`promptsUserIfNeeded == true`) is documented behaviour, the flag is now
  set to `false` at the only `NSWorkspace.shared.open` call site in the repo, and
  the pin is red on the pre-fix tree.
- **No macOS SDK on the verifying host.** The `activates` question in the issue
  could not be checked against a real `NSWorkspace.OpenConfiguration`
  interface here; it is recorded from the reviewer's note and is not relied on by
  any code (see `fix.md`, "Not changed").
- **Runtime confirmation is the acceptance criterion of issue #22 and is still
  open.** It lands with the mac110 appex rebuild tracked in
  zuraffa_browser#996 — commit the `.appex` to the host repo and give it a
  durable rebuild path. Issue #22's acceptance item 3 ("reply confirming the
  fleet appex rebuild picked it up") is therefore not satisfiable from this repo.
- **The failed-open path stays silent.** `{ [weak self], _ in … }` calls
  `completeRequest` regardless of the open result; pre-existing and out of scope
  here (own follow-up issue).