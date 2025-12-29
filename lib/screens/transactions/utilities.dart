import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Icon(
              Icons.history,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'No transactions found',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Try adjusting your filters',
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String error;

  const ErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.warmRed,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Failed to load $error',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.warmRed,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HELPER CLASSES ====================

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
