import 'package:get_it/get_it.dart';

import 'data/intents/in_memory_share_intent_adapter.dart';
import 'domain/entities/shared_media/shared_media.dart';
import 'domain/intents/share_intent_port.dart';

export 'data/intents/in_memory_share_intent_adapter.dart';
export 'domain/intents/share_intent_port.dart';

/// The app-facing share-intent facade: the boot-time initial share, the
/// live share stream, and sent-message share-suggestion recording —
/// over the registered [ShareIntentPort].
///
/// ```dart
/// final intents = ShareIntentService();
/// final boot = await intents.getInitialSharedMedia();
/// if (boot != null) await intents.resetInitialSharedMedia();
/// intents.sharedMediaStream.listen(handleShare);
/// await intents.recordSentMessage(
///     conversationIdentifier: 'conv-9', conversationName: 'Mom');
/// ```
class ShareIntentService {
  /// The port this facade delegates to (the pure-Dart
  /// [InMemoryShareIntentAdapter] when none is injected).
  final ShareIntentPort port;

  ShareIntentService({ShareIntentPort? port})
      : port = port ?? InMemoryShareIntentAdapter();

  /// Returns the initially stored shared media for single time use on
  /// app boot.
  Future<SharedMedia?> getInitialSharedMedia() =>
      port.getInitialSharedMedia();

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
  Future<void> resetInitialSharedMedia() =>
      port.resetInitialSharedMedia();

  /// Stream that can be listened to for shared media when the app is
  /// already running — the port's stream instance, re-exposed
  /// identically.
  Stream<SharedMedia> get sharedMediaStream => port.sharedMediaStream;
}

/// Registers the share-intent stack onto [getIt]. The service is a lazy
/// singleton: repeated resolution yields the identical instance.
void registerShareIntentDependencies(GetIt getIt) {
  getIt.registerLazySingleton<ShareIntentService>(ShareIntentService.new);
}
