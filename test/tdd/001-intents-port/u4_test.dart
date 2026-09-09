// GENERATED TEST — `zfa tdd gen U4` (spec 044-test-tdd-generation).
//
// behavior_id: U4
// source_criterion: FR-004, SharedMedia
// kind: unit
// description: `SharedMedia` MUST be an immutable entity with the plugin's
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): replaced the fallback
// guard-only assertion with the observable outcome the behavior names —
// full-fidelity toJson → fromJson round trips: a fully-populated
// instance (nested attachments + a null element inside
// recipientIdentifiers) and a minimal instance whose JSON omits absent
// fields. The capture keeps an unimplemented subject an honest
// ASSERTION red.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/u4_subject.dart' as subject;

void main() {
  group('U4 (FR-004, SharedMedia)', () {
    test('U4 — `SharedMedia` MUST be an immutable entity with the plugin\'s', () {
      final result = (() {
        try {
          return subject.subject_u4();
        } on UnimplementedError catch (error) {
          return error;
        }
      })();
      expect(result, isA<SharedMedia>());
      final populated = result as SharedMedia;
      expect(
        populated.attachments!.map((a) => (a.path, a.type.name)).toList(),
        [('/tmp/a.png', 'image'), ('/tmp/b.mp4', 'video')],
      );
      expect(populated.recipientIdentifiers, ['user-1', null]);
      expect(populated.conversationIdentifier, 'conv-9');
      expect(populated.content, 'https://zuraffa.dev');
      expect(populated.speakableGroupName, 'Mom');
      expect(populated.serviceName, 'iMessage');
      expect(populated.senderIdentifier, '+1 555 0100');
      expect(populated.imageFilePath, '/tmp/sender.png');
      expect(populated.subject, 'Hello');

      final back = SharedMedia.fromJson(populated.toJson());
      expect(back.attachments, populated.attachments);
      expect(back.recipientIdentifiers, populated.recipientIdentifiers);
      expect(
        back.recipientIdentifiers!,
        contains(null),
        reason: 'null elements inside recipientIdentifiers survive',
      );
      expect(back.conversationIdentifier, populated.conversationIdentifier);
      expect(back.content, populated.content);
      expect(back.speakableGroupName, populated.speakableGroupName);
      expect(back.serviceName, populated.serviceName);
      expect(back.senderIdentifier, populated.senderIdentifier);
      expect(back.imageFilePath, populated.imageFilePath);
      expect(back.subject, populated.subject);
      // Whole-instance equality is pinned on the scalar-field carrier
      // (FR-005's scalar-field equality contract); the populated
      // carrier's nested list is compared field-by-field above.
      final scalarOnly = SharedMedia(content: 'x', speakableGroupName: 'y');
      expect(SharedMedia.fromJson(scalarOnly.toJson()), scalarOnly);

      final minimal = subject.minimal_u4();
      final minimalJson = minimal.toJson();
      final minimalBack = SharedMedia.fromJson(minimalJson);
      expect(minimalBack, minimal);
      expect(minimalJson.containsKey('content'), isFalse,
          reason: 'an absent optional is omitted from the JSON');
    });
  });
}
