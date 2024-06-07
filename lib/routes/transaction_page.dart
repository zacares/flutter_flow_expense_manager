import 'dart:developer';

import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/prefs.dart';
import 'package:flow/routes/new_transaction/input_amount_sheet.dart';
import 'package:flow/routes/new_transaction/select_account_sheet.dart';
import 'package:flow/routes/new_transaction/select_category_sheet.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/shortcut.dart';
import 'package:flow/utils/toast.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/utils/value_or.dart';
import 'package:flow/widgets/delete_button.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/transaction/type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';

class TransactionPage extends StatefulWidget {
  /// Transaction Object ID
  final int transactionId;

  final TransactionType? initialTransactionType;

  bool get isNewTransaction => transactionId == 0;

  const TransactionPage.create({
    super.key,
    this.initialTransactionType = TransactionType.expense,
  }) : transactionId = 0;
  const TransactionPage.edit({
    super.key,
    required this.transactionId,
  }) : initialTransactionType = null;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late TransactionType _transactionType;

  bool get isTransfer => _transactionType == TransactionType.transfer;

  late final TextEditingController _titleController;
  late double _amount;

  late final Transaction? _currentlyEditing;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _selectAccountFocusNode = FocusNode();
  final FocusNode _selectAccountTransferToFocusNode = FocusNode();

  late final List<Account> accounts;
  late final List<Category> categories;

  dynamic error;

  Account? _selectedAccount;
  Category? _selectedCategory;

  Account? _selectedAccountTransferTo;

  List<RelevanceScoredTitle>? autofillHints;

  late DateTime _transactionDate;

