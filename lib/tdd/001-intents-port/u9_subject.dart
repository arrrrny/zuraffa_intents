// GENERATED STUB — `zfa tdd gen U9` (spec 044-test-tdd-generation
// + issue #1259 contract derivation).
//
// behavior_id: U9
// source_criterion: FR-009, ShareIntentService.sharedMediaStream
//
// Hand step (U9:hand): the subject exposes the real facade plus the
// test's throwing port and a scoped composition root.
//
// The subject name is derived from the behavior id (`subject_u9`) and is
// deliberately snake_cased (issue #1035).
// ignore_for_file: non_constant_identifier_names
library;

import 'package:get_it/get_it.dart';
import 'package:zuraffa_intents/src/domain/entities/shared_media/shared_media.dart';
import 'package:zuraffa_intents/src/share_intent_service.dart';

/// Subject for behavior U9: the facade over the in-memory port.
ShareIntentService subject_u9() =>
    ShareIntentService(port: InMemoryShareIntentAdapter());

/// A port whose every operation throws [error] — the verbatim probe.
ShareIntentPort throwingPort(Object error) => _ThrowingPort(error);

/// The composition root under test.
void register(GetIt getIt) => registerShareIntentDependencies(getIt);

class _ThrowingPort implements ShareIntentPort {
  _ThrowingPort(this.error);

  final Object error;

  @override
  Future<SharedMedia?> getInitialSharedMedia() => Future.error(error);

  @override
  Future<void> recordSentMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
  }) => Future.error(error);

  @override
  Future<void> resetInitialSharedMedia() => Future.error(error);

  @override
  Stream<SharedMedia> get sharedMediaStream => throw error;
}
