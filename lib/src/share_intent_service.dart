import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'data/intents/in_memory_share_intent_adapter.dart';
import 'data/outbound/in_memory_share_sender_adapter.dart';
import 'domain/entities/shared_media/shared_media.dart';
import 'domain/intents/share_intent_port.dart';
import 'domain/outbound/share_sender_port.dart';
import 'platform/method_channel/method_channel_share_intent_port.dart';
import 'platform/share_plus/share_plus_share_sender_port.dart';

export 'data/intents/in_memory_share_intent_adapter.dart';
export 'data/outbound/in_memory_share_sender_adapter.dart';
export 'domain/intents/share_intent_port.dart';
export 'domain/outbound/share_sender_port.dart';
export 'platform/method_channel/method_channel_share_intent_port.dart';
export 'platform/share_plus/share_plus_share_sender_port.dart';
export 'platform/wire/share_intents_wire.dart';

/// The app-facing share-intent facade: the boot-time initial share, the
/// live share stream, and sent-message share-suggestion recording —
/// over the registered [ShareIntentPort] — plus the outbound send seam
/// ([shareText]/[shareFiles]) over the registered [ShareSenderPort].
///
/// ```dart
/// final intents = ShareIntentService.platform();
/// final boot = await intents.getInitialSharedMedia();
/// if (boot != null) await intents.resetInitialSharedMedia();
/// intents.sharedMediaStream.listen(handleShare);
/// final sent = await intents.shareText(
///     text: 'go.zuzu.dev/scan/abc',
///     subject: 'Scan result');
/// ```
class ShareIntentService {
  /// The port this facade delegates to (the
  /// [MethodChannelShareIntentPort] platform driver under [ShareIntentService.platform],
  /// the pure-Dart [InMemoryShareIntentAdapter] when constructed directly —
  /// the test/dev default).
  final ShareIntentPort port;

  /// The port the send methods delegate to (the
  /// [SharePlusShareSenderPort] platform driver under
  /// [ShareIntentService.platform], the pure-Dart
  /// [InMemoryShareSenderAdapter] when constructed directly — the
  /// test/dev default).
  final ShareSenderPort senderPort;

  ShareIntentService({ShareIntentPort? port, ShareSenderPort? senderPort})
    : port = port ?? InMemoryShareIntentAdapter(),
      senderPort = senderPort ?? InMemoryShareSenderAdapter();

  /// The plugin constructor: binds the method-channel platform driver (the
  /// real native share pipeline) and the share_plus-wrapping send driver
  /// (the real outbound share surface). Pass a [BinaryMessenger] to route
  /// the channels over a custom messenger (tests, background isolates).
  factory ShareIntentService.platform({BinaryMessenger? binaryMessenger}) =>
      ShareIntentService(
        port: MethodChannelShareIntentPort(binaryMessenger: binaryMessenger),
        senderPort: SharePlusShareSenderPort(),
      );

  /// Returns the initially stored shared media for single time use on
  /// app boot.
  Future<SharedMedia?> getInitialSharedMedia() => port.getInitialSharedMedia();

  /// Records a sent message so the share menu can suggest
  /// recipients/conversations to share to.
  Future<void> recordSentMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
  }) {
    return port.recordSentMessage(
      conversationIdentifier: conversationIdentifier,
      conversationName: conversationName,
      conversationImageFilePath: conversationImageFilePath,
      serviceName: serviceName,
    );
  }

  /// Resets the initial shared media to null to prevent duplicate
  /// handling.
  Future<void> resetInitialSharedMedia() => port.resetInitialSharedMedia();

  /// Stream that can be listened to for shared media when the app is
  /// already running — the port's stream instance, re-exposed
  /// identically.
  Stream<SharedMedia> get sharedMediaStream => port.sharedMediaStream;

  /// Presents the native share surface for [text] — the outbound seam
  /// over the registered [ShareSenderPort]. Success says the surface was
  /// presented; failure is the one error path (the send contract
  /// resolves instead of throwing).
  Future<ShareSendResult> shareText({
    required String text,
    String? subject,
    Rect? anchor,
  }) {
    return senderPort.shareText(text: text, subject: subject, anchor: anchor);
  }

  /// Presents the native share surface for [files] — the outbound seam
  /// over the registered [ShareSenderPort], with the same one-error-path
  /// outcome as [shareText].
  Future<ShareSendResult> shareFiles({
    required List<String> files,
    String? subject,
    Map<String, String>? mimeHints,
    Rect? anchor,
  }) {
    return senderPort.shareFiles(
      files: files,
      subject: subject,
      mimeHints: mimeHints,
      anchor: anchor,
    );
  }
}

/// Registers the share-intent stack onto [getIt]: the method-channel
/// driver (the real native share pipeline) as the inbound
/// [ShareIntentPort], the share_plus-wrapping send driver (the real
/// outbound share surface) as the outbound [ShareSenderPort], and the
/// service bound to both — lazy singletons, so repeated resolution
/// yields the identical instances. Pure-Dart/test contexts that want the
/// [InMemoryShareIntentAdapter]/[InMemoryShareSenderAdapter] construct
/// [ShareIntentService] directly or register their own port bindings
/// first.
///
/// Pass [binaryMessenger] to route the underlying platform channels over a
/// custom messenger (tests, background isolates). Defaults to the default
/// messenger.
void registerShareIntentDependencies(
  GetIt getIt, {
  BinaryMessenger? binaryMessenger,
}) {
  getIt.registerLazySingleton<ShareIntentPort>(
    () => MethodChannelShareIntentPort(binaryMessenger: binaryMessenger),
  );
  getIt.registerLazySingleton<ShareSenderPort>(
    () => SharePlusShareSenderPort(),
  );
  getIt.registerLazySingleton<ShareIntentService>(
    () => ShareIntentService(
      port: getIt<ShareIntentPort>(),
      senderPort: getIt<ShareSenderPort>(),
    ),
  );
}
