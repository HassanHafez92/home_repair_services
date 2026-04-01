// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      uid: json['uid'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.customer,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      isActive: json['isActive'] as bool? ?? true,
      fcmToken: json['fcmToken'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'phone': instance.phone,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'isActive': instance.isActive,
      'fcmToken': instance.fcmToken,
    };

const _$UserRoleEnumMap = {
  UserRole.customer: 'customer',
  UserRole.technician: 'technician',
  UserRole.admin: 'admin',
};
