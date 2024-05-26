import 'package:flow/l10n/named_enum.dart';

enum CSVHeadersV2 implements LocalizedEnum {
  uuid,
  title,
  amount,
  currency,
  account,
  accountUuid,
  category,
  categoryUuid,
  createdDate,
  transactionDate,
  relatedDebtUuid,
  relatedDebtParty,
  extra;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "CSVHeadersV2";
}
