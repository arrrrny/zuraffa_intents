# Tasks: 003-outbound-send-port

> Brownfield addition of the send side (issue #9, zik_zak spec 1205): the
> outbound text/file share seam behind `ShareIntentService`, with
> `share_plus` wrapped as an internal implementation detail. Order honors
> the red→green discipline: the suite is written first (compiling against
> an absent API is the honest red), then the implementation lands.

## 1. Setup

- [x] 1.1 Resolve the build: add `share_plus: ^13.3.0` (+ the
      `share_plus_platform_interface` test seam in dev_dependencies);
      drop the `zuraffa: path: …` entries from both
      `dependency_overrides:` blocks (root + example) — the stray mono-dev
      path overrides broke `flutter pub get` (and therefore `test.yml`) on
      every CI checkout since 3526412; the fleet `xml: 7.1.0` pin stays
      (`PUBLISH.md` / `update_fleet.sh` enforce it). zuraffa resolves from
      pub.dev at ^7.3.0.

## 2. Specification

- [x] 2.1 Write `specs/003-outbound-send-port/spec.md` (FR-001..FR-006
      mirroring the issue's FR-1..FR-6; FR-5 recorded as the zik_zak
      cross-link it is; plan-phase decision recorded in FR-003: share_plus
      delegation over a first-party send channel).

## 3. Red — failing suite first

- [x] 3.1 Write `test/sender_suite_test.dart` (S1–S16) importing the
      package barrel; run
      `flutter test --concurrency=2 test/sender_suite_test.dart` and
      observe the red (compile failure against the not-yet-written API):

      ```
      Error: The method 'shareText' isn't defined for the type 'ShareIntentService'.
      Error: 'ShareSenderPort' isn't a type.
      Error: Method not found: 'InMemoryShareSenderAdapter'.
      Error: 'SharePlusShareSenderPort' isn't a type.
      ```

## 4. Green — make the suite pass

- [x] 4.1 `ShareSendResult` / `ShareSenderPort` in
      `lib/src/domain/outbound/share_sender_port.dart` (FR-001).
- [x] 4.2 `ShareSendRecord` / `InMemoryShareSenderAdapter` in
      `lib/src/data/outbound/in_memory_share_sender_adapter.dart` — records
      every request in call order, files/hints snapshotted (FR-004).
- [x] 4.3 `SharePlusShareSenderPort` in
      `lib/src/platform/share_plus/share_plus_share_sender_port.dart` —
      share_plus delegation via the `SharePlus.custom` seam, bare-catch
      one error path (FR-003).
- [x] 4.4 `ShareIntentService` delegation (`shareText`/`shareFiles`),
      `senderPort` field, `.platform()` binding both drivers,
      `registerShareIntentDependencies` binding the send port; barrel +
      facade exports (FR-002).
- [x] 4.5 `flutter analyze --fatal-infos` clean;
      `flutter test --concurrency=2` green — 93/93 including the 16 new
      send behaviors (S1–S16) (FR-006).
- [x] 4.6 README: send API + outcome/error-path semantics documented,
      platform note for the send side, install snippet refreshed to the
      current fleet version (^7.3.0), behavior count updated.

## 5. Release (out of scope for this change)

- [ ] 5.1 Fleet mono bump via `../zuraffa/scripts/update_fleet.sh` with the
      README install guides in the same change — never out of family
      (`PUBLISH.md`). The release itself is not part of this PR; no
      version bump ships here.

## 6. Review fixes (PR #10 review round)

- [x] 6.1 `SharePlusShareSenderPort._present`: report the swallowed failure
      cause in debug builds (assert-wrapped `FlutterError.reportError`);
      release builds keep the silent one-error-path contract (FR-003).
- [x] 6.2 S15 tightened — the scripted `ArgumentError` was dead code
      (`SharePlus.share` validates params before the `SharePlatform` seam),
      so the test now exercises the real validation error and asserts the
      seam was never reached; S17 added for the spec.md empty-text edge case
      (`shareText(text: '')` → failure). Suite: 94/94, spec-003 behaviors
      16 → 17 (README counts updated).
