import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Extended profile for verified technicians.
/// Contains KYC documents, specialties, and performance metrics.
class TechnicianProfileModel extends Equatable {
  final String userId;
  final List<ServiceCategory> specialties;
  final VerificationStatus verificationStatus;
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? criminalRecordUrl;
  final double averageRating;
  final int totalJobs;
  final int totalReviews;
  final bool isOnline;
  final String? currentZone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TechnicianProfileModel({
    required this.userId,
    required this.specialties,
    this.verificationStatus = VerificationStatus.pending,
    this.idFrontUrl,
    this.idBackUrl,
    this.criminalRecordUrl,
    this.averageRating = 0.0,
    this.totalJobs = 0,
    this.totalReviews = 0,
    this.isOnline = false,
    this.currentZone,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the technician has completed KYC document submission.
  bool get hasSubmittedKyc =>
      idFrontUrl != null &&
      idBackUrl != null &&
      criminalRecordUrl != null;

  /// Whether the technician is fully approved and can receive jobs.
  bool get canReceiveJobs =>
      verificationStatus == VerificationStatus.approved && isOnline;

  factory TechnicianProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TechnicianProfileModel(
      userId: doc.id,
      specialties: (data['specialties'] as List<dynamic>?)
              ?.map((e) => ServiceCategory.fromString(e as String))
              .toList() ??
          [],
      verificationStatus: VerificationStatus.fromString(
          data['verificationStatus'] as String? ?? 'pending'),
      idFrontUrl: data['idFrontUrl'] as String?,
      idBackUrl: data['idBackUrl'] as String?,
      criminalRecordUrl: data['criminalRecordUrl'] as String?,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalJobs: data['totalJobs'] as int? ?? 0,
      totalReviews: data['totalReviews'] as int? ?? 0,
      isOnline: data['isOnline'] as bool? ?? false,
      currentZone: data['currentZone'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'specialties': specialties.map((e) => e.value).toList(),
      'verificationStatus': verificationStatus.value,
      'idFrontUrl': idFrontUrl,
      'idBackUrl': idBackUrl,
      'criminalRecordUrl': criminalRecordUrl,
      'averageRating': averageRating,
      'totalJobs': totalJobs,
      'totalReviews': totalReviews,
      'isOnline': isOnline,
      'currentZone': currentZone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TechnicianProfileModel copyWith({
    String? userId,
    List<ServiceCategory>? specialties,
    VerificationStatus? verificationStatus,
    String? idFrontUrl,
    String? idBackUrl,
    String? criminalRecordUrl,
    double? averageRating,
    int? totalJobs,
    int? totalReviews,
    bool? isOnline,
    String? currentZone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TechnicianProfileModel(
      userId: userId ?? this.userId,
      specialties: specialties ?? this.specialties,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      idFrontUrl: idFrontUrl ?? this.idFrontUrl,
      idBackUrl: idBackUrl ?? this.idBackUrl,
      criminalRecordUrl: criminalRecordUrl ?? this.criminalRecordUrl,
      averageRating: averageRating ?? this.averageRating,
      totalJobs: totalJobs ?? this.totalJobs,
      totalReviews: totalReviews ?? this.totalReviews,
      isOnline: isOnline ?? this.isOnline,
      currentZone: currentZone ?? this.currentZone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId, specialties, verificationStatus, idFrontUrl,
        idBackUrl, criminalRecordUrl, averageRating, totalJobs,
        totalReviews, isOnline, currentZone, createdAt, updatedAt,
      ];
}
