import "package:flow/entity/file_attachment.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/routes/transaction_page/section.dart";
import "package:flow/widgets/file_attachment_add_list_tile.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class FilesSection extends StatelessWidget {
  final List<FileAttachment>? attachments;
  final Function(List<XFile> files) onAdd;

  const FilesSection({super.key, required this.onAdd, this.attachments});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: "transaction.attachments".t(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FileAttachmentAddListTile(onFilesPicked: onAdd),
          const SizedBox(height: 8),
          InfoText(child: Text("transaction.attachments.warning".t(context))),
        ],
      ),
    );
  }
}
