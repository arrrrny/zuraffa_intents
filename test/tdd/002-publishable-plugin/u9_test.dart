// GENERATED TEST — hand step (U9:hand): the observable outcome —
// the platform wiring of FR-009.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:zuraffa_intents/src/share_intent_service.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u9_subject.dart' as subject;
import 'package:zuraffa_intents/zuraffa_intents.dart';

void main() {
  group('U9 (FR-009, ShareIntentService.platform)', () {
    test('U9 — Platform wiring — `ShareIntentService.platform()` MUST be a', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      // platform() binds the method-channel driver (optionally parameterized).
      final platformDriven = subject.subject_u9();
      expect(platformDriven.port, isA<MethodChannelShareIntentPort>());
      expect(
        ShareIntentService.platform(
          binaryMessenger: TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger,
        ).port,
        isA<MethodChannelShareIntentPort>(),
      );

      // Direct construction keeps the spec-001 in-memory default.
      expect(ShareIntentService().port, isA<InMemoryShareIntentAdapter>());

      // registerShareIntentDependencies binds lazy singletons.
      final getIt = GetIt.asNewInstance();
      registerShareIntentDependencies(getIt);
      expect(identical(getIt<ShareIntentService>(), getIt<ShareIntentService>()),
          isTrue);
      expect(getIt<ShareIntentService>().port, same(getIt<ShareIntentPort>()));
      getIt.reset();
    });
  });
}
