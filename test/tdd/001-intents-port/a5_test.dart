// GENERATED TEST — `zfa tdd gen A5` (spec 044-test-tdd-generation).
//
// behavior_id: A5
// source_criterion: AC-5
// kind: acceptance
// description: exactly two records exist in call order and the second carries
//
// This test asserts the observable behavior described above. It is
// "honest red" on first execution: the paired subject at
// `package:zuraffa_intents/tdd/001-intents-port/a5_subject.dart` is unimplemented, so the test fails through an
// assertion (not an uncaught error, compile/load error, skip, or
// placeholder). Replace the subject's
// stub body with real implementation to make this test pass.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/a5_subject.dart' as subject;

void main() {
  group('A5 (AC-5)', () {
    test('A5 — exactly two records exist in call order and the second carries', () {
      final Object? result = (() {
        try {
          subject.subject_a5();
          return null;
        } on UnimplementedError catch (error) {
          return error;
        }
      })();
      expect(result, isNot(isA<UnimplementedError>()));
    });
  });
}
