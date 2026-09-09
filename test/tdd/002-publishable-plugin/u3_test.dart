// GENERATED TEST — hand step (U3:hand): the observable outcome —
// type-tagged codec fidelity per FR-003.
library;

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_attachment/shared_attachment.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u3_subject.dart'
    as subject;

void main() {
  group('U3 (FR-003, ShareIntentsApiCodec.decodeMessage)', () {
    test(
      'U3 — The wire codec MUST be a `StandardMessageCodec` subclass that',
      () {
        final codec = subject.subject_u3();
        expect(codec, isA<StandardMessageCodec>());

        final media = SharedMedia(content: 'tagged');
        final data = codec.encodeMessage(media)!;
        final decoded = codec.decodeMessage(data);
        expect(decoded, isA<SharedMedia>());
        expect((decoded! as SharedMedia).content, 'tagged');

        // The legacy duplicate tag 130 decodes the same payload shape.
        const std = StandardMessageCodec();
        final payload = std.encodeMessage(<Object?, Object?>{
          'attachments': null,
          'recipientIdentifiers': null,
          'conversationIdentifier': null,
          'content': 'tag 130',
          'speakableGroupName': null,
          'serviceName': null,
          'senderIdentifier': null,
          'imageFilePath': null,
          'subject': null,
        })!;
        final bytes = BytesBuilder()
          ..addByte(kSharedMediaLegacyTag)
          ..add(
            payload.buffer.asUint8List(
              payload.offsetInBytes,
              payload.lengthInBytes,
            ),
          );
        final fromTag130 =
            codec.decodeMessage(ByteData.sublistView(bytes.toBytes()))!
                as SharedMedia;
        expect(fromTag130.content, 'tag 130');

        // Tag 128 wraps a plain attachment map.
        final attachmentPayload = std.encodeMessage(<Object?, Object?>{
          'path': '/tmp/p.jpg',
          'type': 1,
        })!;
        final attachmentBytes = BytesBuilder()
          ..addByte(kSharedAttachmentTag)
          ..add(
            attachmentPayload.buffer.asUint8List(
              attachmentPayload.offsetInBytes,
              attachmentPayload.lengthInBytes,
            ),
          );
        final fromTag128 =
            codec.decodeMessage(
                  ByteData.sublistView(attachmentBytes.toBytes()),
                )!
                as SharedAttachment;
        expect(fromTag128.path, '/tmp/p.jpg');
        expect(fromTag128.type, SharedAttachmentType.video);

        // Plain native maps decode through decodeSharedMedia (the shape the
        // natives emit on the event channel / as method-channel payloads).
        final plain = decodeSharedMedia(<Object?, Object?>{
          'attachments': [
            <Object?, Object?>{'path': '/tmp/x.png', 'type': 0},
          ],
          'recipientIdentifiers': <Object?>['u1', null],
          'content': 'plain',
        });
        expect(plain.content, 'plain');
        expect(plain.attachments!.single.path, '/tmp/x.png');
        expect(plain.recipientIdentifiers, ['u1', null]);
      },
    );
  });
}
