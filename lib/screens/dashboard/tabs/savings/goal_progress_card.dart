// lib/screens/dashboard/tabs/savings/goal_progress_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/goals_model.dart';
import '../../../../extensions/goal_category_extension.dart';

class GoalProgressCard extends StatelessWidget {
  final GoalModel goal;
  final int animationIndex;
  final VoidCallback onAddFunds;
  final VoidCallback onViewDetails;

  const GoalProgressCard({
    super.key,
    required this.goal,
    required this.animationIndex,
    required this.onAddFunds,
    required this.onViewDetails,
  });

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = goal.progressPercentage;
    final isCompleted = goal.isCompleted;
    final categoryColor = goal.category.color;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (animationIndex * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetails,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          child: Container(
            decoration: AdminDesignSystem.cardDecoration,
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon, title, and chevron
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                      ),
                      padding: const EdgeInsets.all(
                        AdminDesignSystem.spacing12,
                      ),
                      child: Text(
                        goal.iconEmoji ?? goal.category.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: AdminDesignSystem.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AdminDesignSystem.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AdminDesignSystem.spacing4),
                          _buildStatusBadge(isCompleted),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AdminDesignSystem.textTertiary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Amount metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saved', style: AdminDesignSystem.labelSmall),
                        const SizedBox(height: AdminDesignSystem.spacing4),
                        Text(
                          '₦${_formatAmount(goal.currentAmount)}',
                          style: AdminDesignSystem.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? AdminDesignSystem.statusActive
                                : categoryColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Target', style: AdminDesignSystem.labelSmall),
                        const SizedBox(height: AdminDesignSystem.spacing4),
                        Text(
                          '₦${_formatAmount(goal.targetAmount)}',
                          style: AdminDesignSystem.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AdminDesignSystem.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),

                // Animated progress bar
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
                            backgroundColor: categoryColor.withAlpha(38),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? AdminDesignSystem.statusActive
                                  : categoryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(value * 100).toStringAsFixed(0)}% complete',
                              style: AdminDesignSystem.labelSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₦${_formatAmount((goal.targetAmount - goal.currentAmount).clamp(0, double.infinity))} to go',
                              style: AdminDesignSystem.labelSmall.copyWith(
                                color: AdminDesignSystem.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                // Add to goal button (only if not completed)
                if (!isCompleted) ...[
                  const SizedBox(height: AdminDesignSystem.spacing16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onAddFunds,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
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
                      ),
                      child: Text(
                        'Update Progress on Goal',
                        style: AdminDesignSystem.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],

                // Completion celebration
                if (isCompleted) ...[
                  const SizedBox(height: AdminDesignSystem.spacing16),
                  Container(
                    padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                    decoration: BoxDecoration(
                      color: AdminDesignSystem.statusActive.withAlpha(25),
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: AdminDesignSystem.statusActive,
                          size: 20,
                        ),
                        const SizedBox(width: AdminDesignSystem.spacing8),
                        Expanded(
                          child: Text(
                            'Goal completed! Congratulations 🎉',
                            style: AdminDesignSystem.bodySmall.copyWith(
                              color: AdminDesignSystem.statusActive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isCompleted) {
    if (isCompleted) {
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AdminDesignSystem.statusActive,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing4),
          Text(
            'Completed',
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.statusActive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final isOverdue = goal.isOverdue;

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isOverdue
                ? AdminDesignSystem.statusError
                : AdminDesignSystem.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AdminDesignSystem.spacing4),
        Text(
          isOverdue ? 'Overdue' : '${goal.daysRemaining} days remaining',
          style: AdminDesignSystem.labelSmall.copyWith(
            color: isOverdue
                ? AdminDesignSystem.statusError
                : AdminDesignSystem.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
