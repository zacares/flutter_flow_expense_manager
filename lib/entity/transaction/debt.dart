import 'package:flow/entity/_base.dart';
import 'package:flow/entity/transaction.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

part "debt.g.dart";

@Entity()
@JsonSerializable()
class Debt implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  @Property(type: PropertyType.date)
  DateTime? closedDate;

  static const int maxOtherPartyLength = 80;

  String otherParty;

  @Backlink('debt')
  @JsonKey(includeFromJson: false, includeToJson: false)
  final transactions = ToMany<Transaction>();

  Debt({
    this.id = 0,
    required this.otherParty,
    DateTime? createdDate,
    String? uuidOverride,
  })  : createdDate = createdDate ?? DateTime.now(),
        uuid = uuidOverride ?? const Uuid().v4(),
        assert(otherParty.length <= maxOtherPartyLength);

  factory Debt.fromJson(Map<String, dynamic> json) => _$DebtFromJson(json);
  Map<String, dynamic> toJson() => _$DebtToJson(this);
}
