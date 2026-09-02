import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:test/test.dart';
import 'package:zuraffa_intents/zuraffa_intents.dart';

/// Spec `001-intents-port` — the pure-Dart reimplementation of the
/// `zikzak_share_handler` plugin contract: the attachment vocabulary,
/// the SharedAttachment/SharedMedia entity contracts with JSON
/// round-trips, the initial-share lifecycle, the recordSentMessage
/// argument mapping, broadcast stream semantics, and the service facade
/// with its composition root. Written test-first; the implementation
/// lands in the green phase (tasks 4.x).

/// A hand-rolled scripted port: records recordSentMessage arguments and
/// throws a scripted error when asked. No mocking library.
class ScriptedShareIntentPort implements ShareIntentPort {
  final List<Map<String, Object?>> recordedArgs = [];
  final StreamController<SharedMedia> _controller =
      StreamController<SharedMedia>.broadcast();

  /// The memoized stream — the port contract (FR-008) requires a stable
  /// per-port stream instance, so a valid fake must honor it too
  /// (StreamController.stream returns a new view on every access).
  late final Stream<SharedMedia> _stream = _controller.stream;

  /// When non-null, port reads surface this error verbatim.
  Object? error;

  @override
  Future<SharedMedia?> getInitialSharedMedia() async {
    final scripted = error;
    if (scripted != null) throw scripted;
    return null;
  }

  @override
  Future<void> recordSentMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
  }) async {
    recordedArgs.add(<String, Object?>{
      'conversationIdentifier': conversationIdentifier,
      'conversationName': conversationName,
      'conversationImageFilePath': conversationImageFilePath,
      'serviceName': serviceName,
    });
  }

  @override
  Future<void> resetInitialSharedMedia() async {
    final scripted = error;
    if (scripted != null) throw scripted;
  }

  @override
  Stream<SharedMedia> get sharedMediaStream => _stream;
}

SharedMedia _fullMedia() => SharedMedia(
      attachments: [
        SharedAttachment(
            path: '/tmp/pic.jpg', type: SharedAttachmentType.image),
        SharedAttachment(
            path: '/tmp/clip.mp4', type: SharedAttachmentType.video),
      ],
      recipientIdentifiers: const ['r-1', null, 'r-3'],
      conversationIdentifier: 'conv-42',
      content: 'Look at this',
      speakableGroupName: 'Design Crew',
      serviceName: 'Messages',
      senderIdentifier: 'sender-7',
      imageFilePath: '/tmp/sender.png',
      subject: 'Vacation',
    );

