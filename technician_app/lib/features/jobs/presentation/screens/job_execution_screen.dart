import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tech_theme.dart';
import '../../bloc/tech_job_bloc.dart';

/// Job Execution Screen — Active job management for technician
class JobExecutionScreen extends StatefulWidget {
  final String jobId;

  const JobExecutionScreen({super.key, required this.jobId});

  @override
  State<JobExecutionScreen> createState() => _JobExecutionScreenState();
}

class _JobExecutionScreenState extends State<JobExecutionScreen> {
  @override
  void initState() {
    super.initState();
    // Start tracking the job
    context.read<TechJobBloc>().add(TechJobTrackingStarted(widget.jobId));
  }

  int _getStatusIndex(String status) {
    switch (status) {
      case 'accepted':
      case 'en_route':
        return 0; // "في الطريق" is active
      case 'arrived':
        return 1;
      case 'diagnosing':
        return 2;
      case 'working':
        return 3;
      default:
        return 0;
    }
  }

  String _getNextStatus(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return 'arrived';
      case 1:
        return 'diagnosing';
      case 2:
        return 'working';
      default:
        return 'working';
    }
  }

  final List<String> _statusLabels = [
    'في الطريق',
    'وصلت',
    'جاري الفحص',
    'جاري العمل',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TechJobBloc, TechJobState>(
      listener: (context, state) {
        if (state is TechJobError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: TechColors.offline,
            ),
          );
        } else if (state is TechJobInvoicePending) {
          // If invoice is submitted successfully, navigate to dashboard
          context.go('/dashboard');
        }
      },
      builder: (context, state) {
        if (state is TechJobLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل الطلب')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        Map<String, dynamic> job = {};
        String currentStatus = 'en_route';

        if (state is TechJobActive) {
          job = state.jobData;
          currentStatus = state.status;
        }

        final currentIndex = _getStatusIndex(currentStatus);

        return Scaffold(
          backgroundColor: TechColors.background,
          appBar: AppBar(
            title: const Text('تفاصيل الطلب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Customer Info ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TechColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: TechColors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: TechColors.primarySurface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: TechColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['customerName'] ?? 'عميل',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: TechColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      size: 14, color: TechColors.accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    job['address'] ?? 'غير محدد',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      color: TechColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Call button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: TechColors.online.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.call_rounded,
                            color: TechColors.online,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Problem Description ───────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TechColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TechColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'وصف المشكلة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TechColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job['issueDescription'] ?? 'بدون وصف',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TechColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Voice note indicator
                        Row(
                          children: [
                            Icon(Icons.mic_rounded,
                                size: 18, color: TechColors.accent),
                            SizedBox(width: 6),
                            Text(
                              'ملاحظة صوتية مرفقة (٠:١٥)',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: TechColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Status Stepper ────────────────────────────
                  const Text(
                    'حالة الطلب',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TechColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...List.generate(_statusLabels.length, (index) {
                    final isDone = index <= currentIndex;
                    final isActive = index == currentIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? TechColors.online
                                      : TechColors.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isDone
                                      ? Icons.check_rounded
                                      : Icons.circle,
                                  size: isDone ? 16 : 8,
                                  color: isDone
                                      ? Colors.white
                                      : TechColors.textHint,
                                ),
                              ),
                              if (index < _statusLabels.length - 1)
                                Container(
                                  width: 2,
                                  height: 24,
                                  color: index < currentIndex
                                      ? TechColors.online
                                      : TechColors.divider,
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _statusLabels[index],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isDone
                                  ? TechColors.textPrimary
                                  : TechColors.textHint,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: TechColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'الحالية',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: TechColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ─── Action Buttons ────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: TechColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                if (currentIndex < 3)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<TechJobBloc>().add(
                          TechJobStatusUpdated(
                            jobId: widget.jobId,
                            newStatus: _getNextStatus(currentIndex),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TechColors.accent,
                      ),
                      child: Text(
                        currentIndex == 0
                            ? 'تأكيد الوصول'
                            : currentIndex == 1
                                ? 'بدء الفحص'
                                : 'بدء العمل',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                if (currentIndex == 3) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/invoice/${widget.jobId}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TechColors.earningsGreen,
                      ),
                      child: const Text(
                        'إنهاء العمل وإرسال الفاتورة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // Panic button
                TextButton.icon(
                  onPressed: () {
                    // TODO: Panic button
                  },
                  icon: const Icon(
                    Icons.warning_rounded,
                    color: TechColors.offline,
                    size: 18,
                  ),
                  label: const Text(
                    'الإبلاغ عن مشكلة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: TechColors.offline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}
