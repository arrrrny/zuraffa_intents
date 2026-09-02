import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'data/intents/in_memory_share_intent_adapter.dart';
import 'domain/entities/shared_media/shared_media.dart';
import 'domain/intents/share_intent_port.dart';
import 'platform/method_channel/method_channel_share_intent_port.dart';

export 'data/intents/in_memory_share_intent_adapter.dart';
export 'domain/intents/share_intent_port.dart';
export 'platform/method_channel/method_channel_share_intent_port.dart';
export 'platform/wire/share_intents_wire.dart';

/// The app-facing share-intent facade: the boot-time initial share, the
/// live share stream, and sent-message share-suggestion recording —
/// over the registered [ShareIntentPort].
///
/// ```dart
/// final intents = ShareIntentService.platform();
/// final boot = await intents.getInitialSharedMedia();
/// if (boot != null) await intents.resetInitialSharedMedia();
/// intents.sharedMediaStream.listen(handleShare);
/// await intents.recordSentMessage(
///     conversationIdentifier: 'conv-9', conversationName: 'Mom');
/// ```
class ShareIntentService {
  /// The port this facade delegates to (the
  /// [MethodChannelShareIntentPort] platform driver under [ShareIntentService.platform],
  /// the pure-Dart [InMemoryShareIntentAdapter] when constructed directly —
  /// the test/dev default).
  final ShareIntentPort port;

  ShareIntentService({ShareIntentPort? port})
    : port = port ?? InMemoryShareIntentAdapter();

  /// The plugin constructor: binds the method-channel platform driver (the
  /// real native share pipeline). Pass a [BinaryMessenger] to route the
  /// channels over a custom messenger (tests, background isolates).
  factory ShareIntentService.platform({BinaryMessenger? binaryMessenger}) =>
      ShareIntentService(
        port: MethodChannelShareIntentPort(binaryMessenger: binaryMessenger),
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
}

/// Registers the share-intent stack onto [getIt]. The platform driver is
/// the default port (the real native share pipeline); the service is bound
/// to that port, and both are lazy singletons: repeated resolution yields
/// the identical instances. Pure-Dart/test contexts that want the
/// [InMemoryShareIntentAdapter] construct [ShareIntentService] directly or
/// register their own [ShareIntentPort] binding first.
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
  getIt.registerLazySingleton<ShareIntentService>(
    () => ShareIntentService(port: getIt<ShareIntentPort>()),
  );
}
