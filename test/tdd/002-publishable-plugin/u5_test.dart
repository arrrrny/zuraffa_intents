// GENERATED TEST — hand step (U5:hand): the observable outcome —
// the pigeon reply mapping of FR-005.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u5_subject.dart'
    as subject;

void main() {
  group('U5 (FR-005, MethodChannelShareIntentPort.getInitialSharedMedia)', () {
    test(
      'U5 — `getInitialSharedMedia` over the pigeon channel MUST map: a',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final binding = TestDefaultBinaryMessengerBinding.instance;
        final port = subject.subject_u5();
        const channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia',
          ShareIntentsApiCodec(),
        );

        // {result: wire map} decodes into SharedMedia.
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
        expect(result!.content, 'boot share');

        // {result: null} is a legit null answer.
        binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
          channel,
          (message) async => <Object?, Object?>{'result': null},
        );
        expect(await port.getInitialSharedMedia(), isNull);

        // {error: {code, message, details}} surfaces verbatim.
        binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
          channel,
          (message) async => <Object?, Object?>{
            'error': <Object?, Object?>{
              'code': 'NATIVE_ERR',
              'message': 'donating failed',
              'details': 'details-payload',
            },
          },
        );
        await expectLater(
          port.getInitialSharedMedia(),
          throwsA(
            isA<PlatformException>()
                .having((e) => e.code, 'code', 'NATIVE_ERR')
                .having((e) => e.message, 'message', 'donating failed')
                .having((e) => e.details, 'details', 'details-payload'),
          ),
        );

        // A null reply (channel missing) is the canonical channel-error.
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
      },
    );
  });
}
