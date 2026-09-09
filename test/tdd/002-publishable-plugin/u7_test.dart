// GENERATED TEST — hand step (U7:hand): the observable outcome —
// the reset null-payload contract of FR-007.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u7_subject.dart' as subject;

void main() {
  group('U7 (FR-007, MethodChannelShareIntentPort.resetInitialSharedMedia)', () {
    test('U7 — `resetInitialSharedMedia` MUST send a null payload on its', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = subject.subject_u7();
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
      expect(identical(captured, null), isTrue);

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
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'RESET_ERR')
            .having((e) => e.message, 'message', 'reset failed')),
      );
    });
  });
}
