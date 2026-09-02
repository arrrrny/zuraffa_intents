import 'package:zorphy_annotation/zorphy_annotation.dart';

import '../enums/index.dart';

part 'shared_attachment.zorphy.dart';
part 'shared_attachment.g.dart';

/// Shared attachment entity — one file carried inside a shared payload.
@Zorphy(generateJson: true)
abstract class $SharedAttachment {
  /// The path to the file on device.
  String get path;

  /// The kind of payload the file carries.
  SharedAttachmentType get type;
}
