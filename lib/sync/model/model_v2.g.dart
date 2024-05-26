// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncModelV2 _$SyncModelV2FromJson(Map<String, dynamic> json) => SyncModelV2(
      versionCode: (json['versionCode'] as num).toInt(),
      exportDate: DateTime.parse(json['exportDate'] as String),
      username: json['username'] as String,
      appVersion: json['appVersion'] as String,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      accounts: (json['accounts'] as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      debts: (json['debts'] as List<dynamic>)
          .map((e) => Debt.fromJson(e as Map<String, dynamic>))
          .toList(),
      transactionFeePresets: (json['transactionFeePresets'] as List<dynamic>)
          .map((e) => TransactionFeePreset.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncModelV2ToJson(SyncModelV2 instance) =>
    <String, dynamic>{
      'versionCode': instance.versionCode,
      'exportDate': instance.exportDate.toIso8601String(),
      'username': instance.username,
      'appVersion': instance.appVersion,
      'transactions': instance.transactions,
      'debts': instance.debts,
      'accounts': instance.accounts,
      'categories': instance.categories,
      'transactionFeePresets': instance.transactionFeePresets,
    };
