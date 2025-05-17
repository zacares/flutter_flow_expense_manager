import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/transactions.dart";
import "package:flow/sync/export/export_pdf/headers.dart";
import "package:flutter/services.dart";
import "package:moment_dart/moment_dart.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;

class ExportPdfOptions {
  final TimeRange timeRange;
  final List<Account>? whitelistedAccounts;
  final bool useA4;

  const ExportPdfOptions({
    required this.timeRange,
    this.whitelistedAccounts,
    this.useA4 = true,
  });
}

Future<Uint8List> generatePDFContent({
  required ExportPdfOptions options,
  List<pw.Font>? fontFallbacks,
  required pw.Font defaultFont,
  required Uint8List logoBytes,
}) async {
  final List<Account> accounts = await AccountsService().getAll();
  final List<Category> categories =
      await ObjectBox().box<Category>().getAllAsync();

  final Map<String, String> accountNames = {
    for (final Account account in accounts) account.uuid: account.name,
  };

  final Map<String, String> categoryNames = {
    for (final Category category in categories) category.uuid: category.name,
  };

  final TransactionFilter filter = TransactionFilter(
    accounts:
        options.whitelistedAccounts?.map((account) => account.uuid).toList(),
    range: TransactionFilterTimeRange.fromTimeRange(options.timeRange),
  );

  final List<Transaction> transactions = await TransactionsService().findMany(
    filter,
  );

  /// TODO @sadespresso maybe ask user to download missing fonts?
  // final Map<String, bool> potentialMissingFonts = {
  //   "korean": false,
  //   "chinese": false,
  //   "japanese": false,
  //   "arabic": false,
  // };

  final List<String?> resultingAccounts =
      transactions
          .map((transaction) {
            // TODO @sadespresso check if there's any CJK, Arabic, or other characters in the title

            return transaction.accountUuid;
          })
          .toSet()
          .toList();

  final pw.TextStyle defaultTextStyle = pw.TextStyle(
    font: defaultFont,
    color: PdfColor.fromInt(0xFF050505),
    fontSize: 10.0,
    fontFallback:
        fontFallbacks ??
        [pw.Font.courier(), pw.Font.helvetica(), pw.Font.times()],
  );

  final pw.TextStyle fineTextStyle = defaultTextStyle.copyWith(
    fontSize: 6.0,
    color: PdfColor.fromInt(0xa0050505),
  );

  bool even = true;

  final pw.BoxDecoration rowEvenDeco = pw.BoxDecoration(
    color: PdfColor.fromInt(0xFFEFEFEF),
  );
  final pw.BoxDecoration rowOddDeco = pw.BoxDecoration(
    color: PdfColor.fromInt(0xFFFFFFFF),
  );

  pw.TableRow generateRow(Transaction transaction) {
    final String transactionDate = transaction.transactionDate.format(
      payload: "LLL",
      forceLocal: true,
    );

    final String title =
        transaction.title ??
        (transaction.isTransfer
            ? "transaction.transfer.fromToTitle".tr({
              "from":
                  accountNames[transaction
                      .extensions
                      .transfer
                      ?.fromAccountUuid] ??
                  "~",
              "to":
                  accountNames[transaction
                      .extensions
                      .transfer
                      ?.toAccountUuid] ??
                  "~",
            })
            : "transaction.fallbackTitle".tr());
    final String accountName =
        (transaction.isTransfer)
            ? "${accountNames[transaction.extensions.transfer!.fromAccountUuid] ?? "~"} -> ${accountNames[transaction.extensions.transfer!.toAccountUuid] ?? "~"}"
            : (accountNames[transaction.accountUuid] ?? "~");

    return pw.TableRow(
      decoration: (even = !even) ? rowEvenDeco : rowOddDeco,
      children:
          [
                pw.Text(
                  transactionDate,
                  style: defaultTextStyle.copyWith(fontSize: 8.0),
                ),
                pw.Text(title, style: defaultTextStyle.copyWith(fontSize: 8.0)),
                pw.Align(
                  child: pw.Text(transaction.money.formatMoney()),
                  alignment: pw.Alignment.topRight,
                ),
                pw.Text(accountName),
                pw.Text(categoryNames[transaction.categoryUuid] ?? "~"),
              ]
              .map(
                (cell) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 2.0,
                  ),
                  child: cell,
                ),
              )
              .toList(),
    );
  }

  final String author =
      ObjectBox().box<Profile>().getAll().firstOrNull?.name ?? "Flow";

  final pw.Document pdf = pw.Document(
    theme: pw.ThemeData(defaultTextStyle: defaultTextStyle),
    // TODO @sadespresso add l10n support
    title: "Flow - Transactions statement (${options.timeRange})",
    author: author,
    keywords: "Flow, statement, personal, non-legal",
  );
  pdf.addPage(
    pw.MultiPage(
      maxPages: 10000,
      pageTheme: pw.PageTheme(
        clip: true,
        pageFormat: options.useA4 ? PdfPageFormat.a4 : PdfPageFormat.letter,
        buildBackground: (context) {
          return pw.Container(height: 4.0, color: PdfColor.fromInt(0xFF8500a6));
        },
        margin: pw.EdgeInsets.all(32.0),
      ),
      header:
          (context) => pw.Container(
            width: double.infinity,
            child: pw.Text(
              "sync.export.pdf.header".tr({
                "range": options.timeRange.format(useRelative: false),
              }),
            ),
          ),
      footer:
          (context) => pw.Container(
            width: double.infinity,
            margin: pw.EdgeInsets.only(top: 16.0),
            child: pw.RichText(
              text: pw.TextSpan(
                style: fineTextStyle,
                children: [
                  pw.TextSpan(text: "sync.export.pdf.notice[0]".tr()),
                  pw.WidgetSpan(
                    child: pw.UrlLink(
                      child: pw.Text("Flow", style: fineTextStyle),
                      destination: "https://flow.gege.mn",
                    ),
                  ),
                  pw.TextSpan(text: "sync.export.pdf.notice[1]".tr()),
                ],
              ),
            ),
          ),
      build:
          (context) => [
            pw.Row(
              children: [
                pw.Image(
                  pw.MemoryImage(logoBytes),
                  height: defaultTextStyle.fontSize,
                  width: defaultTextStyle.fontSize,
                ),
                pw.Text("Flow"),
              ],
            ),
            pw.Row(
              children: [
                pw.Text(
                  "Statement for: ${resultingAccounts.nonNulls.map((account) => accountNames[account] ?? "~").join(", ")}",
                ),
                pw.Text(options.timeRange.format(useRelative: false)),
              ],
            ),
            pw.Divider(),
            pw.Text("transactions.title".tr()),
            pw.SizedBox(height: 20),
            pw.Table(
              defaultColumnWidth: pw.FlexColumnWidth(),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF5CCFF),
                  ),
                  children:
                      PDFHeader.values
                          .map(
                            (header) => pw.Padding(
                              padding: pw.EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 2.0,
                              ),
                              child: pw.Text(header.localizedName),
                            ),
                          )
                          .toList(),
                ),
                ...transactions.map(generateRow),
              ],
            ),
          ],
    ),
  );

  return await pdf.save();
}
