// lib/screens/dashboard/modals/withdrawal/states/blocked_state.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../../core/theme/admin_design_system.dart';
import '../state/withdrawal_state.dart';
import '../logic/withdrawal_logic.dart';
import '../widgets/wallet_form_builder.dart';

class BlockedState extends StatefulWidget {
  final WithdrawalState state;
  final WithdrawalLogic logic;
  final Function(WithdrawalState) onStateChanged;
  final Function(String) onError;

  const BlockedState({
    super.key,
    required this.state,
    required this.logic,
    required this.onStateChanged,
    required this.onError,
  });

  @override
  State<BlockedState> createState() => _BlockedStateState();
}

class _BlockedStateState extends State<BlockedState> {
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
        children: [
          const SizedBox(height: 40),
          _buildIcon(),
          const SizedBox(height: AdminDesignSystem.spacing20),
          _buildTitle(),
          const SizedBox(height: AdminDesignSystem.spacing12),
          _buildDescription(),
          const SizedBox(height: AdminDesignSystem.spacing24),
          if (widget.state.isNoWallet) _buildWalletForm(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final isNoBalance = widget.state.isNoBalance;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AdminDesignSystem.statusError.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isNoBalance ? Icons.account_balance_wallet_outlined : Icons.add,
        color: AdminDesignSystem.statusError,
        size: 40,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.state.stateMessage!,
      style: AdminDesignSystem.headingMedium.copyWith(
        color: AdminDesignSystem.primaryNavy,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    final isNoBalance = widget.state.isNoBalance;
    return Text(
      isNoBalance
          ? 'You don\'t have sufficient balance to withdraw. Add funds to your account first.'
          : 'You haven\'t set up a withdrawal wallet yet. Add one below to proceed.',
      style: AdminDesignSystem.bodySmall.copyWith(
        color: AdminDesignSystem.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildWalletForm() {
    return WalletFormBuilder(
      walletNameController: _walletNameController,
      bankNameController: _bankNameController,
      accountNumberController: _accountNumberController,
      accountHolderController: _accountHolderController,
      onAddWallet: _handleAddWallet,
      isQuick: true,
    );
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
