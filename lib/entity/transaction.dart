import 'package:flow/entity/_base.dart';
import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction/debt.dart';
import 'package:flow/entity/transaction/extensions/base.dart';
import 'package:flow/entity/transaction/wrapper.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

part "transaction.g.dart";

@Entity()
@JsonSerializable()
class Transaction implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  @Property(type: PropertyType.date)
  DateTime transactionDate;

  static const int maxTitleLength = 256;

  String? title;

  double amount;

  /// Currency code complying with [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217)
  String currency;

  /// Extra information related to the transaction
  ///
  /// We plan to use this field as place to store data for custom extensions.
  /// e.g., We can use JSON, and give each extension ability to edit their "key"
  /// in this field. (ensuring no collision between extensions)
  String? extra;

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  ExtensionsWrapper get extensions => ExtensionsWrapper.parse(extra);

  @Transient()
  set extensions(ExtensionsWrapper newValue) {
    extra = newValue.serialize();
  }

  void addExtensions(Iterable<TransactionExtension> newExtensions) {
    extensions = extensions.merge(newExtensions.toList());
  }

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isTransfer => extensions.transfer != null;

  @Transient()
  @JsonKey(includeFromJson: false, includeToJson: false)
  TransactionType get type {
    if (isTransfer) return TransactionType.transfer;

    return amount.isNegative ? TransactionType.expense : TransactionType.income;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  final category = ToOne<Category>();

  @Transient()
  String? _categoryUuid;

  String? get categoryUuid => _categoryUuid ?? category.target?.uuid;

  set categoryUuid(String? value) {
    _categoryUuid = value;
  }

  /// This won't be saved until you call `Box.put()`
  void setCategory(Category? newCategory) {
    category.target = newCategory;
    categoryUuid = newCategory?.uuid;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  final account = ToOne<Account>();

  @Transient()
  String? _accountUuid;

  String? get accountUuid => _accountUuid ?? account.target?.uuid;

  set accountUuid(String? value) {
    _accountUuid = value;
  }

  /// This won't be saved until you call `Box.put()`
  void setAccount(Account? newAccount) {
    // TODO (sadespresso): When changing currencies, we can either ask
    // the user to re-enter the amount, or do an automatic conversion

    if (currency != newAccount?.currency) {
      throw Exception("Cannot convert between currencies");
    }

    account.target = newAccount;
    accountUuid = newAccount?.uuid;
    currency = newAccount?.currency ?? currency;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  final debt = ToOne<Debt>();

  @Transient()
  String? _debtUuid;

  String? get debtUuid => _debtUuid ?? debt.target?.uuid;

  set debtUuid(String? value) {
    _debtUuid = value;
  }

  /// This won't be saved until you call `Box.put()`
  void setDebt(Debt? newAccount) {
    debt.target = newAccount;
    debtUuid = newAccount?.uuid;
  }

  Transaction({
    this.id = 0,
    this.title,
    required this.amount,
    required this.currency,
    DateTime? transactionDate,
    DateTime? createdDate,
    String? uuidOverride,
  })  : createdDate = createdDate ?? DateTime.now(),
        transactionDate = transactionDate ?? createdDate ?? DateTime.now(),
        uuid = uuidOverride ?? const Uuid().v4(),
        assert(title == null || title.length <= maxTitleLength);

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

@JsonEnum(valueField: "value")
enum TransactionType implements LocalizedEnum {
  transfer("transfer"),
  income("income"),
  expense("expense");

  final String value;

  const TransactionType(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "TransactionType";

  static TransactionType? fromJson(Map json) {
    return TransactionType.values
        .firstWhereOrNull((element) => element.value == json["value"]);
  }

  Map<String, dynamic> toJson() => {"value": value};
}
