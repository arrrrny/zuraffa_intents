// GENERATED TEST — hand step (A2): the AC-2 acceptance scenario —
// the single-element envelope and the plugin's carrier mapping.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/a2_subject.dart' as subject;

void main() {
  group('A2 (AC-2)', () {
    test('A2 — the payload is the single-element `[SharedMedia]`', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = subject.subject_a2();
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

      final envelope = captured! as List<Object?>;
      expect(envelope.length, 1);
      final carrier = envelope.single! as SharedMedia;
      expect(carrier.conversationIdentifier, 'conv-9');
      expect(carrier.speakableGroupName, 'Mom');
      expect(carrier.imageFilePath, '/tmp/mom.png');
      expect(carrier.serviceName, 'iMessage');
    });
  });
}