void main() {
  group('SharedAttachmentType vocabulary (FR-001)', () {
    test(
        'U1: the attachment vocabulary is exactly image/video/audio/file '
        'in declaration order with stable wire indices', () {
      expect(SharedAttachmentType.values.map((t) => t.name).toList(),
          ['image', 'video', 'audio', 'file']);
      expect(SharedAttachmentType.values.map((t) => t.index).toList(),
          [0, 1, 2, 3]);
    });
  });

  group('SharedAttachment entity (FR-002, FR-003)', () {
    test('U2: copyWith replaces only the given field', () {
      final attachment = SharedAttachment(
          path: '/tmp/pic.jpg', type: SharedAttachmentType.image);

      final retyped =
          attachment.copyWith(type: SharedAttachmentType.video);
      expect(retyped.path, '/tmp/pic.jpg');
      expect(retyped.type, SharedAttachmentType.video);

      final moved = attachment.copyWith(path: '/tmp/clip.mp4');
      expect(moved.path, '/tmp/clip.mp4');
      expect(moved.type, SharedAttachmentType.image);
    });

    test(
        'U3: equality is field-based — same path+type equal with matching '
        'hashCode; different path or type unequal', () {
      final a = SharedAttachment(
          path: '/tmp/pic.jpg', type: SharedAttachmentType.image);
      final b = SharedAttachment(
          path: '/tmp/pic.jpg', type: SharedAttachmentType.image);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(
          a,
          isNot(equals(SharedAttachment(
              path: '/tmp/other.jpg', type: SharedAttachmentType.image))));
      expect(
          a,
          isNot(equals(SharedAttachment(
              path: '/tmp/pic.jpg', type: SharedAttachmentType.file))));
    });

    test('U4: toJson → fromJson round-trips path and type exactly', () {
      final attachment = SharedAttachment(
          path: '/tmp/voice.m4a', type: SharedAttachmentType.audio);

      final decoded = SharedAttachment.fromJson(attachment.toJson());

      expect(decoded.path, '/tmp/voice.m4a');
      expect(decoded.type, SharedAttachmentType.audio);
    });
  });

  group('SharedMedia entity (FR-004, FR-005)', () {
    test(
        'U5: a fully-populated media round-trips preserving all nine '
        'fields incl. nested attachments and a null recipient element',
        () {
      final media = _fullMedia();

      final decoded = SharedMedia.fromJson(media.toJson());

      expect(decoded.conversationIdentifier, 'conv-42');
      expect(decoded.content, 'Look at this');
      expect(decoded.speakableGroupName, 'Design Crew');
      expect(decoded.serviceName, 'Messages');
      expect(decoded.senderIdentifier, 'sender-7');
      expect(decoded.imageFilePath, '/tmp/sender.png');
      expect(decoded.subject, 'Vacation');
      expect(decoded.recipientIdentifiers, ['r-1', null, 'r-3']);
      expect(decoded.attachments, hasLength(2));
      expect(decoded.attachments![0].path, '/tmp/pic.jpg');
      expect(decoded.attachments![0].type, SharedAttachmentType.image);
      expect(decoded.attachments![1].path, '/tmp/clip.mp4');
      expect(decoded.attachments![1].type, SharedAttachmentType.video);
    });

    test(
        'U6: a minimal media round-trips equivalently and its JSON omits '
        'the absent fields', () {
      final media = SharedMedia();

      final json = media.toJson();
      expect(json.containsKey('attachments'), isFalse);
      expect(json.containsKey('content'), isFalse);
      expect(json.containsKey('subject'), isFalse);

      final decoded = SharedMedia.fromJson(json);
      expect(decoded.attachments, isNull);
      expect(decoded.recipientIdentifiers, isNull);
      expect(decoded.conversationIdentifier, isNull);
      expect(decoded.content, isNull);
      expect(decoded.speakableGroupName, isNull);
      expect(decoded.serviceName, isNull);
      expect(decoded.senderIdentifier, isNull);
      expect(decoded.imageFilePath, isNull);
      expect(decoded.subject, isNull);
    });

    test(
        'U7: copyWith replaces the attachments list wholesale and '
        'preserves untouched fields', () {
      final media = _fullMedia();

      final replaced = media.copyWith(attachments: [
        SharedAttachment(
            path: '/tmp/report.pdf', type: SharedAttachmentType.file),
      ]);

      expect(replaced.attachments, hasLength(1));
      expect(replaced.attachments![0].path, '/tmp/report.pdf');
      expect(replaced.attachments![0].type, SharedAttachmentType.file);
      expect(replaced.content, 'Look at this');
      expect(replaced.subject, 'Vacation');
      expect(replaced.conversationIdentifier, 'conv-42');
      expect(replaced.speakableGroupName, 'Design Crew');
    });

    test(
        'U8: scalar-field equality is field-based with consistent '
        'hashCode', () {
      final a = SharedMedia(
          content: 'hello', subject: 's', conversationIdentifier: 'c');
      final b = SharedMedia(
          content: 'hello', subject: 's', conversationIdentifier: 'c');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(
          a,
          isNot(equals(SharedMedia(
              content: 'hello',
              subject: 's',
              conversationIdentifier: 'other'))));
    });
  });

  group('InMemoryShareIntentAdapter initial-share lifecycle (FR-006)', () {
    test('U9: a fresh adapter reports null initial media', () async {
      final adapter = InMemoryShareIntentAdapter();

      expect(await adapter.getInitialSharedMedia(), isNull);
    });

    test(
        'U10: a stored initial share is served verbatim and repeatably '
        'across reads until reset', () async {
      final adapter = InMemoryShareIntentAdapter();
      final share = SharedMedia(
        content: 'boot share',
        attachments: [
          SharedAttachment(
              path: '/tmp/a.png', type: SharedAttachmentType.image),
        ],
      );
      adapter.storeInitial(share);

      final first = await adapter.getInitialSharedMedia();
      final second = await adapter.getInitialSharedMedia();

      expect(identical(first, second), isTrue);
      expect(first!.content, 'boot share');
      expect(first.attachments![0].path, '/tmp/a.png');
    });

    test(
        'U11: reset clears the stored share and is idempotent', () async {
      final adapter = InMemoryShareIntentAdapter();
      adapter.storeInitial(SharedMedia(content: 'once'));

      await adapter.resetInitialSharedMedia();
      expect(await adapter.getInitialSharedMedia(), isNull);

      await adapter.resetInitialSharedMedia();
      expect(await adapter.getInitialSharedMedia(), isNull);
    });
  });

  group('InMemoryShareIntentAdapter sent-message records (FR-007)', () {
    test(
        'U12: recordSentMessage maps named arguments into the wire '
        'fields', () async {
      final adapter = InMemoryShareIntentAdapter();

      await adapter.recordSentMessage(
        conversationIdentifier: 'conv-9',
        conversationName: 'Mom',
        conversationImageFilePath: '/tmp/mom.png',
        serviceName: 'WhatsApp',
      );

      final record = adapter.sentMessageRecords.single;
      expect(record.conversationIdentifier, 'conv-9');
      expect(record.speakableGroupName, 'Mom');
      expect(record.imageFilePath, '/tmp/mom.png');
      expect(record.serviceName, 'WhatsApp');
    });

    test(
        'U13: records accumulate one per call in call order; omitted '
        'optionals record as null', () async {
      final adapter = InMemoryShareIntentAdapter();

      await adapter.recordSentMessage(
          conversationIdentifier: 'conv-1', conversationName: 'Mom');
      await adapter.recordSentMessage(
        conversationIdentifier: 'conv-2',
        conversationName: 'Dad',
        serviceName: 'Telegram',
      );

      expect(adapter.sentMessageRecords, hasLength(2));
      expect(adapter.sentMessageRecords[0].speakableGroupName, 'Mom');
      expect(adapter.sentMessageRecords[0].serviceName, isNull);
      expect(adapter.sentMessageRecords[0].imageFilePath, isNull);
      expect(adapter.sentMessageRecords[1].speakableGroupName, 'Dad');
      expect(adapter.sentMessageRecords[1].serviceName, 'Telegram');
    });
  });

  group('InMemoryShareIntentAdapter sharedMediaStream (FR-008)', () {
    test(
        'U14: the stream is broadcast — two listeners each receive the '
        'emitted share', () async {
      final adapter = InMemoryShareIntentAdapter();

      final both = Future.wait<SharedMedia>([
        adapter.sharedMediaStream.first,
        adapter.sharedMediaStream.first,
      ]);
      await Future<void>.delayed(Duration.zero);

      adapter.emit(SharedMedia(content: 'live share'));

      final received = await both;
      expect(received, hasLength(2));
      expect(received.every((m) => m.content == 'live share'), isTrue);
    });

    test(
        'U15: repeated access yields the identical stream instance '
        '(lazy singleton)', () {
      final adapter = InMemoryShareIntentAdapter();

      expect(identical(
          adapter.sharedMediaStream, adapter.sharedMediaStream), isTrue);
    });

    test(
        'U16: a late subscriber does not receive pre-subscription '
        'emissions', () async {
      final adapter = InMemoryShareIntentAdapter();

      final earlyReceived = <SharedMedia>[];
      final earlySub = adapter.sharedMediaStream.listen(earlyReceived.add);
      await Future<void>.delayed(Duration.zero);
      adapter.emit(SharedMedia(content: 'early'));
      await Future<void>.delayed(Duration.zero);

      final lateReceived = <SharedMedia>[];
      final lateSub = adapter.sharedMediaStream.listen(lateReceived.add);
      await Future<void>.delayed(Duration.zero);
      adapter.emit(SharedMedia(content: 'late'));
      await Future<void>.delayed(Duration.zero);

      expect(earlyReceived.map((m) => m.content).toList(),
          ['early', 'late']);
      expect(lateReceived.map((m) => m.content).toList(), ['late']);

      await earlySub.cancel();
      await lateSub.cancel();
    });
  });

  group('ShareIntentService facade (FR-009)', () {
    test(
        'U17: the service defaults to the in-memory adapter and '
        'delegates the initial-media lifecycle', () async {
      final service = ShareIntentService();

      expect(service.port, isA<InMemoryShareIntentAdapter>());
      expect(await service.getInitialSharedMedia(), isNull);

      (service.port as InMemoryShareIntentAdapter)
          .storeInitial(SharedMedia(content: 'boot'));
      expect((await service.getInitialSharedMedia())!.content, 'boot');

      await service.resetInitialSharedMedia();
      expect(await service.getInitialSharedMedia(), isNull);
    });

    test(
        'U18: recordSentMessage arguments pass through verbatim and a '
        'port-thrown error surfaces unmodified', () async {
      final port = ScriptedShareIntentPort();
      final service = ShareIntentService(port: port);

      await service.recordSentMessage(
        conversationIdentifier: 'c-1',
        conversationName: 'n-1',
        conversationImageFilePath: 'i-1',
        serviceName: 's-1',
      );

      expect(port.recordedArgs, hasLength(1));
      expect(port.recordedArgs.single['conversationIdentifier'], 'c-1');
      expect(port.recordedArgs.single['conversationName'], 'n-1');
      expect(port.recordedArgs.single['conversationImageFilePath'], 'i-1');
      expect(port.recordedArgs.single['serviceName'], 's-1');

      final boom = StateError('transport dead');
      port.error = boom;
      Object? surfaced;
      try {
        await service.getInitialSharedMedia();
      } catch (error) {
        surfaced = error;
      }
      expect(surfaced, isA<StateError>());
      expect(identical(surfaced, boom), isTrue);
    });

    test(
        'U19: the service re-exposes the port stream identically and the '
        'composition root registers a lazy singleton', () async {
      final port = ScriptedShareIntentPort();
      final service = ShareIntentService(port: port);

      expect(
          identical(service.sharedMediaStream, port.sharedMediaStream),
          isTrue);

      final getIt = GetIt.instance..reset();
      registerShareIntentDependencies(getIt);
      final resolved = getIt<ShareIntentService>();
      expect(identical(resolved, getIt<ShareIntentService>()), isTrue);
    });
  });
}
