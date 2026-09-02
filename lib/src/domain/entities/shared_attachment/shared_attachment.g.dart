// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedAttachment _$SharedAttachmentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SharedAttachment', json, ($checkedConvert) {
      final val = SharedAttachment(
        path: $checkedConvert('path', (v) => v as String),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$SharedAttachmentTypeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SharedAttachmentToJson(SharedAttachment instance) =>
    <String, dynamic>{
      'path': instance.path,
      'type': _$SharedAttachmentTypeEnumMap[instance.type]!,
    };

const _$SharedAttachmentTypeEnumMap = {
  SharedAttachmentType.image: 'image',
  SharedAttachmentType.video: 'video',
  SharedAttachmentType.audio: 'audio',
  SharedAttachmentType.file: 'file',
};
