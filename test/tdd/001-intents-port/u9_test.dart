// GENERATED TEST — `zfa tdd gen U9` (spec 044-test-tdd-generation).
//
// behavior_id: U9
// source_criterion: FR-009, ShareIntentService.sharedMediaStream
// kind: unit
// description: `ShareIntentService` MUST be a thin facade over the port —
//
// Hand step (U9:hand, issue #1308 seam): replaced the vacuous-guard
// assertion with the observable outcomes the behavior names — the facade
// delegates all four operations, surfaces port errors verbatim,
// re-exposes the port's stream instance, and the composition root
// registers a lazy singleton.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:zuraffa_intents/src/data/intents/in_memory_share_intent_adapter.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/src/domain/intents/share_intent_port.dart';
import 'package:zuraffa_intents/src/share_intent_service.dart';
import 'package:zuraffa_intents/tdd/001-intents-port/u9_subject.dart' as subject;

void main() {
  group('U9 (FR-009, ShareIntentService.sharedMediaStream)', () {
    test('U9 — `ShareIntentService` MUST be a thin facade over the port —', () async {
      final service = subject.subject_u9();
      final port = service.port as InMemoryShareIntentAdapter;

      // Delegation: the initial-media lifecycle through the facade.
      port.storeInitial(SharedMedia(content: 'boot'));
      final initial = await service.getInitialSharedMedia();
      expect(initial!.content, 'boot');
      await service.resetInitialSharedMedia();
      expect(await service.getInitialSharedMedia(), isNull);

      // Delegation: recordSentMessage passes through verbatim.
      await service.recordSentMessage(
        conversationIdentifier: 'conv-1',
        conversationName: 'Mom',
      );
      expect(port.sentMessageRecords.single.speakableGroupName, 'Mom');

      // The facade re-exposes the port's stream instance identically.
      expect(identical(service.sharedMediaStream, port.sharedMediaStream),
          isTrue);

      // A port-thrown error surfaces verbatim — never wrapped/swallowed.
      final boom = StateError('verbatim');
      final throwing = subject.throwingPort(boom);
      final throwingService = ShareIntentService(port: throwing);
      await expectLater(
        throwingService.recordSentMessage(
          conversationIdentifier: 'c',
          conversationName: 'n',
        ),
        throwsA(same(boom)),
      );
      await expectLater(
        throwingService.getInitialSharedMedia(),
        throwsA(same(boom)),
      );

      // The composition root registers a lazy singleton.
      final getIt = GetIt.asNewInstance();
      subject.register(getIt);
      final resolved1 = getIt<ShareIntentService>();
      final resolved2 = getIt<ShareIntentService>();
      expect(identical(resolved1, resolved2), isTrue,
          reason: 'repeated resolution yields the identical instance');
      expect(identical(resolved1.port, getIt<ShareIntentPort>()), isTrue);
      getIt.reset();
    });
  });
}
