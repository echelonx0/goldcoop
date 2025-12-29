// lib/screens/dashboard/tabs/account/advanced_kyc/steps/next_of_kin_step.dart
// Next of Kin form step

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';

import '../../../../../../core/theme/admin_design_system.dart';
import '../../../../../../models/advanced_kyc_model.dart';

class NextOfKinStep extends StatefulWidget {
  final NextOfKin initialData;
  final Function(NextOfKin) onSave;
  final VoidCallback onBack;
  final bool isSaving;

  const NextOfKinStep({
    super.key,
    required this.initialData,
    required this.onSave,
    required this.onBack,
    this.isSaving = false,
  });

  @override
  State<NextOfKinStep> createState() => _NextOfKinStepState();
}

class _NextOfKinStepState extends State<NextOfKinStep> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late Relationship? _relationship;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData.fullName);
    _relationship = widget.initialData.relationship;
    _phoneController = TextEditingController(
      text: widget.initialData.phoneNumber,
    );
    _addressController = TextEditingController(
      text: widget.initialData.address,
    );
    _emailController = TextEditingController(text: widget.initialData.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final kin = NextOfKin(
        fullName: _nameController.text.trim(),
        relationship: _relationship,
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
      );
      widget.onSave(kin);
    }
  }

  String _getRelationshipLabel(Relationship r) {
    switch (r) {
      case Relationship.spouse:
        return 'Spouse';
      case Relationship.parent:
        return 'Parent';
      case Relationship.sibling:
        return 'Sibling';
      case Relationship.child:
        return 'Child';
      case Relationship.relative:
        return 'Relative';
      case Relationship.friend:
        return 'Friend';
      case Relationship.other:
        return 'Other';
    }
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
                  'Next of Kin Details',
                  'Someone we can contact in case of emergency',
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // Full Name
              DelayedDisplay(
                delay: const Duration(milliseconds: 150),
                child: _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter their full name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter next of kin name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Relationship
              DelayedDisplay(
                delay: const Duration(milliseconds: 200),
                child: _buildRelationshipDropdown(),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Phone Number
              DelayedDisplay(
                delay: const Duration(milliseconds: 250),
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '08012345678',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter phone number';
                    }
                    if (value!.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Address
              DelayedDisplay(
                delay: const Duration(milliseconds: 300),
                child: _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter their address',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Email (Optional)
              DelayedDisplay(
                delay: const Duration(milliseconds: 350),
                child: _buildTextField(
                  controller: _emailController,
                  label: 'Email (Optional)',
                  hint: 'Enter their email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
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
                                'Continue',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AdminDesignSystem.labelMedium),
        const SizedBox(height: AdminDesignSystem.spacing8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AdminDesignSystem.bodyMedium.copyWith(
            color: AdminDesignSystem.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textTertiary,
            ),
            prefixIcon: Icon(icon, size: 20, color: AdminDesignSystem.textTertiary),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: const BorderSide(
                color: AdminDesignSystem.statusError,
                width: 1,
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

  Widget _buildRelationshipDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Relationship', style: AdminDesignSystem.labelMedium),
        const SizedBox(height: AdminDesignSystem.spacing8),
        DropdownButtonFormField<Relationship>(
          value: _relationship,
          hint: Text(
            'Select relationship',
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textTertiary,
            ),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a relationship';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.people_outline,
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
          items: Relationship.values.map((r) {
            return DropdownMenuItem(
              value: r,
              child: Text(_getRelationshipLabel(r)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _relationship = value),
        ),
      ],
    );
  }
}
