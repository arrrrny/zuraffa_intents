// GENERATED TEST — hand step (U10:hand): the observable outcome —
// native port consistency per FR-010.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u10_subject.dart' as subject;

void main() {
  group('U10 (FR-010, native consistency)', () {
    test('U10 — Native port consistency — the ported native trees', () {
      final dart = subject.subject_u10();
      expect(dart['event'], isNotEmpty, reason: 'the Dart literals anchor the scan');

      // (b) No leftover source-plugin identifiers anywhere in the natives.
      final nativeFiles = <File>[];
      for (final dir in ['android', 'ios', 'macos']) {
        nativeFiles.addAll(
          Directory(dir)
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.kt') ||
                  f.path.endsWith('.java') ||
                  f.path.endsWith('.swift')),
        );
      }
      expect(nativeFiles, isNotEmpty);
      for (final file in nativeFiles) {
        final source = file.readAsStringSync();
        expect(source.contains('zikzak'), isFalse,
            reason: 'no zikzak identifiers may remain in ${file.path}');
        expect(source.contains('ShareHandler'), isFalse,
            reason: 'no ShareHandler identifiers may remain in ${file.path}');
      }

      // (c) The rebranded plugin classes are declared.
      expect(
        File('android/src/main/kotlin/dev/zuraffa/zuraffa_intents/ZuraffaIntentsPlugin.kt')
            .readAsStringSync(),
        contains('class ZuraffaIntentsPlugin'),
      );
      for (final plugin in [
        'ios/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift',
        'macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift',
      ]) {
        expect(File(plugin).readAsStringSync(), contains('ZuraffaIntentsPlugin'),
            reason: plugin);
      }

      // (d) pubspec declares the natives; their declaration files exist.
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('dev.zuraffa.zuraffa_intents'));
      for (final declaration in [
        'ios/zuraffa_intents.podspec',
        'macos/zuraffa_intents.podspec',
        'ios/zuraffa_intents/Package.swift',
        'macos/zuraffa_intents/Package.swift',
        'android/src/main/AndroidManifest.xml',
      ]) {
        expect(File(declaration).existsSync(), isTrue,
            reason: '$declaration must exist');
      }
    });
  });
}
