// lib/screens/dashboard/tabs/savings/widgets/goal_progress_section.dart

import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../models/goals_model.dart';

class GoalProgressSection extends StatelessWidget {
  final GoalModel goal;

  const GoalProgressSection({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progressPercent = goal.progressPercentage;
    final isCompleted = goal.isCompleted;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? AppColors.tealSuccess.withAlpha(25)
                : AppColors.primaryOrange.withAlpha(25),
            isCompleted
                ? AppColors.tealSuccess.withAlpha(12)
                : AppColors.primaryOrange.withAlpha(12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: isCompleted
              ? AppColors.tealSuccess.withAlpha(50)
              : AppColors.primaryOrange.withAlpha(50),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progressPercent),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    '${value.toStringAsFixed(0)}%',
                    style: AppTextTheme.heading3.copyWith(
                      color: isCompleted
                          ? AppColors.tealSuccess
                          : AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progressPercent / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                child: LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: Colors.white.withAlpha(180),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted
                        ? AppColors.tealSuccess
                        : AppColors.primaryOrange,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
