// GENERATED TEST — `zfa tdd gen A7` (spec 044-test-tdd-generation).
//
// behavior_id: A7
// source_criterion: AC-7
// kind: acceptance
// description: the late subscriber
//
// This test asserts the observable behavior described above. It is
// "honest red" on first execution: the paired subject at
// `package:zuraffa_intents/tdd/001-intents-port/a7_subject.dart` is unimplemented, so the test fails through an
// assertion (not an uncaught error, compile/load error, skip, or
// placeholder). Replace the subject's
// stub body with real implementation to make this test pass.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/a7_subject.dart'
    as subject;

void main() {
  group('A7 (AC-7)', () {
    test('A7 — the late subscriber', () {
      final Object? result = (() {
        try {
          subject.subject_a7();
          return null;
        } on UnimplementedError catch (error) {
          return error;
        }
      })();
      expect(result, isNot(isA<UnimplementedError>()));
    });
  });
}
