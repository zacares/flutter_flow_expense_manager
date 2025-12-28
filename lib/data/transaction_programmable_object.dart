import "package:flow/entity/transaction/type.dart";

class TransactionProgrammableObject {
  final String? title;
  final double? amount;
  final String? fromAccountUuid;
  final String? fromAccount;
  final String? toAccountUuid;
  final String? toAccount;
  final TransactionType? type;
  final DateTime? transactionDate;
  final String? categoryUuid;
  final String? category;
  final String? notes;

  /// Only applicable if the type is "transfer" and the accounts have different
  /// currencies. If the device is online, and has the currency rates fetched,
  /// the user will be suggested to fill this in automatically. Otherwise, the
  /// user will need to fill this in manually.
  final double? transferConversionRate;

  /// True by default if the [transactionDate] is in the future
  final bool? isPending;

  const TransactionProgrammableObject({
    this.transactionDate,
    this.categoryUuid,
    this.category,
    this.notes,
    this.title,
    this.amount,
    this.fromAccountUuid,
    this.fromAccount,
    this.toAccountUuid,
    this.toAccount,
    this.type,
    this.isPending,
    this.transferConversionRate,
  });

  Map<String, String> toMap() {
    final map = <String, String>{};
    if (transactionDate != null) {
      map["transactionDate"] = transactionDate!.toIso8601String();
    }
    if (categoryUuid != null) map["categoryUuid"] = categoryUuid!;
    if (category != null) map["category"] = category!;
    if (notes != null) map["notes"] = notes!;
    if (title != null) map["title"] = title!;
    if (amount != null) map["amount"] = amount!.toString();
    if (fromAccountUuid != null) map["fromAccountUuid"] = fromAccountUuid!;
    if (fromAccount != null) map["fromAccount"] = fromAccount!;
    if (toAccountUuid != null) map["toAccountUuid"] = toAccountUuid!;
    if (toAccount != null) map["toAccount"] = toAccount!;
    if (type != null) map["type"] = type!.name;
    if (isPending != null) map["isPending"] = isPending! ? "true" : "false";
    if (transferConversionRate != null) {
      map["transferConversionRate"] = transferConversionRate!.toString();
    }
    return map;
  }

  static TransactionProgrammableObject? fromUri(Uri uri) {
    final params = uri.queryParameters;

    return tryParse(params);
  }

  static TransactionProgrammableObject parse(Map<String, String> params) {
    return TransactionProgrammableObject(
      transactionDate: params["transactionDate"] != null
          ? DateTime.tryParse(params["transactionDate"]!)
          : null,
      categoryUuid: params["categoryUuid"],
      category: params["category"],
      notes: params["notes"],
      title: params["title"],
      amount: params["amount"] != null
          ? double.tryParse(params["amount"]!)
          : null,
      fromAccountUuid: params["fromAccountUuid"],
      fromAccount: params["fromAccount"],
      toAccountUuid: params["toAccountUuid"],
      toAccount: params["toAccount"],
      type: params["type"] != null
          ? TransactionType.values.byName(params["type"]!)
          : null,
      isPending: params["isPending"]?.toLowerCase() == "true",
      transferConversionRate: params["transferConversionRate"] != null
          ? double.tryParse(params["transferConversionRate"]!)
          : null,
    );
  }

  static TransactionProgrammableObject? tryParse(Map<String, String> params) {
    try {
      return parse(params);
    } catch (e) {
      return null;
    }
  }
}
