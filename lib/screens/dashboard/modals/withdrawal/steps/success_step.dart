// lib/screens/dashboard/modals/withdrawal/steps/success_step.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../../core/theme/admin_design_system.dart';
import '../state/withdrawal_state.dart';
import '../logic/withdrawal_logic.dart';
import '../widgets/withdrawal_widgets.dart';

class SuccessStep extends StatelessWidget {
  final WithdrawalState state;
  final WithdrawalLogic logic;

  const SuccessStep({super.key, required this.state, required this.logic});

  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          _buildCheckmark(),
          const SizedBox(height: AdminDesignSystem.spacing20),
          _buildTitle(),
          const SizedBox(height: AdminDesignSystem.spacing12),
          _buildDescription(),
          const SizedBox(height: AdminDesignSystem.spacing20),
          _buildDetailsCard(),
        ],
      ),
    );
  }

  Widget _buildCheckmark() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 300),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AdminDesignSystem.statusActive.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          color: AdminDesignSystem.statusActive,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 400),
      child: Text(
        'Withdrawal Submitted!',
        style: AdminDesignSystem.headingMedium.copyWith(
          color: AdminDesignSystem.primaryNavy,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescription() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 500),
      child: Text(
        'Your withdrawal request has been submitted successfully.',
        style: AdminDesignSystem.bodySmall.copyWith(
          color: AdminDesignSystem.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDetailsCard() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: AdminDesignSystem.accentTeal.withAlpha(12),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SuccessDetail(
              label: 'Amount',
              value: logic.formatCurrency(state.withdrawalAmount),
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            SuccessDetail(
              label: 'Wallet',
              value: state.selectedWallet?.walletName ?? 'N/A',
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            SuccessDetail(label: 'Processing Time', value: 'Up to 24 hours'),
          ],
        ),
      ),
    );
  }
}
