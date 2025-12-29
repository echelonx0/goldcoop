// lib/screens/dashboard/modals/withdrawal/widgets/withdrawal_widgets.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/admin_design_system.dart';
import '../../../../../models/financial_wallet_models.dart';

// ==================== WALLET SELECTION TILE ====================
class WalletSelectionTile extends StatelessWidget {
  final FinancialWallet wallet;
  final bool isSelected;
  final VoidCallback onSelected;

  const WalletSelectionTile({
    super.key,
    required this.wallet,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: EdgeInsets.all(AdminDesignSystem.spacing12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AdminDesignSystem.accentTeal
                : AdminDesignSystem.textTertiary.withAlpha(51),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          color: isSelected
              ? AdminDesignSystem.accentTeal.withAlpha(12)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AdminDesignSystem.accentTeal
                      : AdminDesignSystem.textTertiary,
                  width: 2,
                ),
                shape: BoxShape.circle,
                color: isSelected
                    ? AdminDesignSystem.accentTeal
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AdminDesignSystem.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.walletName,
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AdminDesignSystem.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wallet.displayDetails,
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== REVIEW ROW ====================
class ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final double? valueSize;
  final bool isBold;

  const ReviewRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueSize,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
        Text(
          value,
          style: AdminDesignSystem.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AdminDesignSystem.primaryNavy,
            fontSize: valueSize,
          ),
        ),
      ],
    );
  }
}

// ==================== SUCCESS DETAIL ====================
class SuccessDetail extends StatelessWidget {
  final String label;
  final String value;

  const SuccessDetail({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
        Text(
          value,
          style: AdminDesignSystem.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AdminDesignSystem.primaryNavy,
          ),
        ),
      ],
    );
  }
}

// ==================== MODAL HEADER ====================
class WithdrawalHeader extends StatelessWidget {
  final int currentStep;
  final String stepTitle;
  final double progressValue;
  final VoidCallback onClose;
  final bool isLoading;

  const WithdrawalHeader({
    super.key,
    required this.currentStep,
    required this.stepTitle,
    required this.progressValue,
    required this.onClose,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Withdraw Funds',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close,
                color: AdminDesignSystem.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
        if (!isLoading) ...[
          const SizedBox(height: AdminDesignSystem.spacing12),
          Text(
            'Step $currentStep of 4: $stepTitle',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              backgroundColor: AdminDesignSystem.accentTeal.withAlpha(38),
              valueColor: AlwaysStoppedAnimation<Color>(
                AdminDesignSystem.accentTeal,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ==================== MODAL FOOTER ====================
class WithdrawalFooter extends StatelessWidget {
  final String nextButtonText;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final bool isLoading;
  final bool canGoBack;

  const WithdrawalFooter({
    super.key,
    required this.nextButtonText,
    required this.onNext,
    this.onBack,
    this.isLoading = false,
    this.canGoBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (canGoBack && onBack != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: AdminDesignSystem.spacing12,
                ),
                side: const BorderSide(color: AdminDesignSystem.accentTeal),
              ),
              child: Text(
                'Back',
                style: AdminDesignSystem.labelMedium.copyWith(
                  color: AdminDesignSystem.accentTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (canGoBack && onBack != null)
          const SizedBox(width: AdminDesignSystem.spacing12),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminDesignSystem.accentTeal,
              padding: EdgeInsets.symmetric(
                vertical: AdminDesignSystem.spacing12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    nextButtonText,
                    style: AdminDesignSystem.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ==================== LOADING STATE ====================
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircularProgressIndicator(color: AdminDesignSystem.accentTeal),
          const SizedBox(height: AdminDesignSystem.spacing20),
          Text(
            'Checking withdrawal eligibility...',
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
