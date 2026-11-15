# Bug Assessment: macOS share extension gates every share with the cross-app open confirmation

- **Slug**: macos-open-prompt-suppression
- **Created**: 2026-11-15
- **Source**: https://github.com/arrrrny/zuraffa_intents/issues/22
- **Verdict**: valid
- **Severity**: medium — a per-share user interaction on the primary macOS
  hand-off path, with no data loss and no crash. Graded below "high" (the
  neighbouring `macos-open-url-receive` class, where the whole receive path was
  unreachable) because the payload still arrives: the user pays one click per
  share, not a broken feature.

Written as the review follow-up on
https://github.com/arrrrny/zuraffa_intents/pull/23 — the diagnosis and the
remediation are the ones that PR shipped, recorded here because the repo's bug
extension convention is a per-bug directory and this bug had none.

## Report (verbatim or summarized)

Issue title: "macOS: share extension triggers the wants-to-open / app-data-separate
confirmation on every share - set promptsUserIfNeeded = false".

Reported symptom: on macOS 26.x the extension → host hand-off works (the
`ShareMedia-<host bundle id>://` scheme launches the main app), but every single
share first shows:

> **Zuraffa wants to open "Zuraffa"**
> Keeping app data separate makes it easier to manage your privacy and security.

The user must click *Open* on every share before the app activates.

The reporter's diagnosis: `redirectToHostApp()` opens the URL with a **default**
`NSWorkspace.OpenConfiguration`, and on modern macOS an app-extension process
opening a URL into a different bundle is gated by
`OpenConfiguration.promptsUserIfNeeded`, which **defaults to true**. The issue
notes the string `promptsUserIfNeeded` appeared nowhere in `macos/` or `lib/`
before this fix.

## Symptom

Every share that reaches the macOS share extension raises a system confirmation
naming the host app ("Zuraffa wants to open 'Zuraffa' / Keeping app data separate…")
before the host is brought to the front. The hand-off itself is correct — the
payload is delivered, the custom scheme resolves, `completeRequest` fires from
the open completion handler — so the defect is purely the extra gate, which makes
the share flow feel like an install prompt on every use.

## Reproduction

1. Build a host macOS app with a Share Extension target whose principal class
   subclasses `ShareIntentMacosViewController` (a host `.appex` is required for
   this path to run at all).
2. Share anything into the extension from Finder or Safari.
3. Observed: macOS shows the "wants to open … / Keeping app data separate"
   confirmation; the host app only launches after *Open* is clicked.
4. Expected: the host app is activated with no confirmation, and the payload is
   delivered exactly as before.

Not reproducible on iOS/Android — `NSWorkspace` is AppKit-only and the other
platforms hand off through their own mechanisms.

## Suspected Code Paths

- `macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift:218`
  — `redirectToHostApp()`, the whole extension → host hand-off.
- `.../ShareIntentMacosViewController.swift:255-257` — the open site: the
  configuration was constructed **inline** at the call
  (`NSWorkspace.shared.open(url, configuration: NSWorkspace.OpenConfiguration())`),
  so nothing ever set `promptsUserIfNeeded` and the AppKit default (`true`)
  governed the open.
- `.../ShareIntentMacosViewController.swift:257-260` — the completion closure
  `{ [weak self] _, _ in … }`: `completeRequest` fires on both success and
  failure. Pre-existing and untouched by the fix (see `fix.md`, "Not changed").

## Root Cause Hypothesis

Confidence: high. `NSWorkspace.OpenConfiguration.promptsUserIfNeeded` is `true`
by default, and macOS consults it when an app-extension process opens a URL into
a **different** bundle — which is exactly what the share extension does. Because
the configuration was built inline at the call site, there was no seam at which
the flag could be set, so every share took the prompt path. The fix therefore
has two parts, not one: hoist the configuration into a named local, then opt out.

## Proposed Remediation

**Preferred** (this is what shipped on `fix/macos-open-prompt-suppression`):

```swift
let openConfiguration = NSWorkspace.OpenConfiguration()
openConfiguration.promptsUserIfNeeded = false
NSWorkspace.shared.open(url, configuration: openConfiguration) { [weak self], _ in
    self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
}
```

Prepare the configuration explicitly, opt out of the prompt, and pass **that**
configuration to the open call — passing a different one would leave the pin
decorative.

**Lock it with a textual-contract guard.** CI in this repo never compiles Swift
(`flutter test` does not build native code), so the automated gate is a source
pin in the established style of `test/macos_file_url_shadowing_test.dart`:
`test/macos_open_prompt_test.dart` asserts (1) the flag is set to `false`,
(2) the inline default form is gone, and (3) the prepared configuration is the
one handed to `NSWorkspace.shared.open`.

**Alternatives**:
- Set the flag globally / via `NSWorkspace.shared.open(_:)` without a
  configuration — rejected: the prompt behaviour is per-configuration, and the
  no-configuration overload is not what the extension needs.
- Suppress the prompt app-side (the host's own launch handling) — rejected: the
  prompt is raised by the **extension** process at open time, before the host
  runs, so no host-side change can prevent it.

**Files likely to change**:
- `macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift`
- `test/macos_open_prompt_test.dart` (new guard test)

**Tests to add or update**:
- The guard test above (red on the parent commit, green after the fix).

## Risks & Considerations

- **The fix only lands when the host's `.appex` is rebuilt.** This Swift runs in
  the Share Extension binary, not the main app, and no host app currently ships
  an extension built from these sources — see `test.md`, "Not covered locally".
  Until that rebuild happens, merging here changes nothing the user can observe.
- **The open result is still unchecked.** `completeRequest` runs whether the open
  succeeded or not, so a failed hand-off still looks like a completed share.
  Pre-existing, out of scope for this bug, worth its own issue.
- No wire-contract change: channel names, the pigeon codec and `SharedMedia` are
  untouched.
- No Dart/lib change, no version bump (fleet release chores own bumps —
  `PUBLISH.md`).

## Open Questions

- **Runtime proof is deferred.** This repo's CI never compiles Swift, so the
  behavioural evidence — the confirmation actually being gone — can only come
  from a real host build. That is tracked as zuraffa_browser#996 (commit the
  `.appex` to the host repo and give it a durable rebuild path). Until then the
  claim rests on the textual pin plus the AppKit default.
- The issue suggested additionally setting `config.activates = true` to keep
  bring-to-front behaviour explicit. **Not taken.** The reviewer's 🔵 note on
  PR #23 records that `NSWorkspace.OpenConfiguration` has no `activates`
  property — the properties in play here are `promptsUserIfNeeded` and `hides` —
  so the PR body's mention of `activates` was a documentation slip. No code in
  this fix depends on it, and no macOS SDK is available on the Linux host that
  verified this change, so the claim is recorded from the review rather than
  re-checked locally.