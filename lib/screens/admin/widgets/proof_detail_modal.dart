// lib/screens/admin/widgets/proof_detail_modal.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/payment_proof_model.dart';

class ProofDetailModal extends StatelessWidget {
  final PaymentProofModel proof;
  final String adminUserId;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onClose;

  const ProofDetailModal({
    super.key,
    required this.proof,
    required this.adminUserId,
    required this.onApprove,
    required this.onReject,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final amount = proof.metadata['amount'] as double? ?? 0.0;
    final goalTitle = proof.metadata['goalTitle'] as String?;
    final currencyFormatter = NumberFormat('#,##0', 'en_US');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.large),
          topRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Deposit Verification',
                      style: AppTextTheme.heading2.copyWith(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount card
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 150),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryOrange,
                            AppColors.primaryOrange.withAlpha(230),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.large,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'N${currencyFormatter.format(amount)}',
                            style: AppTextTheme.display.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            goalTitle ?? 'General Savings Deposit',
                            style: AppTextTheme.bodyRegular.copyWith(
                              color: Colors.white.withAlpha(230),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Details grid
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        _buildDetailRow('Status', proof.statusLabel),
                        _buildDetailRow('User ID', proof.userId),
                        _buildDetailRow('Transaction ID', proof.transactionId),
                        _buildDetailRow('File Name', proof.fileName),
                        _buildDetailRow(
                          'Uploaded',
                          DateFormat(
                            'MMM dd, yyyy HH:mm',
                          ).format(proof.uploadedAt),
                        ),
                        if (proof.verifiedAt != null)
                          _buildDetailRow(
                            'Verified',
                            DateFormat(
                              'MMM dd, yyyy HH:mm',
                            ).format(proof.verifiedAt!),
                          ),
                        if (proof.verifiedBy != null)
                          _buildDetailRow('Verified By', proof.verifiedBy!),
                        if (proof.rejectionReason != null)
                          _buildDetailRow(
                            'Rejection Reason',
                            proof.rejectionReason!,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // View proof button
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 250),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openProofFile(proof.fileUrl),
                        icon: Icon(
                          proof.fileType == ProofFileType.pdf
                              ? Icons.picture_as_pdf
                              : Icons.image,
                          size: 20,
                        ),
                        label: Text('View Proof Document'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          side: BorderSide(color: AppColors.primaryOrange),
                          foregroundColor: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Action buttons (only for pending)
                  if (proof.isPending)
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 300),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onReject,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                side: BorderSide(color: AppColors.warmRed),
                                foregroundColor: AppColors.warmRed,
                              ),
                              child: Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onApprove,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealSuccess,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                              ),
                              child: Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openProofFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
