// GENERATED STUB — hand step (U10:hand, issue #1308 seam).
//
// behavior_id: U10
// source_criterion: FR-010, native consistency
// ignore_for_file: non_constant_identifier_names
library;

import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';

/// Subject for behavior U10: the Dart wire literals the natives must carry.
Map<String, String> subject_u10() => {
  'event': kSharedMediaStreamChannel,
  'getInitialSharedMedia': kGetInitialSharedMediaChannel,
  'recordSentMessage': kRecordSentMessageChannel,
  'resetInitialSharedMedia': kResetInitialSharedMediaChannel,
};
