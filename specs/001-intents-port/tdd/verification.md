---
feature: 001-intents-port
verdict: PASS
standard: .specify/extensions/tdd/templates/tdd-test-quality-rubric.md # rubric graded against (toolchain-level)
verified_at: 52186ac # short SHA audited (the feature's TDD commit)
behaviors: 19
proven: 19
likely: 0
test_after: 0
no_test: 0
not_applicable: 0
high_smells: 0
criteria_total: 9
criteria_covered: 9
mutation_score: 100 # scope: the attachment-type enum, the generated SharedAttachment/SharedMedia serializers (zorphy copyWith + equality + json_serializable), the in-memory adapter, and the service facade; deliberate-mutant sweep (19/19 killed) — see tooling note
mutants_survived: 0
suite: 20 passed, 0 failed (1 bootstrap smoke + 19 suite); dart analyze clean
real_device: "not applicable — pure-Dart package; the port is exercised through the shipped InMemoryShareIntentAdapter plus a hand-rolled scripted port fake, with no platform channel, network, or clock dependency"
---

# TDD Verification: 001-intents-port — the share-intent receiving suite

**Verdict: PASS.** Every one of the 19 behaviors is `PROVEN`: the suite
was written first and observed red against the absent API (compile
failure — no behavior could pass before the implementation existed), the
implementation then landed green (20 passed including the bootstrap
smoke, `dart analyze` clean), and the deliberate-mutant sweep killed
19/19 injected mutants with zero survivors. All 9 FRs are covered
end-to-end through the package's real public API — the barrel exports —
with no direct private-source imports in the suite.

## Test-first evidence

This feature is greenfield, so the red is structural: the 19-behavior
suite was committed in a state where `dart test
test/intents_suite_test.dart` failed at load time (`ShareIntentPort`,
`SharedMedia`, `SharedAttachment`, `SharedAttachmentType` not found —
the compiler is the oracle), which means no test could have passed
before the implementation landed. After the implementation
(commit `52186ac`) the suite turned green, and each behavior's teeth
were separately proven with a deliberate mutant: baseline PASS on the
clean tree → inject → targeted FAIL via the profile's single command
(`dart test test/intents_suite_test.dart --plain-name "<id>:"`) →
revert with byte-for-byte verification. All 19 injections, observations,
and reverts are recorded per-cycle in `tdd/cycle-log.md` and as a
machine-readable matrix in `tdd/mutant-run.md`. The runner refuses to
proceed if a baseline test fails on the clean tree, if a mutant's anchor
is not unique in its file, or if a revert drifts — the matrix is
trustworthy by construction, not by assertion.

One defect was caught and fixed during the green phase, recorded in the
cycle log rather than silently folded in: the scripted port fixture
returned a fresh `StreamController.stream` view per access, violating
the port contract's stable-stream-instance requirement (FR-008, the
plugin's `_sharedMediaStream ??=` semantics) that U19 pins; the fake now
memoizes its stream. The production adapter already complied (proven
separately by U15 and its mutant).

## Coverage of the spec criteria

- **FR-001** (vocabulary): U1 — exactly image/video/audio/file in
  declaration order, indices 0..3.
- **FR-002** (attachment entity): U2 (copyWith), U3 (field-based
  equality + hashCode).
- **FR-003** (attachment JSON): U4 round-trip.
- **FR-004** (media entity + JSON): U5 full-fidelity round-trip (nine
  fields, nested attachments, null recipient element), U6 minimal
  round-trip + absent-field omission.
- **FR-005** (media copyWith/equality): U7 (wholesale list
  replacement), U8 (scalar field-based equality).
- **FR-006** (initial-share lifecycle): U9 (fresh null), U10 (verbatim,
  repeatable reads), U11 (reset clears; idempotent).
- **FR-007** (recordSentMessage): U12 (plugin argument mapping),
  U13 (ordered accumulation, null optionals).
- **FR-008** (stream semantics): U14 (broadcast, two listeners),
  U15 (lazy singleton identity), U16 (no replay).
- **FR-009** (facade + composition root): U17 (default in-memory port +
  lifecycle delegation), U18 (verbatim pass-through + verbatim error
  surfacing), U19 (stream identity + lazy-singleton resolution).

## Smells and scope

- No test-after productions: the suite predates the implementation.
- No skipped, hidden, or runtime-depending tests: no clocks, no sleeps
  beyond event-loop settling, no network, no platform channels.
- One test helper (the scripted port) is a hand-rolled fake — no
  mocking library; it participates in the port contract (including the
  U19 stream-identity requirement it initially violated and was fixed
  to honor).
- Mutation score is a deliberate-mutant sweep, not statistical
  mutation testing: 19 hand-injected mutants, one per behavior, each
  demonstrably detected.
