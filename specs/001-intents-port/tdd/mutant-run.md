# Deliberate-mutant red evidence (spec 001-intents-port)

| behavior | mutant | baseline | mutant | revert | verdict |
| --- | --- | --- | --- | --- | --- |
| U1 | enum constant renamed (`audio` → `sound`) — vocabulary drifts | baseline PASS | mutant KILLED | revert PASS | OK |
| U2 | attachment `copyWith` ignores the new `type` (`type ?? this.type` → `this.type`) | baseline PASS | mutant KILLED | revert PASS | OK |
| U3 | attachment `==` drops the `type` field check | baseline PASS | mutant KILLED | revert PASS | OK |
| U4 | generated attachment `toJson` emits a constant `'/mutant'` path — round-trip loses the path | baseline PASS | mutant KILLED | revert PASS | OK |
| U5 | generated media `toJson` emits a constant `'mutant'` senderIdentifier — full-fidelity round-trip broken | baseline PASS | mutant KILLED | revert PASS | OK |
| U6 | generated media `toJson` loses the null-aware `?subject` entry — absent fields reappear in JSON | baseline PASS | mutant KILLED | revert PASS | OK |
| U7 | media `copyWith` ignores the new `attachments` — replacement list dropped | baseline PASS | mutant KILLED | revert PASS | OK |
| U8 | media `==` drops the `conversationIdentifier` field check | baseline PASS | mutant KILLED | revert PASS | OK |
| U9 | adapter fabricates a default media for a fresh store (`?? SharedMedia()`) | baseline PASS | mutant KILLED | revert PASS | OK |
| U10 | `storeInitial` stores null — the boot share is silently dropped | baseline PASS | mutant KILLED | revert PASS | OK |
| U11 | `resetInitialSharedMedia` self-assigns — reset becomes a no-op | baseline PASS | mutant KILLED | revert PASS | OK |
| U12 | recordSentMessage maps `conversationIdentifier` into `speakableGroupName` — plugin mapping broken | baseline PASS | mutant KILLED | revert PASS | OK |
| U13 | sent-message records prepend instead of append — call order lost | baseline PASS | mutant KILLED | revert PASS | OK |
| U14 | stream controller degrades from `.broadcast()` to single-subscription — second listener fails | baseline PASS | mutant KILLED | revert PASS | OK |
| U15 | stream getter rebuilds per access (`late final` → getter) — stream identity lost | baseline PASS | mutant KILLED | revert PASS | OK |
| U16 | `emit` double-fires each share — duplicate delivery | baseline PASS | mutant KILLED | revert PASS | OK |
| U17 | service `getInitialSharedMedia` returns null without consulting the port — delegation broken | baseline PASS | mutant KILLED | revert PASS | OK |
| U18 | service recordSentMessage pass-through drops `serviceName` (`serviceName: null`) | baseline PASS | mutant KILLED | revert PASS | OK |
| U19 | service stream getter returns `Stream.empty()` instead of the port's stream | baseline PASS | mutant KILLED | revert PASS | OK |

Matrix: **19/19 KILLED, 0 SURVIVED.** Runner:
`scripts/mutant_matrix_intents.py` (agent workspace; protocol: per-behavior
targeted run via the profile's single command —
`dart test test/intents_suite_test.dart --plain-name "<id>:"` — baseline
must PASS on the clean tree, the injected mutant must FAIL, the anchor must
be unique in its file, and the subject is restored via `git checkout --`
with byte-for-byte verification; any survivor or revert drift exits
non-zero).
