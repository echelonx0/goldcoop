// ==================== SEARCH BAR WIDGET ====================

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/transaction_model.dart';
import '../utilities.dart';

class TransactionSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool showFilters;
  final VoidCallback onFilterTapped;
  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final DateRange? selectedDateRange;
  final VoidCallback onTypeRemoved;
  final VoidCallback onStatusRemoved;
  final VoidCallback onDateRangeRemoved;

  const TransactionSearchBar({
    super.key,
    required this.searchController,
    required this.showFilters,
    required this.onFilterTapped,
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.onTypeRemoved,
    required this.onStatusRemoved,
    required this.onDateRangeRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        selectedType != null ||
        selectedStatus != null ||
        selectedDateRange != null;

    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search transactions',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.primaryOrange,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: onFilterTapped,
                  child: Container(
                    decoration: BoxDecoration(
                      color: showFilters
                          ? AppColors.primaryOrange
                          : AppColors.backgroundNeutral,
                      border: Border.all(
                        color: showFilters
                            ? AppColors.primaryOrange
                            : AppColors.borderLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.medium,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.tune,
                      color: showFilters
                          ? AppColors.backgroundWhite
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasFilters)
            DelayedDisplay(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (selectedType != null)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Chip(
                            label: Text(
                              _getTransactionTypeLabel(selectedType!),
                            ),
                            onDeleted: onTypeRemoved,
                          ),
                        ),
                      if (selectedStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Chip(
                            label: Text(_getStatusLabel(selectedStatus!)),
                            onDeleted: onStatusRemoved,
                          ),
                        ),
                      if (selectedDateRange != null)
                        Chip(
                          label: Text(_formatDateRange(selectedDateRange!)),
                          onDeleted: onDateRangeRemoved,
                        ),
                    ],
                  ),
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

  String _formatDateRange(DateRange range) {
    final start = range.start;
    final end = range.end;
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }
}
