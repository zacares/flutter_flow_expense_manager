import 'package:flow/entity/_base.dart';
import 'package:flow/entity/account.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

part "fee_preset.g.dart";

@Entity()
@JsonSerializable()
class TransactionFeePreset extends EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  static const int maxNameLength = 48;

  @Unique()
  String name;

  bool appliedByDefault;

  double amount;

  /// Currency code complying with [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217)
  String currency;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final fromAccount = ToOne<Account>();

  @Transient()
  String? _fromAccountUuid;

  String? get fromAccountUuid => _fromAccountUuid ?? fromAccount.target?.uuid;

  set fromAccountUuid(String? value) {
    _fromAccountUuid = value;
  }

  /// This won't be saved until you call `Box.put()`
  void setFromAccount(Account? newAccount) {
    // TODO (sadespresso): When changing currencies, we can either ask
    // the user to re-enter the amount, or do an automatic conversion

    if (currency != newAccount?.currency) {
      throw Exception("Cannot convert between currencies");
    }

    fromAccount.target = newAccount;
    fromAccountUuid = newAccount?.uuid;
    currency = newAccount?.currency ?? currency;
  }

  TransactionFeePreset({
    this.id = 0,
    required this.name,
    required this.amount,
    required this.currency,
    this.appliedByDefault = false,
    DateTime? createdDate,
  })  : createdDate = createdDate ?? DateTime.now(),
        uuid = const Uuid().v4();

  factory TransactionFeePreset.fromJson(Map<String, dynamic> json) =>
      _$TransactionFeePresetFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionFeePresetToJson(this);
}
