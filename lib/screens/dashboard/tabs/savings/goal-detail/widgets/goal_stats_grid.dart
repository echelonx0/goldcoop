// lib/screens/dashboard/tabs/savings/widgets/goal_stats_grid.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../models/goals_model.dart';
import 'animated_stat_card.dart';

class GoalStatsGrid extends StatelessWidget {
  final GoalModel goal;
  final NumberFormat currencyFormatter;

  const GoalStatsGrid({
    super.key,
    required this.goal,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        AnimatedStatCard(
          label: 'Saved',
          value: currencyFormatter.format(goal.currentAmount),
          color: AppColors.tealSuccess,
          icon: Icons.savings_outlined,
          delay: 100,
          targetValue: goal.currentAmount,
        ),
        AnimatedStatCard(
          label: 'Target',
          value: currencyFormatter.format(goal.targetAmount),
          color: AppColors.primaryOrange,
          icon: Icons.flag_outlined,
          delay: 200,
          targetValue: goal.targetAmount,
        ),
        AnimatedStatCard(
          label: 'Remaining',
          value: currencyFormatter.format(goal.remainingAmount),
          color: AppColors.deepNavy,
          icon: Icons.trending_up,
          delay: 300,
          targetValue: goal.remainingAmount,
        ),
        AnimatedStatCard(
          label: 'Days Left',
          value: '${goal.daysRemaining}',
          color: AppColors.textSecondary,
          icon: Icons.calendar_today,
          delay: 400,
          targetValue: goal.daysRemaining.toDouble(),
        ),
      ],
    );
  }
}
