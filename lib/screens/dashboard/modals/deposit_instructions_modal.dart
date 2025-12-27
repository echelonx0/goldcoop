// lib/screens/dashboard/modals/deposit_instructions_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../core/theme/app_colors.dart';
import '../../../components/base/app_button.dart';

class DepositInstructionsModal extends StatelessWidget {
  final String userId;
  final VoidCallback onClose;

  const DepositInstructionsModal({
    super.key,
    required this.userId,
    required this.onClose,
  });

  String get _paymentReference {
    // Last 7 digits of UID
    return userId.substring(userId.length - 7).toUpperCase();
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppColors.tealSuccess,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.large),
          topRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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

          // Title
          DelayedDisplay(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: AppColors.primaryOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deposit Instructions',
                        style: AppTextTheme.heading3.copyWith(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Transfer to this account',
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Bank details card
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepNavy,
                    AppColors.deepNavy.withAlpha(230),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppBorderRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withAlpha(38),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bank name
                  Text(
                    'GOLD Savings Co-operative',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Account number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Number',
                            style: AppTextTheme.bodySmall.copyWith(
                              color: Colors.white.withAlpha(179),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '1234567890',
                            style: AppTextTheme.heading2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _copyToClipboard(
                          context,
                          '1234567890',
                          'Account number',
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.small,
                            ),
                          ),
                          child: Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Account name
                  Text(
                    'Account Name',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: Colors.white.withAlpha(179),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'GOLD Savings Investment Ltd',
                    style: AppTextTheme.bodyRegular.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Payment reference card
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withAlpha(25),
                border: Border.all(color: AppColors.primaryOrange, width: 2),
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'IMPORTANT: Use this reference',
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Reference',
                            style: AppTextTheme.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _paymentReference,
                            style: AppTextTheme.heading2.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _copyToClipboard(
                          context,
                          _paymentReference,
                          'Reference',
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.small,
                            ),
                          ),
                          child: Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Instructions
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Steps:',
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildInstructionItem(
                  '1',
                  'Make transfer to the account above',
                ),
                _buildInstructionItem('2', 'Use your payment reference'),
                _buildInstructionItem('3', 'Upload proof of payment'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Close button
          DelayedDisplay(
            delay: const Duration(milliseconds: 500),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: 'Got It', onPressed: onClose),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextTheme.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
