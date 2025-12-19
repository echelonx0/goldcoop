// lib/screens/dashboard/tabs/savings/set_savings_target_form.dart

import 'package:flutter/material.dart';
import '../../../../components/base/app_button.dart';
import '../../../../core/theme/app_colors.dart';

class SetSavingsTargetForm extends StatefulWidget {
  final Function(double) onSetTarget;
  final VoidCallback onCancel;

  const SetSavingsTargetForm({
    super.key,
    required this.onSetTarget,
    required this.onCancel,
  });

  @override
  State<SetSavingsTargetForm> createState() => _SetSavingsTargetFormState();
}

class _SetSavingsTargetFormState extends State<SetSavingsTargetForm> {
  late final TextEditingController _amountController;
  String? _amountError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool _validateAmount() {
    setState(() => _amountError = null);

    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr);

    if (amountStr.isEmpty) {
      setState(() => _amountError = 'Amount required');
      return false;
    }
    if (amount == null) {
      setState(() => _amountError = 'Invalid amount');
      return false;
    }
    if (amount <= 0) {
      setState(() => _amountError = 'Must be greater than 0');
      return false;
    }
    if (amount > 999999999) {
      setState(() => _amountError = 'Amount too large');
      return false;
    }

    return true;
  }

  void _handleSetTarget() {
    if (!_validateAmount()) return;

    setState(() => _isLoading = true);
    widget.onSetTarget(double.parse(_amountController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.large),
            topRight: Radius.circular(AppBorderRadius.large),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          top: AppSpacing.lg,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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
              Text(
                'Set Savings Target',
                style: AppTextTheme.heading3.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'How much do you want to save?',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Amount input
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Target amount',
                  hintText: 'Enter amount',
                  prefixText: '₦ ',
                  errorText: _amountError,
                  hintStyle: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    borderSide: BorderSide(
                      color:
                          _amountError != null
                              ? AppColors.warmRed
                              : AppColors.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    borderSide: BorderSide(
                      color: AppColors.primaryOrange,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancel',
                      onPressed: _isLoading ? null : widget.onCancel,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PrimaryButton(
                      label: _isLoading ? 'Setting...' : 'Set Target',
                      onPressed: _isLoading ? null : _handleSetTarget,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
