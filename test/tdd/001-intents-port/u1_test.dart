// GENERATED TEST — `zfa tdd gen U1` (spec 044-test-tdd-generation).
//
// behavior_id: U1
// source_criterion: FR-001, SharedAttachmentType
// kind: unit
// description: `SharedAttachmentType` MUST expose exactly the four share
//
// Hand-delta (arrrrny/zuraffa#1420 workaround): the generator's fallback
// emitted a guard-only assertion; replaced with the observable outcome
// the behavior names — the four-kind vocabulary in declaration order
// with stable indices 0..3 — exercised against the real entity.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/enums/shared_attachment_type.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/u1_subject.dart' as subject;

void main() {
  group('U1 (FR-001, SharedAttachmentType)', () {
    test('U1 — `SharedAttachmentType` MUST expose exactly the four share', () {
      final values = subject.subject_u1();
      expect(
        values.map((t) => t.name).toList(),
        ['image', 'video', 'audio', 'file'],
      );
      for (var i = 0; i < values.length; i++) {
        expect(
          values[i].index,
          i,
          reason: 'stable wire index for ${values[i].name}',
        );
      }
      expect(values.length, 4);
    });
  });
}
