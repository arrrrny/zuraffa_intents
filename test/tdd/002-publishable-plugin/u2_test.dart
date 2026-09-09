// GENERATED TEST — hand step (U2:hand): the observable outcome —
// wire-map fidelity per FR-002.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u2_subject.dart' as subject;

void main() {
  group('U2 (FR-002, sharedAttachmentWireMap.sharedAttachmentWireMap, sharedMediaWireMap.sharedMediaWireMap)', () {
    test('U2 — Wire-map fidelity — `sharedAttachmentWireMap` MUST produce', () {
      expect(
        sharedAttachmentWireMap(subject.attachment_u2()),
        <Object?, Object?>{'path': '/tmp/a.png', 'type': SharedAttachmentType.image.index},
      );

      final media = subject.media_u2();
      final wire = sharedMediaWireMap(media);
      expect(
        wire.keys,
        containsAll(<Object?>[
          'attachments', 'recipientIdentifiers', 'conversationIdentifier',
          'content', 'speakableGroupName', 'serviceName', 'senderIdentifier',
          'imageFilePath', 'subject',
        ]),
        reason: 'all nine keys ride the wire',
      );
      expect(wire['attachments'], [
        <Object?, Object?>{'path': '/tmp/a.png', 'type': 0},
      ], reason: 'attachments serialize as wire maps');
      expect(wire['recipientIdentifiers'], ['user-1', null],
          reason: 'null elements are preserved on the wire');
      expect(wire['content'], 'hello');
      expect(wire['speakableGroupName'], isNull,
          reason: 'null optionals keep their key with a null value');

      final minimalWire = sharedMediaWireMap(subject.minimal_u2());
      expect(minimalWire.keys.length, 9,
          reason: 'even the minimal carrier carries all nine keys');
      expect(minimalWire['attachments'], isNull);
    });
  });
}
