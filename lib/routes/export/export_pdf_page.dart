import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/accounts.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/transaction_filter_head/select_multi_account_sheet.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class ExportPdfPage extends StatefulWidget {
  const ExportPdfPage({super.key});

  @override
  State<ExportPdfPage> createState() => _ExportPdfPageState();
}

class _ExportPdfPageState extends State<ExportPdfPage> {
  final List<Account> _accounts = [];
  final Set<String> _selectedAccounts = {};
  final bool _useA4 = true;
  final TimeRange _range = DateTime(0).rangeTo(DateTime(4000));

  bool? get allSelected {
    if (_selectedAccounts.isEmpty) return false;

    return setEquals(
          _selectedAccounts,
          _accounts.map((account) => account.uuid).toSet(),
        )
        ? true
        : null;
  }

  bool ready = false;

  @override
  void initState() {
    super.initState();

    AccountsService()
        .getAll()
        .then((accounts) {
          _accounts.addAll(accounts);
          _selectedAccounts.addAll(accounts.map((account) => account.uuid));
        })
        .catchError((_) {})
        .whenComplete(() {
          ready = true;
          if (!mounted) return;
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.export.asPDF".t(context))),
      body: SafeArea(child: buildChild(context)),
    );
  }

  Widget buildChild(BuildContext context) {
    if (!ready) {
      return Spinner.center();
    }

    if (_accounts.isEmpty) {
      return Center(child: Text("error.sync.exportFailed".t(context)));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Frame.standalone(
            child: InfoText(
              child: Text("sync.export.asPDF.description".t(context)),
            ),
          ),
          ListTile(
            leading: Icon(Symbols.wallet_rounded),
            title: Text("sync.export.asPDF.accounts".t(context)),
            subtitle: Text(
              "sync.export.asPDF.accounts.selected".tr({
                "n": _selectedAccounts.length.toString(),
                "total": _accounts.length.toString(),
              }),
            ),
            onTap: _selectAccounts,
            trailing: DirectionalChevron(),
          ),
          ListTile(
            leading: Icon(Symbols.schedule_rounded),
            title: Text("sync.export.asPDF.timeRange".t(context)),
            subtitle: Text(rangeText),
            onTap: _selectRange,
            trailing: DirectionalChevron(),
          ),
          ListTile(
            leading: Icon(Symbols.expand_content_rounded),
            title: Text("sync.export.asPDF.size".t(context)),
            subtitle: Text(_useA4 ? "A4" : "Letter"),
            onTap: _selectPaperSize,
            trailing: DirectionalChevron(),
          ),
        ],
      ),
    );
  }

  void selectAll() {
    if (allSelected == true) {
      _selectedAccounts.clear();
    } else {
      _selectedAccounts.addAll(_accounts.map((account) => account.uuid));
    }

    setState(() {});
  }

  void _selectAccounts() async {
    final List<Account>? selected = await showModalBottomSheet(
      context: context,
      builder:
          (context) => SelectMultiAccountSheet(
            accounts: _accounts,
            selectedUuids: _selectedAccounts.toList(),
          ),
      isScrollControlled: true,
    );

    if (selected == null) return;

    setState(() {
      _selectedAccounts.clear();
      _selectedAccounts.addAll(selected.map((account) => account.uuid));
    });
  }

  void _selectRange() async {
    // TODO @sadespresso implement
  }

  void _selectPaperSize() async {
    // TODO @sadespresso implement
  }

  String get rangeText {
    if (_range.from <= DateTime(0) && _range.to >= DateTime(4000)) {
      return "select.timeRange.allTime".t(context);
    }

    return _range.format(useRelative: false);
  }
}
