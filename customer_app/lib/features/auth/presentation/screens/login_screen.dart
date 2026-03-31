import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

/// Login Screen — Phone OTP + Google Sign-In (BLoC-connected)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitPhone() {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = '+20${_phoneController.text.trim()}';
      context.read<AuthBloc>().add(AuthOtpRequested(phone));
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.push('/otp', extra: state.phoneNumber);
        } else if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthNeedsOnboarding) {
          context.go('/onboarding');
        } else if (state is AuthError) {
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
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: FixawyColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),

                      // ─── Logo Section ──────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: FixawyColors.primarySurface,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.home_repair_service_rounded,
                                size: 40,
                                color: FixawyColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'فيكساوي',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: FixawyColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ─── Title ─────────────────────────────────────
                      const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: FixawyColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أدخل رقم الموبايل لتسجيل الدخول أو إنشاء حساب جديد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: FixawyColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // ─── Phone Input ───────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: FixawyColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: FixawyColors.divider),
                        ),
                        child: Row(
                          children: [
                            // Country Code
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: FixawyColors.divider),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🇪🇬', style: TextStyle(fontSize: 20)),
                                  SizedBox(width: 8),
                                  Text(
                                    '+20',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: FixawyColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Phone Number Field
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.left,
                                enabled: !isLoading,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: const InputDecoration(
                                  hintText: '1XX XXX XXXX',
                                  hintStyle: TextStyle(
                                    color: FixawyColors.textHint,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 2,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'من فضلك أدخل رقم الموبايل';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'رقم الموبايل غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── Send OTP Button ───────────────────────────
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitPhone,
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
                                  'إرسال كود التحقق',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ─── Divider ───────────────────────────────────
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: FixawyColors.divider)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'أو',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                color: FixawyColors.textHint,
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: FixawyColors.divider)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ─── Google Sign-In ────────────────────────────
                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: FixawyColors.textPrimary,
                            side: const BorderSide(
                                color: FixawyColors.divider, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 28,
                            color: FixawyColors.textPrimary,
                          ),
                          label: const Text(
                            'المتابعة بحساب جوجل',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ─── Terms ─────────────────────────────────────
                      Text(
                        'بالمتابعة أنت توافق على الشروط والأحكام وسياسة الخصوصية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: FixawyColors.textHint,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
