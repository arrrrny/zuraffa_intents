import 'dart:ui' show Rect;

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:zuraffa_intents/zuraffa_intents.dart';

/// Spec `1205-zuraffa-outbound-share-fleet-hardening` (arrrrny/zik_zak,
/// zuraffa_intents issue #9) — the send side of the intents package: the
/// [ShareSenderPort] contract, the pure-Dart [InMemoryShareSenderAdapter]
/// recording surface, the [ShareIntentService] facade delegation with the
/// platform/in-memory construction pattern, and the
/// [SharePlusShareSenderPort] platform driver as far as testable without
/// a device. Written test-first; the implementation lands in the green
/// phase.
const Rect _anchor = Rect.fromLTWH(8, 16, 120, 48);

/// A hand-rolled scripted sender port: records shareText/shareFiles
/// arguments and returns a scripted result (or throws a scripted error).
/// No mocking library.
class ScriptedShareSenderPort implements ShareSenderPort {
  final List<Map<String, Object?>> recordedTextArgs = [];
  final List<Map<String, Object?>> recordedFilesArgs = [];

  /// The result every scripted send resolves to.
  ShareSendResult result = ShareSendResult.success;

  @override
  Future<ShareSendResult> shareText({
    required String text,
    String? subject,
    Rect? anchor,
  }) async {
    recordedTextArgs.add(<String, Object?>{
      'text': text,
      'subject': subject,
      'anchor': anchor,
    });
    return result;
  }

  @override
  Future<ShareSendResult> shareFiles({
    required List<String> files,
    String? subject,
    Map<String, String>? mimeHints,
    Rect? anchor,
  }) async {
    recordedFilesArgs.add(<String, Object?>{
      'files': files,
      'subject': subject,
      'mimeHints': mimeHints,
      'anchor': anchor,
    });
    return result;
  }
}

/// A hand-rolled scripted share_plus platform: records the
/// [ShareParams] every share call receives and either resolves a
/// scripted [ShareResult] or throws a scripted error. No mocking
/// library — subclasses the public `SharePlatform` seam the way
/// `SharePlus.custom` expects.
class ScriptedSharePlatform extends SharePlatform {
  final List<ShareParams> recordedParams = [];

  /// The result a successful share resolves to.
  ShareResult result = const ShareResult('raw', ShareResultStatus.success);

  /// When non-null, the share call throws this verbatim.
  Object? error;

  @override
  Future<ShareResult> share(ShareParams params) async {
    recordedParams.add(params);
    final scripted = error;
    if (scripted != null) throw scripted;
    return result;
  }
}

