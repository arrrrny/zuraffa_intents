// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'shared_attachment.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class SharedAttachment {
  SharedAttachment({
    required String this.path,
    required SharedAttachmentType this.type,
  });

  factory SharedAttachment.fromJson(Map<String, dynamic> json) =>
      _$SharedAttachmentFromJson(json);

  final String path;

  final SharedAttachmentType type;

  SharedAttachment copyWith({String? path, SharedAttachmentType? type}) {
    return SharedAttachment(path: path ?? this.path, type: type ?? this.type);
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  SharedAttachment copyWithField<T>(Field<SharedAttachment, T> field, T value) {
    switch (field.name) {
      case 'path':
        return copyWith(path: value as String);
      case 'type':
        return copyWith(type: value as SharedAttachmentType);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'SharedAttachment has no settable field with this name',
        );
    }
  }

  SharedAttachment copyWithSharedAttachment({
    String? path,
    SharedAttachmentType? type,
  }) {
    return copyWith(path: path, type: type);
  }

  SharedAttachment patchWithSharedAttachment([
    SharedAttachmentPatch? patchInput,
  ]) {
    final _patcher = patchInput ?? SharedAttachmentPatch();
    final _patchMap = _patcher.patchMap;
    return SharedAttachment(
      path: _patchMap.containsKey(SharedAttachment$.path)
          ? ((_patchMap[SharedAttachment$.path] is Function)
                    ? _patchMap[SharedAttachment$.path](this.path)
                    : (_patchMap[SharedAttachment$.path] is Patch)
                    ? _patchMap[SharedAttachment$.path].applyTo(this.path)
                    : _patchMap[SharedAttachment$.path])
                as String
          : this.path,
      type: _patchMap.containsKey(SharedAttachment$.type)
          ? ((_patchMap[SharedAttachment$.type] is Function)
                    ? _patchMap[SharedAttachment$.type](this.type)
                    : (_patchMap[SharedAttachment$.type] is Patch)
                    ? _patchMap[SharedAttachment$.type].applyTo(this.type)
                    : _patchMap[SharedAttachment$.type])
                as SharedAttachmentType
          : this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedAttachment &&
        path == other.path &&
        type == other.type;
  }

  @override
  int get hashCode {
    return Object.hash(this.path, this.type);
  }

  @override
  String toString() {
    return 'SharedAttachment(' + 'path: ${path}' + ', ' + 'type: ${type})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$SharedAttachmentToJson(this);
    _sanitizeJson(data);
    return data;
  }

  dynamic _sanitizeJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      json.remove('__typename');
      return json..forEach((key, value) {
        json[key] = _sanitizeJson(value);
      });
    } else if (json is List) {
      return json.map((e) => _sanitizeJson(e)).toList();
    }
    return json;
  }
}

extension SharedAttachmentPropertyHelpers on SharedAttachment {
  bool get hasPath {
    return this.path.isNotEmpty;
  }

  bool get noPath {
    return this.path.isEmpty;
  }

  bool get isTypeImage {
    return this.type == SharedAttachmentType.image;
  }

  bool get isTypeVideo {
    return this.type == SharedAttachmentType.video;
  }

  bool get isTypeAudio {
    return this.type == SharedAttachmentType.audio;
  }

  bool get isTypeFile {
    return this.type == SharedAttachmentType.file;
  }
}

extension SharedAttachmentSerialization on SharedAttachment {
  Map<String, dynamic> toJson() {
    return _$SharedAttachmentToJson(this);
  }
}

enum SharedAttachment$ { path, type }

class SharedAttachmentPatch
    extends PatchBase<SharedAttachment, SharedAttachment$> {
  SharedAttachment applyTo(SharedAttachment entity) {
    return entity.patchWithSharedAttachment(this);
  }

  SharedAttachmentPatch withPath(String? value) {
    patchMap[SharedAttachment$.path] = value;
    return this;
  }

  SharedAttachmentPatch withType(SharedAttachmentType? value) {
    patchMap[SharedAttachment$.type] = value;
    return this;
  }
}

/// Field descriptors for [SharedAttachment] query construction
abstract final class SharedAttachmentFields {
  static const path = Field<SharedAttachment, String>('path', _$path);

  static const type = Field<SharedAttachment, SharedAttachmentType>(
    'type',
    _$type,
  );

  static String _$path(SharedAttachment e) {
    return e.path;
  }

  static SharedAttachmentType _$type(SharedAttachment e) {
    return e.type;
  }
}

extension SharedAttachmentCompareE on SharedAttachment {
  Map<String, dynamic> compareToSharedAttachment(SharedAttachment other) {
    final Map<String, dynamic> diff = {};

    if (path != other.path) {
      diff['path'] = () => other.path;
    }

    if (type != other.type) {
      diff['type'] = () => other.type;
    }
    return diff;
  }
}
