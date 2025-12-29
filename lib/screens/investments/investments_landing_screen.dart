// lib/screens/investments/investments_landing_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/base/app_button.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/floating_particles_animation.dart';
import 'investments_screen.dart';

class InvestmentsLandingScreen extends StatefulWidget {
  final String uid;

  const InvestmentsLandingScreen({super.key, required this.uid});

  @override
  State<InvestmentsLandingScreen> createState() =>
      _InvestmentsLandingScreenState();
}

class _InvestmentsLandingScreenState extends State<InvestmentsLandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markAsViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenInvestmentsLanding', true);
  }

  void _navigateToMain() {
    _markAsViewed();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => InvestmentsScreen(uid: widget.uid),
      ),
    );
  }

  void _showROICalculator() {
    // TODO: Implement generic ROI calculator modal
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ROI Calculator coming soon')));
  }

  void _navigateToMyInvestments() {
    // TODO: Navigate to user's active investments
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('My Investments coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: FloatingParticlesAnimation(
              primaryColor: AppColors.primaryOrange,
              secondaryColor: AppColors.softAmber,
              particleCount: 15,
            ),
          ),

          // Gradient overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundWhite.withAlpha(230),
                    AppColors.backgroundNeutral.withAlpha(240),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // Hero illustration
                      _buildHeroIllustration(),

                      const SizedBox(height: AppSpacing.xl),

                      // Headline
                      Text(
                        'Curated Investment Plans',
                        style: AppTextTheme.heading1.copyWith(
                          color: AppColors.deepNavy,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Subheadline
                      Text(
                        'Access reliable, secure investment returns through our gold-backed cooperative plans',
                        style: AppTextTheme.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(flex: 2),

                      // Entry points
                      _buildEntryPoints(),

                      const SizedBox(height: AppSpacing.lg),

                      // Skip button
                      TextButton(
                        onPressed: _navigateToMain,
                        child: Text(
                          'Skip',
                          style: AppTextTheme.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIllustration() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryOrange, AppColors.softAmber],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withAlpha(76),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated pulse ring
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (context, pulseValue, child) {
                    return Transform.scale(
                      scale: 1 + (pulseValue * 0.1),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(
                              ((1 - pulseValue) * 128).toInt(),
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Gold bar icon
                Icon(Icons.layers_rounded, size: 80, color: Colors.white),

                // Trending up arrow
                Positioned(
                  right: 30,
                  top: 30,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tealSuccess,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tealSuccess.withAlpha(76),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 20,
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

  Widget _buildEntryPoints() {
    return Column(
      children: [
        // Primary CTA
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Browse All Plans',
            onPressed: _navigateToMain,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Secondary CTAs
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                icon: Icons.calculate_outlined,
                label: 'Calculate Returns',
                onPressed: _showROICalculator,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSecondaryButton(
                icon: Icons.account_balance_wallet_outlined,
                label: 'My Investments',
                onPressed: _navigateToMyInvestments,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.md,
        ),
        side: BorderSide(color: AppColors.borderLight, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryOrange, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
