import 'dart:async';

import '../../domain/entities/shared_media/shared_media.dart';
import '../../domain/intents/share_intent_port.dart';

/// The pure-Dart [ShareIntentPort] — the test/dev stand-in for the
/// native plugin side.
///
/// The adapter plays the producer role the platform plays on a device:
/// [storeInitial] seeds the boot-time share, [emit] pushes a live share
/// onto the broadcast stream, and [sentMessageRecords] exposes what the
/// app recorded through [recordSentMessage] so tests can pin the
/// argument mapping.
class InMemoryShareIntentAdapter implements ShareIntentPort {
  /// The boot-time share, served until explicitly reset.
  SharedMedia? _initialSharedMedia;

  /// One record per recordSentMessage call, in call order.
  final List<SharedMedia> _sentMessageRecords = [];

  final StreamController<SharedMedia> _controller =
      StreamController<SharedMedia>.broadcast();

  /// The lazily-created singleton stream — repeated access yields the
  /// identical instance (the plugin's `_sharedMediaStream ??=`
  /// contract).
  late final Stream<SharedMedia> _sharedMediaStream = _controller.stream;

  /// Seeds (or clears, with null) the boot-time share.
  void storeInitial(SharedMedia? media) {
    _initialSharedMedia = media;
  }

  /// Pushes a live share event to every current stream listener.
  void emit(SharedMedia media) {
    _controller.add(media);
  }

  /// Everything recorded through [recordSentMessage], in call order.
  List<SharedMedia> get sentMessageRecords =>
      List.unmodifiable(_sentMessageRecords);

  @override
  Future<SharedMedia?> getInitialSharedMedia() async => _initialSharedMedia;

  @override
  Future<void> recordSentMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
  }) async {
    _sentMessageRecords.add(
      SharedMedia(
        conversationIdentifier: conversationIdentifier,
        speakableGroupName: conversationName,
        serviceName: serviceName,
        imageFilePath: conversationImageFilePath,
      ),
    );
  }

  @override
  Future<void> resetInitialSharedMedia() async {
    _initialSharedMedia = null;
  }

  @override
  Stream<SharedMedia> get sharedMediaStream => _sharedMediaStream;
}
