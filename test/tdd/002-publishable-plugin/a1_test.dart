// GENERATED TEST — hand step (A1): the AC-1 acceptance scenario —
// the getInitialSharedMedia pigeon reply mapping end to end.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/a1_subject.dart'
    as subject;

void main() {
  group('A1 (AC-1)', () {
    test('A1 — a `{result: <wire map>}` reply decodes into the', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = subject.subject_a1();
      const channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia',
        ShareIntentsApiCodec(),
      );

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async => <Object?, Object?>{
          'result': sharedMediaWireMap(
            SharedMedia(
              content: 'boot share',
              conversationIdentifier: 'conv-9',
            ),
          ),
        },
      );
      final result = await port.getInitialSharedMedia();
      expect(result, isA<SharedMedia>());
      expect(result!.content, 'boot share');
      expect(result.conversationIdentifier, 'conv-9');

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async => <Object?, Object?>{'result': null},
      );
      expect(await port.getInitialSharedMedia(), isNull);

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async => <Object?, Object?>{
          'error': <Object?, Object?>{
            'code': 'NATIVE_ERR',
            'message': 'donating failed',
            'details': 42,
          },
        },
      );
      await expectLater(
        port.getInitialSharedMedia(),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'NATIVE_ERR')
              .having((e) => e.message, 'message', 'donating failed')
              .having((e) => e.details, 'details', 42),
        ),
      );

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        null,
      );
      await expectLater(
        port.getInitialSharedMedia(),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'channel-error',
          ),
        ),
      );
    });
  });
}
