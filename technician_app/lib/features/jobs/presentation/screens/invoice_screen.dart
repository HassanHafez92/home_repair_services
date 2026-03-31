import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tech_theme.dart';
import '../../bloc/tech_job_bloc.dart';

/// Invoice Builder — Technician creates itemized invoice with receipt photo
class InvoiceScreen extends StatefulWidget {
  final String jobId;

  const InvoiceScreen({super.key, required this.jobId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final List<_InvoiceItem> _items = [
    _InvoiceItem(name: 'تصليح حنفية', amount: 150),
  ];
  double _materialsAmount = 0;
  bool _receiptCaptured = false;

  double get _laborTotal =>
      _items.fold(0, (sum, item) => sum + item.amount);
  double get _total => 75 + _laborTotal + _materialsAmount; // 75 = inspection

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
          context.go('/dashboard');
        }
      },
      builder: (context, state) {
        final isSubmitting = state is TechJobLoading;

        return Scaffold(
          backgroundColor: TechColors.background,
      appBar: AppBar(
        title: const Text('إنشاء الفاتورة'),
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
                  // Inspection fee (read-only)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TechColors.online.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: TechColors.online.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: TechColors.online, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'رسوم المعاينة (محددة مسبقاً)',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color: TechColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '٧٥ ج.م',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: TechColors.online,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Labor Items ───────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'أعمال الصيانة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TechColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _items.add(_InvoiceItem(
                              name: 'بند جديد',
                              amount: 0,
                            ));
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: TechColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 16, color: TechColors.accent),
                              SizedBox(width: 4),
                              Text(
                                'إضافة بند',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: TechColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(_items.length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TechColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: TechColors.divider),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: TextEditingController(
                                text: _items[index].name,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'وصف البند',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (v) => _items[index].name = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: TextEditingController(
                                text: _items[index].amount > 0
                                    ? _items[index].amount.toInt().toString()
                                    : '',
                              ),
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                hintText: '٠',
                                suffixText: 'ج.م',
                                suffixStyle: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: TechColors.textHint,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: TechColors.divider,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (v) {
                                setState(() {
                                  _items[index].amount =
                                      double.tryParse(v) ?? 0;
                                });
                              },
                            ),
                          ),
                          if (_items.length > 1)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _items.removeAt(index)),
                              child: const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: TechColors.offline,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // ─── Materials ─────────────────────────────────
                  const Text(
                    'قطع الغيار',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TechColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TechColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TechColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'إجمالي قطع الغيار',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TechColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              hintText: '٠',
                              suffixText: 'ج.م',
                              suffixStyle: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                            onChanged: (v) {
                              setState(() {
                                _materialsAmount =
                                    double.tryParse(v) ?? 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Receipt Photo ─────────────────────────────
                  const Text(
                    'صورة الإيصال (إجباري)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TechColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '⚠️ يجب التقاط الصورة بالكاميرا مباشرة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: TechColors.offline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      // TODO: Launch camera (no gallery access)
                      setState(() => _receiptCaptured = true);
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _receiptCaptured
                            ? TechColors.online.withValues(alpha: 0.05)
                            : TechColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _receiptCaptured
                              ? TechColors.online
                              : TechColors.divider,
                          style: _receiptCaptured
                              ? BorderStyle.solid
                              : BorderStyle.none,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _receiptCaptured
                                  ? Icons.check_circle_rounded
                                  : Icons.camera_alt_rounded,
                              size: 36,
                              color: _receiptCaptured
                                  ? TechColors.online
                                  : TechColors.textHint,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _receiptCaptured
                                  ? 'تم التقاط صورة الإيصال ✓'
                                  : 'اضغط لالتقاط صورة الإيصال',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _receiptCaptured
                                    ? TechColors.online
                                    : TechColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Total & Submit ────────────────────────────────
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الإجمالي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TechColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: TechColors.earningsGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_total.toInt()} ج.م',
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_receiptCaptured && _laborTotal > 0 &&
                            !isSubmitting)
                        ? () {
                            context.read<TechJobBloc>().add(
                              TechJobInvoiceSubmitted(
                                jobId: widget.jobId,
                                inspectionFee: 75,
                                laborItems: _items
                                    .map((e) => {
                                          'name': e.name,
                                          'amount': e.amount,
                                        })
                                    .toList(),
                                materialsAmount: _materialsAmount,
                                receiptPhotoUrl: 'dummy_receipt.jpg', // TODO: actual upload
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TechColors.accent,
                      disabledBackgroundColor:
                          TechColors.accent.withValues(alpha: 0.3),
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
                            'إرسال الفاتورة للعميل',
                            style: TextStyle(fontFamily: 'Cairo'),
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

class _InvoiceItem {
  String name;
  double amount;

  _InvoiceItem({required this.name, required this.amount});
}
