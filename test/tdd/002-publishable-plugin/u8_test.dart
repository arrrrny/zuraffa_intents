// GENERATED TEST — hand step (U8:hand): the observable outcome —
// the event-channel broadcast stream with the apple-like quirk (FR-008).
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u8_subject.dart' as subject;

void main() {
  group('U8 (FR-008, MethodChannelShareIntentPort.sharedMediaStream)', () {
    test('U8 — `sharedMediaStream` MUST be the `EventChannel', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = subject.subject_u8();
      const eventChannelName = 'dev.zuraffa.zuraffa_intents/sharedMediaStream';

      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(eventChannelName),
        (call) async => call.method == 'listen'
            ? const StandardMethodCodec().encodeSuccessEnvelope(null)
            : null,
      );

      final received = <SharedMedia>[];
      final subscription = port.sharedMediaStream.listen(received.add);
      await Future<void>.delayed(Duration.zero);

      // The natives push EventSink.success(media.toMap()) — a
      // StandardMethodCodec success envelope around the plain media map.
      final eventBytes = const StandardMethodCodec().encodeSuccessEnvelope(
        <Object?, Object?>{
          'attachments': [
            <Object?, Object?>{'path': 'file:///var/mobile/pic%20name.jpg', 'type': 0},
          ],
          'recipientIdentifiers': null,
          'conversationIdentifier': null,
          'content': 'live share',
          'speakableGroupName': null,
          'serviceName': null,
          'senderIdentifier': null,
          'imageFilePath': null,
          'subject': null,
        },
      );
      await binding.defaultBinaryMessenger.handlePlatformMessage(
        eventChannelName,
        eventBytes,
        (_) {},
      );
      await Future<void>.delayed(Duration.zero);

      expect(received.length, 1);
      expect(received.single.content, 'live share');
      expect(received.single.attachments!.single.path,
          'file:///var/mobile/pic name.jpg',
          reason: 'the apple-like predicate decodes percent-encoded paths');

      // The stream is a per-port lazy singleton.
      expect(identical(port.sharedMediaStream, port.sharedMediaStream), isTrue);
      await subscription.cancel();
    });
  });
}
