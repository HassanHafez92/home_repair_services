import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../jobs/bloc/job_bloc.dart';
import '../../../jobs/bloc/job_event.dart';
import '../../../jobs/bloc/job_state.dart';

/// Live Tracking Screen — Map with real-time status stepper (BLoC-connected)
class TrackingScreen extends StatefulWidget {
  final String jobId;

  const TrackingScreen({super.key, required this.jobId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final List<_TrackingStep> _steps = const [
    _TrackingStep(label: 'تم القبول', icon: Icons.check_circle_rounded),
    _TrackingStep(label: 'في الطريق', icon: Icons.directions_car_rounded),
    _TrackingStep(label: 'وصل', icon: Icons.location_on_rounded),
    _TrackingStep(label: 'جاري العمل', icon: Icons.build_rounded),
  ];

  @override
  void initState() {
    super.initState();
    // Start real-time tracking for this job
    context.read<JobBloc>().add(JobTrackingStarted(widget.jobId));
  }

  int _statusToStep(String status) {
    switch (status) {
      case 'accepted':
        return 0;
      case 'en_route':
        return 1;
      case 'arrived':
      case 'diagnosing':
        return 2;
      case 'working':
      case 'in_progress':
        return 3;
      default:
        return 0;
    }
  }

  void _callTechnician(String? phone) {
    if (phone != null && phone.isNotEmpty) {
      launchUrl(Uri.parse('tel:$phone'));
    }
  }

  void _cancelJob() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'إلغاء الطلب',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هل أنت متأكد من إلغاء هذا الطلب؟',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('لا', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<JobBloc>().add(JobCancelRequested(
                    jobId: widget.jobId,
                    reason: 'إلغاء بواسطة العميل',
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FixawyColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'نعم، إلغاء',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobInvoiceReceived) {
          context.go('/checkout/${state.jobId}');
        } else if (state is JobCancelled) {
          context.go('/home');
        } else if (state is JobCompleted) {
          context.go('/rating/${state.jobId}');
        } else if (state is JobError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: FixawyColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          final isTracking = state is JobTracking;
          final isSearching = state is JobSearchingTechnician;
          final currentStep =
              isTracking ? _statusToStep(state.status) : -1;
          final techName =
              isTracking ? (state.technicianName ?? 'فني') : 'جاري البحث...';
          final techPhone = isTracking ? state.technicianPhone : null;
          final eta = isTracking ? state.eta : null;

          return Scaffold(
            body: Stack(
              children: [
                // ─── Map Background ──────────────────────────────
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: FixawyColors.surfaceVariant,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSearching
                              ? Icons.search_rounded
                              : Icons.map_rounded,
                          size: 80,
                          color: FixawyColors.textHint,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSearching
                              ? 'جاري البحث عن فني متاح...'
                              : 'خريطة التتبع المباشر',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: FixawyColors.textHint,
                          ),
                        ),
                        if (isSearching)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: CircularProgressIndicator(
                              color: FixawyColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ─── Back Button ─────────────────────────────────
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: FixawyColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 18,
                        color: FixawyColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                // ─── Technician Card (only when tracking) ──────
                if (isTracking)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    right: 72,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: FixawyColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: FixawyColors.primarySurface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: FixawyColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  techName,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: FixawyColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  state.status == 'en_route'
                                      ? 'في الطريق'
                                      : state.status == 'arrived'
                                          ? 'وصل'
                                          : 'جاري العمل',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    color: FixawyColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (techPhone != null)
                            GestureDetector(
                              onTap: () => _callTechnician(techPhone),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: FixawyColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.call_rounded,
                                  color: FixawyColors.success,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // ─── Bottom Panel ────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    decoration: BoxDecoration(
                      color: FixawyColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: FixawyColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ETA
                        if (isTracking &&
                            (state.status == 'en_route') &&
                            eta != null)
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: FixawyColors.primarySurface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: FixawyColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'الوصول خلال ${eta.toInt()} دقائق',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: FixawyColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Searching state
                        if (isSearching)
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: FixawyColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: FixawyColors.secondary,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'جاري البحث عن فني متاح...',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: FixawyColors.secondaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Status stepper (only when tracking)
                        if (isTracking)
                          Row(
                            children:
                                List.generate(_steps.length, (index) {
                              final isDone = index <= currentStep;
                              final isActive = index == currentStep;

                              return Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        if (index > 0)
                                          Expanded(
                                            child: Container(
                                              height: 3,
                                              color: isDone
                                                  ? FixawyColors.primary
                                                  : FixawyColors.divider,
                                            ),
                                          ),
                                        Container(
                                          width: isActive ? 36 : 28,
                                          height: isActive ? 36 : 28,
                                          decoration: BoxDecoration(
                                            color: isDone
                                                ? FixawyColors.primary
                                                : FixawyColors.surfaceVariant,
                                            shape: BoxShape.circle,
                                            border: isActive
                                                ? Border.all(
                                                    color: FixawyColors.primary
                                                        .withValues(alpha: 0.3),
                                                    width: 3,
                                                  )
                                                : null,
                                          ),
                                          child: Icon(
                                            isDone
                                                ? Icons.check_rounded
                                                : _steps[index].icon,
                                            size: isActive ? 18 : 14,
                                            color: isDone
                                                ? Colors.white
                                                : FixawyColors.textHint,
                                          ),
                                        ),
                                        if (index < _steps.length - 1)
                                          Expanded(
                                            child: Container(
                                              height: 3,
                                              color: index < currentStep
                                                  ? FixawyColors.primary
                                                  : FixawyColors.divider,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _steps[index].label,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11,
                                        fontWeight: isActive
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: isDone
                                            ? FixawyColors.primary
                                            : FixawyColors.textHint,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),

                        const SizedBox(height: 20),

                        // Cancel button
                        TextButton(
                          onPressed: _cancelJob,
                          child: const Text(
                            'إلغاء الطلب',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: FixawyColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrackingStep {
  final String label;
  final IconData icon;

  const _TrackingStep({required this.label, required this.icon});
}
