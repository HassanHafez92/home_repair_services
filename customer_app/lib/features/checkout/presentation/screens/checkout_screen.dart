import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../jobs/bloc/job_bloc.dart';
import '../../../jobs/bloc/job_event.dart';
import '../../../jobs/bloc/job_state.dart';

/// Checkout Screen — Invoice approval with itemized breakdown (BLoC-connected)
class CheckoutScreen extends StatefulWidget {
  final String jobId;

  const CheckoutScreen({super.key, required this.jobId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isApproving = false;
  bool _isDisputing = false;

  void _approveInvoice() {
    setState(() => _isApproving = true);
    context.read<JobBloc>().add(
      JobInvoiceResponse(jobId: widget.jobId, approved: true),
    );
  }

  void _disputeInvoice() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'سبب الرفض',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          decoration: InputDecoration(
            hintText: 'اذكر سبب رفض الفاتورة...',
            hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              color: FixawyColors.textHint,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _isDisputing = true);
              context.read<JobBloc>().add(
                JobInvoiceResponse(
                  jobId: widget.jobId,
                  approved: false,
                  disputeReason: reasonController.text.trim(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FixawyColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'إرسال',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
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
        if (state is JobCompleted) {
          context.go('/rating/${state.jobId}');
        } else if (state is JobError) {
          setState(() {
            _isApproving = false;
            _isDisputing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: FixawyColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          // Extract invoice data from state
          final invoice = state is JobInvoiceReceived ? state : null;
          final inspectionFee = invoice?.inspectionFee ?? 75.0;
          final laborItems = invoice?.laborItems ?? [];
          final materialsAmount = invoice?.materialsAmount ?? 0.0;
          final total = invoice?.total ?? 0.0;
          final receiptUrl = invoice?.receiptPhotoUrl;
          final isProcessing = _isApproving || _isDisputing;

          return Scaffold(
            backgroundColor: FixawyColors.background,
            appBar: AppBar(
              title: const Text('الفاتورة'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: isProcessing ? null : () => context.pop(),
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
                        // Job ID
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: FixawyColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long_rounded,
                                color: FixawyColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'رقم الطلب: #${widget.jobId.length >= 8 ? widget.jobId.substring(0, 8).toUpperCase() : widget.jobId.toUpperCase()}',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: FixawyColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Invoice title
                        const Text(
                          'تفاصيل الفاتورة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: FixawyColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Inspection fee
                        _InvoiceRow(
                          label: 'رسوم المعاينة',
                          amount: inspectionFee.toStringAsFixed(0),
                          isDone: true,
                        ),
                        const SizedBox(height: 8),

                        // Labor items from BLoC
                        ...laborItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _InvoiceRow(
                              label: item['description'] ?? 'بند عمالة',
                              amount: (item['amount'] ?? 0)
                                  .toDouble()
                                  .toStringAsFixed(0),
                            ),
                          ),
                        ),

                        // Materials
                        if (materialsAmount > 0) ...[
                          _InvoiceRow(
                            label: 'قطع الغيار / الخامات',
                            amount: materialsAmount.toStringAsFixed(0),
                            isHighlighted: true,
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Receipt photo
                        if (receiptUrl != null) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'صورة الإيصال',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: FixawyColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              receiptUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: FixawyColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    size: 36,
                                    color: FixawyColors.textHint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                        Container(height: 1, color: FixawyColors.divider),
                        const SizedBox(height: 16),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الإجمالي',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: FixawyColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: FixawyColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${total.toStringAsFixed(0)} ج.م',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'جميع الأسعار محددة مسبقاً ولا يمكن تعديلها',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: FixawyColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Action Buttons ──────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: FixawyColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: isProcessing ? null : _disputeInvoice,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FixawyColors.error,
                              side: const BorderSide(
                                color: FixawyColors.error,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isDisputing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: FixawyColors.error,
                                    ),
                                  )
                                : const Text(
                                    'رفض',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: isProcessing ? null : _approveInvoice,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FixawyColors.success,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: FixawyColors.success
                                  .withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            icon: _isApproving
                                ? const SizedBox.shrink()
                                : const Icon(Icons.check_rounded, size: 20),
                            label: _isApproving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'موافقة',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isDone;
  final bool isHighlighted;

  const _InvoiceRow({
    required this.label,
    required this.amount,
    this.isDone = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? FixawyColors.secondary.withValues(alpha: 0.08)
            : FixawyColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (isDone)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: FixawyColors.success,
              ),
            ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDone
                    ? FixawyColors.textHint
                    : FixawyColors.textPrimary,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            '$amount ج.م',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDone ? FixawyColors.textHint : FixawyColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
