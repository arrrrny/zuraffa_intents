# Bug Assessment: macOS share extension treats shared files as URLs (UTI shadowing skips the App Group copy)

- **Slug**: macos-file-url-shadowing
- **Created**: 2026-11-14
- **Source**: pasted text (an AI-mode share conversation quoted across the user's messages, fact-checked line-by-line against this repo's Swift sources in the same session). Original share URL supplied by the user: `https://share.google/aimode/qBePjKO5lkC8lhLds` — host `share.google`, not on the safe list, so the fetch path is `auto-refused: host not on safe list: share.google`; no page was fetched for this assessment. The conversation's content was already available as pasted text in-chat (read earlier through the user's own Zuraffa browser session).
- **Verdict**: valid
- **Severity**: high

## Report (verbatim or summarized)

The conversation claimed the macOS controller passes raw sender paths to the
host app and mismatches the macOS App Group ID. Fact-check against the source:

- **False**: "it serializes the raw path into UserDefaults — the extension does
  not copy". `handleFiles` does copy into
  `containerURL(forSecurityApplicationGroupIdentifier:)` and serializes the
  copied path.
- **True (the real bug)**: because `public.file-url` conforms to
  `public.url`, `handleInputItems` checks `urlContentType` first, so shared
  files match the URL branch and `handleFiles` (the copy) is never reached;
  the raw `file:///...` string lands in `content` as text.
- **True (aggravators)**: `getNewFileUrl` force-unwraps `containerURL(...)!`
  (crashes the extension when `AppGroupId` is missing or not team-prefixed on
  macOS); `handleFiles` uses `loadItem` instead of the safer
  `loadFileRepresentation`; `URL.queryDictionary` in the plugin indexes
  `components(separatedBy: "=")[1]` and crashes on any parameter without `=`.

## Symptom

A shared file sent to a macOS share extension built on
`ShareIntentMacosViewController` is handled as a text URL instead of a file:
the App Group copy never happens and the raw `file:///...` path inside the
sender's container is serialized as `SharedMedia.content` for the host app.
The host then reads a foreign-container path (triggering the
"'Zuraffa' would like to access data from other apps" prompt per read, or a
failed read) instead of the TCC-safe group-container copy. Separately, a
missing/unprefixed `AppGroupId` crashes the extension at the
`containerURL(...)!` force-unwrap, and a malformed share URL crashes the host
in `queryDictionary`.

## Reproduction

1. Build a host macOS app with a Share Extension target whose principal class
   subclasses `ShareIntentMacosViewController` (the plugin package provides
   the controller; a host .appex is required for this path to run at all).
2. Share a local file (e.g. from Finder or Preview) into the extension.
3. Observed: `handleUrl` runs (`public.file-url` conforms to `public.url`, so
   the first `hasItemConformingToTypeIdentifier(urlContentType)` matches), the
   raw path is appended to `sharedText`, and `redirectToHostApp` serializes it
   in `SharedMedia.content` with no attachment and no copy.
4. Expected: `handleFiles` runs, copies the file into the App Group container,
   and hands the host the copied path (the pattern the iOS sibling already
   ships — it checks `fileURLType` before `urlContentType`).

[NEEDS CLARIFICATION: no host app currently ships the .appex (zuraffa_browser
has no extension target yet), so this is source-verified, not yet
device-reproduced; the app-side companion work (extension target + App Group
entitlements) is tracked separately.]

## Suspected Code Paths

- `macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift:46` —
  the `urlContentType` branch checked before `fileURLType`: the shadowing.
- `.../ShareIntentMacosViewController.swift:90` — `loadItem` for
  `fileURLType`: returns a transient original-path URL; `loadFileRepresentation`
  is the provider-coordinated contract.
- `.../ShareIntentMacosViewController.swift:102-106` — `getNewFileUrl` force-
  unwraps `containerURL(...)!`: nil (missing/unprefixed `AppGroupId`) crashes
  the extension mid-share instead of failing loudly.
