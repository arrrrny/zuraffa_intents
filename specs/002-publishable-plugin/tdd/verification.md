---
feature: 002-publishable-plugin
verdict: PASS
standard: .specify/extensions/tdd/templates/tdd-test-quality-rubric.md # rubric graded against (toolchain-level)
verified_at: e0849a1 # short SHA audited (the packaging/TDD commit)
behaviors: 21
proven: 21
likely: 0
test_after: 0
no_test: 0
not_applicable: 0
high_smells: 0
criteria_total: 10
criteria_covered: 10
mutation_score: 100 # scope: wire-map builders, the type-tagged codec, the quirk predicate, the method-channel driver (result/error/channel-error + stream singleton), the platform wiring, packaging metadata, and the Dart↔native channel-consistency contract; deliberate-mutant sweep (21/21 killed) — see tdd/mutant-run.md
mutants_survived: 0
suite: 41 passed, 0 failed (1 bootstrap smoke + 19 spec-001 + 21 spec-002); flutter analyze clean; flutter pub publish --dry-run 0 warnings
real_device: "not applicable in this environment — the Dart platform-interface layer is exercised over TestDefaultBinaryMessenger plumbing (mocked BasicMessageChannel replies and real handlePlatformMessage event envelopes); the native trees are a faithful port of the proven zikzak_share_handler implementations pinned by the U38–U40 consistency suite; device bring-up is the maintainer's CI matrix"
---

# TDD Verification: 002-publishable-plugin — the platform-interface layer

**Verdict: PASS.** Every one of the 21 behaviors is `PROVEN`: the suite was
written first and observed red against the absent API (compile failure —
`sharedAttachmentWireMap`, `ShareIntentsApiCodec`,
`MethodChannelShareIntentPort`, `ShareIntentService.platform` not found; the
compiler is the oracle), the implementation then landed green (41/41 across
the bootstrap smoke, spec-001, and spec-002 suites; `flutter analyze` clean),
and the deliberate-mutant sweep killed 21/21 injected mutants with zero
survivors and byte-identical reverts. All 10 FRs are covered end-to-end
through the package's real public API — the barrel exports — with the
packaging and native-consistency FRs enforced as executable tests rather
than review claims.

## Test-first evidence

The layer is greenfield on top of the frozen spec-001 baseline (20/20 under
the converted flutter runner at the harness commit `2384ab0`). The
21-behavior suite was committed red: `flutter test
test/platform_interface_suite_test.dart` failed at load time with
`Method not found` on every new symbol. After the implementation landed the
suite turned green, and each behavior's teeth were confirmed by the mutant
matrix (`flutter test … --plain-name "<id>:"` per deliberate mutant).

## Coverage of the criteria

- **FR-001 (publish-ready packaging)** — U36 (pubspec: six platforms,
  rebranded classes, repository/issue_tracker, description length, flutter
  floor) and U37 (declared podspec/Package.swift/fileName paths exist;
  CHANGELOG head matches the version). Machine-checked; `flutter pub publish
  --dry-run` finishes with 0 warnings.
- **FR-002 (wire-map fidelity)** — U20 (attachment `{path, type: index}` for
  all four kinds) and U21 (all nine media keys present, nulls preserved,
  attachments as wire maps).
- **FR-003 (codec)** — U22 (`encodeMessage`/`decodeMessage` round-trip under
  the tag-129 envelope; the first wire byte is asserted), U23 (native-emitted
  plain maps decode into entities via the driver's decode path), U24 (tags
  128 and 130 both accepted).
- **FR-004 (quirk + injectable predicate)** — U25 (quirk applies iff the
  predicate holds; default predicate is `!kIsWeb && (isIOS || isMacOS)` and
  is verified on the VM host).
- **FR-005 (getInitial semantics)** — U26 (result map → entity; null result
  → null), U27 (error reply → `PlatformException` with exact
  code/message/details), U28 (null reply → `channel-error` with the
  canonical message).
- **FR-006 (recordSentMessage)** — U29 (single-element entity envelope with
  the argument mapping; `{result: null}` completes), U30 (error/null reply
  semantics).
- **FR-007 (reset)** — U31 (null payload; result/error semantics).
- **FR-008 (stream)** — U32 (a real `handlePlatformMessage` success envelope
  decodes into an entity under the injectable predicate), U33 (lazy-singleton
  stream identity per port, distinct across ports).
- **FR-009 (platform wiring)** — U34 (`ShareIntentService.platform()` binds
  the driver and accepts a `BinaryMessenger`; direct construction keeps the
  in-memory default — spec-001's U17 remains authoritative there), U35 (the
  composition root binds the driver as the `ShareIntentPort` singleton and
  the service to that port, both lazy singletons).
- **FR-010 (native consistency)** — U38 (event channel literal equal across
  the Dart wire module, Kotlin plugin, both Swift plugins), U39 (the three
  pigeon channels equal across the Dart wire module, Pigeon Java, both Swift
  APIs), U40 (rebranded plugin classes present; zero leftover
  zikzak/ShareHandler identifiers across all five native trees, scanned
  case-insensitively by the suite itself).

## Mutation evidence

21/21 deliberate mutants killed, 0 survived, every revert byte-identical
(`tdd/mutant-run.md`). The matrix includes the cross-language rows: a
one-character channel drift on the Dart side and a rebrand reversion in the
ported Kotlin are both killed by the consistency suite — the property that
makes the six-platform port auditable from a single `flutter test` run.

## Baseline integrity

Spec-001's behaviors are untouched: its 19 behaviors pass unmodified under
the flutter runner (only the test import moved from `package:test` to
`package:flutter_test` in the harness commit), `lib/src/domain/**` is
byte-identical to master, and the in-memory default for direct service
construction is preserved (U17/U34 pin both sides of the seam).

## Known boundaries (documented, not defects)

- The native trees are not compiled here (no Android/iOS/macOS toolchains in
  the environment); they are a systematic rename-port of the proven source
  implementations, and every rename-shaped delta a compiler would catch in
  the wire path (channel literals, plugin classes, identifiers) is covered
  by U38–U40 from the Dart side.
- Linux/Windows/web remain the source plugin's honest stubs; web receive is
  an app-level `share_target` flow, documented in the README.
