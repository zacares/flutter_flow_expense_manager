import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/entity/file_attachment.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/file_attachment.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/file_attachment.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/directional_slidable.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class FileAttachmentListTile extends StatefulWidget {
  final FileAttachment fileAttachment;
  final Key? dismissibleKey;

  const FileAttachmentListTile({
    super.key,
    required this.fileAttachment,
    this.dismissibleKey,
  });

  @override
  State<FileAttachmentListTile> createState() => _FileAttachmentListTileState();
}

class _FileAttachmentListTileState extends State<FileAttachmentListTile> {
  int? sizeInBytes;
  bool? fileExists;

  @override
  void initState() {
    super.initState();

    _inspectFile();
  }

  @override
  Widget build(BuildContext context) {
    final String subtitle = [
      widget.fileAttachment.createdDate.toMoment().toLocal().lll,
      sizeInBytes != null ? Text(sizeInBytes!.humanReadableBinarySize) : null,
    ].whereType<String>().join(" • ");

    final List<SlidableAction> endActions = [
      SlidableAction(
        onPressed: (context) => showDeleteConfirmation(),
        icon: Symbols.delete_forever_rounded,
        backgroundColor: context.flowColors.expense,
      ),
    ];

    return DirectionalSlidable(
      key: widget.dismissibleKey,
      endActions: endActions,
      child: ListTile(
        leading: FlowIcon(
          FlowIconData.icon(widget.fileAttachment.icon),
          size: 24.0,
        ),
        title: Text(widget.fileAttachment.displayName),
        subtitle: Text(subtitle),
        onTap: () {
          //
        },
      ),
    );
  }

  void _inspectFile() async {
    final File file = File(widget.fileAttachment.filePath);

    final bool exists = await file.exists();

    fileExists = exists;

    if (!exists || !mounted) {
      return;
    }

    if (mounted) {
      setState(() {});
    }

    final int size = await file.length();

    sizeInBytes = size;

    if (mounted) {
      setState(() {});
    }
  }

  void showDeleteConfirmation() async {
    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "fileAttachment.delete".t(context),
      child: Text("fileAttachment.delete".t(context)),
    );

    if (confirmation != true || !mounted) return;

    context.pop();

    try {
      await FileAttachmentService().delete(widget.fileAttachment);
      if (mounted) {
        context.showToast(text: "fileAttachment.delete.success".t(context));
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorToast(error: "error.sync.fileNotFound".t(context));
    }
  }
}
