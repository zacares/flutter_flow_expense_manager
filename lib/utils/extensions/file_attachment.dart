import "package:flow/entity/file_attachment.dart";

/// Extensions for [FileAttachment]
extension FileAttachmentExtension on FileAttachment {
  String get displayName => name ?? fileName;
}
