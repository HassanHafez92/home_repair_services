// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technician_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TechnicianProfileImpl _$$TechnicianProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$TechnicianProfileImpl(
      userId: json['userId'] as String,
      specialty: (json['specialty'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      verificationStatus: $enumDecodeNullable(
              _$VerificationStatusEnumMap, json['verificationStatus']) ??
          VerificationStatus.pending,
      idFrontUrl: json['idFrontUrl'] as String?,
      idBackUrl: json['idBackUrl'] as String?,
      criminalRecordUrl: json['criminalRecordUrl'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalJobs: (json['totalJobs'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      currentZone: json['currentZone'] as String?,
    );

Map<String, dynamic> _$$TechnicianProfileImplToJson(
        _$TechnicianProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'specialty': instance.specialty,
      'verificationStatus':
          _$VerificationStatusEnumMap[instance.verificationStatus]!,
      'idFrontUrl': instance.idFrontUrl,
      'idBackUrl': instance.idBackUrl,
      'criminalRecordUrl': instance.criminalRecordUrl,
      'averageRating': instance.averageRating,
      'totalJobs': instance.totalJobs,
      'isOnline': instance.isOnline,
      'currentZone': instance.currentZone,
    };

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
};
