// GENERATED TEST — hand step (A5): the AC-5 acceptance scenario —
// broadcast delivery, no pre-subscription replay, lazy-singleton stream.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/a5_subject.dart' as subject;

void main() {
  group('A5 (AC-5)', () {
    test('A5 — each receives every post-subscription native', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = subject.subject_a5();
      const eventChannelName = 'dev.zuraffa.zuraffa_intents/sharedMediaStream';

      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(eventChannelName),
        (call) async => call.method == 'listen'
            ? const StandardMethodCodec().encodeSuccessEnvelope(null)
            : null,
      );

      final first = <SharedMedia>[];
      final second = <SharedMedia>[];
      final sub1 = port.sharedMediaStream.listen(first.add);
      final sub2 = port.sharedMediaStream.listen(second.add);
      await Future<void>.delayed(Duration.zero);

      Future<void> push(String content) async {
        final eventBytes = const StandardMethodCodec().encodeSuccessEnvelope(
          <Object?, Object?>{
            'attachments': null,
            'recipientIdentifiers': null,
            'conversationIdentifier': null,
            'content': content,
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
      }

      await push('share-1');
      expect(first.single.content, 'share-1',
          reason: 'every listener receives every share');
      expect(second.single.content, 'share-1');

      final late_ = <SharedMedia>[];
      final sub3 = port.sharedMediaStream.listen(late_.add);
      await push('share-2');
      expect(late_.map((m) => m.content), ['share-2'],
          reason: 'no pre-subscription replay');
      expect(identical(port.sharedMediaStream, port.sharedMediaStream), isTrue,
          reason: 'lazy singleton stream instance');

      await sub1.cancel();
      await sub2.cancel();
      await sub3.cancel();
    });
  });
}
