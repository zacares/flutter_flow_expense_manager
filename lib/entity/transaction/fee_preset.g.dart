// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionFeePreset _$TransactionFeePresetFromJson(
        Map<String, dynamic> json) =>
    TransactionFeePreset(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      appliedByDefault: json['appliedByDefault'] as bool? ?? false,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
    )
      ..uuid = json['uuid'] as String
      ..fromAccountUuid = json['fromAccountUuid'] as String?;

Map<String, dynamic> _$TransactionFeePresetToJson(
        TransactionFeePreset instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': instance.createdDate.toIso8601String(),
      'name': instance.name,
      'appliedByDefault': instance.appliedByDefault,
      'amount': instance.amount,
      'currency': instance.currency,
      'fromAccountUuid': instance.fromAccountUuid,
    };
