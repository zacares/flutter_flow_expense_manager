import 'dart:convert';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flow/constants.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/profile.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/entity/transaction/debt.dart';
import 'package:flow/entity/transaction/fee_preset.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/sync/export/headers/header_v2.dart';
import 'package:flow/sync/model/model_v2.dart';
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';

Future<String> generateBackupContentV2() async {
  const int versionCode = 2;
  log("[Flow Sync] Initiating export, version code = $versionCode");

  final List<Transaction> transactions =
      await ObjectBox().box<Transaction>().getAllAsync();
  log("[Flow Sync] Finished fetching transactions");

  final List<Account> accounts = await ObjectBox().box<Account>().getAllAsync();
  log("[Flow Sync] Finished fetching accounts");

  final List<Category> categories =
      await ObjectBox().box<Category>().getAllAsync();
  log("[Flow Sync] Finished fetching categories");

  final List<Debt> debts = await ObjectBox().box<Debt>().getAllAsync();
  log("[Flow Sync] Finished fetching debts");

  final List<TransactionFeePreset> transactionFeePresets =
      await ObjectBox().box<TransactionFeePreset>().getAllAsync();
  log("[Flow Sync] Finished fetching transaction fee presets");

  final DateTime exportDate = DateTime.now().toUtc();

  final Query<Profile> firstProfileQuery =
      ObjectBox().box<Profile>().query().build();

  final String username =
      firstProfileQuery.findFirst()?.name ?? "Default Profile";

  firstProfileQuery.close();

  final SyncModelV2 obj = SyncModelV2(
    versionCode: versionCode,
    exportDate: exportDate,
    username: username,
    appVersion: appVersion,
    transactions: transactions,
    accounts: accounts,
    categories: categories,
    debts: debts,
    transactionFeePresets: transactionFeePresets,
  );

  return jsonEncode(obj.toJson());
}

Future<String> generateCSVContentV2() async {
  final transaction = await ObjectBox().box<Transaction>().getAllAsync();

  final headers = [
    CSVHeadersV2.uuid.localizedName,
    CSVHeadersV2.title.localizedName,
    CSVHeadersV2.amount.localizedName,
    CSVHeadersV2.currency.localizedName,
    CSVHeadersV2.account.localizedName,
    CSVHeadersV2.accountUuid.localizedName,
    CSVHeadersV2.category.localizedName,
    CSVHeadersV2.categoryUuid.localizedName,
    CSVHeadersV2.createdDate.localizedName,
    CSVHeadersV2.transactionDate.localizedName,
    CSVHeadersV2.relatedDebtUuid.localizedName,
    CSVHeadersV2.relatedDebtParty.localizedName,
    CSVHeadersV2.extra.localizedName,
  ];

  final Map<String, int> numberOfDecimalsToKeep = {};

  final transformed = transaction
      .map(
        (e) => [
          e.uuid,
          e.title ?? "",
          e.amount.toStringAsFixed(
            numberOfDecimalsToKeep[e.currency] ??=
                NumberFormat.currency(name: e.currency).decimalDigits ?? 2,
          ),
          e.currency,
          e.account.target?.name,
          e.account.target?.uuid,
          e.category.target?.name,
          e.category.target?.uuid,
          e.createdDate.format(
            payload: "LLL",
            forceLocal: true,
          ),
          e.transactionDate.format(
            payload: "LLL",
            forceLocal: true,
          ),
          e.debtUuid,
          e.debt.target?.otherParty ?? "",
          e.extra,
        ],
      )
      .toList()
    ..insert(0, headers);

  return const ListToCsvConverter().convert(transformed);
}