- `.../ShareIntentMacosViewController.swift:41-54` — contrast with
  `ios/.../ShareIntentIosViewController.swift:76-79`, which checks
  `fileURLType` first: the macOS controller is the outlier.
- `macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift:184-188` —
  `queryDictionary` indexes `components(separatedBy: "=")[1]`: crash on any
  `&`-separated pair without `=`.

## Root Cause Hypothesis

Confidence: high. `UTType.fileURL` ("public.file-url") conforms to
`UTType.url` ("public.url"), and `hasItemConformingToTypeIdentifier` walks the
conformance chain, so a provider vending a file always satisfies the
`urlContentType` check. The macOS controller's branch order (url first, file
second) therefore routes every shared file through `handleUrl` — text handling
with no copy — while the iOS controller, sharing the same upstream lineage,
already checks files first. The force-unwrap and `loadItem` are aggravators in
the same intake: the first turns a config error into an extension crash, the
second reads the sender's original path where `loadFileRepresentation` vends a
provider-coordinated copy whose URL is valid only inside the completion block.

## Proposed Remediation

**Preferred**: four surgical Swift edits on the macOS half only.

1. Reorder `handleInputItems` branches: `fileURLType` before `urlContentType`
   (aligning with the iOS controller), with a comment recording the UTI
   conformance reason.
2. `handleFiles`: switch `loadItem` to `loadFileRepresentation`, wrapped in
   `withCheckedThrowingContinuation`; copy into the App Group container inside
   the completion block (the vended URL is only valid there).
3. `getNewFileUrl`: return `URL?`, nil-guard `containerURL(...)` with a loud
   `[zuraffa_intents]` log naming the misconfiguration; `handleFiles` skips the
   attachment when nil. Also log in `loadIds` when the `AppGroupId` key is
   absent (the `group.<bundle-id>` fallback is iOS-shaped and never resolves
   on macOS).
4. `URL.queryDictionary` in the plugin: guard pairs without `=`.

Lock the fix in with a textual-contract guard test (the repo's U-series
pattern, e.g. `test/tdd/002-publishable-plugin/u10_test.dart`): pin the branch
order, the `loadFileRepresentation` usage, the absent force-unwrap, and the
absent unguarded `[1]` indexing — red on master, green after the fix. CI
never compiles Swift in this repo (`flutter test` does not build native
code), so the textual pin is the only automated gate; the first real compile
happens in a downstream host build.

**Alternatives**:
- Inspect `registeredTypeIdentifiers` order instead of reordering the checks:
  more code, same effect; rejected for simplicity.
- Leave the branch order, make `handleUrl` sniff `file://` prefixes: text
  handling would still carry no attachment type and no copy; rejected as
  fragile and semantically wrong.

**Files likely to change**:
- `macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift`
- `macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift`
- `test/macos_file_url_shadowing_test.dart` (new guard test)

**Tests to add or update**:
- The guard test above (red-green in this cycle; runs in CI on both lanes).

## Risks & Considerations

- Swift is not compiled by CI in this repo: the guard test pins the text, the
  first native build (a downstream host) gates the semantics. The
  continuation-based `handleFiles` mirrors Apple's documented
  `loadFileRepresentation` contract and the AI-proven pattern already used
  elsewhere in the fleet.
- Behavior change: attachments that register BOTH a web URL and a file URL
  now take the file branch — the same precedence iOS already ships; expected
  and desirable.
- No wire-contract changes: channel literals, pigeon codec, and the
  `SharedMedia` shape are untouched (the U/A-series pins must stay green).
- The companion app-side work (a real .appex target in zuraffa_browser plus
  team-prefixed `2D3QTPZG5J.group.*` App Group entitlements) is out of scope
  here and tracked separately; without it this controller remains dormant.

## Open Questions

- [NEEDS CLARIFICATION: host-side confirmation — which app ships the .appex
  first and when, for a device-level end-to-end verification of the prompt
  disappearing.]
