// ==================== TRANSACTION CARD WIDGET ====================

import 'package:flutter/material.dart';

import '../../../components/base/app_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncoming = _isIncomingTransaction(transaction.type);

    return GestureDetector(
      onTap: onTap,
      child: StandardCard(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _getTransactionColor(transaction.type).withAlpha(25),
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Icon(
                _getTransactionIcon(transaction.type),
                color: _getTransactionColor(transaction.type),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: AppTextTheme.bodyRegular.copyWith(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        _getTransactionTypeLabel(transaction.type),
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        ' • ',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                      Text(
                        _formatTransactionTime(transaction.createdAt),
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      if (transaction.status != TransactionStatus.completed)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                transaction.status,
                              ).withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            child: Text(
                              _getStatusLabel(transaction.status),
                              style: AppTextTheme.micro.copyWith(
                                color: _getStatusColor(transaction.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncoming ? '+' : '−'}₦${transaction.amount.toStringAsFixed(0)}',
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: isIncoming
                        ? AppColors.tealSuccess
                        : AppColors.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (transaction.fees! > 0)
                  Text(
                    'Fee: ₦${transaction.fees!.toStringAsFixed(0)}',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
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

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.investment:
        return Icons.trending_up;
      case TransactionType.investment_return:
        return Icons.trending_up;
      case TransactionType.interest_earned:
        return Icons.percent;
      case TransactionType.referral_bonus:
        return Icons.card_giftcard;
      case TransactionType.token_conversion:
        return Icons.swap_horiz;
      case TransactionType.token_purchase:
        return Icons.shopping_cart;
      case TransactionType.transfer_to_user:
        return Icons.send;
      case TransactionType.transfer_from_user:
        return Icons.call_received;
      case TransactionType.fee:
        return Icons.receipt;
      case TransactionType.adjustment:
        return Icons.tune;
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

  String _formatTransactionTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
