import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Represents a user in the Fixawy platform.
/// Used by both customer and technician apps.
class UserModel extends Equatable {
  final String uid;
  final String phone;
  final String? email;
  final UserRole role;
  final String displayName;
  final String? photoUrl;
  final bool isActive;
  final bool isBlocked;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.phone,
    this.email,
    required this.role,
    required this.displayName,
    this.photoUrl,
    this.isActive = true,
    this.isBlocked = false,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      role: UserRole.fromString(data['role'] as String? ?? 'customer'),
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      isBlocked: data['isBlocked'] as bool? ?? false,
      fcmToken: data['fcmToken'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'phone': phone,
      'email': email,
      'role': role.value,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? phone,
    String? email,
    UserRole? role,
    String? displayName,
    String? photoUrl,
    bool? isActive,
    bool? isBlocked,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid, phone, email, role, displayName,
        photoUrl, isActive, isBlocked, fcmToken,
        createdAt, updatedAt,
      ];
}
