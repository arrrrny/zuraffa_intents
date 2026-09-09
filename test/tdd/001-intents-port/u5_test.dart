// GENERATED TEST — `zfa tdd gen U5` (spec 044-test-tdd-generation).
//
// behavior_id: U5
// source_criterion: FR-005, SharedMedia
// kind: unit
// description: `SharedMedia.copyWith` MUST replace only the given fields
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): replaced the fallback
// guard-only assertion with the observable outcomes the behavior names —
// a replacement attachments list substitutes wholesale, untouched fields
// survive, and scalar-field equality is field-based with consistent
// hashCode. The capture keeps an unimplemented subject an honest
// ASSERTION red.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_attachment/shared_attachment.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/u5_subject.dart' as subject;

void main() {
  group('U5 (FR-005, SharedMedia)', () {
    test('U5 — `SharedMedia.copyWith` MUST replace only the given fields', () {
      final result = (() {
        try {
          return subject.subject_u5();
        } on UnimplementedError catch (error) {
          return error;
        }
      })();
      expect(result, isA<SharedMedia>());
      final base = result as SharedMedia;
      expect(base.content, 'original');
      expect(base.speakableGroupName, 'Mom');
      expect(
        base.attachments!.map((a) => (a.path, a.type.name)).toList(),
        [('/tmp/a.png', 'image')],
      );

      final withAttachments = base.copyWith(
        attachments: [
          SharedAttachment(path: '/tmp/other.png', type: subject.attachmentType()),
        ],
      );
      final replacement = base.copyWith(
        attachments: (base.attachments ?? const []).toList(),
      );
      expect(replacement.attachments, base.attachments,
          reason: 'an equal replacement list substitutes wholesale');
      expect(withAttachments.attachments!.single.path, '/tmp/other.png',
          reason: 'a new attachments list replaces wholesale, never merges');
      expect(withAttachments.attachments, isNot(base.attachments));
      expect(withAttachments.content, base.content,
          reason: 'untouched fields survive');

      final withContent = base.copyWith(content: 'hello');
      expect(withContent.content, 'hello');
      expect(withContent.attachments, base.attachments);
      expect(withContent.speakableGroupName, base.speakableGroupName);

      final twin = SharedMedia.fromJson(
        SharedMedia(content: 'original', speakableGroupName: 'Mom').toJson(),
      );
      expect(base.copyWith(), base,
          reason: 'scalar-field equality: identical scalar arguments => equal');
      expect(base.hashCode, base.copyWith().hashCode);
      expect(base, isNot(withContent));
      expect(base.copyWith(), isNot(twin),
          reason: 'different scalar fields => unequal');
    });
  });
}
