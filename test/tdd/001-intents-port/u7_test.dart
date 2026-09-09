// GENERATED TEST — `zfa tdd gen U7` (spec 044-test-tdd-generation).
//
// behavior_id: U7
// source_criterion: FR-007, ShareIntentPort.sharedMediaStream
// kind: unit
// description: `recordSentMessage` MUST preserve the plugin's argument
//
// Hand step (U7:hand, issue #1308 seam): replaced the vacuous-guard
// assertion with the observable outcome the behavior names — the plugin's
// argument→carrier mapping, one record per call in call order, omitted
// optionals recorded as null.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/u7_subject.dart'
    as subject;

void main() {
  group('U7 (FR-007, ShareIntentPort.sharedMediaStream)', () {
    test(
      'U7 — `recordSentMessage` MUST preserve the plugin\'s argument',
      () async {
        final port = subject.subject_u7();

        await port.recordSentMessage(
          conversationIdentifier: 'conv-9',
          conversationName: 'Mom',
          conversationImageFilePath: '/tmp/mom.png',
          serviceName: 'iMessage',
        );
        await port.recordSentMessage(
          conversationIdentifier: 'conv-10',
          conversationName: 'Dad',
        );

        final records = port.sentMessageRecords;
        expect(records.length, 2, reason: 'one record per call, in call order');

        final full = records[0];
        expect(full.conversationIdentifier, 'conv-9');
        expect(
          full.speakableGroupName,
          'Mom',
          reason: 'conversationName maps to speakableGroupName',
        );
        expect(
          full.imageFilePath,
          '/tmp/mom.png',
          reason: 'conversationImageFilePath maps to imageFilePath',
        );
        expect(full.serviceName, 'iMessage');

        final minimal = records[1];
        expect(minimal.conversationIdentifier, 'conv-10');
        expect(minimal.speakableGroupName, 'Dad');
        expect(
          minimal.imageFilePath,
          isNull,
          reason: 'omitted optionals are null',
        );
        expect(minimal.serviceName, isNull);
      },
    );
  });
}
