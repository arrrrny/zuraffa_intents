import 'dart:ui' show Rect;

import '../../domain/outbound/share_sender_port.dart';

/// One recorded send request — the arguments a send method was invoked
/// with, exactly as passed: [text] is non-null for a text send ([files]
/// empty), [files] is non-empty for a file send ([text] null);
/// [subject]/[anchor] are null and [mimeHints] empty when the caller
/// omitted them. The files and hints are snapshotted at record time, so
/// later caller mutation cannot rewrite history.
class ShareSendRecord {
  const ShareSendRecord({
    this.text,
    this.subject,
    this.files = const [],
    this.mimeHints = const {},
    this.anchor,
  });

  /// The text a text send carried (null for a file send).
  final String? text;

  /// The subject exactly as passed (null when omitted).
  final String? subject;

  /// The file paths a file send carried (empty for a text send).
  final List<String> files;

  /// The MIME hints exactly as passed (empty when omitted).
  final Map<String, String> mimeHints;

  /// The anchor rect exactly as passed (null when omitted).
  final Rect? anchor;
}

/// The pure-Dart [ShareSenderPort] — the test/dev stand-in for the
/// share_plus-wrapping platform driver.
///
/// The adapter plays the platform role the driver plays on a device:
/// every send resolves [ShareSendResult.success] (the in-memory surface
/// always presents) and is recorded into [records], so package and app
/// tests assert the exact text, subject, files, MIME hints, and anchor
/// in pure Dart with no platform channel (spec 1205 FR-4). Tests that
/// need a failure outcome script it on a hand-rolled fake port instead.
class InMemoryShareSenderAdapter implements ShareSenderPort {
  /// One record per send call, in call order — text and file sends
  /// share the one timeline.
  final List<ShareSendRecord> _records = [];

  /// Everything recorded through [shareText]/[shareFiles], in call order.
  List<ShareSendRecord> get records => List.unmodifiable(_records);

  @override
  Future<ShareSendResult> shareText({
    required String text,
    String? subject,
    Rect? anchor,
  }) async {
    _records.add(ShareSendRecord(text: text, subject: subject, anchor: anchor));
    return ShareSendResult.success;
  }

  @override
  Future<ShareSendResult> shareFiles({
    required List<String> files,
    String? subject,
    Map<String, String>? mimeHints,
    Rect? anchor,
  }) async {
    _records.add(
      ShareSendRecord(
        subject: subject,
        files: List.unmodifiable(files),
        mimeHints: mimeHints == null ? const {} : Map.unmodifiable(mimeHints),
        anchor: anchor,
      ),
    );
    return ShareSendResult.success;
  }
}
