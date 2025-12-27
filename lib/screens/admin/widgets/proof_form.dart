// lib/screens/admin/widgets/proof_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../models/payment_proof_model.dart';

class ProofCard extends StatelessWidget {
  final PaymentProofModel proof;
  final NumberFormat currencyFormatter;
  final VoidCallback onTap;

  const ProofCard({
    super.key,
    required this.proof,
    required this.currencyFormatter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amount = proof.metadata['amount'] as double? ?? 0.0;
    final goalTitle = proof.metadata['goalTitle'] as String?;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: _getStatusColor().withAlpha(50),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepNavy.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Amount + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'â‚¦${currencyFormatter.format(amount)}',
                          style: AppTextTheme.heading2.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          goalTitle ?? 'General Savings',
                          style: AppTextTheme.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Divider
              Container(height: 1, color: AppColors.borderLight),

              const SizedBox(height: AppSpacing.md),

              // Details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.access_time,
                      timeago.format(proof.uploadedAt),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(_getFileIcon(), proof.fileName),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Transaction ID
              _buildInfoItem(
                Icons.receipt_long,
                'TXN: ${proof.transactionId.substring(0, 8).toUpperCase()}...',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withAlpha(25),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            proof.statusLabel,
            style: AppTextTheme.bodySmall.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (proof.verificationStatus) {
      case PaymentProofStatus.pending:
        return AppColors.softAmber;
      case PaymentProofStatus.approved:
        return AppColors.tealSuccess;
      case PaymentProofStatus.rejected:
        return AppColors.warmRed;
    }
  }

  IconData _getFileIcon() {
    switch (proof.fileType) {
      case ProofFileType.pdf:
        return Icons.picture_as_pdf;
      case ProofFileType.image:
        return Icons.image;
    }
  }
}
