// lib/screens/dashboard/modals/withdrawal/steps/amount_step.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../../core/theme/admin_design_system.dart';
import '../state/withdrawal_state.dart';
import '../logic/withdrawal_logic.dart';

class AmountStep extends StatelessWidget {
  final WithdrawalState state;
  final WithdrawalLogic logic;
  final Function(WithdrawalState) onStateChanged;

  const AmountStep({
    super.key,
    required this.state,
    required this.logic,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How much do you want to withdraw?',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          _buildAmountInput(),
          const SizedBox(height: AdminDesignSystem.spacing20),
          _buildBalanceCard(context),
          const SizedBox(height: AdminDesignSystem.spacing20),
          if (state.withdrawalAmount > 0 && !state.isAmountValid)
            _buildErrorMessage(),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AdminDesignSystem.accentTeal),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing16,
        vertical: AdminDesignSystem.spacing16,
      ),
      child: Row(
        children: [
          Text(
            '₦',
            style: AdminDesignSystem.displayLarge.copyWith(
              color: AdminDesignSystem.accentTeal,
              fontSize: 28,
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing8),
          Expanded(
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: '0',
                border: InputBorder.none,
                hintStyle: AdminDesignSystem.displayLarge.copyWith(
                  color: AdminDesignSystem.textTertiary,
                  fontSize: 28,
                ),
              ),
              style: AdminDesignSystem.displayLarge.copyWith(
                fontSize: 28,
              ),
              onChanged: (value) {
                final newState = logic.setAmount(state, value);
                onStateChanged(newState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: AdminDesignSystem.accentTeal.withAlpha(12),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        border: Border.all(
          color: AdminDesignSystem.accentTeal.withAlpha(51),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance',
                style: AdminDesignSystem.labelSmall.copyWith(
                  color: AdminDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing4),
              Text(
                logic.formatCurrency(state.availableBalance),
                style: AdminDesignSystem.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AdminDesignSystem.accentTeal,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              final newState = logic.setMaxAmount(state);
              onStateChanged(newState);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminDesignSystem.accentTeal,
              padding: const EdgeInsets.symmetric(
                horizontal: AdminDesignSystem.spacing16,
                vertical: AdminDesignSystem.spacing8,
              ),
              elevation: 0,
            ),
            child: Text(
              'Max',
              style: AdminDesignSystem.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
        decoration: BoxDecoration(
          color: AdminDesignSystem.statusError.withAlpha(25),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AdminDesignSystem.statusError,
              size: 20,
            ),
            const SizedBox(width: AdminDesignSystem.spacing12),
            Expanded(
              child: Text(
                'Amount exceeds available balance',
                style: AdminDesignSystem.bodySmall.copyWith(
                  color: AdminDesignSystem.statusError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
