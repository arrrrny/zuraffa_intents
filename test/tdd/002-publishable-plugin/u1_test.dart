// GENERATED TEST — hand step (U1:hand): the observable outcome — the
// publish-ready packaging contract of FR-001.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u1_subject.dart' as subject;

void main() {
  group('U1 (FR-001, publishability)', () {
    test('U1 — The package MUST be publish-ready for pub.dev: `pubspec.yaml`', () {
      final files = subject.subject_u1();
      final newline = String.fromCharCode(10);
      final pubspec = files['pubspec']!;
      expect(pubspec, contains('homepage:'));
      expect(pubspec, contains('repository: https://github.com/arrrrny/zuraffa_intents'));
      expect(pubspec, contains('issue_tracker:'));
      // The description is a folded block between `description: >-` and the
      // next top-level key — pub.dev folds it, then applies its 180-char cap.
      final block = RegExp(
        'description: >-$newline((?:  .*$newline)+)',
      ).firstMatch(pubspec)!.group(1)!;
      final description = block
          .split(newline)
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .join(' ');
      expect(description.length, lessThanOrEqualTo(180));

      // BSD-3 license text is present.
      expect(files['license']!, contains('BSD'));
      // The CHANGELOG head entry matches the package version.
      final version = RegExp(r'^version: (.+)$', multiLine: true)
          .firstMatch(pubspec)!
          .group(1)!
          .trim();
      expect(files['changelog']!.split(newline).take(6).join(newline),
          contains(version));
    });
  });
}
