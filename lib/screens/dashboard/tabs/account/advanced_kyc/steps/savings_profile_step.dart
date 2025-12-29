// lib/screens/dashboard/tabs/account/advanced_kyc/steps/savings_profile_step.dart
// Savings Profile form step

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';

import '../../../../../../core/theme/admin_design_system.dart';
import '../../../../../../models/advanced_kyc_model.dart';

class SavingsProfileStep extends StatefulWidget {
  final SavingsProfile initialData;
  final Function(SavingsProfile) onSave;
  final VoidCallback onBack;
  final bool isSaving;

  const SavingsProfileStep({
    super.key,
    required this.initialData,
    required this.onSave,
    required this.onBack,
    this.isSaving = false,
  });

  @override
  State<SavingsProfileStep> createState() => _SavingsProfileStepState();
}

class _SavingsProfileStepState extends State<SavingsProfileStep> {
  final _formKey = GlobalKey<FormState>();

  late String? _selectedPurpose;
  late TextEditingController _targetAmountController;
  late String? _selectedDuration;
  late TextEditingController _referralNameController;
  late TextEditingController _referralPhoneController;
  late List<String> _selectedInterests;

  final List<String> _durationOptions = [
    '3 months',
    '6 months',
    '1 year',
    '2 years',
    '5 years',
    'No specific timeline',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPurpose = widget.initialData.savingsPurpose.isNotEmpty
        ? widget.initialData.savingsPurpose
        : null;
    _targetAmountController = TextEditingController(
      text: widget.initialData.targetAmount > 0
          ? _formatAmount(widget.initialData.targetAmount)
          : '',
    );
    _selectedDuration = widget.initialData.targetDuration.isNotEmpty
        ? widget.initialData.targetDuration
        : null;
    _referralNameController = TextEditingController(
      text: widget.initialData.referralName,
    );
    _referralPhoneController = TextEditingController(
      text: widget.initialData.referralPhone,
    );
    _selectedInterests = List.from(widget.initialData.interestAreas);
  }

