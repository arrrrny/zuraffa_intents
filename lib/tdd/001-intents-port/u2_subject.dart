// GENERATED STUB — `zfa tdd gen U2` (spec 044-test-tdd-generation).
//
// behavior_id: U2
// source_criterion: FR-002, SharedAttachment
// description: `SharedAttachment` MUST be an immutable entity carrying the
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): implemented against the
// real entity surface — the behavior's observable outcomes live on
// SharedAttachment.
//
// The subject name is derived from the behavior id (`subject_u2`) and is
// deliberately snake_cased (issue #1035).
// ignore_for_file: non_constant_identifier_names
library;

import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_attachment/shared_attachment.dart';

/// Subject for behavior U2.
SharedAttachment subject_u2() =>
    SharedAttachment(path: '/tmp/a.png', type: SharedAttachmentType.image);
