import "package:flow/l10n/named_enum.dart";

enum PDFHeader implements LocalizedEnum {
  transactionDate,
  title,
  amount,
  account,
  category;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "PDFHeader";
}
