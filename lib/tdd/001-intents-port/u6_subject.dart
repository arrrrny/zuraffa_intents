// GENERATED STUB — `zfa tdd gen U6` (spec 044-test-tdd-generation
// + issue #1259 contract derivation).
//
// behavior_id: U6
// source_criterion: FR-006, ShareIntentPort.sharedMediaStream
//
// Hand step (U6:hand): the subject exposes the real in-memory port —
// the behavior's observable outcomes live on ShareIntentPort.
//
// The subject name is derived from the behavior id (`subject_u6`) and is
// deliberately snake_cased (issue #1035).
// ignore_for_file: non_constant_identifier_names
library;

import 'package:zuraffa_intents/src/data/intents/in_memory_share_intent_adapter.dart';

/// Subject for behavior U6.
InMemoryShareIntentAdapter subject_u6() => InMemoryShareIntentAdapter();
