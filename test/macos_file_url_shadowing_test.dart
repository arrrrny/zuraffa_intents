// GENERATED TEST — bug guard (macos-file-url-shadowing): the macOS share
// intake must treat a shared file as a FILE, never as a URL. public.file-url
// conforms to public.url, so when the url branch is checked first it shadows
// the file branch, the App Group copy never runs, and the raw sender path
// crosses into the host app. CI never compiles Swift in this repo, so this
// textual contract pin is the automated gate for the fix.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _macosController =
    'macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift';
const _macosPlugin =
    'macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift';
const _iosController =
    'ios/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentIosViewController.swift';

/// Index of the first `hasItemConformingToTypeIdentifier(<type>)` check for
/// [type] in [path], for branch-order assertions.
int _firstCheckIndex(String path, String type) {
  final source = File(path).readAsStringSync();
  final needle = 'hasItemConformingToTypeIdentifier($type)';
  final index = source.indexOf(needle);
  expect(
    index,
    greaterThanOrEqualTo(0),
    reason: 'no $type conformance check found in $path',
  );
  return index;
}

void main() {
  group('macos-file-url-shadowing guard', () {
    test(
      'macOS: the fileURLType branch precedes the urlContentType branch',
      () {
        final fileBranch = _firstCheckIndex(_macosController, 'fileURLType');
        final urlBranch = _firstCheckIndex(_macosController, 'urlContentType');
        expect(
          fileBranch,
          lessThan(urlBranch),
          reason:
              'public.file-url conforms to public.url — with the url check '
              'first, every shared file matches the url branch and the App '
              'Group copy in handleFiles is never reached',
        );
      },
    );

    test(
      'iOS (regression): the fileURLType branch precedes urlContentType',
      () {
        final fileBranch = _firstCheckIndex(_iosController, 'fileURLType');
        final urlBranch = _firstCheckIndex(_iosController, 'urlContentType');
        expect(
          fileBranch,
          lessThan(urlBranch),
          reason: 'the iOS controller must keep checking files before urls',
        );
      },
    );

    test('macOS handleFiles loads the provider-coordinated representation', () {
      final source = File(_macosController).readAsStringSync();
      expect(
        source,
        contains('loadFileRepresentation(forTypeIdentifier: fileURLType)'),
        reason:
            'loadFileRepresentation vends a copy the extension is '
            'guaranteed to read; its URL is only valid inside the completion',
      );
      expect(
        source,
        isNot(contains('loadItem(forTypeIdentifier: fileURLType')),
        reason: 'loadItem hands back the sender-side original path',
      );
    });

    test('macOS getNewFileUrl fails loudly instead of force-unwrapping', () {
      final source = File(_macosController).readAsStringSync();
      expect(
        source,
        contains('getNewFileUrl(fileName: String) -> URL?'),
        reason:
            'containerURL is nil when AppGroupId is missing or not '
            'team-prefixed on macOS — the extension must skip the '
            'attachment, not crash',
      );
      expect(
        source,
        isNot(contains('getNewFileUrl(fileName: String) -> URL\n')),
        reason:
            'the non-optional signature force-unwraps containerURL and '
            'crashes the extension mid-share',
      );
    });

    test('queryDictionary tolerates pairs without =', () {
      final source = File(_macosPlugin).readAsStringSync();
      expect(
        source,
        isNot(contains('components(separatedBy: "=")[1]')),
        reason:
            'indexing pair components without a count check crashes on '
            'any parameter that carries no =',
      );
      expect(
        source,
        contains('components.count > 1'),
        reason:
            'the value component must only be read when the pair split '
            'actually produced one',
      );
    });

    test('macOS handleUrl routes file URLs through the App Group copy', () {
      final source = File(_macosController).readAsStringSync();
      expect(
        source,
        contains('func copySharedFile(at sourceURL: URL) -> URL?'),
        reason: 'the App Group copy must be one reusable seam',
      );
      expect(
        source,
        contains('if item.isFileURL'),
        reason:
            'senders that register a file URL under public.url without '
            'public.file-url must not slip through handleUrl as text',
      );
      expect(
        source,
        contains('copySharedFile(at: item)'),
        reason:
            'a file URL reaching handleUrl takes the App Group copy, '
            'never the raw sender path',
      );
    });

    test('macOS loadIds treats an empty AppGroupId as missing', () {
      final source = File(_macosController).readAsStringSync();
      expect(
        source,
        contains('!configured.isEmpty'),
        reason:
            'an empty-string AppGroupId must take the fallback: '
            'UserDefaults(suiteName: "") returns nil and the lazy '
            'userDefaults force-unwrap would trap',
      );
      expect(
        source,
        contains('AppGroupId missing or empty in Info.plist'),
        reason: 'the loud log must name both misconfigurations',
      );
    });
  });
}
