import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../../jobs/bloc/job_bloc.dart';
import '../../../jobs/bloc/job_event.dart';
import '../../../jobs/bloc/job_state.dart';
import '../../../notifications/bloc/notification_bloc.dart';

/// Home Screen — Dashboard with service categories and active job (BLoC-connected)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load jobs and notifications on screen init
    context.read<JobBloc>().add(const JobsLoadRequested());
    context.read<NotificationBloc>().add(const NotificationsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FixawyColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final name = state is AuthAuthenticated
                              ? (state.displayName ?? 'مستخدم')
                              : 'مستخدم';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً 👋',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: FixawyColors.textSecondary,
                                ),
                              ),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: FixawyColors.textPrimary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Notification Bell with live badge
                    GestureDetector(
                      onTap: () => context.go('/notifications'),
                      child: BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (context, state) {
                          final unread = state is NotificationsLoaded
                              ? state.unreadCount
                              : 0;
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: FixawyColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: FixawyColors.divider),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: FixawyColors.textPrimary,
                                  ),
                                ),
                                if (unread > 0)
                                  Positioned(
                                    top: 8,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: FixawyColors.accent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: FixawyColors.surface,
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        unread > 9 ? '9+' : '$unread',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Emergency CTA ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: GestureDetector(
                  onTap: () => context.push('/booking', extra: 'emergency'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE85D4A), Color(0xFFD94A38)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE85D4A).withValues(alpha: 0.3),
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
                          child: const Icon(
                            Icons.flash_on_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'طلب خدمة طوارئ',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'فني متخصص في أسرع وقت',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Section Title ──────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'خدماتنا',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: FixawyColors.textPrimary,
                  ),
                ),
              ),
            ),

            // ─── Service Grid ───────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _ServiceCard(
                    icon: Icons.plumbing_rounded,
                    nameAr: 'سباكة',
                    price: '٧٥',
                    color: const Color(0xFF4A9FE5),
                    onTap: () => context.push('/booking', extra: 'plumbing'),
                  ),
                  _ServiceCard(
                    icon: Icons.electrical_services_rounded,
                    nameAr: 'كهرباء',
                    price: '٧٥',
                    color: const Color(0xFFE8A838),
                    onTap: () =>
                        context.push('/booking', extra: 'electrical'),
                  ),
                  _ServiceCard(
                    icon: Icons.ac_unit_rounded,
                    nameAr: 'تكييف',
                    price: '١٠٠',
                    color: const Color(0xFF2CB67D),
                    onTap: () => context.push('/booking', extra: 'hvac'),
                  ),
                  _ServiceCard(
                    icon: Icons.carpenter_rounded,
                    nameAr: 'نجارة',
                    price: '٧٥',
                    color: const Color(0xFF8B6914),
                    onTap: () =>
                        context.push('/booking', extra: 'carpentry'),
                  ),
                  _ServiceCard(
                    icon: Icons.format_paint_rounded,
                    nameAr: 'دهان',
                    price: '١٠٠',
                    color: const Color(0xFFE85D4A),
                    onTap: () =>
                        context.push('/booking', extra: 'painting'),
                  ),
                  _ServiceCard(
                    icon: Icons.kitchen_rounded,
                    nameAr: 'أجهزة منزلية',
                    price: '١٠٠',
                    color: const Color(0xFF7C3AED),
                    onTap: () =>
                        context.push('/booking', extra: 'appliances'),
                  ),
                ]),
              ),
            ),

            // ─── Active Jobs Section ────────────────────────────
            SliverToBoxAdapter(
              child: BlocBuilder<JobBloc, JobState>(
                builder: (context, state) {
                  if (state is JobsLoaded && state.activeJobs.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'طلبات نشطة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: FixawyColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...state.activeJobs.map((job) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ActiveJobCard(
                                  job: job,
                                  onTap: () => context.push(
                                    '/tracking/${job['id'] ?? ''}',
                                  ),
                                ),
                              )),
                        ],
                      ),
                    );
                  }

                  if (state is JobTracking) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'طلب نشط',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: FixawyColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _LiveTrackingCard(
                            state: state,
                            onTap: () =>
                                context.push('/tracking/${state.jobId}'),
                          ),
                        ],
                      ),
                    );
                  }

                  // No active jobs — show empty state
                  return const SizedBox.shrink();
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

/// Service category card
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String nameAr;
  final String price;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.nameAr,
    required this.price,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: FixawyColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: FixawyColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              nameAr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FixawyColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'من $price ج.م',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: FixawyColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Active job preview card — data-driven
class _ActiveJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const _ActiveJobCard({required this.job, required this.onTap});

  IconData _categoryIcon(String? category) {
    switch (category) {
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'hvac':
        return Icons.ac_unit_rounded;
      case 'carpentry':
        return Icons.carpenter_rounded;
      case 'painting':
        return Icons.format_paint_rounded;
      case 'appliances':
        return Icons.kitchen_rounded;
      default:
        return Icons.home_repair_service_rounded;
    }
  }

  String _statusText(String? status) {
    switch (status) {
      case 'pending':
        return 'جاري البحث عن فني...';
      case 'accepted':
        return 'تم قبول الطلب';
      case 'en_route':
        return 'الفني في الطريق';
      case 'arrived':
        return 'الفني وصل';
      case 'in_progress':
        return 'جاري العمل';
      case 'invoice_submitted':
        return 'في انتظار الموافقة';
      default:
        return status ?? 'نشط';
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = job['serviceCategory'] as String?;
    final status = job['status'] as String?;
    final techName = job['technicianName'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FixawyColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FixawyColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: FixawyColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _categoryIcon(category),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    techName.isNotEmpty
                        ? '${_categoryLabel(category)} — $techName'
                        : _categoryLabel(category),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: FixawyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: status == 'pending'
                            ? FixawyColors.warning
                            : FixawyColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusText(status),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: FixawyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: FixawyColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String? category) {
    switch (category) {
      case 'plumbing':
        return 'سباكة';
      case 'electrical':
        return 'كهرباء';
      case 'hvac':
        return 'تكييف';
      case 'carpentry':
        return 'نجارة';
      case 'painting':
        return 'دهان';
      case 'appliances':
        return 'أجهزة منزلية';
      case 'emergency':
        return 'طوارئ';
      default:
        return 'خدمة';
    }
  }
}

/// Live tracking card for when a job is being tracked
class _LiveTrackingCard extends StatelessWidget {
  final JobTracking state;
  final VoidCallback onTap;

  const _LiveTrackingCard({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FixawyColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FixawyColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: FixawyColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.technicianName ?? 'فني',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: FixawyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: FixawyColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.eta != null
                            ? 'في الطريق — ${state.eta!.toInt()} دقائق'
                            : state.status,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: FixawyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: FixawyColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
