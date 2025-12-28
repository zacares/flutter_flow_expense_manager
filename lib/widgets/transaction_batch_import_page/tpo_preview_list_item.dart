import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/providers/categories_provider.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/transaction_list_tile.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:uuid/uuid.dart";

class TpoPreviewListItem extends StatefulWidget {
  final TransactionProgrammableObject tpo;

  const TpoPreviewListItem({super.key, required this.tpo});

  @override
  State<TpoPreviewListItem> createState() => _TpoPreviewListItemState();
}

class _TpoPreviewListItemState extends State<TpoPreviewListItem> {
  Transaction? estimate;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _estimate();
    });
  }

  @override
  void didUpdateWidget(covariant TpoPreviewListItem oldWidget) {
    if (widget.tpo != oldWidget.tpo) {
      _estimate();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: IgnorePointer(
        child: estimate == null
            ? SizedBox.shrink()
            : TransactionListTile(
                transaction: estimate!,
                recoverFromTrashFn: null,
                moveToTrashFn: null,
                combineTransfers: true,
              ),
      ),
    );

    // return InkWell(
    //   child: Material(
    //     type: MaterialType.card,
    //     color: kTransparent,
    //     child: Padding(
    //       padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    //       child: Row(
    //         children: [
    //           FlowIcon(
    //             selectedCategory?.icon ??
    //                 FlowIconData.icon(Symbols.error_circle_rounded_rounded),
    //           ),
    //           Expanded(
    //             child: Column(
    //               mainAxisSize: .min,
    //               children: [

    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  void _estimate() {
    final Account? selectedFromAccount = AccountsProvider.of(context)
        .activeAccounts
        .firstWhereOrNull((account) {
          if (account.uuid == widget.tpo.fromAccountUuid) {
            return true;
          }
          if (account.name == widget.tpo.fromAccount) {
            return true;
          }
          return false;
        });

    final Account? selectedToAccount = widget.tpo.type == .transfer
        ? AccountsProvider.of(context).activeAccounts.firstWhereOrNull((
            account,
          ) {
            if (account.uuid == widget.tpo.toAccountUuid) {
              return true;
            }
            if (account.name == widget.tpo.toAccount) {
              return true;
            }
            return false;
          })
        : null;
    final Category? selectedCategory = widget.tpo.type == .transfer
        ? null
        : CategoriesProvider.of(context).categories.firstWhereOrNull((
            category,
          ) {
            if (category.uuid == widget.tpo.categoryUuid) {
              return true;
            }
            if (category.name == widget.tpo.category) {
              return true;
            }
            return false;
          });

    final Transaction transaction = Transaction(
      title: widget.tpo.title,
      description: widget.tpo.notes,
      amount: widget.tpo.amount?.toDouble() ?? 0.0,
      currency: UserPreferencesService().primaryCurrency,
      isPending: widget.tpo.isPending,
      transactionDate: widget.tpo.transactionDate,
      uuid: const Uuid().v4(),
    );

    if (widget.tpo.type == .transfer) {
      transaction.addExtensions([
        Transfer(
          uuid: const Uuid().v4(),
          fromAccountUuid: selectedFromAccount?.uuid ?? const Uuid().v4(),
          toAccountUuid: selectedToAccount?.uuid ?? const Uuid().v4(),
          relatedTransactionUuid: const Uuid().v4(),
        ),
      ]);
    }

    if (selectedFromAccount != null) {
      transaction.setAccount(selectedFromAccount);
    }
    if (selectedCategory != null) {
      transaction.setCategory(selectedCategory);
    }
    estimate = transaction;
    if (mounted) {
      setState(() {});
    }
  }
}
