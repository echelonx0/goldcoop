// lib/screens/dashboard/tabs/savings/general_savings_section.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/user_model.dart';
import '../../../../services/firestore_service.dart';

class GeneralSavingsSection extends StatelessWidget {
  final String uid;
  final VoidCallback onSetTarget;

  const GeneralSavingsSection({
    super.key,
    required this.uid,
    required this.onSetTarget,
  });

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: AdminDesignSystem.spacing16),
        StreamBuilder<UserModel?>(
          stream: FirestoreService().getUserStream(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
                  child: CircularProgressIndicator(
                    color: AdminDesignSystem.accentTeal,
                  ),
                ),
              );
            }

            final user = snapshot.data;
            final savingsTarget = user?.financialProfile.savingsTarget ?? 0.0;
            log(savingsTarget.toString());
            final currentBalance = user?.financialProfile.accountBalance ?? 0.0;

            if (savingsTarget == 0) {
              return _buildEmptyState(onSetTarget);
            }

            final progressPercent = (currentBalance / savingsTarget) * 100;
            final remainingAmount = (savingsTarget - currentBalance).clamp(
              0.0,
              double.infinity,
            );
            final isGoalReached = currentBalance >= savingsTarget;

            return Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: Container(
                    decoration: AdminDesignSystem.cardDecoration,
                    padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with edit button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Savings Target',
                                    style: AdminDesignSystem.labelMedium,
                                  ),
                                  const SizedBox(
                                    height: AdminDesignSystem.spacing8,
                                  ),
                                  Text(
                                    '₦${_formatAmount(savingsTarget)}',
                                    style: AdminDesignSystem.displayLarge
                                        .copyWith(
                                          color: AdminDesignSystem.primaryNavy,
                                          fontSize: 28,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: onSetTarget,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AdminDesignSystem.accentTeal.withAlpha(
                                    38,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AdminDesignSystem.radius12,
                                  ),
                                ),
                                padding: const EdgeInsets.all(
                                  AdminDesignSystem.spacing12,
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AdminDesignSystem.accentTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing20),

                        // Progress visualization
                        _buildProgressBar(progressPercent, isGoalReached),
                        const SizedBox(height: AdminDesignSystem.spacing20),

                        // Stats grid
                        _buildStatsGrid(
                          currentBalance,
                          remainingAmount,
                          progressPercent,
                          isGoalReached,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Achievement banner
                if (isGoalReached) _buildAchievementBanner(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Savings',
          style: AdminDesignSystem.headingMedium.copyWith(
            color: AdminDesignSystem.primaryNavy,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          'Save without a specific goal in mind',
          style: AdminDesignSystem.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState(VoidCallback onSetTarget) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: AdminDesignSystem.cardDecoration,
        padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AdminDesignSystem.accentTeal.withAlpha(38),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
              ),
              padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
              child: Icon(
                Icons.savings_outlined,
                size: 48,
                color: AdminDesignSystem.accentTeal,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing20),
            Text(
              'No savings target yet',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            Text(
              'Set a savings target to track your progress\nand stay motivated',
              style: AdminDesignSystem.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AdminDesignSystem.spacing24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSetTarget,
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
                  'Set Target',
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progressPercent, bool isGoalReached) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progressPercent / 100),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius8,
                  ),
                  child: LinearProgressIndicator(
                    value: value.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AdminDesignSystem.accentTeal.withAlpha(38),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isGoalReached
                          ? AdminDesignSystem.statusActive
                          : AdminDesignSystem.accentTeal,
                    ),
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(value * 100).toStringAsFixed(1)}% of target',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isGoalReached)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AdminDesignSystem.statusActive,
                          ),
                          const SizedBox(width: AdminDesignSystem.spacing4),
                          Text(
                            'Target reached',
                            style: AdminDesignSystem.labelSmall.copyWith(
                              color: AdminDesignSystem.statusActive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    double currentBalance,
    double remainingAmount,
    double progressPercent,
    bool isGoalReached,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.background,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
      ),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetric(
              label: 'Saved',
              value: '₦${_formatAmount(currentBalance)}',
              color: isGoalReached
                  ? AdminDesignSystem.statusActive
                  : AdminDesignSystem.accentTeal,
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: AdminDesignSystem.divider,
            margin: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing12,
            ),
          ),
          Expanded(
            child: _buildMetric(
              label: 'Remaining',
              value: '₦${_formatAmount(remainingAmount)}',
              color: AdminDesignSystem.textSecondary,
              icon: Icons.hourglass_empty,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color.withAlpha(153), size: 20),
        const SizedBox(height: AdminDesignSystem.spacing8),
        Text(label, style: AdminDesignSystem.labelSmall),
        const SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          value,
          style: AdminDesignSystem.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAchievementBanner() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AdminDesignSystem.statusActive,
              AdminDesignSystem.statusActive.withAlpha(230),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          boxShadow: [
            BoxShadow(
              color: AdminDesignSystem.statusActive.withAlpha(38),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
              child: Icon(Icons.emoji_events, color: Colors.white, size: 32),
            ),
            const SizedBox(width: AdminDesignSystem.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal Achieved! 🎉',
                    style: AdminDesignSystem.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing4),
                  Text(
                    'You\'ve reached your savings target',
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
