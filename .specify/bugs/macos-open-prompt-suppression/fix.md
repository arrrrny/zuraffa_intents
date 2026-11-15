# Bug Fix Report: macos-open-prompt-suppression

- **Slug**: macos-open-prompt-suppression
- **Branch**: `fix/macos-open-prompt-suppression`
- **Status**: applied
- **Date**: 2026-11-15
- **Source**: https://github.com/arrrrny/zuraffa_intents/issues/22, fixed by
  https://github.com/arrrrny/zuraffa_intents/pull/23 (commit `3ba77d0`)

## What changed

`macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift`

1. **The configuration is prepared, not inlined.** `redirectToHostApp()` now
   binds `let openConfiguration = NSWorkspace.OpenConfiguration()` and sets
   `openConfiguration.promptsUserIfNeeded = false` before the open. Inline, there
   was no seam to set the flag and the AppKit default (`true`) governed every
   extension → host open.

2. **The prepared configuration is the one passed to the open call.**
   `NSWorkspace.shared.open(url, configuration: openConfiguration)` — hoisting
   without switching the argument would have left the change decorative, which is
   exactly what guard assertion 3 exists to catch.

3. **The reason is recorded next to the code.** A short comment above the open
   names the AppKit default and the "Keeping app data separate" prompt (#22), so
   the next reader does not mistake the extra three lines for ceremony.

4. **The hand-off is otherwise untouched.** The `ShareMedia-<host>://` URL, the
   `[weak self] _, _ in` completion shape and the `completeRequest` call are
   unchanged — the fix removes a prompt and nothing else.

`test/macos_open_prompt_test.dart` (new)

5. Textual-contract guard (the repo's pattern for native behaviour CI cannot
   compile): the flag is set to `false`, the inline-default form is gone, and the
   prepared configuration reaches the open call. `flutter test` picks it up with
   no `dart_test.yaml` change.

## TDD adaptation

`tdd_enabled` is `true` in `.specify/extensions/bug/config-template.yml`, but the
defect lives in Swift that no Dart test can execute and this repo's CI never
compiles. Per the same textual-contract recipe the sibling
`macos-file-url-shadowing` fix used, the red-green loop ran over the guard test:
written first, run against the unmodified parent commit — **red, 3 of 3 failed**
(the whole file: the inline default was still there) — then the Swift
remediation landed and the same test went green. Recorded in `test.md`.

## Not changed (deliberately)

- **`activates`.** Issue #22 suggested also setting `config.activates = true` to
  make bring-to-front behaviour explicit. The reviewer's 🔵 note on PR #23
  records that `NSWorkspace.OpenConfiguration` has no `activates` property (the
  ones in play are `promptsUserIfNeeded` and `hides`), and the PR body's
  reference to it was a doc slip. The behaviour the issue wanted to preserve —
  the host coming to the front — is the default for a URL open and is unaffected
  by setting the prompt flag. Not added; no macOS SDK on the verifying host to
  check the symbol either way.
- **The completion closure `{ [weak self] _, _ in … }`.** It ignores the open
  result, so a **failed** open still calls `completeRequest` and the share
  silently disappears with no signal to the user. Pre-existing and untouched by
  this diff; the reviewer flagged it as a 🔵 informational note and recommended
  its own follow-up issue rather than widening this PR, and this fix agrees —
  changing the failure path would make an otherwise 6-line Swift change
  unreviewable without a macOS build.
- **`CHANGELOG.md`.** Untouched, matching repo practice: every entry in its
  history is a `chore(fleet)` release commit and no fix PR in this repo bumps it
  (`PUBLISH.md` — the repo is mono-versioned with the fleet).
- **No Dart/lib production code.** The change is the Swift hunk plus one test
  file, so no channel literal, pigeon codec or `SharedMedia` shape moves.

## Deviations / notes

- The PR body's "`activates` left at its default (true) — existing
  bring-to-front behavior preserved" sentence is inaccurate for the reason above.
  It is a description-only slip; the shipped code never mentions `activates`.
- Behavioural proof is not available in this repo: CI never compiles Swift, and
  the code runs in the host's `.appex`, which no host currently builds from these
  sources. That deferral is tracked in zuraffa_browser#996 and is the reason the
  textual pin matters.

## Follow-up (review notes on PR #23)

The single actionable review finding (🟡, `zuraffa-review[bot]`, anchored on
`test/macos_open_prompt_test.dart:6`) was that this bug's `.specify/bugs/<slug>/`
artifacts were missing — both structurally identical macOS share-extension fixes
landed the trio (`.specify/bugs/macos-file-url-shadowing/`, PR #18;
`.specify/bugs/macos-open-url-receive/`, #11 / PR #21), and with
`tdd_enabled: true` the extension pins this directory as the TDD feature.

This directory is that fix: `assessment.md` (issue #22 + diagnosis), `test.md`
(the gate and the negative control), `fix.md` (this file). No code change
accompanies it — the Swift remediation and its guard were already on the branch.