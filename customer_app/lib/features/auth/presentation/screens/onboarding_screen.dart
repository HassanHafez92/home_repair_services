import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Onboarding Screen — 3-page intro slides
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.flash_on_rounded,
      titleAr: 'خدمة فورية',
      titleEn: 'Instant Service',
      descriptionAr: 'اطلب فني متخصص في أي وقت وتابع وصوله مباشرة',
      descriptionEn: 'Request a specialist anytime and track arrival live',
      color: Color(0xFF0D7377),
    ),
    _OnboardingPage(
      icon: Icons.verified_user_rounded,
      titleAr: 'فنيين موثوقين',
      titleEn: 'Verified Technicians',
      descriptionAr: 'جميع الفنيين معتمدين ومتحقق من هويتهم وسجلهم',
      descriptionEn: 'All technicians are vetted and identity-verified',
      color: Color(0xFFE8A838),
    ),
    _OnboardingPage(
      icon: Icons.receipt_long_rounded,
      titleAr: 'أسعار شفافة',
      titleEn: 'Transparent Pricing',
      descriptionAr: 'أسعار ثابتة محددة مسبقاً — بدون مفاجآت',
      descriptionEn: 'Fixed pre-set prices — no surprises',
      color: Color(0xFF2CB67D),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FixawyColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Skip Button ───────────────────────────────────
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'تخطي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FixawyColors.textSecondary,
                  ),
                ),
              ),
            ),

            // ─── Page View ─────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),

            // ─── Page Indicators ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? FixawyColors.primary
                          : FixawyColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // ─── Action Button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.go('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FixawyColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'التالي' : 'ابدأ الآن',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: page.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 48,
                  color: page.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Arabic Title
          Text(
            page.titleAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: FixawyColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // English Title (subtle)
          Text(
            page.titleEn,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: FixawyColors.textHint,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Arabic Description
          Text(
            page.descriptionAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: FixawyColors.textSecondary,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.color,
  });
}
