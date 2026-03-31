import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tech_theme.dart';
import '../../../auth/bloc/tech_auth_bloc.dart';

/// KYC Screen — Technician identity verification and document upload
class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  bool _idUploaded = false;
  bool _certificateUploaded = false;
  bool _criminalRecordUploaded = false;
  String _selectedCategory = '';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'plumbing', 'nameAr': 'سباكة', 'icon': Icons.plumbing_rounded},
    {'id': 'electrical', 'nameAr': 'كهرباء', 'icon': Icons.electrical_services_rounded},
    {'id': 'hvac', 'nameAr': 'تكييف', 'icon': Icons.ac_unit_rounded},
    {'id': 'carpentry', 'nameAr': 'نجارة', 'icon': Icons.carpenter_rounded},
    {'id': 'painting', 'nameAr': 'دهان', 'icon': Icons.format_paint_rounded},
    {'id': 'appliances', 'nameAr': 'أجهزة منزلية', 'icon': Icons.kitchen_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TechAuthBloc, TechAuthState>(
      listener: (context, state) {
        if (state is TechAuthKycPending) {
          // Go to dashboard (the dashboard/router can handle showing a pending screen or similar)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال المستندات بنجاح وفي انتظار المراجعة', style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: TechColors.online,
            ),
          );
          // Normally we re-check auth to go to the proper screen
          context.go('/dashboard');
        } else if (state is TechAuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: TechColors.offline,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TechAuthLoading;

        return Scaffold(
          backgroundColor: TechColors.background,
          appBar: AppBar(title: const Text('توثيق الحساب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TechColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: TechColors.accent, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'يجب إكمال التوثيق لبدء استقبال الطلبات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TechColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── Specialization ──────────────────────────────
            const Text(
              'التخصص',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TechColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TechColors.primary
                          : TechColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? TechColors.primary
                            : TechColors.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : TechColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat['nameAr'] as String,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : TechColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // ─── Document Uploads ────────────────────────────
            const Text(
              'المستندات المطلوبة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TechColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            _DocumentUploadCard(
              title: 'بطاقة الرقم القومي',
              subtitle: 'صورة واضحة للوجهين',
              icon: Icons.badge_rounded,
              isUploaded: _idUploaded,
              onTap: () => setState(() => _idUploaded = true),
            ),
            const SizedBox(height: 12),

            _DocumentUploadCard(
              title: 'شهادة الخبرة / التخصص',
              subtitle: 'شهادة تدريب أو خبرة في المجال',
              icon: Icons.workspace_premium_rounded,
              isUploaded: _certificateUploaded,
              onTap: () => setState(() => _certificateUploaded = true),
            ),
            const SizedBox(height: 12),

            _DocumentUploadCard(
              title: 'فيش جنائي',
              subtitle: 'صادر حديثاً (أقل من ٣ أشهر)',
              icon: Icons.security_rounded,
              isUploaded: _criminalRecordUploaded,
              onTap: () => setState(() => _criminalRecordUploaded = true),
            ),
            const SizedBox(height: 32),

            // ─── Submit Button ───────────────────────────────
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : (_idUploaded &&
                            _certificateUploaded &&
                            _criminalRecordUploaded &&
                            _selectedCategory.isNotEmpty)
                        ? () {
                            context.read<TechAuthBloc>().add(TechAuthKycSubmitted(_selectedCategory));
                          }
                        : null,
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
                        'إرسال للمراجعة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isUploaded;
  final VoidCallback onTap;

  const _DocumentUploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUploaded
              ? TechColors.online.withValues(alpha: 0.05)
              : TechColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? TechColors.online : TechColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUploaded
                    ? TechColors.online.withValues(alpha: 0.1)
                    : TechColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                color: isUploaded ? TechColors.online : TechColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: TechColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploaded ? 'تم الرفع ✓' : subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isUploaded
                          ? TechColors.online
                          : TechColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded
                  ? Icons.check_rounded
                  : Icons.upload_file_rounded,
              color: isUploaded ? TechColors.online : TechColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
