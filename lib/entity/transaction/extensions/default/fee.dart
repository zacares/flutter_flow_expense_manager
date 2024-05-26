import 'package:flow/entity/transaction/extensions/base.dart';
import 'package:flow/utils/jsonable.dart';
import 'package:json_annotation/json_annotation.dart';

part "fee.g.dart";

@JsonSerializable()
class Fee extends TransactionExtension implements Jasonable {
  static const String keyName = "@flow/default-fee";

  @override
  @JsonKey(includeToJson: true)
  final String key = Fee.keyName;

  final String relatedTransactionUuid;

  final String uuid;

  const Fee({
    required this.uuid,
    required this.relatedTransactionUuid,
  }) : super();

  Fee copyWith({
    String? uuid,
    String? fromAccountUuid,
    String? toAccountUuid,
    String? relatedTransactionUuid,
  }) =>
      Fee(
        uuid: uuid ?? this.uuid,
        relatedTransactionUuid:
            relatedTransactionUuid ?? this.relatedTransactionUuid,
      );

  factory Fee.fromJson(Map<String, dynamic> json) => _$FeeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FeeToJson(this);
}
