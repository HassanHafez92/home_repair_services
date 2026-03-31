import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tech_theme.dart';
import '../../../auth/bloc/tech_auth_bloc.dart';
import '../../../jobs/bloc/tech_job_bloc.dart';

/// Technician Dashboard — Earnings, status toggle, recent jobs
class TechDashboardScreen extends StatefulWidget {
  const TechDashboardScreen({super.key});

  @override
  State<TechDashboardScreen> createState() => _TechDashboardScreenState();
}

class _TechDashboardScreenState extends State<TechDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<TechAuthBloc>().state;
    if (authState is TechAuthAuthenticated) {
      context.read<TechJobBloc>().add(TechJobAlertsRequested(authState.categories));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TechAuthBloc, TechAuthState>(
      builder: (context, authState) {
        final bool isOnline =
            authState is TechAuthAuthenticated ? authState.isOnline : false;
        final String displayName = authState is TechAuthAuthenticated
            ? (authState.displayName ?? 'فني')
            : 'فني';
        final String category = authState is TechAuthAuthenticated
            ? (authState.categories.isNotEmpty
                ? authState.categories.first
                : 'عام')
            : 'عام';

        return BlocBuilder<TechJobBloc, TechJobState>(
          builder: (context, jobState) {
            final int alertsCount =
                (jobState is TechJobAlertsLoaded) ? jobState.alerts.length : 0;

            return Scaffold(
      backgroundColor: TechColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: TechColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: TechColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً، $displayName 👋',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color: TechColors.textSecondary,
                            ),
                          ),
                          Text(
                            category,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: TechColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Wallet button
                    GestureDetector(
                      onTap: () => context.push('/wallet'),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: TechColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: TechColors.divider),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: TechColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Online/Offline Toggle ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: GestureDetector(
                  onTap: () {
                    context
                        .read<TechAuthBloc>()
                        .add(TechAuthStatusToggled(!isOnline));
                    if (!isOnline && authState is TechAuthAuthenticated) {
                      context.read<TechJobBloc>().add(
                          TechJobAlertsRequested(authState.categories));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isOnline
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF2CB67D),
                                Color(0xFF1F9B68),
                              ],
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFF6C757D),
                                Color(0xFF4A5058),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isOnline
                                  ? TechColors.online
                                  : TechColors.textHint)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isOnline
                                ? Icons.wifi_rounded
                                : Icons.wifi_off_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOnline ? 'أنت متاح الآن' : 'أنت غير متاح',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                isOnline
                                    ? 'اضغط لإيقاف الاستقبال'
                                    : 'اضغط لبدء استقبال الطلبات',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 56,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            alignment: isOnline
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 26,
                              height: 26,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Today's Earnings ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: TechColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: TechColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أرباح اليوم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: TechColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '١,٢٥٠ ج.م',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: TechColors.earningsGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatChip(
                            label: 'طلبات مكتملة',
                            value: '٥',
                            color: TechColors.online,
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            label: 'التقييم',
                            value: '٤.٨ ⭐',
                            color: TechColors.busy,
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            label: 'ساعات العمل',
                            value: '٦',
                            color: TechColors.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Quick Actions ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.notifications_active_rounded,
                        label: 'الطلبات الجديدة',
                        color: TechColors.accent,
                        badge: alertsCount > 0 ? alertsCount : null,
                        onTap: () => context.push('/job-alerts'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'المحفظة',
                        color: TechColors.earningsGreen,
                        onTap: () => context.push('/wallet'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.person_rounded,
                        label: 'الملف الشخصي',
                        color: TechColors.primary,
                        onTap: () => context.push('/profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Recent Jobs ─────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 28, 24, 14),
                child: Text(
                  'الطلبات الأخيرة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TechColors.textPrimary,
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildListDelegate([
                _RecentJobCard(
                  service: 'سباكة',
                  customer: 'محمد عبدالله',
                  amount: '٣٥٠',
                  status: 'مكتمل',
                  statusColor: TechColors.online,
                  time: 'اليوم ١٠:٣٠ ص',
                ),
                _RecentJobCard(
                  service: 'سباكة',
                  customer: 'أحمد سمير',
                  amount: '٢٠٠',
                  status: 'مكتمل',
                  statusColor: TechColors.online,
                  time: 'اليوم ٨:١٥ ص',
                ),
                _RecentJobCard(
                  service: 'سباكة',
                  customer: 'علي حسن',
                  amount: '٥٠٠',
                  status: 'ملغي',
                  statusColor: TechColors.offline,
                  time: 'أمس ٤:٠٠ م',
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ],
        ),
      ),
    );
  });
});
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: TechColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int? badge;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TechColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TechColors.divider),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: TechColors.offline,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TechColors.surface,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: TechColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentJobCard extends StatelessWidget {
  final String service;
  final String customer;
  final String amount;
  final String status;
  final Color statusColor;
  final String time;

  const _RecentJobCard({
    required this.service,
    required this.customer,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TechColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TechColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$service — $customer',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TechColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
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
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amount ج.م',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TechColors.earningsGreen,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
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