  @override
  void dispose() {
    _targetAmountController.dispose();
    _referralNameController.dispose();
    _referralPhoneController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final chars = formatted.split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }
    return buffer.toString().split('').reversed.join('');
  }

  double _parseAmount(String text) {
    return double.tryParse(text.replaceAll(',', '')) ?? 0.0;
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final profile = SavingsProfile(
        savingsPurpose: _selectedPurpose ?? '',
        targetAmount: _parseAmount(_targetAmountController.text),
        targetDuration: _selectedDuration ?? '',
        referralName: _referralNameController.text.trim(),
        referralPhone: _referralPhoneController.text.trim(),
        interestAreas: _selectedInterests,
      );
      widget.onSave(profile);
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DelayedDisplay(
                delay: const Duration(milliseconds: 100),
                child: _buildSectionHeader(
                  'Your Savings Goals',
                  'Help us understand your financial goals',
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // Savings Purpose
              DelayedDisplay(
                delay: const Duration(milliseconds: 150),
                child: _buildPurposeDropdown(),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Target Amount
              DelayedDisplay(
                delay: const Duration(milliseconds: 200),
                child: _buildAmountField(),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Duration
              DelayedDisplay(
                delay: const Duration(milliseconds: 250),
                child: _buildDurationDropdown(),
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // Interest Areas
              DelayedDisplay(
                delay: const Duration(milliseconds: 300),
                child: _buildInterestAreas(),
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // Referral Section
              DelayedDisplay(
                delay: const Duration(milliseconds: 350),
                child: _buildReferralSection(),
              ),
              const SizedBox(height: AdminDesignSystem.spacing32),

              // Buttons
              DelayedDisplay(
                delay: const Duration(milliseconds: 400),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.isSaving ? null : widget.onBack,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AdminDesignSystem.spacing16,
                          ),
                          side: const BorderSide(
                            color: AdminDesignSystem.divider,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AdminDesignSystem.radius12,
                            ),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: AdminDesignSystem.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AdminDesignSystem.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: widget.isSaving ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminDesignSystem.accentTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AdminDesignSystem.spacing16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AdminDesignSystem.radius12,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: widget.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Complete Profile',
                                style: AdminDesignSystem.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AdminDesignSystem.headingMedium.copyWith(
            color: AdminDesignSystem.primaryNavy,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          subtitle,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What are you saving for?', style: AdminDesignSystem.labelMedium),
        const SizedBox(height: AdminDesignSystem.spacing8),
        DropdownButtonFormField<String>(
          value: _selectedPurpose,
          hint: Text(
            'Select savings purpose',
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textTertiary,
            ),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a savings purpose';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.flag_outlined,
              size: 20,
              color: AdminDesignSystem.textTertiary,
            ),
            filled: true,
            fillColor: AdminDesignSystem.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing16,
              vertical: AdminDesignSystem.spacing12,
            ),
          ),
          items: SavingsPurposeOptions.purposes.map((purpose) {
            return DropdownMenuItem(value: purpose, child: Text(purpose));
          }).toList(),
          onChanged: (value) => setState(() => _selectedPurpose = value),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Target Amount', style: AdminDesignSystem.labelMedium),
        const SizedBox(height: AdminDesignSystem.spacing8),
        TextFormField(
          controller: _targetAmountController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a target amount';
            }
            if (_parseAmount(value!) <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
          onChanged: (value) {
            // Format with commas
            final amount = _parseAmount(value);
            if (amount > 0) {
              final formatted = _formatAmount(amount);
              if (formatted != value) {
                _targetAmountController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            }
          },
          style: AdminDesignSystem.bodyMedium.copyWith(
            color: AdminDesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '0',
            prefixText: '₦ ',
            hintStyle: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textTertiary,
            ),
            prefixIcon: const Icon(
              Icons.savings_outlined,
              size: 20,
              color: AdminDesignSystem.textTertiary,
            ),
            filled: true,
            fillColor: AdminDesignSystem.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: const BorderSide(
                color: AdminDesignSystem.accentTeal,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing16,
              vertical: AdminDesignSystem.spacing12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Timeline', style: AdminDesignSystem.labelMedium),
        const SizedBox(height: AdminDesignSystem.spacing8),
        DropdownButtonFormField<String>(
          value: _selectedDuration,
          hint: Text(
            'Select duration',
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textTertiary,
            ),
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.schedule,
              size: 20,
              color: AdminDesignSystem.textTertiary,
            ),
            filled: true,
            fillColor: AdminDesignSystem.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing16,
              vertical: AdminDesignSystem.spacing12,
            ),
          ),
          items: _durationOptions.map((duration) {
            return DropdownMenuItem(value: duration, child: Text(duration));
          }).toList(),
          onChanged: (value) => setState(() => _selectedDuration = value),
        ),
      ],
    );
  }

  Widget _buildInterestAreas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What products interest you?',
          style: AdminDesignSystem.labelMedium,
        ),
        const SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          'Help us personalize your experience',
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textTertiary,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing12),
        // Product Interests with icons
        ...ProductInterestOptions.products.map((product) {
          final isSelected = _selectedInterests.contains(product.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: AdminDesignSystem.spacing8),
            child: GestureDetector(
              onTap: () => _toggleInterest(product.id),
              child: Container(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AdminDesignSystem.accentTeal.withAlpha(25)
                      : AdminDesignSystem.background,
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius12,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? AdminDesignSystem.accentTeal
                        : AdminDesignSystem.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AdminDesignSystem.accentTeal.withAlpha(38)
                            : AdminDesignSystem.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius8,
                        ),
                      ),
                      child: Icon(
                        _getProductIcon(product.icon),
                        size: 20,
                        color: isSelected
                            ? AdminDesignSystem.accentTeal
                            : AdminDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AdminDesignSystem.bodyMedium.copyWith(
                              color: isSelected
                                  ? AdminDesignSystem.accentTeal
                                  : AdminDesignSystem.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AdminDesignSystem.spacing4),
                          Text(
                            product.description,
                            style: AdminDesignSystem.labelSmall.copyWith(
                              color: AdminDesignSystem.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        size: 24,
                        color: AdminDesignSystem.accentTeal,
                      )
                    else
                      Icon(
                        Icons.circle_outlined,
                        size: 24,
                        color: AdminDesignSystem.divider,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: AdminDesignSystem.spacing16),
        // Legacy interest areas as chips
        Text(
          'Investment categories',
          style: AdminDesignSystem.labelSmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing8),
        Wrap(
          spacing: AdminDesignSystem.spacing8,
          runSpacing: AdminDesignSystem.spacing8,
          children: InterestAreaOptions.areas.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () => _toggleInterest(interest),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminDesignSystem.spacing12,
                  vertical: AdminDesignSystem.spacing8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AdminDesignSystem.accentTeal.withAlpha(38)
                      : AdminDesignSystem.background,
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius24,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? AdminDesignSystem.accentTeal
                        : AdminDesignSystem.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check,
                        size: 16,
                        color: AdminDesignSystem.accentTeal,
                      ),
                      const SizedBox(width: AdminDesignSystem.spacing4),
                    ],
                    Text(
                      interest,
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: isSelected
                            ? AdminDesignSystem.accentTeal
                            : AdminDesignSystem.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getProductIcon(String iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings_outlined;
      case 'trending_up':
        return Icons.trending_up;
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'security':
        return Icons.security_outlined;
      case 'groups':
        return Icons.groups_outlined;
      case 'school':
        return Icons.school_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildReferralSection() {
    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.background,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
      ),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group_add_outlined,
                size: 20,
                color: AdminDesignSystem.accentTeal,
              ),
              const SizedBox(width: AdminDesignSystem.spacing8),
              Text(
                'Referral Information (Optional)',
                style: AdminDesignSystem.labelMedium.copyWith(
                  color: AdminDesignSystem.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing4),
          Text(
            'Did someone refer you to Gold Savings?',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),
          TextFormField(
            controller: _referralNameController,
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Referrer\'s name',
              hintStyle: AdminDesignSystem.bodyMedium.copyWith(
                color: AdminDesignSystem.textTertiary,
              ),
              filled: true,
              fillColor: AdminDesignSystem.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AdminDesignSystem.spacing16,
                vertical: AdminDesignSystem.spacing12,
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          TextFormField(
            controller: _referralPhoneController,
            keyboardType: TextInputType.phone,
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Referrer\'s phone number',
              hintStyle: AdminDesignSystem.bodyMedium.copyWith(
                color: AdminDesignSystem.textTertiary,
              ),
              filled: true,
              fillColor: AdminDesignSystem.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AdminDesignSystem.spacing16,
                vertical: AdminDesignSystem.spacing12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
