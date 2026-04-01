// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletTransactionImpl _$$WalletTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletTransactionImpl(
      transactionId: json['transactionId'] as String,
      walletId: json['walletId'] as String,
      userId: json['userId'] as String,
      jobId: json['jobId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      description: json['description'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$WalletTransactionImplToJson(
        _$WalletTransactionImpl instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'walletId': instance.walletId,
      'userId': instance.userId,
      'jobId': instance.jobId,
      'amount': instance.amount,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.earning: 'earning',
  TransactionType.commission: 'commission',
  TransactionType.penalty: 'penalty',
  TransactionType.refund: 'refund',
  TransactionType.payout: 'payout',
  TransactionType.riskFund: 'risk_fund',
};
