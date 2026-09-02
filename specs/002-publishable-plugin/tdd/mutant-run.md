---
feature: 002-publishable-plugin
matrix_runner: scripts-side deliberate-mutant harness (mutant_matrix_publishable.py in the agent workspace), protocol identical to spec-001
protocol: baseline PASS → inject → targeted FAIL (KILLED) → git checkout revert, byte-verified
target_command: flutter test test/platform_interface_suite_test.dart --plain-name "<id>:"
date: 2026-09-02
---

# Mutant Run: 002-publishable-plugin

Deliberate mutants over the platform-interface layer (U20..U40). Every
mutant kills its targeted behavior; every revert is byte-identical to the
committed tree.

| id | subject file | deliberate mutant | targeted | verdict |
| -- | ------------ | ----------------- | -------- | ------- |
| U20 | lib/src/platform/wire/share_intents_wire.dart | `sharedAttachmentWireMap` drops the `path` key | U20: | KILLED |
| U21 | lib/src/platform/wire/share_intents_wire.dart | `sharedMediaWireMap` omits the `subject` key (nine-key invariant) | U21: | KILLED |
| U22 | lib/src/platform/wire/share_intents_wire.dart | outgoing media envelope uses the legacy tag 130 instead of 129 | U22: | KILLED |
| U23 | lib/src/platform/wire/share_intents_wire.dart | `recipientIdentifiers` cast drops nullability (`cast<String>()`) | U23: | KILLED |
| U24 | lib/src/platform/wire/share_intents_wire.dart | legacy tag 130 no longer accepted on decode | U24: | KILLED |
| U25 | lib/src/platform/wire/share_intents_wire.dart | apple-like `Uri.decodeFull` quirk removed | U25: | KILLED |
| U26 | lib/src/platform/method_channel/…port.dart | null result maps to `SharedMedia()` instead of `null` | U26: | KILLED |
| U27 | lib/src/platform/method_channel/…port.dart | wire-error reply message replaced with `'swallowed'` | U27: | KILLED |
| U28 | lib/src/platform/method_channel/…port.dart | channel-error code `'channel-error'` → `'channel_error'` | U28: | KILLED |
| U29 | lib/src/platform/method_channel/…port.dart | `conversationName` mapped to the wrong carrier field | U29: | KILLED |
| U30 | lib/src/platform/method_channel/…port.dart | `_guard` swallows wire errors (returns instead of throwing) | U30: | KILLED |
| U31 | lib/src/platform/method_channel/…port.dart | reset sends a `'reset'` payload instead of null | U31: | KILLED |
| U32 | lib/src/platform/method_channel/…port.dart | stream decode forces the quirk predicate to true | U32: | KILLED |
| U33 | lib/src/platform/method_channel/…port.dart | stream singleton memoization dropped (fresh stream per access) | U33: | KILLED |
| U34 | lib/src/share_intent_service.dart | `ShareIntentService.platform()` binds the in-memory adapter | U34: | KILLED |
| U35 | lib/src/share_intent_service.dart | composition root binds the in-memory adapter as the port | U35: | KILLED |
| U36 | pubspec.yaml | web `pluginClass` renamed (`ZuraffaIntentsWebBroken`) | U36: | KILLED |
| U37 | CHANGELOG.md | head entry version drifts from the package version | U37: | KILLED |
| U38 | lib/src/platform/wire/share_intents_wire.dart | event channel literal drifts (…`/sharedMediaStreamX`) | U38: | KILLED |
| U39 | lib/src/platform/wire/share_intents_wire.dart | pigeon channel literal drifts (…`getInitialSharedMediaX`) | U39: | KILLED |
| U40 | android/src/main/kotlin/…/ZuraffaIntentsPlugin.kt | rebrand reverted in the native channel (zikzak literal reintroduced) | U40: | KILLED |

**Result: 21/21 KILLED, 0 SURVIVED — mutation score 100 on the spec-002
surface.** The U38–U40 row group is the cross-language consistency contract:
Dart/native channel drift is killed by the suite, not by code review.

Notes:
- U23's mutant survives compilation deliberately (`cast<String>()` is
  assignable to `List<String?>?`) and dies at runtime on the null element —
  the honest nullability kill.
- U40 mutates the ported Kotlin subject rather than the Dart side, proving
  the consistency suite reads the real native files.
