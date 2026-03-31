import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Represents a dispute case in the system.
class DisputeModel extends Equatable {
  final String disputeId;
  final String jobId;
  final String reportedBy;
  final String reportedAgainst;
  final DisputeReason reason;
  final String? description;
  final DisputeStatus status;
  final String? resolution;
  final String? adminNotes;
  final String? handledBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DisputeModel({
    required this.disputeId,
    required this.jobId,
    required this.reportedBy,
    required this.reportedAgainst,
    required this.reason,
    this.description,
    this.status = DisputeStatus.open,
    this.resolution,
    this.adminNotes,
    this.handledBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DisputeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DisputeModel(
      disputeId: doc.id,
      jobId: data['jobId'] as String? ?? '',
      reportedBy: data['reportedBy'] as String? ?? '',
      reportedAgainst: data['reportedAgainst'] as String? ?? '',
      reason: DisputeReason.fromString(data['reason'] as String? ?? 'other'),
      description: data['description'] as String?,
      status: DisputeStatus.fromString(data['status'] as String? ?? 'open'),
      resolution: data['resolution'] as String?,
      adminNotes: data['adminNotes'] as String?,
      handledBy: data['handledBy'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'reportedBy': reportedBy,
      'reportedAgainst': reportedAgainst,
      'reason': reason.name,
      'description': description,
      'status': status.name,
      'resolution': resolution,
      'adminNotes': adminNotes,
      'handledBy': handledBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  DisputeModel copyWith({
    String? disputeId,
    String? jobId,
    String? reportedBy,
    String? reportedAgainst,
    DisputeReason? reason,
    String? description,
    DisputeStatus? status,
    String? resolution,
    String? adminNotes,
    String? handledBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DisputeModel(
      disputeId: disputeId ?? this.disputeId,
      jobId: jobId ?? this.jobId,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedAgainst: reportedAgainst ?? this.reportedAgainst,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      resolution: resolution ?? this.resolution,
      adminNotes: adminNotes ?? this.adminNotes,
      handledBy: handledBy ?? this.handledBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        disputeId, jobId, reportedBy, reportedAgainst, reason,
        description, status, resolution, adminNotes, handledBy,
        createdAt, updatedAt,
      ];
}
