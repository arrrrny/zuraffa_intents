// GENERATED TEST — `zfa tdd gen U6` (spec 044-test-tdd-generation).
//
// behavior_id: U6
// source_criterion: FR-006, ShareIntentPort.sharedMediaStream
// kind: unit
// description: The initial-share lifecycle on `ShareIntentPort` MUST work
//
// Hand step (U6:hand, issue #1308 seam): replaced the vacuous-guard
// assertion with the observable outcome the behavior names — reads are
// repeatable until the explicit reset, fresh state reads null, and the
// reset is idempotent.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/u6_subject.dart'
    as subject;

void main() {
  group('U6 (FR-006, ShareIntentPort.sharedMediaStream)', () {
    test(
      'U6 — The initial-share lifecycle on `ShareIntentPort` MUST work',
      () async {
        final port = subject.subject_u6();

        // Fresh state: nothing stored.
        expect(await port.getInitialSharedMedia(), isNull);

        // Stored: reads are repeatable until reset.
        final share = SharedMedia(content: 'boot-share');
        port.storeInitial(share);
        final first = await port.getInitialSharedMedia();
        final second = await port.getInitialSharedMedia();
        expect(first, isNotNull);
        expect(second, isNotNull);
        expect(first!.content, 'boot-share');
        expect(second!.content, 'boot-share');

        // Explicit reset clears; a second reset is idempotent.
        await port.resetInitialSharedMedia();
        expect(await port.getInitialSharedMedia(), isNull);
        await port.resetInitialSharedMedia();
        expect(await port.getInitialSharedMedia(), isNull);
      },
    );
  });
}
