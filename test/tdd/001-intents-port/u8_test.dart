// GENERATED TEST — `zfa tdd gen U8` (spec 044-test-tdd-generation).
//
// behavior_id: U8
// source_criterion: FR-008, ShareIntentPort.sharedMediaStream
// kind: unit
// description: `sharedMediaStream` MUST be a broadcast stream: every
//
// Hand step (U8:hand, issue #1308 seam): replaced the vacuous-guard
// assertion with the observable outcomes the behavior names — broadcast
// delivery to every current listener, no pre-subscription replay, and a
// per-port lazy-singleton stream instance.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/u8_subject.dart'
    as subject;

void main() {
  group('U8 (FR-008, ShareIntentPort.sharedMediaStream)', () {
    test(
      'U8 — `sharedMediaStream` MUST be a broadcast stream: every',
      () async {
        final port = subject.subject_u8();

        // Pre-subscription emission: a later subscriber must NOT see it.
        port.emit(SharedMedia(content: 'before'));

        final first = <SharedMedia>[];
        final second = <SharedMedia>[];
        final late_ = <SharedMedia>[];
        final sub1 = port.sharedMediaStream.listen(first.add);
        final sub2 = port.sharedMediaStream.listen(second.add);

        port.emit(SharedMedia(content: 'live-1'));
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(first.map((m) => m.content), [
          'live-1',
        ], reason: 'every current listener receives every share');
        expect(second.map((m) => m.content), ['live-1']);

        // The stream is a per-port lazy singleton.
        expect(
          identical(port.sharedMediaStream, port.sharedMediaStream),
          isTrue,
        );

        // A subscriber attaching now gets no replay of 'before' or 'live-1',
        // only post-subscription emissions.
        final sub3 = port.sharedMediaStream.listen(late_.add);
        port.emit(SharedMedia(content: 'live-2'));
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(late_.map((m) => m.content), [
          'live-2',
        ], reason: 'pre-subscription emissions are not replayed');

        await sub1.cancel();
        await sub2.cancel();
        await sub3.cancel();
      },
    );
  });
}