void main() {
  group(
    'InMemoryShareSenderAdapter records sends exactly as passed (FR-4, US5)',
    () {
      test('S1: shareText records text, subject, and anchor verbatim and '
          'resolves success with no platform channel', () async {
        final adapter = InMemoryShareSenderAdapter();

        final result = await adapter.shareText(
          text: 'go.zuzu.dev/scan/abc',
          subject: 'Scan result',
          anchor: _anchor,
        );

        expect(result, ShareSendResult.success);
        expect(adapter.records, hasLength(1));
        expect(adapter.records.single.text, 'go.zuzu.dev/scan/abc');
        expect(adapter.records.single.subject, 'Scan result');
        expect(adapter.records.single.anchor, _anchor);
        expect(adapter.records.single.files, isEmpty);
        expect(adapter.records.single.mimeHints, isEmpty);
      });

      test(
        'S2: shareText without optionals records null subject and anchor',
        () async {
          final adapter = InMemoryShareSenderAdapter();

          await adapter.shareText(text: 'plain text');

          expect(adapter.records.single.text, 'plain text');
          expect(adapter.records.single.subject, isNull);
          expect(adapter.records.single.anchor, isNull);
        },
      );

      test('S3: shareFiles records paths, MIME hints, subject, and anchor '
          'verbatim', () async {
        final adapter = InMemoryShareSenderAdapter();

        final result = await adapter.shareFiles(
          files: ['/tmp/qr.png', '/tmp/receipt.pdf'],
          subject: 'Documents',
          mimeHints: const {'/tmp/receipt.pdf': 'application/pdf'},
          anchor: _anchor,
        );

        expect(result, ShareSendResult.success);
        expect(adapter.records, hasLength(1));
        expect(adapter.records.single.files, [
          '/tmp/qr.png',
          '/tmp/receipt.pdf',
        ]);
        expect(adapter.records.single.mimeHints, const {
          '/tmp/receipt.pdf': 'application/pdf',
        });
        expect(adapter.records.single.subject, 'Documents');
        expect(adapter.records.single.anchor, _anchor);
        expect(adapter.records.single.text, isNull);
      });

      test('S4: shareFiles without optionals records null subject and anchor '
          'and empty hints', () async {
        final adapter = InMemoryShareSenderAdapter();

        await adapter.shareFiles(files: ['/tmp/pic.jpg']);

        expect(adapter.records.single.files, ['/tmp/pic.jpg']);
        expect(adapter.records.single.mimeHints, isEmpty);
        expect(adapter.records.single.subject, isNull);
        expect(adapter.records.single.anchor, isNull);
      });

      test(
        'S5: records accumulate in call order across text and file sends',
        () async {
          final adapter = InMemoryShareSenderAdapter();

          await adapter.shareText(text: 'first');
          await adapter.shareFiles(files: ['/tmp/a.png']);
          await adapter.shareText(text: 'third');

          expect(adapter.records.map((record) => record.text), [
            'first',
            null,
            'third',
          ]);
          expect(adapter.records[1].files, ['/tmp/a.png']);
        },
      );

      test('S6: the record snapshots the caller\'s files and hints — later '
          'mutation cannot rewrite history', () async {
        final adapter = InMemoryShareSenderAdapter();
        final files = ['/tmp/a.png'];
        final hints = {'/tmp/a.png': 'image/png'};

        await adapter.shareFiles(files: files, mimeHints: hints);
        files.clear();
        hints.clear();

        expect(adapter.records.single.files, ['/tmp/a.png']);
        expect(adapter.records.single.mimeHints, {'/tmp/a.png': 'image/png'});
      });
    },
  );

  group('ShareIntentService facade send delegation (FR-2)', () {
    test('S7: direct construction binds the pure-Dart sender adapter and '
        'delegates both send methods to it', () async {
      final service = ShareIntentService();

      expect(service.senderPort, isA<InMemoryShareSenderAdapter>());

      final textResult = await service.shareText(text: 'hello');
      final filesResult = await service.shareFiles(files: ['/tmp/a.png']);

      expect(textResult, ShareSendResult.success);
      expect(filesResult, ShareSendResult.success);
      final records =
          (service.senderPort as InMemoryShareSenderAdapter).records;
      expect(records, hasLength(2));
      expect(records.first.text, 'hello');
      expect(records.last.files, ['/tmp/a.png']);
    });

    test('S8: an injected sender port receives the send verbatim and its '
        'result is returned unchanged', () async {
      final port = ScriptedShareSenderPort();
      final service = ShareIntentService(senderPort: port);

      port.result = ShareSendResult.failure;
      final failure = await service.shareText(
        text: 'link',
        subject: 'subject',
        anchor: _anchor,
      );
      final filesFailure = await service.shareFiles(
        files: ['/tmp/a.png'],
        mimeHints: const {'/tmp/a.png': 'image/png'},
      );

      expect(failure, ShareSendResult.failure);
      expect(filesFailure, ShareSendResult.failure);
      expect(port.recordedTextArgs.single['text'], 'link');
      expect(port.recordedTextArgs.single['subject'], 'subject');
      expect(port.recordedTextArgs.single['anchor'], _anchor);
      expect(port.recordedFilesArgs.single['files'], ['/tmp/a.png']);
      expect(port.recordedFilesArgs.single['mimeHints'], const {
        '/tmp/a.png': 'image/png',
      });
    });

    test('S9: .platform() binds the share_plus send driver while keeping '
        'the method-channel intent port', () {
      final service = ShareIntentService.platform();

      expect(service.port, isA<MethodChannelShareIntentPort>());
      expect(service.senderPort, isA<SharePlusShareSenderPort>());
    });

    test('S10: the composition root registers the send driver as a lazy '
        'singleton and binds the service to both ports', () {
      final getIt = GetIt.instance..reset();
      registerShareIntentDependencies(getIt);

      final sender = getIt<ShareSenderPort>();
      expect(sender, isA<SharePlusShareSenderPort>());
      expect(identical(sender, getIt<ShareSenderPort>()), isTrue);

      final service = getIt<ShareIntentService>();
      expect(identical(service.senderPort, sender), isTrue);
      expect(service.port, isA<MethodChannelShareIntentPort>());
    });
  });

  group('SharePlusShareSenderPort driver (FR-3, FR-6 — no device)', () {
    test('S11: shareText forwards text, subject, and anchor in the '
        'ShareParams and maps completion to success', () async {
      final platform = ScriptedSharePlatform();
      final driver = SharePlusShareSenderPort(
        sharePlus: SharePlus.custom(platform),
      );

      final result = await driver.shareText(
        text: 'go.zuzu.dev/scan/abc',
        subject: 'Scan result',
        anchor: _anchor,
      );

      expect(result, ShareSendResult.success);
      expect(platform.recordedParams, hasLength(1));
      expect(platform.recordedParams.single.text, 'go.zuzu.dev/scan/abc');
      expect(platform.recordedParams.single.subject, 'Scan result');
      expect(platform.recordedParams.single.sharePositionOrigin, _anchor);
    });

    test('S12: shareFiles forwards paths as XFiles with the MIME hints '
        'attached, plus subject and anchor', () async {
      final platform = ScriptedSharePlatform();
      final driver = SharePlusShareSenderPort(
        sharePlus: SharePlus.custom(platform),
      );

      final result = await driver.shareFiles(
        files: ['/tmp/qr.png', '/tmp/receipt.pdf'],
        subject: 'Documents',
        mimeHints: const {'/tmp/receipt.pdf': 'application/pdf'},
        anchor: _anchor,
      );

      expect(result, ShareSendResult.success);
      final params = platform.recordedParams.single;
      expect(params.files!.map((file) => file.path).toList(), [
        '/tmp/qr.png',
        '/tmp/receipt.pdf',
      ]);
      expect(params.files!.map((file) => file.mimeType).toList(), [
        isNull,
        'application/pdf',
      ]);
      expect(params.subject, 'Documents');
      expect(params.sharePositionOrigin, _anchor);
    });

    test('S13: shareFiles without hints forces no MIME type — share_plus '
        'keeps its own extension lookup', () async {
      final platform = ScriptedSharePlatform();
      final driver = SharePlusShareSenderPort(
        sharePlus: SharePlus.custom(platform),
      );

      await driver.shareFiles(files: ['/tmp/pic.jpg']);

      expect(platform.recordedParams.single.files!.single.mimeType, isNull);
    });

    test('S14: a failing platform channel resolves to the failure result '
        '— no exception escapes', () async {
      final platform = ScriptedSharePlatform()
        ..error = PlatformException(
          code: 'channel-error',
          message: 'Unable to establish connection on channel.',
        );
      final driver = SharePlusShareSenderPort(
        sharePlus: SharePlus.custom(platform),
      );

      final result = await driver.shareText(text: 'link');

      expect(result, ShareSendResult.failure);
    });

    test('S15: even argument errors (empty files) resolve to the failure '
        'result — one error path for callers', () async {
      final platform = ScriptedSharePlatform()
        ..error = ArgumentError('files provided, but cannot be empty');
      final driver = SharePlusShareSenderPort(
        sharePlus: SharePlus.custom(platform),
      );

      final result = await driver.shareFiles(files: const <String>[]);

      expect(result, ShareSendResult.failure);
    });

    test('S16: the outcome is not a delivery receipt — a dismissed or '
        'unavailable share result still presents the surface', () async {
      final dismissed = ScriptedSharePlatform()
        ..result = const ShareResult('raw', ShareResultStatus.dismissed);
      final unavailable = ScriptedSharePlatform()
        ..result = ShareResult.unavailable;

      final dismissedResult = await SharePlusShareSenderPort(
        sharePlus: SharePlus.custom(dismissed),
      ).shareText(text: 'link');
      final unavailableResult = await SharePlusShareSenderPort(
        sharePlus: SharePlus.custom(unavailable),
      ).shareFiles(files: ['/tmp/a.png']);

      expect(dismissedResult, ShareSendResult.success);
      expect(unavailableResult, ShareSendResult.success);
    });
  });
}
