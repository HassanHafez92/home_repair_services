import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Push notification model for the notification system.
class NotificationModel extends Equatable {
  final String notificationId;
  final String userId;
  final String title;
  final String titleAr;
  final String body;
  final String bodyAr;
  final NotificationType type;
  final String? jobId;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    required this.type,
    this.jobId,
    this.isRead = false,
    this.metadata,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      titleAr: data['titleAr'] as String? ?? '',
      body: data['body'] as String? ?? '',
      bodyAr: data['bodyAr'] as String? ?? '',
      type: NotificationType.fromString(data['type'] as String? ?? 'general'),
      jobId: data['jobId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'titleAr': titleAr,
      'body': body,
      'bodyAr': bodyAr,
      'type': type.value,
      'jobId': jobId,
      'isRead': isRead,
      'metadata': metadata,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [
        notificationId, userId, title, titleAr, body, bodyAr,
        type, jobId, isRead, metadata, createdAt,
      ];
}
