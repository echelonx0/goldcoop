// ==================== TRANSACTION DETAILS SHEET ====================

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/transaction_model.dart';

class TransactionDetailsSheet extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncoming = _isIncomingTransaction(transaction.type);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.large),
          topRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DelayedDisplay(
              delay: const Duration(milliseconds: 100),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getTransactionColor(transaction.type).withAlpha(12),
                  borderRadius: BorderRadius.circular(AppBorderRadius.large),
                  border: Border.all(
                    color: _getTransactionColor(transaction.type).withAlpha(25),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${isIncoming ? '+' : '−'}₦${transaction.amount.toStringAsFixed(0)}',
                      style: AppTextTheme.display.copyWith(
                        color: _getTransactionColor(transaction.type),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      transaction.description,
                      style: AppTextTheme.heading3.copyWith(
                        color: AppColors.deepNavy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DelayedDisplay(
              delay: const Duration(milliseconds: 200),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withAlpha(12),
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  border: Border.all(
                    color: _getStatusColor(transaction.status).withAlpha(25),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(transaction.status),
                      color: _getStatusColor(transaction.status),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: AppTextTheme.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _getStatusLabel(transaction.status),
                            style: AppTextTheme.bodyRegular.copyWith(
                              color: _getStatusColor(transaction.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DelayedDisplay(
              delay: const Duration(milliseconds: 300),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                children: [
                  _DetailItem(
                    label: 'Type',
                    value: _getTransactionTypeLabel(transaction.type),
                  ),
                  _DetailItem(
                    label: 'Date & Time',
                    value: _formatDetailedDateTime(transaction.createdAt),
                  ),
                  _DetailItem(
                    label: 'Amount',
                    value: '₦${transaction.amount.toStringAsFixed(0)}',
                  ),
                  _DetailItem(
                    label: 'Fees',
                    value: transaction.fees! > 0
                        ? '₦${transaction.fees!.toStringAsFixed(0)}'
                        : 'None',
                  ),
                  _DetailItem(
                    label: 'Net Amount',
                    value: '₦${transaction.netAmount!.toStringAsFixed(0)}',
                  ),
                  _DetailItem(
                    label: 'Reference',
                    value: transaction.referenceNumber.toString(),
                  ),
                ],
              ),
            ),
            if (transaction.status == TransactionStatus.failed &&
                transaction.failureReason != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.warmRed.withAlpha(12),
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        border: Border.all(
                          color: AppColors.warmRed.withAlpha(25),
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        transaction.failureReason!,
                        style: AppTextTheme.bodyRegular.copyWith(
                          color: AppColors.warmRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool _isIncomingTransaction(TransactionType type) {
    return type == TransactionType.deposit ||
        type == TransactionType.investment_return ||
        type == TransactionType.interest_earned ||
        type == TransactionType.referral_bonus ||
        type == TransactionType.token_conversion ||
        type == TransactionType.transfer_from_user;
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
      case TransactionType.investment_return:
      case TransactionType.interest_earned:
      case TransactionType.referral_bonus:
      case TransactionType.transfer_from_user:
        return AppColors.tealSuccess;
      case TransactionType.withdrawal:
      case TransactionType.investment:
      case TransactionType.transfer_to_user:
      case TransactionType.token_purchase:
        return AppColors.deepNavy;
      case TransactionType.token_conversion:
        return AppColors.primaryOrange;
      case TransactionType.fee:
      case TransactionType.adjustment:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColors.softAmber;
      case TransactionStatus.completed:
        return AppColors.tealSuccess;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppColors.warmRed;
      case TransactionStatus.reversed:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.processing:
        return Icons.hourglass_bottom;
      case TransactionStatus.completed:
        return Icons.check_circle;
      case TransactionStatus.failed:
        return Icons.cancel;
      case TransactionStatus.reversed:
        return Icons.undo;
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
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

  String _formatDetailedDateTime(DateTime date) {
    return '${_formatTransactionDate(date)} at ${_formatTransactionTime(date)}';
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _formatTransactionTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

// ==================== HELPER WIDGETS ====================

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextTheme.bodyRegular.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
