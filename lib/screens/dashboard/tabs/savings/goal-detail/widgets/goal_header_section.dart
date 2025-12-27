// lib/screens/dashboard/tabs/savings/widgets/goal_header_section.dart

import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../extensions/goal_category_extension.dart';
import '../../../../../../models/goals_model.dart';

class GoalHeaderSection extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onClose;

  const GoalHeaderSection({
    super.key,
    required this.goal,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Close button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.backgroundNeutral,
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Title with icon
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: goal.category.color.withAlpha(25),
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Icon(
                _getCategoryIcon(goal.category),
                color: goal.category.color,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: AppTextTheme.heading2.copyWith(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildStatusBadge(),
                ],
              ),
            ),
          ],
        ),

        // Description
        if (goal.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            goal.description,
            style: AppTextTheme.bodyRegular.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isCompleted = goal.isCompleted;
    final isOverdue = goal.isOverdue;

    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    if (isCompleted) {
      badgeColor = AppColors.tealSuccess;
      badgeIcon = Icons.check_circle;
      badgeText = 'Completed';
    } else if (isOverdue) {
      badgeColor = AppColors.warmRed;
      badgeIcon = Icons.warning_amber_rounded;
      badgeText = 'Overdue';
    } else {
      badgeColor = AppColors.primaryOrange;
      badgeIcon = Icons.schedule;
      badgeText = '${goal.daysRemaining} days left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            badgeText,
            style: AppTextTheme.bodySmall.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.vacation:
        return Icons.flight_takeoff;
      case GoalCategory.realestate:
        return Icons.home;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.vehicle:
        return Icons.directions_car;
      case GoalCategory.wedding:
        return Icons.favorite;
      case GoalCategory.business:
        return Icons.business_center;
      case GoalCategory.investment:
        return Icons.trending_up;
      case GoalCategory.retirement:
        return Icons.beach_access;
      case GoalCategory.emergency:
        return Icons.health_and_safety;
      case GoalCategory.other:
        return Icons.flag;
    }
  }
}
