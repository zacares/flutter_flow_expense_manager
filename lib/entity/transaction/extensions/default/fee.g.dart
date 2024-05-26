// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fee _$FeeFromJson(Map<String, dynamic> json) => Fee(
      uuid: json['uuid'] as String,
      relatedTransactionUuid: json['relatedTransactionUuid'] as String,
    );

Map<String, dynamic> _$FeeToJson(Fee instance) => <String, dynamic>{
      'key': instance.key,
      'relatedTransactionUuid': instance.relatedTransactionUuid,
      'uuid': instance.uuid,
    };
