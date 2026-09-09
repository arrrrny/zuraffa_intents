// GENERATED STUB — `zfa tdd gen U3` (spec 044-test-tdd-generation).
//
// behavior_id: U3
// source_criterion: FR-003, SharedAttachment
// description: `SharedAttachment` MUST round-trip `toJson` → `fromJson`
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): implemented against the
// real entity surface — the behavior's observable outcome is the JSON
// round trip.
//
// The subject name is derived from the behavior id (`subject_u3`) and is
// deliberately snake_cased (issue #1035).
// ignore_for_file: non_constant_identifier_names
library;

import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_attachment/shared_attachment.dart';

/// Subject for behavior U3.
SharedAttachment subject_u3() =>
    SharedAttachment(path: '/tmp/clip.mp4', type: SharedAttachmentType.video);
