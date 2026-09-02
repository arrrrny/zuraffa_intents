// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedMedia _$SharedMediaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SharedMedia', json, ($checkedConvert) {
      final val = SharedMedia(
        attachments: $checkedConvert(
          'attachments',
          (v) => (v as List<dynamic>?)
              ?.map((e) => SharedAttachment.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        recipientIdentifiers: $checkedConvert(
          'recipientIdentifiers',
          (v) => (v as List<dynamic>?)?.map((e) => e as String?).toList(),
        ),
        conversationIdentifier: $checkedConvert(
          'conversationIdentifier',
          (v) => v as String?,
        ),
        content: $checkedConvert('content', (v) => v as String?),
        speakableGroupName: $checkedConvert(
          'speakableGroupName',
          (v) => v as String?,
        ),
        serviceName: $checkedConvert('serviceName', (v) => v as String?),
        senderIdentifier: $checkedConvert(
          'senderIdentifier',
          (v) => v as String?,
        ),
        imageFilePath: $checkedConvert('imageFilePath', (v) => v as String?),
        subject: $checkedConvert('subject', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SharedMediaToJson(SharedMedia instance) =>
    <String, dynamic>{
      'attachments': ?instance.attachments?.map((e) => e.toJson()).toList(),
      'recipientIdentifiers': ?instance.recipientIdentifiers,
      'conversationIdentifier': ?instance.conversationIdentifier,
      'content': ?instance.content,
      'speakableGroupName': ?instance.speakableGroupName,
      'serviceName': ?instance.serviceName,
      'senderIdentifier': ?instance.senderIdentifier,
      'imageFilePath': ?instance.imageFilePath,
      'subject': ?instance.subject,
    };
