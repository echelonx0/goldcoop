// lib/screens/dashboard/modals/deposit_success_screen.dart
// Full-screen deposit success with savings planning education

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/user_model.dart';

class DepositSuccessScreen extends StatefulWidget {
  final UserModel user;
  final double depositAmount;
  final String? goalTitle;
  final VoidCallback onDone;

  const DepositSuccessScreen({
    super.key,
    required this.user,
    required this.depositAmount,
    this.goalTitle,
    required this.onDone,
  });

  @override
  State<DepositSuccessScreen> createState() => _DepositSuccessScreenState();
}

class _DepositSuccessScreenState extends State<DepositSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Force dismiss any lingering keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: AdminDesignSystem.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Success animation section
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    // Success header
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Checkmark circle
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AdminDesignSystem.statusActive,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AdminDesignSystem.statusActive
                                            .withAlpha(77),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: AdminDesignSystem.spacing24,
                                ),
                                Text(
                                  'Deposit Received!',
                                  style: AdminDesignSystem.headingLarge
                                      .copyWith(
                                        color: AdminDesignSystem.primaryNavy,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: AdminDesignSystem.spacing12,
                                ),
                                Text(
                                  'Your payment is being verified',
                                  style: AdminDesignSystem.bodyMedium.copyWith(
                                    color: AdminDesignSystem.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Amount display card
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AdminDesignSystem.spacing16,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AdminDesignSystem.accentTeal,
                                AdminDesignSystem.accentTeal.withAlpha(230),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              AdminDesignSystem.radius16,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AdminDesignSystem.accentTeal.withAlpha(
                                  38,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Amount Deposited',
                                style: AdminDesignSystem.labelMedium.copyWith(
                                  color: Colors.white.withAlpha(179),
                                ),
                              ),
                              const SizedBox(
                                height: AdminDesignSystem.spacing8,
                              ),
                              TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0,
                                  end: widget.depositAmount,
                                ),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Text(
                                    _currencyFormatter.format(value),
                                    style: AdminDesignSystem.displayLarge
                                        .copyWith(
                                          color: Colors.white,
                                          fontSize: 28,
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AdminDesignSystem.spacing32),

                    // Education cards
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AdminDesignSystem.spacing16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Savings Journey',
                              style: AdminDesignSystem.headingMedium.copyWith(
                                color: AdminDesignSystem.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: AdminDesignSystem.spacing12),
                            _EducationCard(
                              icon: Icons.trending_up,
                              title: 'Long-Term Growth',
                              description:
                                  'Every deposit compounds over time. Regular contributions build wealth faster.',
                              color: AdminDesignSystem.accentTeal,
                            ),
                            const SizedBox(height: AdminDesignSystem.spacing12),
                            _EducationCard(
                              icon: Icons.shield_rounded,
                              title: 'Protection Against Inflation',
                              description:
                                  'Gold-backed savings protect your purchasing power as naira value changes.',
                              color: const Color(0xFF9B7653),
                            ),
                            const SizedBox(height: AdminDesignSystem.spacing12),
                            _EducationCard(
                              icon: Icons.power_input_outlined,
                              title: 'Set & Achieve Goals',
                              description:
                                  'Create savings goals and track progress. Small steps lead to big milestones.',
                              color: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AdminDesignSystem.spacing24),

                    // CTA Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminDesignSystem.spacing16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Dismiss keyboard if any
                            FocusManager.instance.primaryFocus?.unfocus();

                            widget.onDone();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminDesignSystem.accentTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AdminDesignSystem.spacing16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AdminDesignSystem.radius12,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Continue to Dashboard',
                            style: AdminDesignSystem.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AdminDesignSystem.spacing32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== EDUCATION CARD ====================

class _EducationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _EducationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AdminDesignSystem.cardDecoration,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AdminDesignSystem.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AdminDesignSystem.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  description,
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
