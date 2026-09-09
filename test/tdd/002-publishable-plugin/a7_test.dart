// GENERATED TEST — hand step (A7): the Dart literals and the ported
// native trees agree — channel names match and the rebrand is total.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/a7_subject.dart' as subject;

void main() {
  group('A7 (AC-7)', () {
    test('A7 — the three pigeon channel literals and the event', () {
      final dart = subject.subject_a7();
      expect(dart['event'], 'dev.zuraffa.zuraffa_intents/sharedMediaStream');
      expect(dart['getInitialSharedMedia'],
          'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia');
      expect(dart['recordSentMessage'],
          'dev.flutter.pigeon.ZuraffaIntentsApi.recordSentMessage');
      expect(dart['resetInitialSharedMedia'],
          'dev.flutter.pigeon.ZuraffaIntentsApi.resetInitialSharedMedia');

      // The Kotlin and both Swift plugins carry the event literal.
      final eventCarriers = [
        'android/src/main/kotlin/dev/zuraffa/zuraffa_intents/ZuraffaIntentsPlugin.kt',
        'ios/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift',
        'macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsPlugin.swift',
      ];
      for (final path in eventCarriers) {
        expect(File(path).readAsStringSync(), contains(dart['event']),
            reason: 'event channel literal must appear in $path');
      }

      // The Pigeon Java and both Swift APIs carry the three pigeon literals.
      final pigeonCarriers = [
        'android/src/main/java/dev/zuraffa/zuraffa_intents/Messages.java',
        'ios/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsApi.swift',
        'macos/zuraffa_intents/Sources/zuraffa_intents/ZuraffaIntentsApi.swift',
      ];
      for (final path in pigeonCarriers) {
        final source = File(path).readAsStringSync();
        for (final literal in [
          dart['getInitialSharedMedia']!,
          dart['recordSentMessage']!,
          dart['resetInitialSharedMedia']!,
        ]) {
          expect(source, contains(literal),
              reason: 'pigeon literal must appear in $path');
        }
      }
    });
  });
}
