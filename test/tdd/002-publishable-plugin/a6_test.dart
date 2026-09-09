// GENERATED TEST — hand step (A6): the observable outcome of AC-6 —
// the composition root binds lazy singletons and the direct constructor
// keeps the in-memory default.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/a6_subject.dart'
    as subject;
import 'package:zuraffa_intents/zuraffa_intents.dart';

void main() {
  group('A6 (AC-6)', () {
    test('A6 — each yields the identical lazy-singleton instance', () {
      final getIt = subject.subject_a6();
      registerShareIntentDependencies(getIt);
      expect(
        identical(getIt<ShareIntentPort>(), getIt<ShareIntentPort>()),
        isTrue,
        reason: 'port is a lazy singleton',
      );
      expect(
        identical(getIt<ShareIntentService>(), getIt<ShareIntentService>()),
        isTrue,
        reason: 'service is a lazy singleton',
      );
      expect(getIt<ShareIntentPort>(), isA<MethodChannelShareIntentPort>());
      expect(getIt<ShareIntentService>().port, same(getIt<ShareIntentPort>()));
      getIt.reset();

      // Direct construction keeps the spec-001 in-memory default.
      final direct = ShareIntentService();
      expect(direct.port, isA<InMemoryShareIntentAdapter>());
    });
  });
}
