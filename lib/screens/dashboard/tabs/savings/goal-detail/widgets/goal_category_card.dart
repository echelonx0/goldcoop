// lib/screens/dashboard/tabs/savings/widgets/goal_category_card.dart

import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../extensions/goal_category_extension.dart';
import '../../../../../../models/goals_model.dart';

class GoalCategoryCard extends StatelessWidget {
  final GoalModel goal;

  const GoalCategoryCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: goal.category.color.withAlpha(12),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: goal.category.color.withAlpha(25)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: goal.category.color.withAlpha(25),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              _getCategoryIcon(goal.category),
              color: goal.category.color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  goal.category.label,
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: goal.category.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Text(
              goal.category.emoji,
              style: const TextStyle(fontSize: 20),
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
