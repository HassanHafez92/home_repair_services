import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../jobs/bloc/job_bloc.dart';
import '../../../jobs/bloc/job_event.dart';
import '../../../jobs/bloc/job_state.dart';

/// Rating Screen — Post-job technician rating (BLoC-connected)
class RatingScreen extends StatefulWidget {
  final String jobId;

  const RatingScreen({super.key, required this.jobId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRating() {
    context.read<JobBloc>().add(JobRatingSubmitted(
          jobId: widget.jobId,
          rating: _rating.toDouble(),
          comment: _commentController.text.trim().isNotEmpty
              ? _commentController.text.trim()
              : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobRated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'شكراً لتقييمك! 🌟',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: FixawyColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.go('/home');
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
          final isSubmitting = state is JobLoading;

          return Scaffold(
            backgroundColor: FixawyColors.background,
            appBar: AppBar(
              title: const Text('تقييم الخدمة'),
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ─── Success Icon ────────────────────────────
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: FixawyColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 56,
                        color: FixawyColors.success,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'تم إتمام الخدمة بنجاح!',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: FixawyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'كيف كانت تجربتك مع الفني؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        color: FixawyColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── Star Rating ─────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _rating = index + 1),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                            child: AnimatedScale(
                              scale: index < _rating ? 1.2 : 1.0,
                              duration:
                                  const Duration(milliseconds: 200),
                              child: Icon(
                                index < _rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 44,
                                color: index < _rating
                                    ? FixawyColors.secondary
                                    : FixawyColors.textHint,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _rating == 0
                          ? ''
                          : _rating <= 2
                              ? 'سيئة 😞'
                              : _rating == 3
                                  ? 'متوسطة 😐'
                                  : _rating == 4
                                      ? 'جيدة 😊'
                                      : 'ممتازة! 🌟',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FixawyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Comment Field ───────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: FixawyColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: FixawyColors.divider),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 3,
                        enabled: !isSubmitting,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'أضف تعليق (اختياري)...',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: FixawyColors.textHint,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ─── Submit Button ───────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _rating == 0 || isSubmitting
                            ? null
                            : _submitRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FixawyColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              FixawyColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'إرسال التقييم',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed:
                          isSubmitting ? null : () => context.go('/home'),
                      child: const Text(
                        'تخطي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: FixawyColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
