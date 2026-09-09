// GENERATED STUB — `zfa tdd gen U4` (spec 044-test-tdd-generation).
//
// behavior_id: U4
// source_criterion: FR-004, SharedMedia
// description: `SharedMedia` MUST be an immutable entity with the plugin's
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): implemented against the
// real entity surface — a fully-populated carrier (nested attachments +
// a null element inside recipientIdentifiers) and a minimal instance.
//
// The subject name is derived from the behavior id (`subject_u4`) and is
// deliberately snake_cased (issue #1035).
// ignore_for_file: non_constant_identifier_names
library;

import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_attachment/shared_attachment.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';

/// Subject for behavior U4: the fully-populated carrier.
SharedMedia subject_u4() => SharedMedia(
  attachments: [
    SharedAttachment(path: '/tmp/a.png', type: SharedAttachmentType.image),
    SharedAttachment(path: '/tmp/b.mp4', type: SharedAttachmentType.video),
  ],
  recipientIdentifiers: const ['user-1', null],
  conversationIdentifier: 'conv-9',
  content: 'https://zuraffa.dev',
  speakableGroupName: 'Mom',
  serviceName: 'iMessage',
  senderIdentifier: '+1 555 0100',
  imageFilePath: '/tmp/sender.png',
  subject: 'Hello',
);

/// The minimal carrier: every optional absent.
SharedMedia minimal_u4() => SharedMedia();
