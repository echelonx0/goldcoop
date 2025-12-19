// lib/screens/dashboard/tabs/savings/add_to_goal_form.dart

import 'package:flutter/material.dart';
import '../../../../components/base/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/goals_model.dart';

class AddToGoalForm extends StatefulWidget {
  final GoalModel goal;
  final Function(double) onContribute;
  final VoidCallback onCancel;

  const AddToGoalForm({
    super.key,
    required this.goal,
    required this.onContribute,
    required this.onCancel,
  });

  @override
  State<AddToGoalForm> createState() => _AddToGoalFormState();
}

class _AddToGoalFormState extends State<AddToGoalForm> {
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
    if (amount > widget.goal.remainingAmount) {
      setState(
        () =>
            _amountError =
                'Amount exceeds remaining (₦${widget.goal.remainingAmount.toStringAsFixed(0)})',
      );
      return false;
    }

    return true;
  }

  void _handleContribute() {
    if (!_validateAmount()) return;

    setState(() => _isLoading = true);
    widget.onContribute(double.parse(_amountController.text.trim()));
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

              // Header
              Text(
                'Add to ${widget.goal.title}',
                style: AppTextTheme.heading3.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'How much do you want to contribute?',
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
                  labelText: 'Amount',
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

              // Goal progress card
              _buildGoalProgressInfo(),
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
                      label: _isLoading ? 'Adding...' : 'Add to Goal',
                      onPressed: _isLoading ? null : _handleContribute,
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

  Widget _buildGoalProgressInfo() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Progress',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₦${widget.goal.currentAmount.toStringAsFixed(0)} / ₦${widget.goal.targetAmount.toStringAsFixed(0)}',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.goal.progressPercentage.toStringAsFixed(0)}%',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
            child: LinearProgressIndicator(
              value:
                  (widget.goal.progressPercentage / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.primaryOrange.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
