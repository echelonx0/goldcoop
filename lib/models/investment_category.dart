// lib/models/investment_category.dart

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum InvestmentCategory {
  quickWins,
  steadyGrowth,
  longTermWealth,
}

extension InvestmentCategoryExtension on InvestmentCategory {
  String get displayName {
    switch (this) {
      case InvestmentCategory.quickWins:
        return 'Quick Wins';
      case InvestmentCategory.steadyGrowth:
        return 'Steady Growth';
      case InvestmentCategory.longTermWealth:
        return 'Long-term Wealth';
    }
  }

  String get description {
    switch (this) {
      case InvestmentCategory.quickWins:
        return 'Short-term plans (3-6 months) for faster returns';
      case InvestmentCategory.steadyGrowth:
        return 'Medium-term plans (6-12 months) for balanced growth';
      case InvestmentCategory.longTermWealth:
        return '12+ months for maximum returns';
    }
  }

  Color get color {
    switch (this) {
      case InvestmentCategory.quickWins:
        return AppColors.softAmber;
      case InvestmentCategory.steadyGrowth:
        return AppColors.tealSuccess;
      case InvestmentCategory.longTermWealth:
        return AppColors.primaryOrange;
    }
  }

  IconData get icon {
    switch (this) {
      case InvestmentCategory.quickWins:
        return Icons.bolt_rounded;
      case InvestmentCategory.steadyGrowth:
        return Icons.trending_up_rounded;
      case InvestmentCategory.longTermWealth:
        return Icons.account_balance_rounded;
    }
  }

  /// Determine category from plan duration
  static InvestmentCategory fromDuration(int months) {
    if (months <= 6) {
      return InvestmentCategory.quickWins;
    } else if (months <= 12) {
      return InvestmentCategory.steadyGrowth;
    } else {
      return InvestmentCategory.longTermWealth;
    }
  }
}
