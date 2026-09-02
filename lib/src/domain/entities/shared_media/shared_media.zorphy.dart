// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'shared_media.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class SharedMedia {
  SharedMedia({
    List<SharedAttachment>? this.attachments,
    List<String?>? this.recipientIdentifiers,
    String? this.conversationIdentifier,
    String? this.content,
    String? this.speakableGroupName,
    String? this.serviceName,
    String? this.senderIdentifier,
    String? this.imageFilePath,
    String? this.subject,
  });

  factory SharedMedia.fromJson(Map<String, dynamic> json) =>
      _$SharedMediaFromJson(json);

  final List<SharedAttachment>? attachments;

  final List<String?>? recipientIdentifiers;

  final String? conversationIdentifier;

  final String? content;

  final String? speakableGroupName;

  final String? serviceName;

  final String? senderIdentifier;

  final String? imageFilePath;

  final String? subject;

  SharedMedia copyWith({
    List<SharedAttachment>? attachments,
    List<String?>? recipientIdentifiers,
    String? conversationIdentifier,
    String? content,
    String? speakableGroupName,
    String? serviceName,
    String? senderIdentifier,
    String? imageFilePath,
    String? subject,
  }) {
    return SharedMedia(
      attachments: attachments ?? this.attachments,
      recipientIdentifiers: recipientIdentifiers ?? this.recipientIdentifiers,
      conversationIdentifier:
          conversationIdentifier ?? this.conversationIdentifier,
      content: content ?? this.content,
      speakableGroupName: speakableGroupName ?? this.speakableGroupName,
      serviceName: serviceName ?? this.serviceName,
      senderIdentifier: senderIdentifier ?? this.senderIdentifier,
      imageFilePath: imageFilePath ?? this.imageFilePath,
      subject: subject ?? this.subject,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  SharedMedia copyWithField<T>(Field<SharedMedia, T> field, T value) {
    switch (field.name) {
      case 'attachments':
        return copyWith(attachments: value as List<SharedAttachment>?);
      case 'recipientIdentifiers':
        return copyWith(recipientIdentifiers: value as List<String?>?);
      case 'conversationIdentifier':
        return copyWith(conversationIdentifier: value as String?);
      case 'content':
        return copyWith(content: value as String?);
      case 'speakableGroupName':
        return copyWith(speakableGroupName: value as String?);
      case 'serviceName':
        return copyWith(serviceName: value as String?);
      case 'senderIdentifier':
        return copyWith(senderIdentifier: value as String?);
      case 'imageFilePath':
        return copyWith(imageFilePath: value as String?);
      case 'subject':
        return copyWith(subject: value as String?);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'SharedMedia has no settable field with this name',
        );
    }
  }

  SharedMedia copyWithSharedMedia({
    List<SharedAttachment>? attachments,
    List<String?>? recipientIdentifiers,
    String? conversationIdentifier,
    String? content,
    String? speakableGroupName,
    String? serviceName,
    String? senderIdentifier,
    String? imageFilePath,
    String? subject,
  }) {
    return copyWith(
      attachments: attachments,
      recipientIdentifiers: recipientIdentifiers,
      conversationIdentifier: conversationIdentifier,
      content: content,
      speakableGroupName: speakableGroupName,
      serviceName: serviceName,
      senderIdentifier: senderIdentifier,
      imageFilePath: imageFilePath,
      subject: subject,
    );
  }

  SharedMedia patchWithSharedMedia([SharedMediaPatch? patchInput]) {
    final _patcher = patchInput ?? SharedMediaPatch();
    final _patchMap = _patcher.patchMap;
    return SharedMedia(
      attachments: _patchMap.containsKey(SharedMedia$.attachments)
          ? ((_patchMap[SharedMedia$.attachments] is Function)
                    ? _patchMap[SharedMedia$.attachments](this.attachments)
                    : (_patchMap[SharedMedia$.attachments] is Patch)
                    ? _patchMap[SharedMedia$.attachments].applyTo(
                        this.attachments,
                      )
                    : _patchMap[SharedMedia$.attachments])
                as List<SharedAttachment>?
          : this.attachments,
      recipientIdentifiers:
          _patchMap.containsKey(SharedMedia$.recipientIdentifiers)
          ? ((_patchMap[SharedMedia$.recipientIdentifiers] is Function)
                    ? _patchMap[SharedMedia$.recipientIdentifiers](
                        this.recipientIdentifiers,
                      )
                    : (_patchMap[SharedMedia$.recipientIdentifiers] is Patch)
                    ? _patchMap[SharedMedia$.recipientIdentifiers].applyTo(
                        this.recipientIdentifiers,
                      )
                    : _patchMap[SharedMedia$.recipientIdentifiers])
                as List<String?>?
          : this.recipientIdentifiers,
      conversationIdentifier:
          _patchMap.containsKey(SharedMedia$.conversationIdentifier)
          ? ((_patchMap[SharedMedia$.conversationIdentifier] is Function)
                    ? _patchMap[SharedMedia$.conversationIdentifier](
                        this.conversationIdentifier,
                      )
                    : (_patchMap[SharedMedia$.conversationIdentifier] is Patch)
                    ? _patchMap[SharedMedia$.conversationIdentifier].applyTo(
                        this.conversationIdentifier,
                      )
                    : _patchMap[SharedMedia$.conversationIdentifier])
                as String?
          : this.conversationIdentifier,
      content: _patchMap.containsKey(SharedMedia$.content)
          ? ((_patchMap[SharedMedia$.content] is Function)
                    ? _patchMap[SharedMedia$.content](this.content)
                    : (_patchMap[SharedMedia$.content] is Patch)
                    ? _patchMap[SharedMedia$.content].applyTo(this.content)
                    : _patchMap[SharedMedia$.content])
                as String?
          : this.content,
      speakableGroupName: _patchMap.containsKey(SharedMedia$.speakableGroupName)
          ? ((_patchMap[SharedMedia$.speakableGroupName] is Function)
                    ? _patchMap[SharedMedia$.speakableGroupName](
                        this.speakableGroupName,
                      )
                    : (_patchMap[SharedMedia$.speakableGroupName] is Patch)
                    ? _patchMap[SharedMedia$.speakableGroupName].applyTo(
                        this.speakableGroupName,
                      )
                    : _patchMap[SharedMedia$.speakableGroupName])
                as String?
          : this.speakableGroupName,
      serviceName: _patchMap.containsKey(SharedMedia$.serviceName)
          ? ((_patchMap[SharedMedia$.serviceName] is Function)
                    ? _patchMap[SharedMedia$.serviceName](this.serviceName)
                    : (_patchMap[SharedMedia$.serviceName] is Patch)
                    ? _patchMap[SharedMedia$.serviceName].applyTo(
                        this.serviceName,
                      )
                    : _patchMap[SharedMedia$.serviceName])
                as String?
          : this.serviceName,
      senderIdentifier: _patchMap.containsKey(SharedMedia$.senderIdentifier)
          ? ((_patchMap[SharedMedia$.senderIdentifier] is Function)
                    ? _patchMap[SharedMedia$.senderIdentifier](
                        this.senderIdentifier,
                      )
                    : (_patchMap[SharedMedia$.senderIdentifier] is Patch)
                    ? _patchMap[SharedMedia$.senderIdentifier].applyTo(
                        this.senderIdentifier,
                      )
                    : _patchMap[SharedMedia$.senderIdentifier])
                as String?
          : this.senderIdentifier,
      imageFilePath: _patchMap.containsKey(SharedMedia$.imageFilePath)
          ? ((_patchMap[SharedMedia$.imageFilePath] is Function)
                    ? _patchMap[SharedMedia$.imageFilePath](this.imageFilePath)
                    : (_patchMap[SharedMedia$.imageFilePath] is Patch)
                    ? _patchMap[SharedMedia$.imageFilePath].applyTo(
                        this.imageFilePath,
                      )
                    : _patchMap[SharedMedia$.imageFilePath])
                as String?
          : this.imageFilePath,
      subject: _patchMap.containsKey(SharedMedia$.subject)
          ? ((_patchMap[SharedMedia$.subject] is Function)
                    ? _patchMap[SharedMedia$.subject](this.subject)
                    : (_patchMap[SharedMedia$.subject] is Patch)
                    ? _patchMap[SharedMedia$.subject].applyTo(this.subject)
                    : _patchMap[SharedMedia$.subject])
                as String?
          : this.subject,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedMedia &&
        attachments == other.attachments &&
        recipientIdentifiers == other.recipientIdentifiers &&
        conversationIdentifier == other.conversationIdentifier &&
        content == other.content &&
        speakableGroupName == other.speakableGroupName &&
        serviceName == other.serviceName &&
        senderIdentifier == other.senderIdentifier &&
        imageFilePath == other.imageFilePath &&
        subject == other.subject;
  }

  @override
  int get hashCode {
    return Object.hash(
      this.attachments,
      this.recipientIdentifiers,
      this.conversationIdentifier,
      this.content,
      this.speakableGroupName,
      this.serviceName,
      this.senderIdentifier,
      this.imageFilePath,
      this.subject,
    );
  }

  @override
  String toString() {
    return 'SharedMedia(' +
        'attachments: ${attachments}' +
        ', ' +
        'recipientIdentifiers: ${recipientIdentifiers}' +
        ', ' +
        'conversationIdentifier: ${conversationIdentifier}' +
        ', ' +
        'content: ${content}' +
        ', ' +
        'speakableGroupName: ${speakableGroupName}' +
        ', ' +
        'serviceName: ${serviceName}' +
        ', ' +
        'senderIdentifier: ${senderIdentifier}' +
        ', ' +
        'imageFilePath: ${imageFilePath}' +
        ', ' +
        'subject: ${subject})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$SharedMediaToJson(this);
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

extension SharedMediaPropertyHelpers on SharedMedia {
  List<SharedAttachment> get attachmentsRequired {
    return this.attachments ??
        (throw StateError('attachments is required but was null'));
  }

  bool get hasAttachments {
    return this.attachments?.isNotEmpty ?? false;
  }

  bool get noAttachments {
    return this.attachments?.isEmpty ?? true;
  }

  List<String?> get recipientIdentifiersRequired {
    return this.recipientIdentifiers ??
        (throw StateError('recipientIdentifiers is required but was null'));
  }

  bool get hasRecipientIdentifiers {
    return this.recipientIdentifiers?.isNotEmpty ?? false;
  }

  bool get noRecipientIdentifiers {
    return this.recipientIdentifiers?.isEmpty ?? true;
  }

  bool get hasConversationIdentifier {
    return this.conversationIdentifier?.isNotEmpty == true;
  }

  bool get noConversationIdentifier {
    return this.conversationIdentifier?.isEmpty ?? true;
  }

  String get conversationIdentifierRequired {
    return this.conversationIdentifier ??
        (throw StateError('conversationIdentifier is required but was null'));
  }

  bool get hasContent {
    return this.content?.isNotEmpty == true;
  }

  bool get noContent {
    return this.content?.isEmpty ?? true;
  }

  String get contentRequired {
    return this.content ??
        (throw StateError('content is required but was null'));
  }

  bool get hasSpeakableGroupName {
    return this.speakableGroupName?.isNotEmpty == true;
  }

  bool get noSpeakableGroupName {
    return this.speakableGroupName?.isEmpty ?? true;
  }

  String get speakableGroupNameRequired {
    return this.speakableGroupName ??
        (throw StateError('speakableGroupName is required but was null'));
  }

  bool get hasServiceName {
    return this.serviceName?.isNotEmpty == true;
  }

  bool get noServiceName {
    return this.serviceName?.isEmpty ?? true;
  }

  String get serviceNameRequired {
    return this.serviceName ??
        (throw StateError('serviceName is required but was null'));
  }

  bool get hasSenderIdentifier {
    return this.senderIdentifier?.isNotEmpty == true;
  }

  bool get noSenderIdentifier {
    return this.senderIdentifier?.isEmpty ?? true;
  }

  String get senderIdentifierRequired {
    return this.senderIdentifier ??
        (throw StateError('senderIdentifier is required but was null'));
  }

  bool get hasImageFilePath {
    return this.imageFilePath?.isNotEmpty == true;
  }

  bool get noImageFilePath {
    return this.imageFilePath?.isEmpty ?? true;
  }

  String get imageFilePathRequired {
    return this.imageFilePath ??
        (throw StateError('imageFilePath is required but was null'));
  }

  bool get hasSubject {
    return this.subject?.isNotEmpty == true;
  }

  bool get noSubject {
    return this.subject?.isEmpty ?? true;
  }

  String get subjectRequired {
    return this.subject ??
        (throw StateError('subject is required but was null'));
  }
}

extension SharedMediaSerialization on SharedMedia {
  Map<String, dynamic> toJson() {
    return _$SharedMediaToJson(this);
  }
}

enum SharedMedia$ {
  attachments,
  recipientIdentifiers,
  conversationIdentifier,
  content,
  speakableGroupName,
  serviceName,
  senderIdentifier,
  imageFilePath,
  subject,
}

class SharedMediaPatch extends PatchBase<SharedMedia, SharedMedia$> {
  SharedMedia applyTo(SharedMedia entity) {
    return entity.patchWithSharedMedia(this);
  }

  SharedMediaPatch withAttachments(List<SharedAttachment>? value) {
    patchMap[SharedMedia$.attachments] = value;
    return this;
  }

  SharedMediaPatch updateAttachmentsAt(
    int index,
    SharedAttachmentPatch Function(SharedAttachmentPatch) patch,
  ) {
    patchMap[SharedMedia$.attachments] = (List<dynamic> list) {
      var updatedList = List<SharedAttachment>.from(list);
      if (index >= 0 && index < updatedList.length) {
        updatedList[index] = patch(SharedAttachmentPatch())
            .applyTo(updatedList[index] as SharedAttachment);
      }
      return updatedList;
    };
    return this;
  }

  SharedMediaPatch withRecipientIdentifiers(List<String?>? value) {
    patchMap[SharedMedia$.recipientIdentifiers] = value;
    return this;
  }

  SharedMediaPatch withConversationIdentifier(String? value) {
    patchMap[SharedMedia$.conversationIdentifier] = value;
    return this;
  }

  SharedMediaPatch withContent(String? value) {
    patchMap[SharedMedia$.content] = value;
    return this;
  }

  SharedMediaPatch withSpeakableGroupName(String? value) {
    patchMap[SharedMedia$.speakableGroupName] = value;
    return this;
  }

  SharedMediaPatch withServiceName(String? value) {
    patchMap[SharedMedia$.serviceName] = value;
    return this;
  }

  SharedMediaPatch withSenderIdentifier(String? value) {
    patchMap[SharedMedia$.senderIdentifier] = value;
    return this;
  }

  SharedMediaPatch withImageFilePath(String? value) {
    patchMap[SharedMedia$.imageFilePath] = value;
    return this;
  }

  SharedMediaPatch withSubject(String? value) {
    patchMap[SharedMedia$.subject] = value;
    return this;
  }
}

/// Field descriptors for [SharedMedia] query construction
abstract final class SharedMediaFields {
  static const attachments = Field<SharedMedia, List<SharedAttachment>?>(
    'attachments',
    _$attachments,
  );

  static const recipientIdentifiers = Field<SharedMedia, List<String?>?>(
    'recipientIdentifiers',
    _$recipientIdentifiers,
  );

  static const conversationIdentifier = Field<SharedMedia, String?>(
    'conversationIdentifier',
    _$conversationIdentifier,
  );

  static const content = Field<SharedMedia, String?>('content', _$content);

  static const speakableGroupName = Field<SharedMedia, String?>(
    'speakableGroupName',
    _$speakableGroupName,
  );

  static const serviceName = Field<SharedMedia, String?>(
    'serviceName',
    _$serviceName,
  );

  static const senderIdentifier = Field<SharedMedia, String?>(
    'senderIdentifier',
    _$senderIdentifier,
  );

  static const imageFilePath = Field<SharedMedia, String?>(
    'imageFilePath',
    _$imageFilePath,
  );

  static const subject = Field<SharedMedia, String?>('subject', _$subject);

  static List<SharedAttachment>? _$attachments(SharedMedia e) {
    return e.attachments;
  }

  static List<String?>? _$recipientIdentifiers(SharedMedia e) {
    return e.recipientIdentifiers;
  }

  static String? _$conversationIdentifier(SharedMedia e) {
    return e.conversationIdentifier;
  }

  static String? _$content(SharedMedia e) {
    return e.content;
  }

  static String? _$speakableGroupName(SharedMedia e) {
    return e.speakableGroupName;
  }

  static String? _$serviceName(SharedMedia e) {
    return e.serviceName;
  }

  static String? _$senderIdentifier(SharedMedia e) {
    return e.senderIdentifier;
  }

  static String? _$imageFilePath(SharedMedia e) {
    return e.imageFilePath;
  }

  static String? _$subject(SharedMedia e) {
    return e.subject;
  }
}

extension SharedMediaCompareE on SharedMedia {
  Map<String, dynamic> compareToSharedMedia(SharedMedia other) {
    final Map<String, dynamic> diff = {};

    if (attachments != other.attachments) {
      diff['attachments'] = () => other.attachments;
    }

    if (recipientIdentifiers != other.recipientIdentifiers) {
      diff['recipientIdentifiers'] = () => other.recipientIdentifiers;
    }

    if (conversationIdentifier != other.conversationIdentifier) {
      diff['conversationIdentifier'] = () => other.conversationIdentifier;
    }

    if (content != other.content) {
      diff['content'] = () => other.content;
    }

    if (speakableGroupName != other.speakableGroupName) {
      diff['speakableGroupName'] = () => other.speakableGroupName;
    }

    if (serviceName != other.serviceName) {
      diff['serviceName'] = () => other.serviceName;
    }

    if (senderIdentifier != other.senderIdentifier) {
      diff['senderIdentifier'] = () => other.senderIdentifier;
    }

    if (imageFilePath != other.imageFilePath) {
      diff['imageFilePath'] = () => other.imageFilePath;
    }

    if (subject != other.subject) {
      diff['subject'] = () => other.subject;
    }
    return diff;
  }
}
