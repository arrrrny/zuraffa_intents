import 'dart:ui' show Rect;

/// The outcome of one outbound send: the native share surface was
/// presented (success), or the send could not present it (failure).
///
/// It is deliberately a delivery-free answer — what the user does inside
/// the share surface, and whether anything was actually shared, is not a
/// fact the caller can rely on across platforms, so the port does not
/// pretend to know it (spec 1205 FR-1: "share surface presented", not a
/// delivery receipt).
enum ShareSendResult { success, failure }

/// The outbound-share seam: one interface between the app and whatever
/// presents the native share surface (the share_plus-wrapping
/// [SharePlusShareSenderPort] platform driver on a device, the pure-Dart
/// [InMemoryShareSenderAdapter] in tests and dev).
///
/// The send-side counterpart of [ShareIntentPort] — the receiving seam
/// shipped first (spec 001). With this port the intents package covers
/// both directions of inter-app communication, and a direct `share_plus`
/// dependency becomes an internal implementation detail of this package
/// instead of an app dependency (spec 1205 FR-1, zik_zak spec
/// 1205-share-fleet-hardening).
///
/// The error contract: implementations resolve [ShareSendResult.failure]
/// instead of throwing — a failed channel, an unsupported platform, and
/// rejected arguments all land on the one failure result, so callers own
/// a single error path (acceptance scenario 4).
abstract class ShareSenderPort {
  /// Presents the native share surface for [text] — a deep link, a
  /// barcode payload, or any plain text. [subject] populates the email
  /// subject field where the platform supports one; [anchor] is the
  /// global rect the iPad popover (and the macOS picker) anchors to —
  /// pass the sending widget's rect on iPad; omit it on other devices
  /// and whenever no widget context exists (the platform default
  /// presentation is used).
  Future<ShareSendResult> shareText({
    required String text,
    String? subject,
    Rect? anchor,
  });

  /// Presents the native share surface for [files] — local file paths
  /// offered to the receiving apps. [mimeHints] maps a file path to the
  /// MIME type the share should declare for it (the platform infers one
  /// from the extension; an explicit hint wins where they disagree);
  /// [subject] and [anchor] behave exactly as in [shareText].
  Future<ShareSendResult> shareFiles({
    required List<String> files,
    String? subject,
    Map<String, String>? mimeHints,
    Rect? anchor,
  });
}
