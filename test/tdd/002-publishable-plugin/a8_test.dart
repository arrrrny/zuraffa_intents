// GENERATED TEST — hand step (A8): the publish contract holds —
// exactly three declared platforms, rebranded package/class, existing
// native declaration files, repository metadata, and a versioned
// CHANGELOG head.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/a8_subject.dart'
    as subject;

void main() {
  group('A8 (AC-8)', () {
    test(
      'A8 — `pubspec.yaml` declares the plugin for exactly android, ios,',
      () {
        final pubspec = subject.subject_a8();
        expect(pubspec, contains("name: zuraffa_intents"));
        expect(pubspec, contains('dev.zuraffa.zuraffa_intents'));
        expect(pubspec, contains(' ZuraffaIntentsPlugin'));
        expect(pubspec, contains('repository:'));
        expect(pubspec, contains('issue_tracker:'));

        // Exactly the three shipped platforms; no linux/windows/web surface.
        expect(pubspec, contains('android:'));
        expect(pubspec, contains('ios:'));
        expect(pubspec, contains('macos:'));
        for (final removed in [
          'pluginClass: ZuraffaIntentsWeb',
          'linux:',
          'windows:',
          'web:',
        ]) {
          expect(
            pubspec.contains(removed),
            isFalse,
            reason: 'no $removed platform surface may remain',
          );
        }

        // The native declaration files exist on disk.
        for (final path in [
          'ios/zuraffa_intents.podspec',
          'macos/zuraffa_intents.podspec',
          'ios/zuraffa_intents/Package.swift',
          'macos/zuraffa_intents/Package.swift',
        ]) {
          expect(File(path).existsSync(), isTrue, reason: '$path must exist');
        }

        // A CHANGELOG head entry matches the package version.
        final changelog = File('CHANGELOG.md').readAsStringSync();
        final version = RegExp(
          r'^version: (.+)$',
          multiLine: true,
        ).firstMatch(pubspec)!.group(1)!.trim();
        expect(changelog, contains(version));
      },
    );
  });
}
