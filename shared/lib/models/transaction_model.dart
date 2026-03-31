import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Represents a single financial transaction in the ledger.
class TransactionModel extends Equatable {
  final String transactionId;
  final String walletId;
  final String userId;
  final String? jobId;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime createdAt;

  const TransactionModel({
    required this.transactionId,
    required this.walletId,
    required this.userId,
    this.jobId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  /// Whether this transaction is a credit (positive).
  bool get isCredit => amount > 0;

  /// Whether this transaction is a debit (negative).
  bool get isDebit => amount < 0;

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      transactionId: doc.id,
      walletId: data['walletId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      jobId: data['jobId'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.fromString(data['type'] as String? ?? 'earning'),
      description: data['description'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'walletId': walletId,
      'userId': userId,
      'jobId': jobId,
      'amount': amount,
      'type': type.value,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [
        transactionId, walletId, userId, jobId,
        amount, type, description, createdAt,
      ];
}
