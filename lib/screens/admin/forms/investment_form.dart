// lib/screens/admin/forms/investment_form.dart

import 'package:flutter/material.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/investment_plan_model.dart';

class InvestmentPlanForm extends StatefulWidget {
  final InvestmentPlanModel? plan;
  final Function(InvestmentPlanModel) onSave;

  const InvestmentPlanForm({
    super.key,
    required this.plan,
    required this.onSave,
  });

  @override
  State<InvestmentPlanForm> createState() => _InvestmentPlanFormState();
}

class _InvestmentPlanFormState extends State<InvestmentPlanForm> {
  late final TextEditingController _planNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _minInvestmentController;
  late final TextEditingController _maxInvestmentController;
  late final TextEditingController _expectedReturnController;
  late final TextEditingController _durationController;

  late String _selectedPayoutFrequency;
  late bool _isActive;
  late bool _isFeatured;

  final FocusNode _planNameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _minInvestmentFocus = FocusNode();
  final FocusNode _maxInvestmentFocus = FocusNode();
  final FocusNode _expectedReturnFocus = FocusNode();
  final FocusNode _durationFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _planNameController = TextEditingController(text: plan?.planName ?? '');
    _descriptionController = TextEditingController(
      text: plan?.description ?? '',
    );
    _minInvestmentController = TextEditingController(
      text: plan != null ? _formatCurrency(plan.minimumInvestment) : '',
    );
    _maxInvestmentController = TextEditingController(
      text: plan != null ? _formatCurrency(plan.maximumInvestment) : '',
    );
    _expectedReturnController = TextEditingController(
      text: plan?.expectedAnnualReturn.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: plan?.durationMonths.toString() ?? '',
    );
    _selectedPayoutFrequency = plan?.payoutFrequency ?? 'Monthly';
    _isActive = plan?.isActive ?? true;
    _isFeatured = plan?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _descriptionController.dispose();
    _minInvestmentController.dispose();
    _maxInvestmentController.dispose();
    _expectedReturnController.dispose();
    _durationController.dispose();
    _planNameFocus.dispose();
    _descriptionFocus.dispose();
    _minInvestmentFocus.dispose();
    _maxInvestmentFocus.dispose();
    _expectedReturnFocus.dispose();
    _durationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Container(
        decoration: BoxDecoration(
          color: AdminDesignSystem.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AdminDesignSystem.radius24),
            topRight: Radius.circular(AdminDesignSystem.radius24),
          ),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: AdminDesignSystem.spacing16,
              right: AdminDesignSystem.spacing16,
              top: AdminDesignSystem.spacing16,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  AdminDesignSystem.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AdminDesignSystem.divider,
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing20),

                // Title
                Text(
                  widget.plan == null ? 'Create Investment Plan' : 'Edit Plan',
                  style: AdminDesignSystem.headingLarge.copyWith(
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing8),
                Text(
                  widget.plan == null
                      ? 'Add a new investment product'
                      : 'Update plan details',
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),

                const SizedBox(height: AdminDesignSystem.spacing24),

                // Plan Name
                _buildFormField(
                  label: 'Plan Name',
                  hint: 'e.g., Gold Plus, Silver Shield',
                  controller: _planNameController,
                  focusNode: _planNameFocus,
                  nextFocus: _descriptionFocus,
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Description
                _buildFormField(
                  label: 'Description',
                  hint: 'Brief description of the plan',
                  controller: _descriptionController,
                  focusNode: _descriptionFocus,
                  nextFocus: _minInvestmentFocus,
                  maxLines: 3,
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Min & Max Investment Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: 'Min Investment',
                        hint: '1,000,000',
                        controller: _minInvestmentController,
                        focusNode: _minInvestmentFocus,
                        nextFocus: _maxInvestmentFocus,
                        keyboardType: TextInputType.number,
                        onChanged: _formatMinInvestmentInput,
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),
                    Expanded(
                      child: _buildFormField(
                        label: 'Max Investment',
                        hint: '100,000,000',
                        controller: _maxInvestmentController,
                        focusNode: _maxInvestmentFocus,
                        nextFocus: _expectedReturnFocus,
                        keyboardType: TextInputType.number,
                        onChanged: _formatMaxInvestmentInput,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Expected Return & Duration Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: 'Annual Return (%)',
                        hint: '12.5',
                        controller: _expectedReturnController,
                        focusNode: _expectedReturnFocus,
                        nextFocus: _durationFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),
                    Expanded(
                      child: _buildFormField(
                        label: 'Duration (months)',
                        hint: '12',
                        controller: _durationController,
                        focusNode: _durationFocus,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Payout Frequency
                _buildDropdownField(
                  label: 'Payout Frequency',
                  value: _selectedPayoutFrequency,
                  items: ['Monthly', 'Quarterly', 'Annual'],
                  onChanged: (value) {
                    setState(
                      () => _selectedPayoutFrequency = value ?? 'Monthly',
                    );
                    _dismissKeyboard();
                  },
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Status Toggles
                Container(
                  decoration: BoxDecoration(
                    color: AdminDesignSystem.background,
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius12,
                    ),
                    border: Border.all(color: AdminDesignSystem.divider),
                  ),
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                  child: Column(
                    children: [
                      _buildToggleRow(
                        label: 'Active',
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value);
                          _dismissKeyboard();
                        },
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing12),
                      _buildToggleRow(
                        label: 'Featured',
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() => _isFeatured = value);
                          _dismissKeyboard();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AdminDesignSystem.spacing24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _dismissKeyboard();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminDesignSystem.textSecondary,
                          side: BorderSide(color: AdminDesignSystem.divider),
                          padding: const EdgeInsets.symmetric(
                            vertical: AdminDesignSystem.spacing12,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AdminDesignSystem.labelSmall,
                        ),
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminDesignSystem.accentTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AdminDesignSystem.spacing12,
                          ),
                        ),
                        child: Text(
                          'Save Plan',
                          style: AdminDesignSystem.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AdminDesignSystem.labelMedium.copyWith(
            color: AdminDesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : null,
          textInputAction: nextFocus != null
              ? TextInputAction.next
              : TextInputAction.done,
          onSubmitted: nextFocus != null
              ? (_) => _moveFocus(context, nextFocus)
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textTertiary,
            ),
            filled: true,
            fillColor: AdminDesignSystem.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide(color: AdminDesignSystem.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide(
                color: AdminDesignSystem.accentTeal,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing12,
              vertical: AdminDesignSystem.spacing12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AdminDesignSystem.labelMedium.copyWith(
            color: AdminDesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing8),
        Container(
          decoration: BoxDecoration(
            color: AdminDesignSystem.background,
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            border: Border.all(color: AdminDesignSystem.divider),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: onChanged,
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminDesignSystem.spacing12,
                        vertical: AdminDesignSystem.spacing12,
                      ),
                      child: Text(item, style: AdminDesignSystem.bodyMedium),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AdminDesignSystem.bodyMedium.copyWith(
            color: AdminDesignSystem.textPrimary,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AdminDesignSystem.accentTeal,
          activeTrackColor: AdminDesignSystem.accentTeal.withAlpha(127),
        ),
      ],
    );
  }

  void _formatMinInvestmentInput(String value) {
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericValue.isEmpty) {
      _minInvestmentController.clear();
      return;
    }

    final formatted = _formatCurrency(double.parse(numericValue));
    _minInvestmentController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _formatMaxInvestmentInput(String value) {
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericValue.isEmpty) {
      _maxInvestmentController.clear();
      return;
    }

    final formatted = _formatCurrency(double.parse(numericValue));
    _maxInvestmentController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = RegExp(r'(\d)(?=(\d{3})+$)');
    final intAmount = amount.toInt();
    return intAmount.toString().replaceAllMapped(
      formatter,
      (match) => '${match.group(1)},',
    );
  }

  void _moveFocus(BuildContext context, FocusNode nextFocus) {
    _dismissKeyboard();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _saveForm() {
    if (_planNameController.text.isEmpty ||
        _minInvestmentController.text.isEmpty ||
        _maxInvestmentController.text.isEmpty ||
        _expectedReturnController.text.isEmpty ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: AdminDesignSystem.statusError,
        ),
      );
      return;
    }

    final minInvestment = double.parse(
      _minInvestmentController.text.replaceAll(',', ''),
    );
    final maxInvestment = double.parse(
      _maxInvestmentController.text.replaceAll(',', ''),
    );

    if (minInvestment > maxInvestment) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Min investment must be less than max investment',
          ),
          backgroundColor: AdminDesignSystem.statusError,
        ),
      );
      return;
    }

    final updatedPlan =
        (widget.plan ??
                InvestmentPlanModel(
                  planId: DateTime.now().millisecondsSinceEpoch.toString(),
                  planName: '',
                  description: '',
                  minimumInvestment: 0,
                  maximumInvestment: 0,
                  expectedAnnualReturn: 0,
                  payoutFrequency: 'Monthly',
                  durationMonths: 12,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
            .copyWith(
              planName: _planNameController.text,
              description: _descriptionController.text,
              minimumInvestment: minInvestment,
              maximumInvestment: maxInvestment,
              expectedAnnualReturn: double.parse(
                _expectedReturnController.text,
              ),
              payoutFrequency: _selectedPayoutFrequency,
              durationMonths: int.parse(_durationController.text),
              isActive: _isActive,
              isFeatured: _isFeatured,
            );

    _dismissKeyboard();
    widget.onSave(updatedPlan);
  }
}
