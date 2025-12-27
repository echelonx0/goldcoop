// lib/screens/dashboard/tabs/savings/widgets/goal_transaction_history.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../models/payment_proof_model.dart';
import '../../../../../../services/deposit_service.dart';

class GoalTransactionHistory extends StatelessWidget {
  final String goalId;
  final String userId;

  const GoalTransactionHistory({
    super.key,
    required this.goalId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final depositService = DepositService();
    final currencyFormatter = NumberFormat('#,##0', 'en_US');

    return StreamBuilder<List<PaymentProofModel>>(
      stream: depositService
          .getUserPaymentProofsStream(userId)
          .map(
            (proofs) =>
                proofs.where((p) => p.goalId == goalId).toList()
                  ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt)),
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final proofs = snapshot.data ?? [];

        if (proofs.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: proofs
              .map((proof) => _buildTransactionItem(proof, currencyFormatter))
              .toList(),
        );
      },
    );
  }

  Widget _buildTransactionItem(
    PaymentProofModel proof,
    NumberFormat formatter,
  ) {
    final amount = proof.metadata['amount'] as double? ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: _getStatusColor(proof.verificationStatus).withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _getStatusColor(proof.verificationStatus).withAlpha(25),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Icon(
              _getStatusIcon(proof.verificationStatus),
              color: _getStatusColor(proof.verificationStatus),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₦${formatter.format(amount)}',
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      timeago.format(proof.uploadedAt),
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

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(proof.verificationStatus).withAlpha(25),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Text(
              proof.statusLabel,
              style: AppTextTheme.bodySmall.copyWith(
                color: _getStatusColor(proof.verificationStatus),
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No deposits yet',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmRed.withAlpha(25),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.warmRed, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Failed to load transaction history',
              style: AppTextTheme.bodySmall.copyWith(color: AppColors.warmRed),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentProofStatus status) {
    switch (status) {
      case PaymentProofStatus.pending:
        return AppColors.softAmber;
      case PaymentProofStatus.approved:
        return AppColors.tealSuccess;
      case PaymentProofStatus.rejected:
        return AppColors.warmRed;
    }
  }

  IconData _getStatusIcon(PaymentProofStatus status) {
    switch (status) {
      case PaymentProofStatus.pending:
        return Icons.schedule;
      case PaymentProofStatus.approved:
        return Icons.check_circle;
      case PaymentProofStatus.rejected:
        return Icons.cancel;
    }
  }
}
