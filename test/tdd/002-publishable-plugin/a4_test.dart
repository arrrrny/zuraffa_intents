// GENERATED TEST — hand step (A4): the AC-4 acceptance scenario —
// the Uri.decodeFull quirk applied exactly when the predicate says so.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/a4_subject.dart'
    as subject;

void main() {
  group('A4 (AC-4)', () {
    test('A4 — the decoded `SharedAttachment` paths are `Uri.decodeFull`-expanded;', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final binding = TestDefaultBinaryMessengerBinding.instance;
      const eventChannelName = 'dev.zuraffa.zuraffa_intents/sharedMediaStream';

      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(eventChannelName),
        (call) async => call.method == 'listen'
            ? const StandardMethodCodec().encodeSuccessEnvelope(null)
            : null,
      );

      final decoded = <SharedMedia>[];
      final subscription = subject.subject_a4().sharedMediaStream.listen(
        decoded.add,
      );
      await Future<void>.delayed(Duration.zero);

      final eventBytes = const StandardMethodCodec().encodeSuccessEnvelope(
        <Object?, Object?>{
          'attachments': [
            <Object?, Object?>{
              'path': 'file:///var/mobile/pic%20name.jpg',
              'type': 0,
            },
          ],
          'recipientIdentifiers': null,
          'conversationIdentifier': null,
          'content': 'quirk',
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

      expect(
        decoded.single.attachments!.single.path,
        'file:///var/mobile/pic name.jpg',
        reason: 'apple-like: percent-encoded path decoded',
      );
      await subscription.cancel();
    });
  });
}
