import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/converters.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum UserRole {
  @JsonValue('customer') customer,
  @JsonValue('technician') technician,
  @JsonValue('admin') admin,
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String phone,
    String? email,
    @Default(UserRole.customer) UserRole role,
    String? displayName,
    String? photoUrl,
    @TimestampConverter() DateTime? createdAt,
    @Default(true) bool isActive,
    String? fcmToken,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
