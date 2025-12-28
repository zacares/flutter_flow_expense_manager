import "package:flow/data/transaction_multi_programmable_object.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/shortcut.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/transaction_batch_import_page/tpo_preview_list_item.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionBatchImportPage extends StatefulWidget {
  final TransactionMultiProgrammableObject? params;

  const TransactionBatchImportPage({super.key, required this.params});

  @override
  State<TransactionBatchImportPage> createState() =>
      _TransactionBatchImportPageState();
}

class _TransactionBatchImportPageState
    extends State<TransactionBatchImportPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () => (),
          osSingleActivator(LogicalKeyboardKey.enter): () => (),
          osSingleActivator(LogicalKeyboardKey.numpadEnter): () => (),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              leadingWidth: 40.0,
              leading: FormCloseButton(canPop: () => !hasChanged()),
              actions: [
                IconButton(
                  onPressed: () => (),
                  icon: const Icon(Symbols.check_rounded),
                  tooltip: "general.save".t(context),
                ),
              ],
              titleTextStyle: context.textTheme.bodyLarge,
              centerTitle: true,
              backgroundColor: context.colorScheme.surface,
            ),
            body: Column(
              children: [
                ...?widget.params?.t.map((tpo) => TpoPreviewListItem(tpo: tpo)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool hasChanged() => false;
}
