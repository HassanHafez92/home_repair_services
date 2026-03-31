import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/notification_bloc.dart';

/// Notifications Screen — Real-time push notification history (BLoC-connected)
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FixawyColors.background,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    // Mark all as read by iterating unread notifications
                    for (final n in state.notifications) {
                      if (n['read'] != true && n['id'] != null) {
                        context.read<NotificationBloc>().add(
                          NotificationMarkRead(n['id']),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'قراءة الكل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: FixawyColors.primary,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(color: FixawyColors.primary),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: FixawyColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: FixawyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 80,
                      color: FixawyColors.textHint,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد إشعارات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FixawyColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ستظهر إشعاراتك هنا',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: FixawyColors.textHint,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = state.notifications[index];
                final isUnread = n['read'] != true;
                final type = n['type'] as String? ?? 'system';

                return GestureDetector(
                  onTap: () {
                    // Mark as read on tap
                    if (isUnread && n['id'] != null) {
                      context.read<NotificationBloc>().add(
                        NotificationMarkRead(n['id']),
                      );
                    }
                  },
                  child: _NotificationCard(
                    icon: _iconForType(type),
                    iconColor: _colorForType(type),
                    title: n['title'] ?? '',
                    body: n['body'] ?? '',
                    time: _formatTime(n['createdAt']),
                    isUnread: isUnread,
                  ),
                );
              },
            );
          }

          // Initial state — trigger load
          return const Center(
            child: CircularProgressIndicator(color: FixawyColors.primary),
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'job_accepted':
        return Icons.check_circle_rounded;
      case 'job_completed':
        return Icons.done_all_rounded;
      case 'invoice':
        return Icons.receipt_long_rounded;
      case 'rating':
        return Icons.star_rounded;
      case 'promo':
        return Icons.campaign_rounded;
      case 'tech_en_route':
        return Icons.directions_car_rounded;
      case 'tech_arrived':
        return Icons.location_on_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'job_accepted':
        return FixawyColors.success;
      case 'job_completed':
        return FixawyColors.primary;
      case 'invoice':
        return FixawyColors.primary;
      case 'rating':
        return FixawyColors.secondary;
      case 'promo':
        return FixawyColors.accent;
      case 'tech_en_route':
        return const Color(0xFF4A9FE5);
      case 'tech_arrived':
        return FixawyColors.success;
      default:
        return FixawyColors.textSecondary;
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    // Handle Firestore Timestamp or DateTime
    try {
      final dt = timestamp is DateTime
          ? timestamp
          : DateTime.fromMillisecondsSinceEpoch(
              (timestamp.seconds * 1000) + (timestamp.nanoseconds ~/ 1000000),
            );
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقائق';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعات';
      if (diff.inDays == 1) return 'أمس';
      return 'منذ ${diff.inDays} أيام';
    } catch (_) {
      return '';
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool isUnread;

  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? FixawyColors.primarySurface : FixawyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? FixawyColors.primary.withValues(alpha: 0.15)
              : FixawyColors.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: FixawyColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: FixawyColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: FixawyColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: FixawyColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
