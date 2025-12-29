// lib/screens/dashboard/modals/withdrawal/steps/review_step.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../../core/theme/admin_design_system.dart';
import '../state/withdrawal_state.dart';
import '../logic/withdrawal_logic.dart';

import '../widgets/withdrawal_widgets.dart';

class ReviewStep extends StatelessWidget {
  final WithdrawalState state;
  final WithdrawalLogic logic;

  const ReviewStep({super.key, required this.state, required this.logic});

  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Withdrawal',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),
          _buildAmountCard(),
          const SizedBox(height: AdminDesignSystem.spacing20),
          _buildProcessingInfoBox(),
          const SizedBox(height: AdminDesignSystem.spacing20),
          _buildAccountVerificationWarning(),
          const SizedBox(height: AdminDesignSystem.spacing16),
          _buildLiabilityDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: AdminDesignSystem.accentTeal.withAlpha(12),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(color: AdminDesignSystem.accentTeal.withAlpha(51)),
        ),
        child: Column(
          children: [
            ReviewRow(
              label: 'Withdrawal Amount',
              value: logic.formatCurrency(state.withdrawalAmount),
              valueColor: AdminDesignSystem.accentTeal,
              isBold: true,
            ),
            const Divider(height: 24),
            ReviewRow(
              label: 'To Wallet',
              value: state.selectedWallet?.walletName ?? 'N/A',
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            ReviewRow(
              label: 'Bank Details',
              value: state.selectedWallet?.displayDetails ?? 'N/A',
              valueSize: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingInfoBox() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: AdminDesignSystem.statusActive.withAlpha(12),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(
            color: AdminDesignSystem.statusActive.withAlpha(51),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AdminDesignSystem.statusActive,
              size: 20,
            ),
            const SizedBox(width: AdminDesignSystem.spacing12),
            Expanded(
              child: Text(
                'Withdrawals typically arrive within 24 hours',
                style: AdminDesignSystem.bodySmall.copyWith(
                  color: AdminDesignSystem.statusActive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountVerificationWarning() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: AdminDesignSystem.statusPending.withAlpha(12),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(
            color: AdminDesignSystem.statusPending.withAlpha(51),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: AdminDesignSystem.statusPending,
                  size: 20,
                ),
                const SizedBox(width: AdminDesignSystem.spacing12),
                Expanded(
                  child: Text(
                    'Please verify account details',
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.statusPending,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            Text(
              'Ensure the wallet name, bank name, and account number are correct. Funds cannot be recovered if sent to the wrong account.',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiabilityDisclaimer() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
        decoration: BoxDecoration(
          color: AdminDesignSystem.background,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
          border: Border.all(color: AdminDesignSystem.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disclaimer',
              style: AdminDesignSystem.labelSmall.copyWith(
                color: AdminDesignSystem.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            Text(
              'GOLD Savings & Investment Co-operative is not liable for any funds sent to incorrect account details. You are solely responsible for verifying all account information before confirming this withdrawal. Once submitted, withdrawals cannot be cancelled or reversed.',
              style: AdminDesignSystem.labelSmall.copyWith(
                color: AdminDesignSystem.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: AdminDesignSystem.statusActive,
                  size: 16,
                ),
                const SizedBox(width: AdminDesignSystem.spacing8),
                Expanded(
                  child: Text(
                    'I have verified all account details and accept responsibility',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
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
}
