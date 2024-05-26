// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Debt _$DebtFromJson(Map<String, dynamic> json) => Debt(
      otherParty: json['otherParty'] as String,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
    )
      ..uuid = json['uuid'] as String
      ..closedDate = json['closedDate'] == null
          ? null
          : DateTime.parse(json['closedDate'] as String);

Map<String, dynamic> _$DebtToJson(Debt instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': instance.createdDate.toIso8601String(),
      'closedDate': instance.closedDate?.toIso8601String(),
      'otherParty': instance.otherParty,
    };
