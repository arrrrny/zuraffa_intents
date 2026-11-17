// GENERATED TEST — bug guard (extension-intent-crash): `NSExtensionContext
// .intent` is documented only for the Share extension point and throws an
// uncaught ObjC exception (SIGSEGV) from any other one, while
// `extensionContext!.inputItems[0]` traps on an empty or late items array.
// CI never compiles Swift in this repo, so this textual contract pin is the
// automated gate for the fix: nothing else would fail if someone restored the
// force-subscript, read the extension point from the wrong plist level, or
// dropped the explicit failure path.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _iosController =
    'ios/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentIosViewController.swift';
const _macosController =
    'macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift';

/// The body of the Swift function whose signature starts with [signature].
String _functionBody(String path, String signature) {
  final source = File(path).readAsStringSync();
  final start = source.indexOf(signature);
  expect(
    start,
    greaterThanOrEqualTo(0),
    reason: '$signature not found in $path',
  );
  final rest = source.substring(start);
  final nextDeclaration = rest.indexOf('\n    public func ', 1);
  final end = nextDeclaration < 0 ? rest.length : nextDeclaration;
  return rest.substring(0, end);
}

void main() {
  group('extension-intent-crash guard', () {
    test('the extension point is read from inside the NSExtension dictionary', () {
      final source = File(_iosController).readAsStringSync();
      expect(
        source,
        contains('forInfoDictionaryKey: "NSExtension"'),
        reason:
            'NSExtensionPointIdentifier is a child of the NSExtension '
            'dictionary, so a top-level lookup resolves nil on a stock '
            'extension Info.plist and isSharePoint would be false everywhere',
      );
      expect(
        source,
        contains('extensionInfo?["NSExtensionPointIdentifier"]'),
        reason:
            'the documented nested shape must be the primary read, or every '
            'share extension silently loses conversationIdentifier / sender / '
            'serviceName / speakableGroupName',
      );
      expect(
        source,
        contains('forInfoDictionaryKey: "NSExtensionPointIdentifier"'),
        reason:
            'the flat key stays as a fallback: hand-flattened Info.plists '
            'exist in the wild',
      );
    });

    test('intent is only read on the share extension point', () {
      final source = File(_iosController).readAsStringSync();
      expect(
        source,
        contains('extensionPoint == "com.apple.share-services"'),
        reason:
            'the allowlist is the crash guard: every other extension point '
            '(an Action extension, e.g. com.apple.ui-services) throws from '
            '.intent',
      );
      expect(
        source,
        contains('extensionContext?.intent as? INSendMessageIntent'),
        reason:
            'the share point must still read the intent, otherwise the guard '
            'fixes the crash by deleting the feature',
      );
      expect(
        source,
        contains('NOT in the\n        // allowlist'),
        reason:
            'the narrow scope (no com.apple.intents-service / '
            'com.apple.intents-ui-service) must be stated as deliberate',
      );
    });

    test('iOS inputItems access is guarded, never a force-subscript', () {
      final source = File(_iosController).readAsStringSync();
      expect(
        source,
        isNot(contains('inputItems[0]')),
        reason:
            'extensionContext!.inputItems[0] crashes the extension when a host '
            'delivers an empty or late items array',
      );
      expect(
        source,
        contains('extensionContext?.inputItems'),
        reason:
            'both the intake and saveSharedMedia must tolerate a nil '
            'extensionContext',
      );
      expect(
        source,
        isNot(contains('extensionContext!')),
        reason:
            'no remaining force-unwrap of extensionContext — the error path '
            '(dismissWithError) must tolerate nil too, or the safe branch '
            'becomes a second crash',
      );
    });

    test('iOS handleInputItems dismisses instead of hanging silently', () {
      final body = _functionBody(
        _iosController,
        'func handleInputItems() async',
      );
      expect(
        body,
        contains('if let content = items.first as? NSExtensionItem'),
        reason: 'the intake must use the guarded first access',
      );
      expect(
        body,
        contains('dismissWithError()'),
        reason:
            'a host that delivered no NSExtensionItem must produce feedback: '
            'returning silently leaves the share sheet on screen forever',
      );
    });

    test('macOS handleInputItems fails explicitly instead of hanging', () {
      final source = File(_macosController).readAsStringSync();
      expect(
        source,
        isNot(contains('inputItems[0]')),
        reason:
            'the macOS controller crashed on the same force-subscript family',
      );
      final body = _functionBody(
        _macosController,
        'func handleInputItems() async',
      );
      expect(
        body,
        contains('extensionContext?.completeRequest'),
        reason:
            'the else path must dismiss the extension: a silent return leaves '
            'the share window up with nothing to do',
      );
      expect(
        body,
        contains(
          'share dropped: the extension context carried no NSExtensionItem',
        ),
        reason:
            'the failure must be diagnosable in Console.app — macOS extension '
            'stdout is never captured, so the log goes through os_log/Logger',
      );
    });
  });
}
