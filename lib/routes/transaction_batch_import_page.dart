import "package:flow/data/flow_icon.dart";
import "package:flow/data/transaction_multi_programmable_object.dart";
import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/routes/transaction_page/section.dart";
import "package:flow/routes/transaction_page/select_account_sheet.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/scaffold_actions.dart";
import "package:flow/widgets/transaction_batch_import_page/tpo_preview_list_item.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
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
  // final List<String> _assignedAccountUuids = [];
  String? _massAssignedAccountUuid;

  bool assignIndividually = false;

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    try {
      _massAssignedAccountUuid = UserPreferencesService().primaryAccountUuid;
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Account> accounts = AccountsProvider.of(context).activeAccounts;

    final Account? selectedAccount = _massAssignedAccountUuid == null
        ? null
        : accounts.firstWhereOrNull(
            (account) => account.uuid == _massAssignedAccountUuid,
          );

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
              leading: FormCloseButton(canPop: () => false),
              titleTextStyle: context.textTheme.bodyLarge,
              title: Text("transactions.batch.import".t(context)),
              centerTitle: true,
              backgroundColor: context.colorScheme.surface,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Frame(
                    child: InfoText(
                      child: Text("transactions.batch.review".t(context)),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ...?widget.params?.t.map(
                    (tpo) => TpoPreviewListItem(tpo: tpo),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: ScaffoldActions(
              children: [
                // Frame(
                //   child: Align(
                //     alignment: AlignmentDirectional.topEnd,
                //     child: TextButton(
                //       onPressed: () => setState(
                //         () => assignIndividually = !assignIndividually,
                //       ),
                //       child: Text(
                //         assignIndividually
                //             ? "transactions.batch.assignAccountForAll".t(
                //                 context,
                //               )
                //             : "transactions.batch.assignAccountIndividually".t(
                //                 context,
                //               ),
                //       ),
                //     ),
                //   ),
                // ),
                if (!assignIndividually)
                  Section(
                    title: "transactions.batch.selectAccount".t(context),
                    child: ListTile(
                      leading: selectedAccount == null
                          ? null
                          : FlowIcon(selectedAccount.icon, plated: true),
                      title: Text(
                        selectedAccount?.name ??
                            "transaction.edit.selectAccount".t(context),
                      ),
                      subtitle: selectedAccount == null
                          ? null
                          : MoneyText(selectedAccount.balance),
                      onTap: () => selectAccount(),
                      trailing: const Icon(Symbols.chevron_right),
                    ),
                  ),
                Button(
                  onTap: _busy ? null : importTransactions,
                  leading: FlowIcon(
                    FlowIconData.icon(Symbols.download_rounded),
                  ),
                  child: Text(
                    "transactions.batch.importN".t(
                      context,
                      widget.params?.t.length ?? 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void selectAccount() async {
    final accounts = AccountsProvider.of(context).activeAccounts;

    if (accounts.length == 1) {
      _massAssignedAccountUuid = accounts.first.uuid;

      if (!mounted) return;

      setState(() {});

      return;
    }

    final selectedAccountId = accounts
        .firstWhereOrNull((account) => account.uuid == _massAssignedAccountUuid)
        ?.id;

    final Account? account = await showModalBottomSheet<Account>(
      context: context,
      builder: (context) => SelectAccountSheet(
        accounts: accounts,
        currentlySelectedAccountId: selectedAccountId,
        showBalance: true,
        showTrailing: false,
      ),
      isScrollControlled: true,
    );

    if (account == null) return;

    _massAssignedAccountUuid = account.uuid;

    if (!mounted) return;

    setState(() {});
  }

  Future<void> importTransactions() async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    final List<TransactionProgrammableObject> tpos =
        widget.params?.t ?? <TransactionProgrammableObject>[];

    try {
      for (final TransactionProgrammableObject tpo in tpos) {
        tpo.save(_massAssignedAccountUuid);
      }
      if (!mounted) return;

      if (context.canPop()) {
        context.pop();
      }

      context.showToast(
        text: "transactions.batch.import.success".t(context, tpos.length),
        type: .success,
      );
    } catch (e) {
      //
    } finally {
      _busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
