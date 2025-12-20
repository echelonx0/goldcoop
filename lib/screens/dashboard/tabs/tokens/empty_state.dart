// lib/screens/dashboard/widgets/tokens_empty_state.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';

import '../../../../core/theme/admin_design_system.dart';

class TokensEmptyState extends StatelessWidget {
  final VoidCallback onStartEarning;

  const TokensEmptyState({super.key, required this.onStartEarning});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminDesignSystem.spacing16,
          vertical: AdminDesignSystem.spacing24,
        ),
        child: Column(
          children: [
            // ==================== GRADIENT BACKGROUND ====================
            DelayedDisplay(
              delay: const Duration(milliseconds: 100),
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AdminDesignSystem.accentTeal,
                      AdminDesignSystem.accentTeal.withAlpha(200),
                      Colors.teal[700] ?? Colors.teal,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius16,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AdminDesignSystem.accentTeal.withAlpha(76),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background decorative lines (inspired by VoltBank)
                    Positioned(
                      top: -50,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(200),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -80,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12),
                          borderRadius: BorderRadius.circular(150),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(
                        AdminDesignSystem.spacing24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon circle
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 200),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.stars,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Text content
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 300),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unlock Your',
                                  style: AdminDesignSystem.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Token Rewards',
                                  style: AdminDesignSystem.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 36,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(
                                  height: AdminDesignSystem.spacing12,
                                ),
                                Text(
                                  'Earn tokens through your financial activities\nand convert them to instant airtime',
                                  style: AdminDesignSystem.bodySmall.copyWith(
                                    color: Colors.white.withAlpha(204),
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AdminDesignSystem.spacing32),

            // ==================== HOW TO EARN SECTION ====================
            DelayedDisplay(
              delay: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Earn Tokens',
                    style: AdminDesignSystem.headingMedium.copyWith(
                      color: AdminDesignSystem.primaryNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing16),
                  _buildEarnCard(
                    delay: 500,
                    icon: Icons.flag_outlined,
                    iconBg: Colors.orange,
                    title: 'Complete Savings Goals',
                    subtitle: 'Earn 50 tokens per goal reached',
                    value: '+50',
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _buildEarnCard(
                    delay: 600,
                    icon: Icons.trending_up_outlined,
                    iconBg: Colors.blue,
                    title: 'Make Investments',
                    subtitle: 'Earn 10 tokens per investment made',
                    value: '+10',
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _buildEarnCard(
                    delay: 700,
                    icon: Icons.calendar_today_outlined,
                    iconBg: Colors.purple,
                    title: 'Daily Savings Streak',
                    subtitle: 'Earn 5 tokens every week you stay consistent',
                    value: '+5',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AdminDesignSystem.spacing32),

            // ==================== BENEFITS SECTION ====================
            DelayedDisplay(
              delay: const Duration(milliseconds: 800),
              child: Container(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.background,
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius16,
                  ),
                  border: Border.all(
                    color: AdminDesignSystem.accentTeal.withAlpha(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What You Can Do',
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AdminDesignSystem.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing16),
                    _buildBenefitRow(
                      icon: Icons.phone_android_outlined,
                      text: 'Convert to airtime instantly',
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing12),
                    _buildBenefitRow(
                      icon: Icons.card_giftcard_outlined,
                      text: 'Redeem for exclusive rewards',
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing12),
                    _buildBenefitRow(
                      icon: Icons.trending_up_outlined,
                      text: 'Track your earnings growth',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AdminDesignSystem.spacing32),

            // ==================== CTA BUTTON ====================
            DelayedDisplay(
              delay: const Duration(milliseconds: 900),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStartEarning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminDesignSystem.accentTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AdminDesignSystem.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius12,
                      ),
                    ),
                    elevation: 0,
                    shadowColor: AdminDesignSystem.accentTeal.withAlpha(76),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on_outlined, size: 20),
                      const SizedBox(width: AdminDesignSystem.spacing8),
                      Text(
                        'Start Earning Now',
                        style: AdminDesignSystem.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AdminDesignSystem.spacing20),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildEarnCard({
    required int delay,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return DelayedDisplay(
      delay: Duration(milliseconds: delay),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(
            color: AdminDesignSystem.textTertiary.withAlpha(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg.withAlpha(25),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              child: Icon(icon, size: 24, color: iconBg),
            ),
            const SizedBox(width: AdminDesignSystem.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AdminDesignSystem.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminDesignSystem.spacing12,
                vertical: AdminDesignSystem.spacing8,
              ),
              decoration: BoxDecoration(
                color: iconBg.withAlpha(25),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
              ),
              child: Text(
                value,
                style: AdminDesignSystem.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: iconBg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AdminDesignSystem.accentTeal.withAlpha(25),
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
          ),
          child: Icon(icon, size: 16, color: AdminDesignSystem.accentTeal),
        ),
        const SizedBox(width: AdminDesignSystem.spacing12),
        Text(
          text,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
