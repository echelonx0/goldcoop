import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/admin_design_system.dart';

class WalletFormBuilder extends StatefulWidget {
  final TextEditingController walletNameController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController accountHolderController;
  final VoidCallback onAddWallet;
  final bool isQuick;

  const WalletFormBuilder({
    super.key,
    required this.walletNameController,
    required this.bankNameController,
    required this.accountNumberController,
    required this.accountHolderController,
    required this.onAddWallet,
    required this.isQuick,
  });

  @override
  State<WalletFormBuilder> createState() => _WalletFormBuilderState();
}

class _WalletFormBuilderState extends State<WalletFormBuilder> {
  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: Duration(milliseconds: widget.isQuick ? 200 : 300),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          border: Border.all(color: AdminDesignSystem.accentTeal.withAlpha(51)),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          color: AdminDesignSystem.accentTeal.withAlpha(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Withdrawal Wallet',
              style: AdminDesignSystem.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            _buildTextField(
              'Wallet Nickname (e.g., My TripWallet)',
              widget.walletNameController,
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            _buildTextField('Bank Name', widget.bankNameController),
            const SizedBox(height: AdminDesignSystem.spacing12),
            _buildTextField('Account Number', widget.accountNumberController),
            const SizedBox(height: AdminDesignSystem.spacing12),
            _buildTextField(
              'Account Holder Name',
              widget.accountHolderController,
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onAddWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminDesignSystem.accentTeal,
                  padding: const EdgeInsets.symmetric(
                    vertical: AdminDesignSystem.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius8,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Add Wallet',
                  style: AdminDesignSystem.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AdminDesignSystem.bodySmall.copyWith(
          color: AdminDesignSystem.textTertiary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
          borderSide: const BorderSide(color: AdminDesignSystem.textTertiary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdminDesignSystem.spacing12,
          vertical: AdminDesignSystem.spacing12,
        ),
      ),
    );
  }
}
