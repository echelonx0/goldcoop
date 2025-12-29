// lib/screens/dashboard/modals/withdrawal/steps/wallet_step.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../../core/theme/admin_design_system.dart';
import '../state/withdrawal_state.dart';
import '../logic/withdrawal_logic.dart';
import '../widgets/wallet_form_builder.dart';
import '../widgets/withdrawal_widgets.dart';

class WalletStep extends StatefulWidget {
  final WithdrawalState state;
  final WithdrawalLogic logic;
  final Function(WithdrawalState) onStateChanged;
  final Function(String) onError;

  const WalletStep({
    super.key,
    required this.state,
    required this.logic,
    required this.onStateChanged,
    required this.onError,
  });

  @override
  State<WalletStep> createState() => _WalletStepState();
}

class _WalletStepState extends State<WalletStep> {
  late TextEditingController _walletNameController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _accountHolderController;

  @override
  void initState() {
    super.initState();
    _walletNameController = TextEditingController();
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _accountHolderController = TextEditingController();
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your withdrawal wallet',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),
          if (widget.state.wallets != null && widget.state.wallets!.isNotEmpty)
            ..._buildWalletList(),
          const SizedBox(height: AdminDesignSystem.spacing24),
          WalletFormBuilder(
            walletNameController: _walletNameController,
            bankNameController: _bankNameController,
            accountNumberController: _accountNumberController,
            accountHolderController: _accountHolderController,
            onAddWallet: _handleAddWallet,
            isQuick: false,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWalletList() {
    return widget.state.wallets!.asMap().entries.map((entry) {
      final index = entry.key;
      final wallet = entry.value;

      return DelayedDisplay(
        delay: Duration(milliseconds: 250 + (index * 100)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AdminDesignSystem.spacing12),
          child: WalletSelectionTile(
            wallet: wallet,
            isSelected:
                widget.state.selectedWallet?.walletId == wallet.walletId,
            onSelected: () {
              final newState = widget.logic.selectWallet(widget.state, wallet);
              widget.onStateChanged(newState);
            },
          ),
        ),
      );
    }).toList();
  }

  void _handleAddWallet() async {
    try {
      final walletState = widget.state.copyWith(
        walletName: _walletNameController.text,
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        accountHolder: _accountHolderController.text,
      );

      final newState = await widget.logic.addWallet(walletState);
      widget.onStateChanged(newState);

      // Clear controllers after success
      _walletNameController.clear();
      _bankNameController.clear();
      _accountNumberController.clear();
      _accountHolderController.clear();
    } catch (e) {
      widget.onError('Error adding wallet: $e');
    }
  }
}
