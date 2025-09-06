import "package:flow/entity/transaction/tag_type.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionTagPage extends StatefulWidget {
  final int tagId;

  bool get isNewTag => tagId == 0;

  const TransactionTagPage({super.key, required this.tagId});
  const TransactionTagPage.create({super.key}) : tagId = 0;

  @override
  State<TransactionTagPage> createState() => _TransactionTagPageState();
}

class _TransactionTagPageState extends State<TransactionTagPage> {
  late final TextEditingController _titleController;

  late TransactionTagType _type;

  Object? payload;

  @override
  void initState() {
    super.initState();

    if (widget.isNewTag) {
      _titleController = TextEditingController();
      _type = TransactionTagType.generic;
      payload = null;
    } else {
      _titleController = TextEditingController();
      _type = TransactionTagType.generic;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40.0,
        leading: FormCloseButton(canPop: () => !hasChanged()),
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(Symbols.check_rounded),
            tooltip: "general.save".t(context),
          ),
        ],
      ),
      body: SafeArea(child: Center(child: Text("Not implemented yet"))),
    );
  }

  bool hasChanged() {
    return false;
  }

  void save() {
    if (!hasChanged()) {
      Navigator.of(context).pop();
      return;
    }
  }
}
