// GENERATED TEST — `zfa tdd gen U3` (spec 044-test-tdd-generation).
//
// behavior_id: U3
// source_criterion: FR-003, SharedAttachment
// kind: unit
// description: `SharedAttachment` MUST round-trip `toJson` → `fromJson`
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): replaced the fallback
// guard-only assertion with the observable outcome the behavior names —
// a toJson → fromJson round trip preserving path and type exactly. The
// capture keeps an unimplemented subject an honest ASSERTION red.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_attachment/shared_attachment.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/u3_subject.dart' as subject;

void main() {
  group('U3 (FR-003, SharedAttachment)', () {
    test('U3 — `SharedAttachment` MUST round-trip `toJson` → `fromJson`', () {
      final result = (() {
        try {
          return subject.subject_u3();
        } on UnimplementedError catch (error) {
          return error;
        }
      })();
      expect(result, isA<SharedAttachment>());
      final original = result as SharedAttachment;
      expect(original.path, '/tmp/clip.mp4');
      expect(original.type, SharedAttachmentType.video);

      final back = SharedAttachment.fromJson(original.toJson());
      expect(back.path, original.path);
      expect(back.type, original.type);
      expect(back, original);
    });
  });
}
