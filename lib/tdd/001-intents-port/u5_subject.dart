// GENERATED STUB — `zfa tdd gen U5` (spec 044-test-tdd-generation).
//
// behavior_id: U5
// source_criterion: FR-005, SharedMedia
// description: `SharedMedia.copyWith` MUST replace only the given fields
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): implemented against the
// real entity surface — the behavior's observable outcomes live on
// SharedMedia.copyWith/equality.
//
// The subject name is derived from the behavior id (`subject_u5`) and is
// deliberately snake_cased (issue #1035).
// ignore_for_file: non_constant_identifier_names
library;

import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_attachment/shared_attachment.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';

/// Subject for behavior U5: the base carrier.
SharedMedia subject_u5() => SharedMedia(
  attachments: [
    SharedAttachment(path: '/tmp/a.png', type: SharedAttachmentType.image),
  ],
  content: 'original',
  speakableGroupName: 'Mom',
);

/// A vocabulary kind for the replacement list under test.
SharedAttachmentType attachmentType() => SharedAttachmentType.file;
