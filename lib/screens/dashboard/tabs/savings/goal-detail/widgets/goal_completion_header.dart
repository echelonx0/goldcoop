// lib/screens/dashboard/tabs/savings/widgets/goal_completion_banner.dart

import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';

class GoalCompletionBanner extends StatelessWidget {
  const GoalCompletionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.tealSuccess.withAlpha(25),
                  AppColors.tealSuccess.withAlpha(12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              border: Border.all(color: AppColors.tealSuccess.withAlpha(50)),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.tealSuccess.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.tealSuccess,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goal Completed! 🎉',
                        style: AppTextTheme.bodyRegular.copyWith(
                          color: AppColors.tealSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'You\'ve reached your target!',
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.tealSuccess,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
