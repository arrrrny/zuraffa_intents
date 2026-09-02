import 'package:zorphy_annotation/zorphy_annotation.dart';

import '../shared_attachment/shared_attachment.dart';

part 'shared_media.zorphy.dart';
part 'shared_media.g.dart';

/// Shared media entity — everything the platform share sheet handed to
/// the app: the boot-time initial share and every live share event.
@Zorphy(generateJson: true)
abstract class $SharedMedia {
  /// Shared attachments (images, videos, pdfs…), each with a type and a
  /// device path.
  List<SharedAttachment>? get attachments;

  /// iOS only: recipient identifiers from the share intent (nullable
  /// elements are part of the wire shape).
  List<String?>? get recipientIdentifiers;

  /// The identifier of the conversation the content was shared to
  /// (populated when the user picks a suggestion recorded via
  /// recordSentMessage).
  String? get conversationIdentifier;

  /// Text content that was shared, if any (a URL counts).
  String? get content;

  /// The name of the recipient the content was shared to, if specified.
  String? get speakableGroupName;

  /// iOS only: the name of the service that sent the content.
  String? get serviceName;

  /// iOS only: the identifier of the sender that shared the content.
  String? get senderIdentifier;

  /// iOS only: the file path for the image of the sender.
  String? get imageFilePath;

  /// The subject of the shared content.
  String? get subject;
}
