// GENERATED STUB — hand step (A7: composition deferred; zuraffa#1420 workaround).
//
// behavior_id: A7
// source_criterion: AC-7
// ignore_for_file: non_constant_identifier_names
library;

import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';

/// Subject for behavior A7: the Dart-side channel literals under test.
Map<String, String> subject_a7() => {
  'event': kSharedMediaStreamChannel,
  'getInitialSharedMedia': kGetInitialSharedMediaChannel,
  'recordSentMessage': kRecordSentMessageChannel,
  'resetInitialSharedMedia': kResetInitialSharedMediaChannel,
};
