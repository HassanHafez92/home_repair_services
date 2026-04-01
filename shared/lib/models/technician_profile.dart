import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'technician_profile.freezed.dart';
part 'technician_profile.g.dart';

enum VerificationStatus {
  @JsonValue('pending') pending,
  @JsonValue('approved') approved,
  @JsonValue('rejected') rejected,
}

@freezed
class TechnicianProfile with _$TechnicianProfile {
  const factory TechnicianProfile({
    required String userId,
    @Default([]) List<String> specialty,
    @Default(VerificationStatus.pending) VerificationStatus verificationStatus,
    String? idFrontUrl,
    String? idBackUrl,
    String? criminalRecordUrl,
    @Default(0.0) double averageRating,
    @Default(0) int totalJobs,
    @Default(false) bool isOnline,
    String? currentZone,
  }) = _TechnicianProfile;

  factory TechnicianProfile.fromJson(Map<String, dynamic> json) =>
      _$TechnicianProfileFromJson(json);
}
