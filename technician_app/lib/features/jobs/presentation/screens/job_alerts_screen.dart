import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tech_theme.dart';
import '../../../auth/bloc/tech_auth_bloc.dart';
import '../../bloc/tech_job_bloc.dart';

/// Job Alerts Screen — Incoming job requests for technician
class JobAlertsScreen extends StatefulWidget {
  const JobAlertsScreen({super.key});

  @override
  State<JobAlertsScreen> createState() => _JobAlertsScreenState();
}

class _JobAlertsScreenState extends State<JobAlertsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    final authState = context.read<TechAuthBloc>().state;
    if (authState is TechAuthAuthenticated) {
      context.read<TechJobBloc>().add(TechJobAlertsRequested(authState.categories));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechColors.background,
      appBar: AppBar(title: const Text('طلبات جديدة')),
      body: BlocConsumer<TechJobBloc, TechJobState>(
        listener: (context, state) {
          if (state is TechJobActive) {
            // When job is accepted, navigate to execution
            context.push('/job/${state.jobId}/execution');
          } else if (state is TechJobError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                backgroundColor: TechColors.offline,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TechJobLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TechJobAlertsLoaded) {
            if (state.alerts.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد طلبات جديدة حالياً',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: TechColors.textSecondary,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.alerts.length,
              itemBuilder: (context, index) {
                final alert = state.alerts[index];
                return _JobAlertCard(
                  service: alert['serviceType'] ?? 'غير محدد',
                  description: alert['issueDescription'] ?? 'بدون وصف',
                  address: alert['address'] ?? 'غير محدد',
                  distance: alert['distance'] != null ? '${alert['distance']} كم' : 'غير معروف',
                  inspectionFee: '${alert['inspectionFee'] ?? 75}',
                  isEmergency: alert['isEmergency'] ?? false,
                  time: alert['timeAgo'] ?? 'الآن',
                  onAccept: () {
                    context.read<TechJobBloc>().add(
                          TechJobAccepted(alert['id'] ?? alert['jobId']),
                        );
                  },
                );
              },
            );
          } else if (state is TechJobError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'حدث خطأ: ${state.message}',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  TextButton(
                    onPressed: _loadAlerts,
                    child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text('في انتظار الطلبات...', style: TextStyle(fontFamily: 'Cairo')),
          );
        },
      ),
    );
  }
}

class _JobAlertCard extends StatelessWidget {
  final String service;
  final String description;
  final String address;
  final String distance;
  final String inspectionFee;
  final bool isEmergency;
  final String time;
  final VoidCallback onAccept;

  const _JobAlertCard({
    required this.service,
    required this.description,
    required this.address,
    required this.distance,
    required this.inspectionFee,
    required this.isEmergency,
    required this.time,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TechColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEmergency
              ? TechColors.offline.withValues(alpha: 0.3)
              : TechColors.divider,
          width: isEmergency ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (isEmergency)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: TechColors.offline,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '🔴 طوارئ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: TechColors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  service,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: TechColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: TechColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TechColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: TechColors.accent,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$address • $distance',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: TechColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.payments_rounded,
                size: 16,
                color: TechColors.earningsGreen,
              ),
              const SizedBox(width: 4),
              Text(
                'رسوم المعاينة: $inspectionFee ج.م',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TechColors.earningsGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      // Decline
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TechColors.textSecondary,
                      side: const BorderSide(color: TechColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'رفض',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TechColors.online,
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'قبول الطلب',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
