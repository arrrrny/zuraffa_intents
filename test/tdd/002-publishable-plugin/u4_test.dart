// GENERATED TEST — hand step (U4:hand): the observable outcome —
// the Uri.decodeFull quirk is predicate-gated per FR-004.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/src/platform/wire/share_intents_wire.dart';
import 'package:zuraffa_intents/tdd/002-publishable-plugin/u4_subject.dart' as subject;

void main() {
  group('U4 (FR-004, decodeSharedMedia.decodeSharedMedia)', () {
    test('U4 — The iOS/macOS attachment-path quirk — attachment paths', () {
      final appleLike = decodeSharedMedia(
        subject.encoded_u4(),
        isAppleLikeUriPath: () => true,
      );
      expect(appleLike.attachments!.single.path, 'file:///var/mobile/pic name.jpg',
          reason: 'apple-like platforms decode percent-encoded paths');

      final verbatim = decodeSharedMedia(
        subject.encoded_u4(),
        isAppleLikeUriPath: () => false,
      );
      expect(verbatim.attachments!.single.path, 'file:///var/mobile/pic%20name.jpg',
          reason: 'non-apple platforms keep paths verbatim');

      // The default predicate is callable without touching a platform gate.
      expect(defaultIsAppleLikeUriPath, isA<bool Function()>());
      expect(defaultIsAppleLikeUriPath(), isA<bool>());
    });
  });
}
