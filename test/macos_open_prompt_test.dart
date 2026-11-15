// GENERATED TEST — bug guard (macos-open-prompt): the macOS share extension
// hands the payload to the host app by opening a ShareMedia-<host>:// URL from
// the extension process. NSWorkspace.OpenConfiguration.promptsUserIfNeeded
// defaults to true, so every share was gated by the cross-app
// "Keeping app data separate" confirmation (#22). CI never compiles Swift in
// this repo, so this textual contract pin is the automated gate for the fix.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _macosController =
    'macos/zuraffa_intents/Sources/zuraffa_intents_models/ShareIntentMacosViewController.swift';

void main() {
  group('macos-open-prompt guard', () {
    test('macOS redirect opens the host app without a user confirmation', () {
      final source = File(_macosController).readAsStringSync();
      expect(
        source,
        contains('openConfiguration.promptsUserIfNeeded = false'),
        reason:
            'a default OpenConfiguration has promptsUserIfNeeded = true, so '
            'macOS gates every extension-to-host open with the '
            '"Keeping app data separate" confirmation (#22)',
      );
    });

    test(
      'macOS redirect no longer opens with an inline default configuration',
      () {
        final source = File(_macosController).readAsStringSync();
        expect(
          source,
          isNot(
            contains(
              'NSWorkspace.shared.open(url, configuration: NSWorkspace.OpenConfiguration())',
            ),
          ),
          reason:
              'an inline default OpenConfiguration reintroduces the '
              'promptsUserIfNeeded = true behavior this guard pins (#22)',
        );
      },
    );

    test('macOS redirect opens through the prepared configuration', () {
      final source = File(_macosController).readAsStringSync();
      expect(
        source,
        contains(
          'NSWorkspace.shared.open(url, configuration: openConfiguration)',
        ),
        reason:
            'the suppressed-prompt configuration must be the one actually '
            'passed to the open call, otherwise the pin is decorative (#22)',
      );
    });
  });
}
