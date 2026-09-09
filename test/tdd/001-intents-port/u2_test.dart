// GENERATED TEST — `zfa tdd gen U2` (spec 044-test-tdd-generation).
//
// behavior_id: U2
// source_criterion: FR-002, SharedAttachment
// kind: unit
// description: `SharedAttachment` MUST be an immutable entity carrying the
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): replaced the fallback
// guard-only assertion with the observable outcomes the behavior names —
// copyWith replaces only the given field; equality is field-based with
// matching hashCode — exercised against the real entity. The capture
// keeps an unimplemented subject an honest ASSERTION red, never an
// uncaught error.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_attachment/shared_attachment.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/u2_subject.dart'
    as subject;

void main() {
  group('U2 (FR-002, SharedAttachment)', () {
    test(
      'U2 — `SharedAttachment` MUST be an immutable entity carrying the',
      () {
        final result = (() {
          try {
            return subject.subject_u2();
          } on UnimplementedError catch (error) {
            return error;
          }
        })();
        expect(result, isA<SharedAttachment>());
        final base = result as SharedAttachment;
        expect(base.path, '/tmp/a.png');
        expect(base.type, SharedAttachmentType.image);

        final typeOnly = base.copyWith(type: SharedAttachmentType.video);
        expect(typeOnly.type, SharedAttachmentType.video);
        expect(
          typeOnly.path,
          base.path,
          reason: 'type-only copyWith preserves path',
        );
        final moved = base.copyWith(path: '/tmp/b.png');
        expect(moved.path, '/tmp/b.png');
        expect(
          moved.type,
          base.type,
          reason: 'path-only copyWith preserves type',
        );
        final twin = subject.subject_u2();
        expect(base, twin, reason: 'same path + type => equal');
        expect(base.hashCode, twin.hashCode);
        expect(base, isNot(typeOnly));
        expect(base, isNot(moved));
      },
    );
  });
}
