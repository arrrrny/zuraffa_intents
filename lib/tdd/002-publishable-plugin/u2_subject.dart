// GENERATED STUB — hand step (U2:hand, issue #1308 seam).
//
// behavior_id: U2
// source_criterion: FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap
// ignore_for_file: non_constant_identifier_names
library;

import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_attachment/shared_attachment.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';

/// Subject for behavior U2: the attachment wire-map fixture.
SharedAttachment attachment_u2() =>
    SharedAttachment(path: '/tmp/a.png', type: SharedAttachmentType.image);

/// Subject for behavior U2: the media wire-map fixture.
SharedMedia media_u2() => SharedMedia(
  attachments: [
    SharedAttachment(path: '/tmp/a.png', type: SharedAttachmentType.image),
  ],
  recipientIdentifiers: const ['user-1', null],
  content: 'hello',
);

/// Subject for behavior U2: the minimal media fixture.
SharedMedia minimal_u2() => SharedMedia();
