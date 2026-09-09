// GENERATED TEST — hand step (U6:hand): the observable outcome —
// the recordSentMessage envelope + carrier mapping of FR-006.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u6_subject.dart' as subject;

void main() {
  group('U6 (FR-006, MethodChannelShareIntentPort.recordSentMessage)', () {
    test('U6 — `recordSentMessage` MUST send the single-element envelope', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = subject.subject_u6();
      const channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ZuraffaIntentsApi.recordSentMessage',
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

      await port.recordSentMessage(
        conversationIdentifier: 'conv-9',
        conversationName: 'Mom',
        conversationImageFilePath: '/tmp/mom.png',
        serviceName: 'iMessage',
      );

      // The payload is the single-element [SharedMedia] envelope with the
      // plugin's argument mapping into the carrier.
      final envelope = captured! as List<Object?>;
      expect(envelope.length, 1, reason: 'the pigeon native handler casts argument 0');
      final carrier = envelope.single! as SharedMedia;
      expect(carrier.conversationIdentifier, 'conv-9');
      expect(carrier.speakableGroupName, 'Mom');
      expect(carrier.imageFilePath, '/tmp/mom.png');
      expect(carrier.serviceName, 'iMessage');

      // Error replies follow the FR-005 semantics.
      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async => <Object?, Object?>{
          'error': <Object?, Object?>{
            'code': 'SEND_ERR',
            'message': 'no activity',
            'details': null,
          },
        },
      );
      await expectLater(
        port.recordSentMessage(
            conversationIdentifier: 'c', conversationName: 'n'),
        throwsA(isA<PlatformException>().having(
            (e) => e.code, 'code', 'SEND_ERR')),
      );
    });
  });
}
