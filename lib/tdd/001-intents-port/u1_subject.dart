// GENERATED STUB — `zfa tdd gen U1` (spec 044-test-tdd-generation).
//
// behavior_id: U1
// source_criterion: FR-001, SharedAttachmentType
// description: `SharedAttachmentType` MUST expose exactly the four share
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): the stub body is
// implemented against the real entity surface — the behavior's
// observable outcome is the vocabulary itself.
//
// The subject name is derived from the behavior id (`subject_u1`) and is
// deliberately snake_cased — the generator KNOWS the name it emits, so
// the lint its shape provably trips is suppressed here rather than
// renaming the contract surface (issue #1035).
// ignore_for_file: non_constant_identifier_names
library;

import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';

/// Subject for behavior U1.
List<SharedAttachmentType> subject_u1() => SharedAttachmentType.values;
