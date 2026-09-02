# Tasks: 002-publishable-plugin

## 1. Baseline (harness)

- [x] 1.1 Port native trees from `zikzak_share_handler` with systematic
      rebranding (android kotlin+pigeon java, ios/macos swift SPM,
      linux/windows C++ stubs); add podspecs for ios/macos (fixes the
      source's missing-podspec defect); AGP8-safe manifest.
- [x] 1.2 Convert pubspec to the Flutter plugin declaration (six platforms),
      swap `test` → `flutter_test`, convert tdd-profile dart → flutter
      runner, add LICENSE. Baseline re-verified: 20/20 under `flutter test`,
      `flutter analyze` clean (commit 2384ab0).

## 2. RED (test-first)

- [ ] 2.1 Write `test/platform_interface_suite_test.dart` (U20..U40) against
      the absent platform-interface API; observe red (compile failure for
      the missing symbols + failing packaging assertions).

## 3. GREEN

- [ ] 3.1 `lib/src/platform/wire/share_intents_wire.dart`: channel name
      constants, wire-map builders (FR-002), `ShareIntentsApiCodec` (FR-003),
      quirk predicate + entity decoding (FR-004).
- [ ] 3.2 `lib/src/platform/method_channel/method_channel_share_intent_port.dart`:
      the driver over pigeon `BasicMessageChannel`s + the `EventChannel`
      lazy-singleton stream (FR-005..FR-008).
- [ ] 3.3 `lib/src/platform/web/zuraffa_intents_web.dart`: web plugin
      registration class (FR-001).
- [ ] 3.4 `lib/src/share_intent_service.dart`: `ShareIntentService.platform()`
      factory + upgraded `registerShareIntentDependencies` (FR-009); barrel
      exports updated.

## 4. Evidence & audit

- [ ] 4.1 Deliberate-mutant matrix over U20..U40 (0 SURVIVED, byte-identical
      reverts) — `tdd/mutant-run.md`.
- [ ] 4.2 `tdd/verification.md` — PASS verdict against the 10 FRs.
- [ ] 4.3 Publish-readiness: README (migration table), CHANGELOG, example
      refresh; `flutter pub publish --dry-run` green.
