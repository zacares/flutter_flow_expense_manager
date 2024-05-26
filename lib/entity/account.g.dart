// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      name: json['name'] as String,
      currency: json['currency'] as String,
      iconCode: json['iconCode'] as String,
      excludeFromTotalBalance:
          json['excludeFromTotalBalance'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? -1,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
    )..uuid = json['uuid'] as String;

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': instance.createdDate.toIso8601String(),
      'name': instance.name,
      'currency': instance.currency,
      'sortOrder': instance.sortOrder,
      'iconCode': instance.iconCode,
      'excludeFromTotalBalance': instance.excludeFromTotalBalance,
    };
