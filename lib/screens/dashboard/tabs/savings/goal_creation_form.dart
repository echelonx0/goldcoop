// lib/screens/dashboard/tabs/savings/goal_creation_form.dart

import 'package:flutter/material.dart';
import '../../../../components/base/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/goals_model.dart';
import '../../../../extensions/goal_category_extension.dart';

class GoalCreationForm extends StatefulWidget {
  final Function(GoalModel) onCreateGoal;
  final VoidCallback onCancel;

  const GoalCreationForm({
    super.key,
    required this.onCreateGoal,
    required this.onCancel,
  });

  @override
  State<GoalCreationForm> createState() => _GoalCreationFormState();
}

class _GoalCreationFormState extends State<GoalCreationForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _selectedTargetDate;
  late GoalCategory _selectedCategory;
  String? _titleError;
  String? _amountError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _selectedTargetDate = DateTime.now().add(const Duration(days: 90));
    _selectedCategory = GoalCategory.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _titleError = null;
      _amountError = null;
    });

    final title = _titleController.text.trim();
    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr);

    if (title.isEmpty) {
      setState(() => _titleError = 'Goal name required');
      return false;
    }
    if (title.length > 100) {
      setState(() => _titleError = 'Max 100 characters');
      return false;
    }

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

    if (_selectedTargetDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target date must be in the future')),
      );
      return false;
    }

    return true;
  }

  void _handleCreate() {
    if (!_validateForm()) return;

    final goal = GoalModel(
      goalId: '',
      userId: '',
      title: _titleController.text.trim(),
      description: 'Personal savings goal',
      category: _selectedCategory,
      status: GoalStatus.active,
      targetAmount: double.parse(_amountController.text.trim()),
      currentAmount: 0,
      monthlyContribution: 0,
      createdAt: DateTime.now(),
      targetDate: _selectedTargetDate,
      iconEmoji: _selectedCategory.emoji,
      updatedAt: DateTime.now(),
    );

    setState(() => _isLoading = true);
    widget.onCreateGoal(goal);
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
                'Create New Goal',
                style: AppTextTheme.heading3.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'What are you saving for?',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Goal title field
              TextField(
                controller: _titleController,
                maxLength: 100,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Goal name',
                  hintText: 'e.g., Summer vacation',
                  hintStyle: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  errorText: _titleError,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    borderSide: BorderSide(
                      color: _titleError != null
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
              const SizedBox(height: AppSpacing.md),

              // Category dropdown
              DropdownButtonFormField<GoalCategory>(
                initialValue: _selectedCategory,

                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    borderSide: BorderSide(color: AppColors.borderLight),
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
                items: GoalCategory.values
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Text(
                              cat.emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(cat.label),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedCategory = value!);
                      },
              ),
              const SizedBox(height: AppSpacing.md),

              // Target amount field
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
                      color: _amountError != null
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
              const SizedBox(height: AppSpacing.md),

              // Target date picker
              ListTile(
                title: Text(
                  'Target Date',
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  _selectedTargetDate.toString().split(' ')[0],
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: _isLoading
                    ? null
                    : Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                onTap: _isLoading
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedTargetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _selectedTargetDate = picked);
                        }
                      },
                contentPadding: EdgeInsets.zero,
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
                      label: _isLoading ? 'Creating...' : 'Create Goal',
                      onPressed: _isLoading ? null : _handleCreate,
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
