import '../entities/shared_media/shared_media.dart';

/// The incoming-share seam: one interface between the app and whatever
/// delivers share intents (the native plugin side on a device, the
/// pure-Dart [InMemoryShareIntentAdapter] in tests and dev).
///
/// The datasource pattern applied to share receiving — apps consume
/// [SharedMedia] through this contract and stay oblivious to how the
/// platform hands the data over (spec 001: reimplements the
/// `zikzak_share_handler` plugin contract).
abstract class ShareIntentPort {
  /// Returns the initially stored shared media for single time use on
  /// app boot. Use [sharedMediaStream] to receive shares while the app
  /// is active. Reads are repeatable until [resetInitialSharedMedia]
  /// clears the store — the explicit anti-duplicate-handling reset the
  /// plugin API provides.
  Future<SharedMedia?> getInitialSharedMedia();

  /// Records a sent message so the share menu can suggest
  /// recipients/conversations to share to. The plugin's argument
  /// mapping is preserved: [conversationName] surfaces on the wire
  /// carrier as `speakableGroupName`, [conversationImageFilePath] as
  /// `imageFilePath`.
  Future<void> recordSentMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
  });

  /// Resets the initial shared media to null to prevent duplicate
  /// handling. Idempotent.
  Future<void> resetInitialSharedMedia();

  /// Stream that can be listened to for shared media when the app is
  /// already running. Broadcast: every listener receives every share
  /// emitted after it subscribed; pre-subscription events are not
  /// replayed.
  Stream<SharedMedia> get sharedMediaStream;
}
