// ==================== FILTER PANEL WIDGET ====================

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../../components/base/app_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/transaction_model.dart';
import '../utilities.dart';

class TransactionFilterPanel extends StatelessWidget {
  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final DateRange? selectedDateRange;
  final Function(TransactionType?) onTypeChanged;
  final Function(TransactionStatus?) onStatusChanged;
  final Function(DateRange?) onDateRangeChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onCustomDatePicker;

  const TransactionFilterPanel({
    super.key,
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
    required this.onCustomDatePicker,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Transaction Type',
              style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 150),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: TransactionType.values
                  .map(
                    (type) => FilterChip(
                      label: Text(_getTransactionTypeLabel(type)),
                      selected: selectedType == type,
                      onSelected: (selected) {
                        onTypeChanged(selected ? type : null);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Status',
              style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 250),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: TransactionStatus.values
                  .map(
                    (status) => FilterChip(
                      label: Text(_getStatusLabel(status)),
                      selected: selectedStatus == status,
                      onSelected: (selected) {
                        onStatusChanged(selected ? status : null);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Date Range',
              style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 350),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children:
                  [
                        (
                          label: 'Last 7 days',
                          range: DateRange(
                            start: DateTime.now().subtract(
                              const Duration(days: 7),
                            ),
                            end: DateTime.now(),
                          ),
                        ),
                        (
                          label: 'Last 30 days',
                          range: DateRange(
                            start: DateTime.now().subtract(
                              const Duration(days: 30),
                            ),
                            end: DateTime.now(),
                          ),
                        ),
                        (
                          label: 'Last 3 months',
                          range: DateRange(
                            start: DateTime.now().subtract(
                              const Duration(days: 90),
                            ),
                            end: DateTime.now(),
                          ),
                        ),
                        (
                          label: 'Last year',
                          range: DateRange(
                            start: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            end: DateTime.now(),
                          ),
                        ),
                      ]
                      .map(
                        (item) => FilterChip(
                          label: Text(item.label),
                          selected: selectedDateRange == item.range,
                          onSelected: (selected) {
                            onDateRangeChanged(selected ? item.range : null);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: ListTile(
              title: Text(
                'Custom Date Range',
                style: AppTextTheme.bodyRegular.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: onCustomDatePicker,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayedDisplay(
            delay: const Duration(milliseconds: 450),
            child: SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                label: 'Clear All Filters',
                onPressed: onClearFilters,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.investment_return:
        return 'Investment Return';
      case TransactionType.interest_earned:
        return 'Interest Earned';
      case TransactionType.referral_bonus:
        return 'Referral Bonus';
      case TransactionType.token_conversion:
        return 'Token Conversion';
      case TransactionType.token_purchase:
        return 'Token Purchase';
      case TransactionType.transfer_to_user:
        return 'Transfer To User';
      case TransactionType.transfer_from_user:
        return 'Transfer From User';
      case TransactionType.fee:
        return 'Fee';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.reversed:
        return 'Reversed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }
}
