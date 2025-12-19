// lib/extensions/goal_category_extension.dart

import 'package:flutter/material.dart';
import '../models/goals_model.dart';
import '../core/theme/app_colors.dart';

extension GoalCategoryX on GoalCategory {
  String get label {
    switch (this) {
      case GoalCategory.vacation:
        return 'Vacation';
      case GoalCategory.realestate:
        return 'Real Estate';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.vehicle:
        return 'Vehicle';
      case GoalCategory.wedding:
        return 'Wedding';
      case GoalCategory.business:
        return 'Business';
      case GoalCategory.investment:
        return 'Investment';
      case GoalCategory.retirement:
        return 'Retirement';
      case GoalCategory.emergency:
        return 'Emergency Fund';
      case GoalCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case GoalCategory.vacation:
        return '✈️';
      case GoalCategory.realestate:
        return '🏠';
      case GoalCategory.education:
        return '📚';
      case GoalCategory.vehicle:
        return '🚗';
      case GoalCategory.wedding:
        return '💒';
      case GoalCategory.business:
        return '💼';
      case GoalCategory.investment:
        return '📈';
      case GoalCategory.retirement:
        return '🏖️';
      case GoalCategory.emergency:
        return '🆘';
      case GoalCategory.other:
        return '🎯';
    }
  }

  Color get color {
    switch (this) {
      case GoalCategory.vacation:
        return const Color(0xFF3498DB);
      case GoalCategory.realestate:
        return const Color(0xFF9B59B6);
      case GoalCategory.education:
        return const Color(0xFFE74C3C);
      case GoalCategory.vehicle:
        return const Color(0xFFF39C12);
      case GoalCategory.wedding:
        return const Color(0xFFE91E63);
      case GoalCategory.business:
        return const Color(0xFF2ECC71);
      case GoalCategory.investment:
        return AppColors.primaryOrange;
      case GoalCategory.retirement:
        return const Color(0xFF34495E);
      case GoalCategory.emergency:
        return AppColors.warmRed;
      case GoalCategory.other:
        return AppColors.textSecondary;
    }
  }
}
