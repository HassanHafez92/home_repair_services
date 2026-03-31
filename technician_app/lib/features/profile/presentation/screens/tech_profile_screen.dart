import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tech_theme.dart';
import '../../../auth/bloc/tech_auth_bloc.dart';

/// Technician Profile Screen
class TechProfileScreen extends StatelessWidget {
  const TechProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TechAuthBloc, TechAuthState>(
      listener: (context, state) {
        if (state is TechAuthUnauthenticated) {
          context.go('/auth');
        } else if (state is TechAuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: TechColors.offline,
            ),
          );
        }
      },
      builder: (context, state) {
        String displayName = 'فني';
        String category = 'خدمات';

        if (state is TechAuthAuthenticated) {
          displayName = state.displayName ?? 'فني';
          if (state.categories.isNotEmpty) {
            category = state.categories.first;
          }
        }

        return Scaffold(
          backgroundColor: TechColors.background,
          appBar: AppBar(
            title: const Text('الملف الشخصي'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar & Info
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: TechColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TechColors.primary.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.engineering_rounded,
                    size: 44,
                    color: TechColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: TechColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TechColors.online.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'فني $category معتمد ✓',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TechColors.online,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats row
                Row(
                  children: [
                    _ProfileStat(label: 'التقييم', value: '٤.٨ ⭐'),
                    _ProfileStat(label: 'طلبات مكتملة', value: '١٢٧'),
                    _ProfileStat(label: 'الأقدمية', value: '٦ أشهر'),
                  ],
                ),
                const SizedBox(height: 32),

                // Menu items
                _ProfileMenuItem(
                  icon: Icons.badge_rounded,
                  label: 'المستندات',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.map_rounded,
                  label: 'مناطق العمل',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.schedule_rounded,
                  label: 'ساعات العمل',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'الإحصائيات',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'المساعدة والدعم',
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<TechAuthBloc>().add(
                        const TechAuthSignOutRequested(),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TechColors.offline,
                      side: const BorderSide(
                        color: TechColors.offline,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TechColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TechColors.divider),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TechColors.primary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: TechColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: TechColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: TechColors.primary),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: TechColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: TechColors.textHint,
        ),
      ),
    );
  }
}