  @override
  void initState() {
    super.initState();

    accounts = ObjectBox().getAccounts();
    categories = ObjectBox().getCategories();

    /// Transaction we're editing.
    _currentlyEditing = widget.isNewTransaction
        ? null
        : ObjectBox()
            .box<Transaction>()
            .get(widget.transactionId)
            ?.findTransferOriginalOrThis();

    if (!widget.isNewTransaction && _currentlyEditing == null) {
      error = "Transaction with id ${widget.transactionId} was not found";
    } else {
      _titleController =
          TextEditingController(text: _currentlyEditing?.title ?? "");
      _selectedAccount = _currentlyEditing?.account.target;
      _selectedCategory = _currentlyEditing?.category.target;
      _transactionDate = _currentlyEditing?.transactionDate ?? DateTime.now();
      _transactionType = _currentlyEditing?.type ??
          widget.initialTransactionType ??
          TransactionType.expense;
      _amount = _currentlyEditing?.isTransfer == true
          ? _currentlyEditing!.amount.abs()
          : _currentlyEditing?.amount ??
              (_transactionType == TransactionType.expense ? -0 : 0);
      _selectedAccountTransferTo = accounts.firstWhereOrNull((account) =>
          account.uuid ==
          _currentlyEditing?.extensions.transfer?.toAccountUuid);
    }

    if (widget.isNewTransaction) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        selectAccount();
      });
    }
  }

  @override
  void dispose() {
    _selectAccountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.symmetric(horizontal: 16.0);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => pop(),
        osSingleActivator(LogicalKeyboardKey.enter): () => save(),
        osSingleActivator(LogicalKeyboardKey.numpadEnter): () => save(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Symbols.close_rounded),
            ),
            actions: [
              IconButton(
                onPressed: () => save(),
                icon: const Icon(Symbols.check_rounded),
                tooltip: "general.save".t(context),
              )
            ],
            leadingWidth: 40.0,
            title: TypeSelector(
              current: _transactionType,
              onChange: updateTransactionType,
              canEdit: _currentlyEditing == null ||
                  _currentlyEditing.isTransfer == false,
            ),
            titleTextStyle: context.textTheme.bodyLarge,
            centerTitle: true,
            backgroundColor: context.colorScheme.surface,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                canPop: !hasChanged(),
                child: Column(
                  children: [
                    const SizedBox(height: 24.0),
                    Padding(
                      padding: contentPadding,
                      child: TypeAheadField<RelevanceScoredTitle>(
                        focusNode: _titleFocusNode,
                        controller: _titleController,
                        itemBuilder: (context, value) =>
                            ListTile(title: Text(value.title)),
                        // TODO fix laoding indicator appearing everytime i type
                        debounceDuration: const Duration(milliseconds: 180),
                        decorationBuilder: (context, child) => Material(
                          clipBehavior: Clip.hardEdge,
                          elevation: 1.0,
                          borderRadius: BorderRadius.circular(16.0),
                          child: child,
                        ),
                        onSelected: (option) =>
                            _titleController.text = option.title,
                        suggestionsCallback: getAutocompleteOptions,
                        builder: (context, controller, focusNode) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            style: context.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                            maxLength: Transaction.maxTitleLength,
                            onSubmitted: (_) => save(),
                            decoration: InputDecoration(
                              hintText: fallbackTitle,
                              counter: const SizedBox.shrink(),
                            ),
                          );
                        },
                        hideOnEmpty: true,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Center(
                      child: InkWell(
                        onTap: inputAmount,
                        child: Center(
                          child: Text(
                            _amount.formatMoney(
                              currency: _selectedAccount?.currency,
                            ),
                            style: context.textTheme.displayMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: contentPadding,
                        child: Text(
                          isTransfer
                              ? "transaction.transfer.from".t(context)
                              : "account".t(context),
                          style: context.textTheme.titleSmall?.semi(context),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: _selectedAccount == null
                          ? null
                          : FlowIcon(
                              _selectedAccount!.icon,
                              plated: true,
                            ),
                      title: Text(_selectedAccount?.name ??
                          "transaction.edit.selectAccount".t(context)),
                      subtitle: _selectedAccount == null
                          ? null
                          : Text(_selectedAccount!.balance.formatMoney(
                              currency: _selectedAccount!.currency,
                            )),
                      onTap: () => selectAccount(),
                      trailing: _selectedAccount == null
                          ? const Icon(Symbols.chevron_right)
                          : null,
                      focusNode: _selectAccountFocusNode,
                    ),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: contentPadding,
                        child: Text(
                          isTransfer
                              ? "transaction.transfer.to".t(context)
                              : "category".t(context),
                          style: context.textTheme.titleSmall?.semi(context),
                        ),
                      ),
                    ),
                    isTransfer
                        ? ListTile(
                            leading: _selectedAccountTransferTo == null
                                ? null
                                : FlowIcon(
                                    _selectedAccountTransferTo!.icon,
                                    plated: true,
                                  ),
                            title: Text(_selectedAccountTransferTo?.name ??
                                "transaction.edit.selectAccount".t(context)),
                            subtitle: _selectedAccountTransferTo == null
                                ? null
                                : Text(_selectedAccountTransferTo!.balance
                                    .formatMoney(
                                    currency:
                                        _selectedAccountTransferTo!.currency,
                                  )),
                            onTap: () => selectAccountTransferTo(),
                            trailing: _selectedAccountTransferTo == null
                                ? const Icon(Symbols.chevron_right)
                                : null,
                            focusNode: _selectAccountTransferToFocusNode,
                          )
                        : ListTile(
                            leading: _selectedCategory == null
                                ? null
                                : FlowIcon(
                                    _selectedCategory!.icon,
                                    plated: true,
                                  ),
                            title: Text(_selectedCategory?.name ??
                                "transaction.edit.selectCategory".t(context)),
                            // subtitle: _selectedAccount == null
                            //     ? null
                            //     : Text(_selectedAccount!.balance.money),
                            onTap: () => selectCategory(),
                            trailing: _selectedCategory == null
                                ? const Icon(Symbols.chevron_right)
                                : null,
                          ),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: contentPadding,
                        child: Text(
                          "transaction.date".t(context),
                          style: context.textTheme.titleSmall?.semi(context),
                        ),
                      ),
                    ),
                    ListTile(
                      // leading: _transactionDate == null
                      //     ? null
                      //     : Icon(_selectedCategory!.icon),
                      title: Text(_transactionDate.toMoment().LLL),
                      // subtitle: _selectedAccount == null
                      //     ? null
                      //     : Text(_selectedAccount!.balance.money),
                      onTap: () => selectTransactionDate(),
                      trailing: _selectedCategory == null
                          ? const Icon(Symbols.chevron_right)
                          : null,
                    ),
                    if (_currentlyEditing != null) ...[
                      const SizedBox(height: 24.0),
                      Text(
                        "${"transaction.createdDate".t(context)} ${_currentlyEditing.createdDate.format(payload: "LLL", forceLocal: true)}",
                        style: context.textTheme.bodyMedium?.semi(context),
                      ),
                      const SizedBox(height: 36.0),
                      DeleteButton(
                        onTap: _deleteTransaction,
                        label: Text("transaction.delete".t(context)),
                      ),
                    ],
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateTransactionType(TransactionType type) {
    if (type == _transactionType ||
        (_currentlyEditing != null && _currentlyEditing.isTransfer)) return;

    _transactionType = type;

    final double amountSign = switch (type) {
      TransactionType.expense => -1.0,
      _ => 1.0,
    };

    _amount = _amount.abs() * amountSign;

    setState(() {});
  }

  void inputAmount() async {
    await LocalPreferences().updateTransitiveProperties();
    final hideCurrencySymbol =
        !LocalPreferences().transitiveUsesSingleCurrency.get();

    if (!mounted) return;

    final double? result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => InputAmountSheet(
        initialAmount: _amount.abs(),
        currency: _selectedAccount?.currency,
        hideCurrencySymbol: _selectedAccount == null && hideCurrencySymbol,
        title: _transactionType.localizedNameContext(context),
        lockSign: true,
      ),
      isScrollControlled: true,
    );

    final double? resultAmount = result == null
        ? null
        : switch (_transactionType) {
            TransactionType.expense => -result.abs(),
            TransactionType.income => result.abs(),
            TransactionType.transfer => result.abs(),
          };

    setState(() {
      _amount = resultAmount ?? _amount;
    });

    if (mounted && widget.isNewTransaction && result != null) {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    }
  }

  void selectAccount() async {
    final Account? result = accounts.length == 1
        ? accounts.single
        : await showModalBottomSheet<Account>(
            context: context,
            builder: (context) => SelectAccountSheet(
              accounts: accounts,
              currentlySelectedAccountId: _selectedAccount?.id,
              titleOverride: isTransfer
                  ? "transaction.transfer.from.select".t(context)
                  : null,
            ),
            isScrollControlled: true,
          );

    setState(() {
      if (result?.id == _selectedAccountTransferTo?.id) {
        _selectedAccountTransferTo = null;
      }
      _selectedAccount = result ?? _selectedAccount;
    });

    if (widget.isNewTransaction && result != null) {
      if (isTransfer) {
        selectAccountTransferTo();
      } else {
        selectCategory();
      }
    }
  }

  void selectAccountTransferTo() async {
    final List<Account> toAccounts = accounts
        .where((element) =>
            element.currency == _selectedAccount?.currency &&
            element.id != _selectedAccount?.id)
        .toList();

    final Account? result = toAccounts.length == 1
        ? toAccounts.single
        : await showModalBottomSheet<Account>(
            context: context,
            builder: (context) => SelectAccountSheet(
              accounts: toAccounts,
              currentlySelectedAccountId: _selectedAccountTransferTo?.id,
              titleOverride: "transaction.transfer.to.select".t(context),
            ),
            isScrollControlled: true,
          );

    setState(() {
      _selectedAccountTransferTo = result ?? _selectedAccountTransferTo;
    });

    if (widget.isNewTransaction && result != null) inputAmount();
  }

  void selectCategory() async {
    if (categories.isEmpty) {
      inputAmount();
      return;
    }

    final ValueOr<Category>? result =
        await showModalBottomSheet<ValueOr<Category>>(
      context: context,
      builder: (context) => SelectCategorySheet(
        categories: categories,
        currentlySelectedCategoryId: _selectedCategory?.id,
      ),
      isScrollControlled: true,
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result.value;
      });
    }

    if (widget.isNewTransaction && result != null) inputAmount();
  }

  void selectTransactionDate() async {
    final TimeOfDay currentTimeOfDay = TimeOfDay.fromDateTime(_transactionDate);

    final DateTime? result = await showDatePicker(
      context: context,
      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
      lastDate: DateTime(9999, 12, 31),
      initialDate: _transactionDate,
    );

    setState(() {
      _transactionDate = result ?? _transactionDate;
    });

    if (!mounted || result == null) return;

    final TimeOfDay? timeResult = await showTimePicker(
      context: context,
      initialTime: currentTimeOfDay,
    );

    if (timeResult == null) return;

    setState(() {
      _transactionDate = _transactionDate.copyWith(
        hour: timeResult.hour,
        minute: timeResult.minute,
        second: 0,
        microsecond: 0,
        millisecond: 0,
      );
    });
  }

  bool _ensureAccountsSelected() {
    if (_selectedAccount == null) {
      context.showErrorToast(
        error: "error.transaction.missingAccount".t(context),
      );
      _selectAccountFocusNode.requestFocus();
      return false;
    }

    if (isTransfer && _selectedAccountTransferTo == null) {
      context.showErrorToast(
        error: "error.transaction.missingAccount".t(context),
      );
      _selectAccountTransferToFocusNode.requestFocus();
      return false;
    }

    return true;
  }

  void update({required String formattedTitle}) async {
    if (_currentlyEditing == null) return;

    if (_transactionType == TransactionType.transfer) {
      try {
        _selectedAccount!.transferTo(
          amount: _amount,
          title: formattedTitle,
          targetAccount: _selectedAccountTransferTo!,
          createdDate: _currentlyEditing.createdDate,
          transactionDate: _transactionDate,
        );

        _currentlyEditing.delete();
        context.pop();
      } catch (e) {
        log("[Transaction Page] Failed to update transfer transaction due to: $e");
      }
      return;
    }

    _currentlyEditing.setCategory(_selectedCategory);
    _currentlyEditing.setAccount(_selectedAccount);
    _currentlyEditing.title = formattedTitle;
    _currentlyEditing.amount = _amount;
    _currentlyEditing.transactionDate = _transactionDate;

    ObjectBox().box<Transaction>().put(
          _currentlyEditing,
          mode: PutMode.update,
        );

    context.pop();
  }

  void save() {
    if (!_ensureAccountsSelected()) return;

    final String trimmed = _titleController.text.trim();
    final String formattedTitle = trimmed.isNotEmpty ? trimmed : fallbackTitle;

    if (_currentlyEditing != null) {
      return update(formattedTitle: formattedTitle);
    }

    if (isTransfer) {
      _selectedAccount!.transferTo(
        targetAccount: _selectedAccountTransferTo!,
        amount: _amount.abs(),
        transactionDate: _transactionDate,
        title: formattedTitle,
      );
    } else {
      _selectedAccount!.createAndSaveTransaction(
        amount: _amount,
        title: formattedTitle,
        category: _selectedCategory,
        transactionDate: _transactionDate,
      );
    }

    context.pop();
  }

  bool hasChanged() {
    if (_currentlyEditing != null) {
      return _currentlyEditing.amount != _amount ||
          (_currentlyEditing.title ?? "") != _titleController.text;
    }

    return _amount != 0 || _titleController.text.isNotEmpty;
  }

  Future<List<RelevanceScoredTitle>> getAutocompleteOptions(
          String query) async =>
      ObjectBox().transactionTitleSuggestions(
        currentInput: query,
        accountId: _selectedAccount?.id,
        categoryId: _selectedCategory?.id,
        type: _transactionType,
        limit: 5,
      );

  void _deleteTransaction() async {
    if (_currentlyEditing == null) return;

    final String txnTitle =
        _currentlyEditing.title ?? "transaction.fallbackTitle".t(context);

    final confirmation = await context.showConfirmDialog(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, txnTitle),
    );

    if (confirmation == true) {
      _currentlyEditing.delete();

      if (mounted) {
        pop();
      }
    }
  }

  void pop() {
    context.pop();
  }

  String get fallbackTitle => switch (_transactionType) {
        TransactionType.transfer
            when _selectedAccount != null &&
                _selectedAccountTransferTo != null =>
          "transaction.transfer.fromToTitle".t(
            context,
            {
              "from": _selectedAccount!.name,
              "to": _selectedAccountTransferTo!.name,
            },
          ),
        _ => "transaction.fallbackTitle".t(context)
      };
}
