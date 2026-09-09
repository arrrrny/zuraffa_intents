// GENERATED TEST — hand step (A3): the AC-3 acceptance scenario —
// reset sends a null payload and completes on {result: null}.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/a3_subject.dart'
    as subject;

void main() {
  group('A3 (AC-3)', () {
    test('A3 — it completes on `{result: null}` and', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = subject.subject_a3();
      const channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ZuraffaIntentsApi.resetInitialSharedMedia',
        ShareIntentsApiCodec(),
      );

      Object? captured;
      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async {
          captured = message;
          return <Object?, Object?>{'result': null};
        },
      );

      await port.resetInitialSharedMedia();
      expect(captured, isNull, reason: 'reset sends a null payload');

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async => <Object?, Object?>{
          'error': <Object?, Object?>{
            'code': 'RESET_ERR',
            'message': 'reset failed',
            'details': null,
          },
        },
      );
      await expectLater(
        port.resetInitialSharedMedia(),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'RESET_ERR')
              .having((e) => e.message, 'message', 'reset failed'),
        ),
      );
    });
  });
}
