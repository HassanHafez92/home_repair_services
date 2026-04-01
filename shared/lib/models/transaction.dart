import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/converters.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionType {
  @JsonValue('earning') earning,
  @JsonValue('commission') commission,
  @JsonValue('penalty') penalty,
  @JsonValue('refund') refund,
  @JsonValue('payout') payout,
  @JsonValue('risk_fund') riskFund,
}

@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required String transactionId,
    required String walletId,
    required String userId,
    String? jobId,
    required double amount,
    required TransactionType type,
    String? description,
    @TimestampConverter() DateTime? createdAt,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
}
