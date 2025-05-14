import "package:flow/l10n/named_enum.dart";

enum PDFHeader implements LocalizedEnum {
  transactionDate,
  title,
  amount,
  account,
  category,
  type;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "PDFHeaders";
}
