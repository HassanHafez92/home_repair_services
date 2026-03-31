import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'job_model.dart';

/// Server-controlled pricing model for a service category.
/// Technicians cannot modify these prices — they are read-only on client.
class PricingModel extends Equatable {
  final String serviceCategory;
  final List<LaborItem> items;
  final double inspectionFee;
  final double surgeMultiplier;
  final bool isSurgeActive;
  final DateTime updatedAt;

  const PricingModel({
    required this.serviceCategory,
    required this.items,
    this.inspectionFee = 75.0,
    this.surgeMultiplier = 1.0,
    this.isSurgeActive = false,
    required this.updatedAt,
  });

  factory PricingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PricingModel(
      serviceCategory: doc.id,
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => LaborItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      inspectionFee: (data['inspectionFee'] as num?)?.toDouble() ?? 75.0,
      surgeMultiplier: (data['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
      isSurgeActive: data['isSurgeActive'] as bool? ?? false,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'items': items.map((e) => e.toMap()).toList(),
      'inspectionFee': inspectionFee,
      'surgeMultiplier': surgeMultiplier,
      'isSurgeActive': isSurgeActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [
        serviceCategory,
        items,
        inspectionFee,
        surgeMultiplier,
        isSurgeActive,
        updatedAt,
      ];
}
