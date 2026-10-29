import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/outbound/share_sender_port.dart';

/// The platform driver for [ShareSenderPort] — the send side rides
/// `share_plus`, the plan-phase decision recorded for spec 1205 FR-3:
/// wrap the battle-tested plugin (all three plugin platforms covered)
/// instead of growing a first-party ACTION_SEND /
/// UIActivityViewController / NSSharingServicePicker channel; the
/// consumer-facing contract is identical either way.
///
/// `share_plus` is therefore an internal implementation detail of this
/// package: apps consume the send API through the facade and drop their
/// own `share_plus` dependency (spec 1205 FR-5). The driver maps
/// share_plus's throwable pipeline onto the port's one error path — a
/// failed channel, an unsupported platform, or rejected arguments
/// resolve [ShareSendResult.failure] and no exception escapes. Any
/// completion of the underlying share call resolves success: the share
/// surface was presented, and the user's subsequent action is not
/// observed (the outcome is not a delivery receipt).
class SharePlusShareSenderPort implements ShareSenderPort {
  SharePlusShareSenderPort({SharePlus? sharePlus})
    : _sharePlus = sharePlus ?? SharePlus.instance;

  /// The share_plus entry point — [SharePlus.instance] by default;
  /// [SharePlus.custom] injects a scripted [SharePlatform] in tests, the
  /// seam that keeps the driver testable without a device.
  final SharePlus _sharePlus;

  @override
  Future<ShareSendResult> shareText({
    required String text,
    String? subject,
    Rect? anchor,
  }) {
    return _present(
      ShareParams(text: text, subject: subject, sharePositionOrigin: anchor),
    );
  }

  @override
  Future<ShareSendResult> shareFiles({
    required List<String> files,
    String? subject,
    Map<String, String>? mimeHints,
    Rect? anchor,
  }) {
    return _present(
      ShareParams(
        files: <XFile>[
          for (final path in files) XFile(path, mimeType: mimeHints?[path]),
        ],
        subject: subject,
        sharePositionOrigin: anchor,
      ),
    );
  }

  Future<ShareSendResult> _present(ShareParams params) async {
    try {
      await _sharePlus.share(params);
      return ShareSendResult.success;
    } catch (error, stackTrace) {
      assert(() {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'zuraffa_intents',
            context: ErrorDescription('while presenting the share surface'),
          ),
        );
        return true;
      }());
      return ShareSendResult.failure;
    }
  }
}
