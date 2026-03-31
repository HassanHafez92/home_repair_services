import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../../wallet/bloc/wallet_bloc.dart';

/// Profile Screen — User account management (BLoC-connected)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const WalletLoadRequested());
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FixawyColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تسجيل الخروج',
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: FixawyColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ─── Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    children: [
                      // Avatar
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final photoUrl = state is AuthAuthenticated
                              ? state.photoUrl
                              : null;
                          final name = state is AuthAuthenticated
                              ? (state.displayName ?? 'مستخدم')
                              : 'مستخدم';
                          final phone = state is AuthAuthenticated
                              ? (state.phone ?? '')
                              : '';

                          return Column(
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: FixawyColors.primarySurface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FixawyColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 3,
                                  ),
                                ),
                                child: photoUrl != null && photoUrl.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          photoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.person_rounded,
                                            size: 44,
                                            color: FixawyColors.primary,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_rounded,
                                        size: 44,
                                        color: FixawyColors.primary,
                                      ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: FixawyColors.textPrimary,
                                ),
                              ),
                              if (phone.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    color: FixawyColors.textSecondary,
                                    letterSpacing: 1,
                                  ),
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // ─── Wallet Card ─────────────────────────────
                      BlocBuilder<WalletBloc, WalletState>(
                        builder: (context, state) {
                          final balance = state is WalletLoaded
                              ? state.balance
                              : 0.0;

                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0D7377), Color(0xFF095456)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'رصيد المحفظة',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 13,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${balance.toStringAsFixed(0)} ج.م',
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: state is WalletLoading
                                      ? const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.account_balance_wallet_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Menu Sections ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الحساب',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: FixawyColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MenuItem(
                        icon: Icons.history_rounded,
                        label: 'سجل الطلبات',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.location_on_rounded,
                        label: 'العناوين المحفوظة',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.payment_rounded,
                        label: 'طرق الدفع',
                        onTap: () {},
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'الإعدادات',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: FixawyColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MenuItem(
                        icon: Icons.language_rounded,
                        label: 'اللغة',
                        trailing: 'العربية',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.dark_mode_rounded,
                        label: 'المظهر',
                        trailing: 'فاتح',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        label: 'الإشعارات',
                        onTap: () {},
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'الدعم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: FixawyColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'المساعدة والدعم',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'سياسة الخصوصية',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.description_outlined,
                        label: 'الشروط والأحكام',
                        onTap: () {},
                      ),

                      const SizedBox(height: 24),
                      // Logout
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _signOut,
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

                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'فيكساوي v1.0.0',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: FixawyColors.textHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
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
            color: FixawyColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: FixawyColors.primary),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: FixawyColors.textPrimary,
          ),
        ),
        trailing: trailing != null
            ? Text(
                trailing!,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: FixawyColors.textHint,
                ),
              )
            : const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: FixawyColors.textHint,
              ),
      ),
    );
  }
}
