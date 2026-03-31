import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tech_theme.dart';
import '../../bloc/tech_auth_bloc.dart';

/// Technician OTP Verification Screen
class TechOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const TechOtpScreen({super.key, required this.phoneNumber});

  @override
  State<TechOtpScreen> createState() => _TechOtpScreenState();
}

class _TechOtpScreenState extends State<TechOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _resendTimer = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendTimer--;
        if (_resendTimer <= 0) {
          _canResend = true;
        }
      });
      return _resendTimer > 0;
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _verifyOtp() {
    if (_otpCode.length == 6) {
      context.read<TechAuthBloc>().add(TechAuthOtpSubmitted(_otpCode));
    }
  }

  void _resendOtp() {
    context.read<TechAuthBloc>().add(TechAuthOtpRequested(widget.phoneNumber));
    _startTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TechAuthBloc, TechAuthState>(
      listener: (context, state) {
        if (state is TechAuthAuthenticated) {
          context.go('/dashboard');
        } else if (state is TechAuthNeedsKyc) {
          context.go('/kyc');
        } else if (state is TechAuthKycPending) {
          context.go('/kyc');
        } else if (state is TechAuthError) {
          for (final c in _controllers) {
            c.clear();
          }
          _focusNodes[0].requestFocus();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: TechColors.offline,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<TechAuthBloc, TechAuthState>(
        builder: (context, state) {
          final isLoading = state is TechAuthLoading;

          return Scaffold(
            backgroundColor: TechColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: isLoading ? null : () => context.pop(),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'تأكيد رقم الموبايل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: TechColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'تم إرسال كود التحقق إلى',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: TechColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TechColors.primary,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 40),

                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 48,
                            height: 56,
                            margin: EdgeInsets.symmetric(
                              horizontal: index == 2 ? 12 : 4,
                            ),
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              enabled: !isLoading,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: TechColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: _controllers[index].text.isNotEmpty
                                    ? TechColors.primarySurface
                                    : TechColors.surfaceVariant,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: _controllers[index].text.isNotEmpty
                                        ? TechColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: _controllers[index].text.isNotEmpty
                                        ? TechColors.primary
                                        : TechColors.divider,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: TechColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                setState(() {});
                                if (value.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                }
                                if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                if (_otpCode.length == 6) {
                                  _verifyOtp();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            isLoading || _otpCode.length < 6 ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TechColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              TechColors.primary.withValues(alpha: 0.3),
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
                                'تأكيد',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: _canResend
                          ? TextButton(
                              onPressed: isLoading ? null : _resendOtp,
                              child: const Text(
                                'إعادة إرسال الكود',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: TechColors.primary,
                                ),
                              ),
                            )
                          : Text(
                              'إعادة الإرسال خلال $_resendTimer ثانية',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                color: TechColors.textHint,
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
