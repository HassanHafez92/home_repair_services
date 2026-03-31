import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Represents a labor item in an invoice with server-controlled pricing.
class LaborItem extends Equatable {
  final String itemId;
  final String name;
  final String nameAr;
  final double fixedPrice;

  const LaborItem({
    required this.itemId,
    required this.name,
    required this.nameAr,
    required this.fixedPrice,
  });

  factory LaborItem.fromMap(Map<String, dynamic> map) {
    return LaborItem(
      itemId: map['itemId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameAr: map['nameAr'] as String? ?? '',
      fixedPrice: (map['fixedPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'nameAr': nameAr,
      'fixedPrice': fixedPrice,
    };
  }

  @override
  List<Object?> get props => [itemId, name, nameAr, fixedPrice];
}

/// The core job model representing the full lifecycle of a service request.
class JobModel extends Equatable {
  final String jobId;
  final String customerId;
  final String? technicianId;
  final ServiceCategory serviceCategory;
  final JobStatus status;

  // Location
  final GeoPoint location;
  final String addressText;
  final String? voiceNoteUrl;

  // Pricing (all server-controlled)
  final double inspectionFee;
  final List<LaborItem> laborItems;
  final double materialsCost;
  final String? receiptImageUrl;
  final double totalAmount;
  final double platformFee;

  // Surge pricing
  final bool isSurge;
  final double surgeMultiplier;

  // Payment
  final PaymentMethod? paymentMethod;
  final bool isPaid;

  // Rating
  final int? rating;
  final String? review;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  // Cancellation
  final String? cancellationReason;
  final String? cancelledBy;

  // Offline sync
  final bool isSynced;

  const JobModel({
    required this.jobId,
    required this.customerId,
    this.technicianId,
    required this.serviceCategory,
    required this.status,
    required this.location,
    required this.addressText,
    this.voiceNoteUrl,
    required this.inspectionFee,
    this.laborItems = const [],
    this.materialsCost = 0.0,
    this.receiptImageUrl,
    this.totalAmount = 0.0,
    this.platformFee = 0.0,
    this.isSurge = false,
    this.surgeMultiplier = 1.0,
    this.paymentMethod,
    this.isPaid = false,
    this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledBy,
    this.isSynced = true,
  });

  /// Calculate the total labor cost from all labor items.
  double get totalLaborCost =>
      laborItems.fold(0.0, (sum, item) => sum + item.fixedPrice);

  /// Calculate the grand total: labor + materials (inspection fee is deducted).
  double get grandTotal =>
      (totalLaborCost + materialsCost - inspectionFee) * surgeMultiplier;

  /// Whether materials require customer approval (above threshold).
  bool get requiresMaterialApproval => materialsCost > 500.0;

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      jobId: doc.id,
      customerId: data['customerId'] as String? ?? '',
      technicianId: data['technicianId'] as String?,
      serviceCategory: ServiceCategory.fromString(
          data['serviceCategory'] as String? ?? 'general'),
      status: JobStatus.fromString(data['status'] as String? ?? 'searching'),
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      addressText: data['addressText'] as String? ?? '',
      voiceNoteUrl: data['voiceNoteUrl'] as String?,
      inspectionFee: (data['inspectionFee'] as num?)?.toDouble() ?? 75.0,
      laborItems: (data['laborItems'] as List<dynamic>?)
              ?.map((e) => LaborItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      materialsCost: (data['materialsCost'] as num?)?.toDouble() ?? 0.0,
      receiptImageUrl: data['receiptImageUrl'] as String?,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (data['platformFee'] as num?)?.toDouble() ?? 0.0,
      isSurge: data['isSurge'] as bool? ?? false,
      surgeMultiplier:
          (data['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
      paymentMethod: data['paymentMethod'] != null
          ? PaymentMethod.fromString(data['paymentMethod'] as String)
          : null,
      isPaid: data['isPaid'] as bool? ?? false,
      rating: data['rating'] as int?,
      review: data['review'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      arrivedAt: (data['arrivedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      cancellationReason: data['cancellationReason'] as String?,
      cancelledBy: data['cancelledBy'] as String?,
      isSynced: data['isSynced'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'technicianId': technicianId,
      'serviceCategory': serviceCategory.name,
      'status': status.name,
      'location': location,
      'addressText': addressText,
      'voiceNoteUrl': voiceNoteUrl,
      'inspectionFee': inspectionFee,
      'laborItems': laborItems.map((e) => e.toMap()).toList(),
      'materialsCost': materialsCost,
      'receiptImageUrl': receiptImageUrl,
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'isSurge': isSurge,
      'surgeMultiplier': surgeMultiplier,
      'paymentMethod': paymentMethod?.name,
      'isPaid': isPaid,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'arrivedAt': arrivedAt != null ? Timestamp.fromDate(arrivedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt':
          cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'isSynced': isSynced,
    };
  }

  JobModel copyWith({
    String? jobId,
    String? customerId,
    String? technicianId,
    ServiceCategory? serviceCategory,
    JobStatus? status,
    GeoPoint? location,
    String? addressText,
    String? voiceNoteUrl,
    double? inspectionFee,
    List<LaborItem>? laborItems,
    double? materialsCost,
    String? receiptImageUrl,
    double? totalAmount,
    double? platformFee,
    bool? isSurge,
    double? surgeMultiplier,
    PaymentMethod? paymentMethod,
    bool? isPaid,
    int? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? cancelledBy,
    bool? isSynced,
  }) {
    return JobModel(
      jobId: jobId ?? this.jobId,
      customerId: customerId ?? this.customerId,
      technicianId: technicianId ?? this.technicianId,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      status: status ?? this.status,
      location: location ?? this.location,
      addressText: addressText ?? this.addressText,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      inspectionFee: inspectionFee ?? this.inspectionFee,
      laborItems: laborItems ?? this.laborItems,
      materialsCost: materialsCost ?? this.materialsCost,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      totalAmount: totalAmount ?? this.totalAmount,
      platformFee: platformFee ?? this.platformFee,
      isSurge: isSurge ?? this.isSurge,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
        jobId, customerId, technicianId, serviceCategory, status,
        location, addressText, voiceNoteUrl, inspectionFee,
        laborItems, materialsCost, receiptImageUrl, totalAmount,
        platformFee, isSurge, surgeMultiplier, paymentMethod,
        isPaid, rating, review, createdAt, updatedAt,
        acceptedAt, arrivedAt, completedAt, cancelledAt,
        cancellationReason, cancelledBy, isSynced,
      ];
}
