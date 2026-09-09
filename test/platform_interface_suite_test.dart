import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:zuraffa_intents/zuraffa_intents.dart';

/// Spec `002-publishable-plugin` — the platform-interface layer that turns
/// the spec-001 pure-Dart contract into a publishable Flutter plugin
/// replacing `zikzak_share_handler`: wire-map fidelity, the type-tagged
/// codec, the apple-like URI quirk with an injectable predicate, the pigeon
/// BasicMessageChannel semantics (result / error / channel-error), the
/// EventChannel lazy-singleton stream, the platform wiring of the
/// composition root, and the packaging + native-consistency guarantees.
/// Written test-first; the implementation lands in the green phase
/// (tasks 3.x).

SharedMedia _fullMedia() => SharedMedia(
  attachments: [
    SharedAttachment(
      path: '/tmp/pic%20name.jpg',
      type: SharedAttachmentType.image,
    ),
    SharedAttachment(path: '/tmp/clip.mp4', type: SharedAttachmentType.video),
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

/// A URI-encoded variant used to observe the apple-like quirk.
SharedMedia _encodedMedia() => SharedMedia(
  attachments: [
    SharedAttachment(
      path: 'file:///var/mobile/pic%20name.jpg',
      type: SharedAttachmentType.image,
    ),
  ],
  content: 'quirk me',
);

/// Whether this test host is an apple-like URI path platform (iOS/macOS).
/// The default predicate decodes percent-encoded paths on these hosts;
/// assertions that compare decoded vs raw paths must branch on this.
final bool _isAppleLikeHost = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wire maps (FR-002)', () {
    test('U20: sharedAttachmentWireMap produces exactly {path, type: index} '
        'for every vocabulary kind', () {
      expect(
        sharedAttachmentWireMap(
          SharedAttachment(
            path: '/tmp/pic.jpg',
            type: SharedAttachmentType.image,
          ),
        ),
        <Object?, Object?>{'path': '/tmp/pic.jpg', 'type': 0},
      );
      expect(
        sharedAttachmentWireMap(
          SharedAttachment(
            path: '/tmp/clip.mp4',
            type: SharedAttachmentType.video,
          ),
        ),
        <Object?, Object?>{'path': '/tmp/clip.mp4', 'type': 1},
      );
      expect(
        sharedAttachmentWireMap(
          SharedAttachment(
            path: '/tmp/voice.m4a',
            type: SharedAttachmentType.audio,
          ),
        ),
        <Object?, Object?>{'path': '/tmp/voice.m4a', 'type': 2},
      );
      expect(
        sharedAttachmentWireMap(
          SharedAttachment(
            path: '/tmp/report.pdf',
            type: SharedAttachmentType.file,
          ),
        ),
        <Object?, Object?>{'path': '/tmp/report.pdf', 'type': 3},
      );
    });

    test('U21: sharedMediaWireMap carries all nine keys with nulls preserved, '
        'attachments serialized as wire maps', () {
      final wire = sharedMediaWireMap(_fullMedia());

      // Every key the natives read by name is present — nulls included.
      expect(wire.keys.toSet(), <String>{
        'attachments',
        'recipientIdentifiers',
        'conversationIdentifier',
        'content',
        'speakableGroupName',
        'serviceName',
        'senderIdentifier',
        'imageFilePath',
        'subject',
      });
      expect(wire['conversationIdentifier'], 'conv-42');
      expect(wire['content'], 'Look at this');
      expect(wire['speakableGroupName'], 'Design Crew');
      expect(wire['serviceName'], 'Messages');
      expect(wire['senderIdentifier'], 'sender-7');
      expect(wire['imageFilePath'], '/tmp/sender.png');
      expect(wire['subject'], 'Vacation');
      expect(wire['recipientIdentifiers'], ['r-1', null, 'r-3']);
      expect(wire['attachments'], hasLength(2));
      expect((wire['attachments']! as List)[0], <Object?, Object?>{
        'path': '/tmp/pic%20name.jpg',
        'type': 0,
      });

      // A minimal media keeps all nine keys, nulls preserved.
      final minimal = sharedMediaWireMap(SharedMedia(content: 'hi'));
      expect(minimal.keys.length, 9);
      expect(minimal['attachments'], isNull);
      expect(minimal['recipientIdentifiers'], isNull);
      expect(minimal['content'], 'hi');
      expect(minimal['conversationIdentifier'], isNull);
    });
  });

  group('ShareIntentsApiCodec (FR-003, FR-004)', () {
    test('U22: the codec round-trips SharedMedia through ByteData (tag 129 '
        'envelope out, entity back in)', () {
      const codec = ShareIntentsApiCodec();
      final media = _fullMedia();

      final data = codec.encodeMessage(media)!;
      // The entity rides the wire under the pigeon media tag.
      expect(data.buffer.asUint8List().first, kSharedMediaTag);

      final decoded = codec.decodeMessage(data);

      expect(decoded, isA<SharedMedia>());
      final back = decoded! as SharedMedia;
      expect(back.conversationIdentifier, 'conv-42');
      expect(back.content, 'Look at this');
      expect(back.speakableGroupName, 'Design Crew');
      expect(back.serviceName, 'Messages');
      expect(back.senderIdentifier, 'sender-7');
      expect(back.imageFilePath, '/tmp/sender.png');
      expect(back.subject, 'Vacation');
      expect(back.recipientIdentifiers, ['r-1', null, 'r-3']);
      expect(back.attachments, hasLength(2));
      expect(
        back.attachments![0].path,
        _isAppleLikeHost ? '/tmp/pic name.jpg' : '/tmp/pic%20name.jpg',
      );
      expect(back.attachments![0].type, SharedAttachmentType.image);
      expect(back.attachments![1].type, SharedAttachmentType.video);
    });

    test('U23: native-emitted plain maps decode into entities (attachments as '
        'maps, nullable recipientIdentifiers)', () {
      final nativeMap = <Object?, Object?>{
        'attachments': [
          <Object?, Object?>{'path': '/tmp/a.png', 'type': 0},
          <Object?, Object?>{'path': '/tmp/b.mp3', 'type': 2},
        ],
        'recipientIdentifiers': <Object?>['r-1', null],
        'conversationIdentifier': 'conv-1',
        'content': 'plain map',
        'speakableGroupName': null,
        'serviceName': null,
        'senderIdentifier': null,
        'imageFilePath': null,
        'subject': null,
      };

      // The natives emit plain maps (EventSink.success(media.toMap()) and
      // the reply envelope's result slot) — the driver converts them.
      final decoded = decodeSharedMedia(nativeMap);

      expect(decoded.content, 'plain map');
      expect(decoded.conversationIdentifier, 'conv-1');
      expect(decoded.recipientIdentifiers, ['r-1', null]);
      expect(decoded.attachments, hasLength(2));
      expect(decoded.attachments![0].path, '/tmp/a.png');
      expect(decoded.attachments![0].type, SharedAttachmentType.image);
      expect(decoded.attachments![1].type, SharedAttachmentType.audio);
    });

    test('U24: the codec decodes tags 128 (attachment) and 130 (legacy '
        'duplicate media tag) as well as 129', () {
      const codec = ShareIntentsApiCodec();
      const std = StandardMessageCodec();

      // Tag 128 envelope around a plain attachment map (exactly the byte
      // range the standard codec emitted — no buffer padding).
      final attachmentPayload = std.encodeMessage(<Object?, Object?>{
        'path': '/tmp/p.jpg',
        'type': 1,
      })!;
      final attachmentBytes = BytesBuilder()
        ..addByte(kSharedAttachmentTag)
        ..add(
          attachmentPayload.buffer.asUint8List(
            attachmentPayload.offsetInBytes,
            attachmentPayload.lengthInBytes,
          ),
        );
      final fromTag128 =
          codec.decodeMessage(ByteData.sublistView(attachmentBytes.toBytes()))!
              as SharedAttachment;
      expect(fromTag128.path, '/tmp/p.jpg');
      expect(fromTag128.type, SharedAttachmentType.video);

      // Tag 130 — the legacy duplicate media tag the pigeon sources emit.
      final mediaPayload = std.encodeMessage(<Object?, Object?>{
        'attachments': null,
        'recipientIdentifiers': null,
        'conversationIdentifier': null,
        'content': 'tag 130',
        'speakableGroupName': null,
        'serviceName': null,
        'senderIdentifier': null,
        'imageFilePath': null,
        'subject': null,
      })!;
      final mediaBytes = BytesBuilder()
        ..addByte(kSharedMediaLegacyTag)
        ..add(
          mediaPayload.buffer.asUint8List(
            mediaPayload.offsetInBytes,
            mediaPayload.lengthInBytes,
          ),
        );
      final fromTag130 =
          codec.decodeMessage(ByteData.sublistView(mediaBytes.toBytes()))!
              as SharedMedia;
      expect(fromTag130.content, 'tag 130');
    });

    test('U25: decode applies Uri.decodeFull to attachment paths iff the '
        'apple-like predicate holds; predicate is injectable; default '
        'short-circuits before dart:io', () {
      var appleLike = true;
      final wire = sharedMediaWireMap(_encodedMedia());
      final media = decodeSharedMedia(
        wire,
        isAppleLikeUriPath: () => appleLike,
      );
      expect(media.attachments![0].path, 'file:///var/mobile/pic name.jpg');

      appleLike = false;
      final untouched = decodeSharedMedia(
        wire,
        isAppleLikeUriPath: () => appleLike,
      );
      expect(
        untouched.attachments![0].path,
        'file:///var/mobile/pic%20name.jpg',
      );

      // The default predicate must consult kIsWeb first (dart:io is never
      // touched on web) and otherwise defer to Platform.
      expect(defaultIsAppleLikeUriPath, isA<bool Function()>());
      // On macOS/iOS the default is true; on Linux it is false.
      expect(defaultIsAppleLikeUriPath(), _isAppleLikeHost);
    });
  });

  group('MethodChannelShareIntentPort — getInitialSharedMedia (FR-005)', () {
    test('U26: getInitialSharedMedia decodes a {result: wire map} reply into '
        'SharedMedia and a null result to null', () async {
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = MethodChannelShareIntentPort();
      const channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia',
        ShareIntentsApiCodec(),
      );

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async {
          return <Object?, Object?>{
            'result': sharedMediaWireMap(
              SharedMedia(
                content: 'boot share',
                conversationIdentifier: 'conv-9',
              ),
            ),
          };
        },
      );

      final result = await port.getInitialSharedMedia();
      expect(result, isA<SharedMedia>());
      expect(result!.content, 'boot share');
      expect(result.conversationIdentifier, 'conv-9');

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async {
          return <Object?, Object?>{'result': null};
        },
      );
      expect(await port.getInitialSharedMedia(), isNull);

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        null,
      );
    });

    test('U27: getInitialSharedMedia maps an {error: {code,message,details}} '
        'reply to PlatformException with those exact fields', () async {
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = MethodChannelShareIntentPort();
      const channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia',
        ShareIntentsApiCodec(),
      );

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async {
          return <Object?, Object?>{
            'error': <Object?, Object?>{
              'code': 'NATIVE_ERR',
              'message': 'Error: donating insendmessage intent',
              'details': null,
            },
          };
        },
      );

      Object? surfaced;
      try {
        await port.getInitialSharedMedia();
      } catch (error) {
        surfaced = error;
      }
      expect(surfaced, isA<PlatformException>());
      final exception = surfaced! as PlatformException;
      expect(exception.code, 'NATIVE_ERR');
      expect(exception.message, 'Error: donating insendmessage intent');
      expect(exception.details, isNull);

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        null,
      );
    });

    test(
      'U28: a null reply (channel missing) surfaces '
      'PlatformException(code: channel-error) with the canonical message',
      () async {
        final binding = TestDefaultBinaryMessengerBinding.instance;
        final port = MethodChannelShareIntentPort();

        // No mock handler registered at all → the messenger replies null.
        binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
          const BasicMessageChannel<Object?>(
            'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia',
            ShareIntentsApiCodec(),
          ),
          (message) async => null,
        );

        Object? surfaced;
        try {
          await port.getInitialSharedMedia();
        } catch (error) {
          surfaced = error;
        }
        expect(surfaced, isA<PlatformException>());
        expect((surfaced! as PlatformException).code, 'channel-error');
        expect(
          (surfaced as PlatformException).message,
          'Unable to establish connection on channel.',
        );

        binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
          const BasicMessageChannel<Object?>(
            'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia',
            ShareIntentsApiCodec(),
          ),
          null,
        );
      },
    );
  });

  group('MethodChannelShareIntentPort — recordSentMessage (FR-006)', () {
    test(
      'U29: recordSentMessage sends the single-element SharedMedia envelope '
      'carrying the argument mapping; a {result: null} reply completes',
      () async {
        final binding = TestDefaultBinaryMessengerBinding.instance;
        final port = MethodChannelShareIntentPort();
        const channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.ZuraffaIntentsApi.recordSentMessage',
          ShareIntentsApiCodec(),
        );

        Object? received;
        binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
          channel,
          (message) async {
            received = message;
            return <Object?, Object?>{'result': null};
          },
        );

        await port.recordSentMessage(
          conversationIdentifier: 'conv-9',
          conversationName: 'Mom',
          conversationImageFilePath: '/tmp/mom.png',
          serviceName: 'WhatsApp',
        );

        expect(received, hasLength(1));
        final media = (received! as List)[0] as SharedMedia;
        expect(media.conversationIdentifier, 'conv-9');
        expect(media.speakableGroupName, 'Mom');
        expect(media.imageFilePath, '/tmp/mom.png');
        expect(media.serviceName, 'WhatsApp');

        binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
          channel,
          null,
        );
      },
    );

    test('U30: recordSentMessage error and null replies follow the FR-005 '
        'semantics', () async {
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = MethodChannelShareIntentPort();
      const channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ZuraffaIntentsApi.recordSentMessage',
        ShareIntentsApiCodec(),
      );

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async {
          return <Object?, Object?>{
            'error': <Object?, Object?>{
              'code': 'NATIVE_ERR',
              'message': 'Error: decoding SharedMedia',
              'details': 'boom',
            },
          };
        },
      );
      Object? surfaced;
      try {
        await port.recordSentMessage(
          conversationIdentifier: 'c',
          conversationName: 'n',
        );
      } catch (error) {
        surfaced = error;
      }
      expect(surfaced, isA<PlatformException>());
      final exception = surfaced! as PlatformException;
      expect(exception.code, 'NATIVE_ERR');
      expect(exception.message, 'Error: decoding SharedMedia');
      expect(exception.details, 'boom');

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async => null,
      );
      Object? surfacedNull;
      try {
        await port.recordSentMessage(
          conversationIdentifier: 'c',
          conversationName: 'n',
        );
      } catch (error) {
        surfacedNull = error;
      }
      expect(surfacedNull, isA<PlatformException>());
      expect((surfacedNull! as PlatformException).code, 'channel-error');

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        null,
      );
    });
  });

  group('MethodChannelShareIntentPort — resetInitialSharedMedia (FR-007)', () {
    test('U31: resetInitialSharedMedia sends a null payload and {result: null} '
        'completes; error and null replies follow FR-005', () async {
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = MethodChannelShareIntentPort();
      const channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ZuraffaIntentsApi.resetInitialSharedMedia',
        ShareIntentsApiCodec(),
      );

      Object? received;
      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async {
          received = message;
          return <Object?, Object?>{'result': null};
        },
      );
      await port.resetInitialSharedMedia();
      expect(received, isNull);

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        (message) async {
          return <Object?, Object?>{
            'error': <Object?, Object?>{
              'code': 'E1',
              'message': 'm1',
              'details': null,
            },
          };
        },
      );
      Object? surfaced;
      try {
        await port.resetInitialSharedMedia();
      } catch (error) {
        surfaced = error;
      }
      expect(surfaced, isA<PlatformException>());
      expect((surfaced! as PlatformException).code, 'E1');
      expect((surfaced as PlatformException).message, 'm1');

      binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        channel,
        null,
      );
    });
  });

  group('MethodChannelShareIntentPort — sharedMediaStream (FR-008)', () {
    test('U32: sharedMediaStream decodes native event maps into SharedMedia '
        '(quirk applied per the predicate)', () async {
      final binding = TestDefaultBinaryMessengerBinding.instance;
      final port = MethodChannelShareIntentPort();
      const eventChannelName = 'dev.zuraffa.zuraffa_intents/sharedMediaStream';

      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(eventChannelName),
        (call) async {
          return call.method == 'listen'
              ? const StandardMethodCodec().encodeSuccessEnvelope(null)
              : null;
        },
      );

      final received = <SharedMedia>[];
      final subscription = port.sharedMediaStream.listen(received.add);
      await Future<void>.delayed(Duration.zero);

      // The natives push `EventSink.success(media.toMap())` — on the wire
      // that is a StandardMethodCodec success envelope around the plain
      // media map.
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

      // The default predicate on this host decides whether the path is decoded.
      await Future<void>.delayed(Duration.zero);
      expect(received, hasLength(1));
      expect(received[0].content, 'live share');
      expect(
        received[0].attachments![0].path,
        _isAppleLikeHost
            ? 'file:///var/mobile/pic name.jpg'
            : 'file:///var/mobile/pic%20name.jpg',
      );

      await subscription.cancel();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel(eventChannelName),
        null,
      );
    });

    test('U33: sharedMediaStream is a lazy singleton per port instance — '
        'repeated access yields the identical stream', () {
      final port = MethodChannelShareIntentPort();
      expect(identical(port.sharedMediaStream, port.sharedMediaStream), isTrue);
      // Distinct ports own distinct streams.
      expect(
        identical(
          port.sharedMediaStream,
          MethodChannelShareIntentPort().sharedMediaStream,
        ),
        isFalse,
      );
    });
  });

  group('Platform wiring (FR-009)', () {
    test('U34: ShareIntentService.platform() binds the method-channel driver '
        '(and accepts a BinaryMessenger); direct construction keeps the '
        'in-memory default', () {
      final platformService = ShareIntentService.platform();
      expect(platformService.port, isA<MethodChannelShareIntentPort>());

      final injected = ShareIntentService.platform(
        binaryMessenger:
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger,
      );
      expect(injected.port, isA<MethodChannelShareIntentPort>());

      final plain = ShareIntentService();
      expect(plain.port, isA<InMemoryShareIntentAdapter>());
    });

    test('U35: registerShareIntentDependencies binds ShareIntentPort to the '
        'method-channel driver and the service to that port, both lazy '
        'singletons', () {
      final getIt = GetIt.instance..reset();
      registerShareIntentDependencies(getIt);

      final port = getIt<ShareIntentPort>();
      expect(port, isA<MethodChannelShareIntentPort>());
      expect(identical(port, getIt<ShareIntentPort>()), isTrue);

      final service = getIt<ShareIntentService>();
      expect(identical(service, getIt<ShareIntentService>()), isTrue);
      expect(identical(service.port, port), isTrue);
    });
  });

  group('Publish-ready packaging (FR-001)', () {
    test('U36: pubspec.yaml is publish-ready: six platforms declared with the '
        'rebranded classes, repository/issue_tracker present, description '
        '≤ 180 chars, flutter floor present', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final lines = pubspec.split('\n');

      expect(
        lines,
        contains('repository: https://github.com/arrrrny/zuraffa_intents'),
      );
      expect(
        lines,
        contains(
          'issue_tracker: https://github.com/arrrrny/zuraffa_intents/issues',
        ),
      );
      expect(lines.any((l) => l.contains('flutter: ">=3.44.0"')), isTrue);

      final descriptionLine = lines
          .firstWhere((l) => l.trim().startsWith('description:'))
          .trim();
      expect(
        'description:'.length + '  '.length + 180,
        greaterThanOrEqualTo(descriptionLine.length),
      );

      for (final platform in ['android:', 'ios:', 'macos:']) {
        expect(
          lines.any((l) => l.trim() == platform),
          isTrue,
          reason: 'pubspec must declare the $platform platform',
        );
      }
      expect(lines, contains('        pluginClass: ZuraffaIntentsPlugin'));
      expect(lines, contains('        package: dev.zuraffa.zuraffa_intents'));
    });

    test('U37: every podspec/Package.swift/fileName path declared by '
        'pubspec.yaml exists on disk and CHANGELOG head entry matches the '
        'package version', () {
      for (final path in [
        'ios/zuraffa_intents.podspec',
        'macos/zuraffa_intents.podspec',
        'ios/zuraffa_intents/Package.swift',
        'macos/zuraffa_intents/Package.swift',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: '$path must exist');
      }

      final pubspec = File('pubspec.yaml').readAsStringSync();
      final version = RegExp(
        r'^version:\s*(\S+)',
        multiLine: true,
      ).firstMatch(pubspec)!.group(1)!;
      final changelog = File('CHANGELOG.md').readAsStringSync();
      expect(changelog.contains('## $version'), isTrue);
    });
  });

  group('Native port consistency (FR-010)', () {
    final dartWireModule = File('lib/src/platform/wire/share_intents_wire.dart')
        .readAsStringSync();

    test('U38: the event channel literal is identical in the Dart wire module '
        'and in the Android/iOS/macOS native plugins', () {
      const eventChannel = 'dev.zuraffa.zuraffa_intents/sharedMediaStream';
      expect(dartWireModule, contains("'$eventChannel'"));

      final androidPlugin = File(
        'android/src/main/kotlin/dev/zuraffa/zuraffa_intents/ZuraffaIntentsPlugin.kt',
      ).readAsStringSync();
      expect(androidPlugin, contains('"$eventChannel"'));

      final iosPlugin = File(
        'ios/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift',
      ).readAsStringSync();
      expect(iosPlugin, contains('"$eventChannel"'));

      final macosPlugin = File(
        'macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift',
      ).readAsStringSync();
      expect(macosPlugin, contains('"$eventChannel"'));
    });

    test('U39: the three ZuraffaIntentsApi pigeon channel literals are '
        'identical in the Dart wire module, Pigeon Java, and both Swift '
        'APIs', () {
      const channels = [
        'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia',
        'dev.flutter.pigeon.ZuraffaIntentsApi.recordSentMessage',
        'dev.flutter.pigeon.ZuraffaIntentsApi.resetInitialSharedMedia',
      ];
      for (final channel in channels) {
        expect(
          dartWireModule,
          contains("'$channel'"),
          reason: 'Dart wire module must pin $channel',
        );
      }

      final pigeonJava = File(
        'android/src/main/java/dev/zuraffa/zuraffa_intents/Messages.java',
      ).readAsStringSync();
      final iosApi = File(
        'ios/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsApi.swift',
      ).readAsStringSync();
      final macosApi = File(
        'macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsApi.swift',
      ).readAsStringSync();

      for (final channel in channels) {
        expect(
          pigeonJava,
          contains('"$channel"'),
          reason: 'Pigeon Java must pin $channel',
        );
        expect(
          iosApi,
          contains('"$channel"'),
          reason: 'iOS API must pin $channel',
        );
        expect(
          macosApi,
          contains('"$channel"'),
          reason: 'macOS API must pin $channel',
        );
      }
    });

    test('U40: the ported native trees carry the rebranded plugin classes and '
        'contain zero leftover zikzak/ShareHandler identifiers', () {
      // Rebranded plugin classes are present on each platform.
      expect(
        File(
          'android/src/main/kotlin/dev/zuraffa/zuraffa_intents/ZuraffaIntentsPlugin.kt',
        ).readAsStringSync(),
        contains('class ZuraffaIntentsPlugin'),
      );
      expect(
        File(
          'ios/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift',
        ).readAsStringSync(),
        contains('class ZuraffaIntentsPlugin'),
      );
      expect(
        File(
          'macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift',
        ).readAsStringSync(),
        contains('class ZuraffaIntentsPlugin'),
      );

      // No leftover source-plugin identifiers anywhere in the native trees
      // (case-insensitive; the rebrand was systematic).
      final nativeExtensions = ['.kt', '.java', '.swift', '.cc', '.cpp', '.h'];
      final offenders = <String>[];
      for (final dir in ['android', 'ios', 'macos']) {
        final root = Directory(dir);
        if (!root.existsSync()) continue;
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File) continue;
          if (!nativeExtensions.any((ext) => entity.path.endsWith(ext))) {
            continue;
          }
          final content = entity.readAsStringSync().toLowerCase();
          if (content.contains('zikzak') ||
              content.contains('sharehandler') ||
              content.contains('share_handler')) {
            offenders.add(entity.path);
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'leftover source-plugin identifiers in: $offenders',
      );
    });

    test('U41: native SharedMedia payload key set matches sharedMediaWireMap '
        '(every Dart wire key is present in each native toMap/toDictionary)', () {
      const expected = <String>{
        'attachments',
        'recipientIdentifiers',
        'conversationIdentifier',
        'content',
        'speakableGroupName',
        'serviceName',
        'senderIdentifier',
        'imageFilePath',
        'subject',
      };

      final javaMessages = File(
        'android/src/main/java/dev/zuraffa/zuraffa_intents/Messages.java',
      ).readAsStringSync();
      for (final key in expected) {
        expect(
          javaMessages,
          contains('toMapResult.put("$key"'),
          reason:
              'Android Messages.java SharedMedia.toMap() must emit '
              '"$key"',
        );
      }

      final iosModels = File(
        'ios/zuraffa_intents/Sources/zuraffa_intents_models/SharedModels.swift',
      ).readAsStringSync();
      for (final key in expected) {
        expect(
          iosModels,
          contains('"$key":'),
          reason:
              'iOS SharedModels.swift SharedMedia.toDictionary() must '
              'emit "$key"',
        );
      }

      final macosModels = File(
        'macos/zuraffa_intents/Sources/zuraffa_intents_models/SharedModels.swift',
      ).readAsStringSync();
      for (final key in expected) {
        expect(
          macosModels,
          contains('"$key":'),
          reason:
              'macOS SharedModels.swift SharedMedia.toDictionary() must '
              'emit "$key"',
        );
      }
    });
  });
}
