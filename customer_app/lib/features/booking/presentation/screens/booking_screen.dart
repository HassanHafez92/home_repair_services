import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../jobs/bloc/job_bloc.dart';
import '../../../jobs/bloc/job_event.dart';
import '../../../jobs/bloc/job_state.dart';

/// Booking Screen — Map + Voice Note + Service Request (BLoC-connected)
class BookingScreen extends StatefulWidget {
  final String serviceCategory;

  const BookingScreen({super.key, required this.serviceCategory});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isRecording = false;
  bool _hasRecordedNote = false;

  final Map<String, String> _categoryNames = {
    'plumbing': 'سباكة',
    'electrical': 'كهرباء',
    'hvac': 'تكييف',
    'carpentry': 'نجارة',
    'painting': 'دهان',
    'appliances': 'أجهزة منزلية',
    'emergency': 'طوارئ',
  };

  void _submitBooking() {
    context.read<JobBloc>().add(JobBookingRequested(
          serviceCategory: widget.serviceCategory,
          lat: 30.0444, // TODO: Get from location service
          lng: 31.2357,
          address: 'المهندسين، شارع الجيزة، الجيزة',
          description: _hasRecordedNote ? 'ملاحظة صوتية مرفقة' : null,
          isEmergency: widget.serviceCategory == 'emergency',
        ));
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = _categoryNames[widget.serviceCategory] ?? 'خدمة';

    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobSearchingTechnician) {
          context.go('/tracking/${state.jobId}');
        } else if (state is JobError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: FixawyColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          final isLoading = state is JobBookingInProgress;

          return Scaffold(
            backgroundColor: FixawyColors.background,
            appBar: AppBar(
              title: Text('طلب $categoryName'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: isLoading ? null : () => context.pop(),
              ),
            ),
            body: Column(
              children: [
                // ─── Map Area ──────────────────────────────────
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    color: FixawyColors.surfaceVariant,
                    child: Stack(
                      children: [
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_rounded,
                                  size: 64, color: FixawyColors.textHint),
                              SizedBox(height: 8),
                              Text(
                                'خريطة جوجل',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: FixawyColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Center(
                          child: Icon(Icons.location_on,
                              size: 48, color: FixawyColors.accent),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: FixawyColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    color: FixawyColors.primary, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'المهندسين، شارع الجيزة، الجيزة',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: FixawyColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.edit_location_alt_rounded,
                                    color: FixawyColors.textHint, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Bottom Panel ──────────────────────────────
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: FixawyColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: FixawyColors.primarySurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.build_rounded,
                                    size: 16, color: FixawyColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  categoryName,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: FixawyColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Voice note
                          const Text(
                            'وصف المشكلة (اختياري)',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: FixawyColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      if (_isRecording) {
                                        _isRecording = false;
                                        _hasRecordedNote = true;
                                      } else {
                                        _isRecording = true;
                                      }
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _isRecording
                                    ? FixawyColors.accent.withValues(alpha: 0.05)
                                    : _hasRecordedNote
                                        ? FixawyColors.success.withValues(alpha: 0.05)
                                        : FixawyColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isRecording
                                      ? FixawyColors.accent
                                      : _hasRecordedNote
                                          ? FixawyColors.success
                                          : FixawyColors.divider,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _hasRecordedNote
                                        ? Icons.check_circle_rounded
                                        : _isRecording
                                            ? Icons.stop_circle_rounded
                                            : Icons.mic_rounded,
                                    size: 28,
                                    color: _hasRecordedNote
                                        ? FixawyColors.success
                                        : _isRecording
                                            ? FixawyColors.accent
                                            : FixawyColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _hasRecordedNote
                                        ? 'تم تسجيل ملاحظة صوتية ✓'
                                        : _isRecording
                                            ? 'جاري التسجيل... اضغط للإيقاف'
                                            : 'اضغط لتسجيل ملاحظة صوتية',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _hasRecordedNote
                                          ? FixawyColors.success
                                          : _isRecording
                                              ? FixawyColors.accent
                                              : FixawyColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Emergency flag
                          if (widget.serviceCategory == 'emergency')
                            Container(
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: FixawyColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: FixawyColors.accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.flash_on_rounded,
                                      color: FixawyColors.accent, size: 22),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'طلب طوارئ — سيتم إرسال أقرب فني متاح',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: FixawyColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Inspection fee
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: FixawyColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('رسوم المعاينة',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      color: FixawyColors.textSecondary,
                                    )),
                                Text('٧٥ ج.م',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: FixawyColors.textPrimary,
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Confirm button
                          SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submitBooking,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FixawyColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    FixawyColors.primary.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'تأكيد الطلب',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
