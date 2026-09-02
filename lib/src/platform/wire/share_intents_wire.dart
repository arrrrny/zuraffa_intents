/// The wire contract of the zuraffa_intents platform interface — the
/// channel names, the Pigeon-shaped wire maps, and the type-tagged codec —
/// shared by the method-channel driver and pinned against the ported
/// native implementations by the spec-002 consistency suite (U38..U40).
///
/// Wire identifiers are single-sourced here on purpose: the natives carry
/// the same literals, and drift is a failing test, not a code review.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/enums/shared_attachment_type.dart';
import '../../domain/entities/shared_attachment/shared_attachment.dart';
import '../../domain/entities/shared_media/shared_media.dart';

/// The broadcast event channel the native plugins push incoming shares on
/// (`EventSink.success(media.toMap())` in the Kotlin/Swift plugins).
const String kSharedMediaStreamChannel =
    'dev.zuraffa.zuraffa_intents/sharedMediaStream';

/// The Pigeon `BasicMessageChannel` names — derived from the
/// `ZuraffaIntentsApi` pigeon interface the native sides implement.
const String kGetInitialSharedMediaChannel =
    'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia';
const String kRecordSentMessageChannel =
    'dev.flutter.pigeon.ZuraffaIntentsApi.recordSentMessage';
const String kResetInitialSharedMediaChannel =
    'dev.flutter.pigeon.ZuraffaIntentsApi.resetInitialSharedMedia';

/// The type tags the pigeon-generated codec registers: 128 for
/// `SharedAttachment`, 129/130 for `SharedMedia` (the generated sources
/// register the same payload type under two tags; both are accepted for
/// wire compatibility).
const int kSharedAttachmentTag = 128;
const int kSharedMediaTag = 129;
const int kSharedMediaLegacyTag = 130;

/// The default apple-like predicate: attachment paths coming from the iOS
/// or macOS plugin are percent-encoded and must be run through
/// `Uri.decodeFull`. `kIsWeb` short-circuits BEFORE `dart:io` is touched —
/// `Platform` throws on web, so evaluation order is load-bearing (the
/// hand-rolled source this plugin replaces got this backwards and crashed
/// on web).
bool defaultIsAppleLikeUriPath() =>
    !kIsWeb && (Platform.isIOS || Platform.isMacOS);

/// `SharedAttachment` → the Pigeon wire map: `{path, type: <index>}` — the
/// attachment type rides the wire as the declaration-order index (the
/// plugin's vocabulary; reordering the enum is a breaking change).
Map<Object?, Object?> sharedAttachmentWireMap(SharedAttachment attachment) =>
    <Object?, Object?>{
      'path': attachment.path,
      'type': attachment.type.index,
    };

/// `SharedMedia` → the Pigeon wire map. All nine keys are ALWAYS present,
/// `null`s preserved: the native sides read by key
/// (`toMap()`/`fromMap()` on Kotlin/Java/Swift), so omitted keys and null
/// keys must not be distinguishable on the wire. Attachments serialize as
/// wire maps — the exact shape the native `SharedMedia.toMap()` emits.
Map<Object?, Object?> sharedMediaWireMap(SharedMedia media) =>
    <Object?, Object?>{
      'attachments':
          media.attachments?.map<Object?>(sharedAttachmentWireMap).toList(),
      'recipientIdentifiers': media.recipientIdentifiers?.toList(),
      'conversationIdentifier': media.conversationIdentifier,
      'content': media.content,
      'speakableGroupName': media.speakableGroupName,
      'serviceName': media.serviceName,
      'senderIdentifier': media.senderIdentifier,
      'imageFilePath': media.imageFilePath,
      'subject': media.subject,
    };

/// Decodes a native wire value (the map shape from
/// [sharedMediaWireMap]/`SharedMedia.toMap()`) into the zorphy entity,
/// running attachment paths through `Uri.decodeFull` when
/// [isAppleLikeUriPath] holds (defaults to [defaultIsAppleLikeUriPath]).
SharedMedia decodeSharedMedia(
  Object? message, {
  bool Function()? isAppleLikeUriPath,
}) {
  final appleLike = isAppleLikeUriPath ?? defaultIsAppleLikeUriPath;
  final map = message as Map<dynamic, dynamic>;
  return SharedMedia(
    attachments: (map['attachments'] as List<Object?>?)
        ?.map((e) => _decodeAttachment(e!, appleLike))
        .toList(),
    recipientIdentifiers:
        (map['recipientIdentifiers'] as List<Object?>?)?.cast<String?>(),
    conversationIdentifier: map['conversationIdentifier'] as String?,
    content: map['content'] as String?,
    speakableGroupName: map['speakableGroupName'] as String?,
    serviceName: map['serviceName'] as String?,
    senderIdentifier: map['senderIdentifier'] as String?,
    imageFilePath: map['imageFilePath'] as String?,
    subject: map['subject'] as String?,
  );
}

SharedAttachment _decodeAttachment(Object message, bool Function() appleLike) {
  final map = message as Map<Object?, Object?>;
  final path = map['path']! as String;
  return SharedAttachment(
    path: appleLike() ? Uri.decodeFull(path) : path,
    type: SharedAttachmentType.values[map['type']! as int],
  );
}

/// The Pigeon codec for the `ZuraffaIntentsApi` channels: a
/// [StandardMessageCodec] that carries the entities under their type tags.
/// Outgoing `SharedMedia` values are wrapped as tag-[kSharedMediaTag]
/// envelopes around [sharedMediaWireMap] (the pigeon native handlers cast
/// argument 0 to the generated `SharedMedia` class, so the envelope is
/// mandatory); incoming tag-[kSharedAttachmentTag]/[kSharedMediaTag]/
/// [kSharedMediaLegacyTag] values decode back into the zorphy entities
/// under the default apple-like predicate.
class ShareIntentsApiCodec extends StandardMessageCodec {
  const ShareIntentsApiCodec();

  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is SharedMedia) {
      buffer.putUint8(kSharedMediaTag);
      writeValue(buffer, sharedMediaWireMap(value));
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case kSharedAttachmentTag:
        return _decodeAttachment(
            readValue(buffer)!, defaultIsAppleLikeUriPath);
      case kSharedMediaTag:
      case kSharedMediaLegacyTag:
        return decodeSharedMedia(readValue(buffer));
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}
