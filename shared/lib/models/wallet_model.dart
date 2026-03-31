import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a user's wallet with running balance and credit limit.
class WalletModel extends Equatable {
  final String userId;
  final double balance;
  final double creditLimit;
  final String currency;
  final DateTime updatedAt;

  const WalletModel({
    required this.userId,
    this.balance = 0.0,
    this.creditLimit = 2000.0,
    this.currency = 'EGP',
    required this.updatedAt,
  });

  /// Whether the wallet has a negative balance (debt).
  bool get hasDebt => balance < 0;

  /// Whether the wallet has exceeded credit limit.
  bool get isOverCreditLimit => balance.abs() > creditLimit;

  /// Credit utilization percentage (0.0 to 1.0+).
  double get creditUtilization =>
      creditLimit > 0 ? (balance.abs() / creditLimit).clamp(0.0, 2.0) : 0.0;

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      userId: doc.id,
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (data['creditLimit'] as num?)?.toDouble() ?? 2000.0,
      currency: data['currency'] as String? ?? 'EGP',
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'balance': balance,
      'creditLimit': creditLimit,
      'currency': currency,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  WalletModel copyWith({
    String? userId,
    double? balance,
    double? creditLimit,
    String? currency,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [userId, balance, creditLimit, currency, updatedAt];
}
