import 'dart:async';

import 'package:flutter/services.dart';

import '../../domain/entities/shared_media/shared_media.dart';
import '../../domain/intents/share_intent_port.dart';
import '../wire/share_intents_wire.dart';

/// The platform driver for [ShareIntentPort] — the method-channel
/// implementation that talks to the ported native plugins (Android/iOS/
/// macOS native; desktop stubs; web registration).
///
/// This is the real replacement for the source plugin's
/// `MethodChannelShareHandler`: the three Pigeon `BasicMessageChannel`s
/// with result/error/channel-error semantics, and the
/// `sharedMediaStream` [EventChannel] behind a lazy-singleton stream —
/// the `_sharedMediaStream ??=` contract, driver edition.
class MethodChannelShareIntentPort implements ShareIntentPort {
  MethodChannelShareIntentPort({this.binaryMessenger, this.isAppleLikeUriPath});

  /// The messenger the API channels ride (null → the default messenger).
  /// Scopes to the pigeon `BasicMessageChannel`s; the `EventChannel` always
  /// rides the default messenger in this Flutter SDK.
  final BinaryMessenger? binaryMessenger;

  /// Overrides the apple-like attachment-path predicate (tests, custom
  /// platform routing). Null → [defaultIsAppleLikeUriPath].
  final bool Function()? isAppleLikeUriPath;

  static const ShareIntentsApiCodec _codec = ShareIntentsApiCodec();

  /// The API is Pigeon-shaped: each operation owns a `BasicMessageChannel`
  /// whose replies are `{result: …}` / `{error: {code, message, details}}`
  /// envelopes; a null reply means the channel could not be established.
  Future<Map<Object?, Object?>?> _send(
    String channelName,
    Object? message,
  ) async {
    final channel = BasicMessageChannel<Object?>(
      channelName,
      _codec,
      binaryMessenger: binaryMessenger,
    );
    return await channel.send(message) as Map<Object?, Object?>?;
  }

  PlatformException _channelError() => PlatformException(
    code: 'channel-error',
    message: 'Unable to establish connection on channel.',
  );

  Never _throwWireError(Map<Object?, Object?> reply) {
    final error = reply['error']! as Map<Object?, Object?>;
    throw PlatformException(
      code: error['code']! as String,
      message: error['message'] as String?,
      details: error['details'],
    );
  }

  @override
  Future<SharedMedia?> getInitialSharedMedia() async {
    final reply = await _send(kGetInitialSharedMediaChannel, null);
    if (reply == null) throw _channelError();
    if (reply['error'] != null) _throwWireError(reply);
    final result = reply['result'];
    if (result == null) return null;
    if (result is SharedMedia) return result;
    return decodeSharedMedia(result, isAppleLikeUriPath: isAppleLikeUriPath);
  }

  @override
  Future<void> recordSentMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
  }) {
    // The spec-001 argument mapping into the wire carrier — the pigeon
    // native handlers cast argument 0, so the single-element entity
    // envelope is mandatory.
    final media = SharedMedia(
      conversationIdentifier: conversationIdentifier,
      speakableGroupName: conversationName,
      serviceName: serviceName,
      imageFilePath: conversationImageFilePath,
    );
    return _guard(() => _send(kRecordSentMessageChannel, <Object?>[media]));
  }

  @override
  Future<void> resetInitialSharedMedia() {
    return _guard(() => _send(kResetInitialSharedMediaChannel, null));
  }

  Future<void> _guard(Future<Map<Object?, Object?>?> Function() send) async {
    final reply = await send();
    if (reply == null) throw _channelError();
    if (reply['error'] != null) _throwWireError(reply);
  }

  Stream<SharedMedia>? _sharedMediaStream;

  @override
  Stream<SharedMedia> get sharedMediaStream {
    return _sharedMediaStream ??= EventChannel(kSharedMediaStreamChannel)
        .receiveBroadcastStream()
        .map<SharedMedia>(
          (event) =>
              decodeSharedMedia(event, isAppleLikeUriPath: isAppleLikeUriPath),
        );
  }
}
