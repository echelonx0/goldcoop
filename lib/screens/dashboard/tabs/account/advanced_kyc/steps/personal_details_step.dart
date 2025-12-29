// lib/screens/dashboard/tabs/account/advanced_kyc/steps/personal_details_step.dart
// Personal Details form step

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';

import '../../../../../../core/theme/admin_design_system.dart';
import '../../../../../../models/advanced_kyc_model.dart';

class PersonalDetailsStep extends StatefulWidget {
  final PersonalDetails initialData;
  final Function(PersonalDetails) onSave;
  final bool isSaving;

  const PersonalDetailsStep({
    super.key,
    required this.initialData,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  State<PersonalDetailsStep> createState() => _PersonalDetailsStepState();
}

class _PersonalDetailsStepState extends State<PersonalDetailsStep> {
  final _formKey = GlobalKey<FormState>();

  late Gender? _gender;
  late TextEditingController _occupationController;
  late TextEditingController _dobController;
  late TextEditingController _homeTownController;
  late TextEditingController _lgaController;
  late String? _selectedState;
  late TextEditingController _whatsappController;

  @override
  void initState() {
    super.initState();
    _gender = widget.initialData.gender;
    _occupationController = TextEditingController(
      text: widget.initialData.occupation,
    );
    _dobController = TextEditingController(
      text: widget.initialData.dateOfBirth,
    );
    _homeTownController = TextEditingController(
      text: widget.initialData.homeTown,
    );
    _lgaController = TextEditingController(text: widget.initialData.lga);
    _selectedState = widget.initialData.state.isNotEmpty
        ? widget.initialData.state
        : null;
    _whatsappController = TextEditingController(
      text: widget.initialData.whatsappNumber,
    );
  }

  @override
  void dispose() {
    _occupationController.dispose();
    _dobController.dispose();
    _homeTownController.dispose();
    _lgaController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 18),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AdminDesignSystem.accentTeal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final details = PersonalDetails(
        gender: _gender,
        occupation: _occupationController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        homeTown: _homeTownController.text.trim(),
        lga: _lgaController.text.trim(),
        state: _selectedState ?? '',
        whatsappNumber: _whatsappController.text.trim(),
      );
      widget.onSave(details);
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
                  'Tell us about yourself',
                  'This helps us personalize your experience',
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // Gender
              DelayedDisplay(
                delay: const Duration(milliseconds: 150),
                child: _buildGenderSelector(),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Occupation
              DelayedDisplay(
                delay: const Duration(milliseconds: 200),
                child: _buildTextField(
                  controller: _occupationController,
                  label: 'Occupation',
                  hint: 'e.g., Trader, Teacher, Engineer',
                  icon: Icons.work_outline,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your occupation';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Date of Birth
              DelayedDisplay(
                delay: const Duration(milliseconds: 250),
                child: _buildDateField(),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // WhatsApp Number
              DelayedDisplay(
                delay: const Duration(milliseconds: 300),
                child: _buildTextField(
                  controller: _whatsappController,
                  label: 'WhatsApp Number',
                  hint: '08012345678',
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Home Town
              DelayedDisplay(
                delay: const Duration(milliseconds: 350),
                child: _buildTextField(
                  controller: _homeTownController,
                  label: 'Home Town',
                  hint: 'e.g., Onitsha, Aba, Nnewi',
                  icon: Icons.location_city,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // LGA
              DelayedDisplay(
                delay: const Duration(milliseconds: 400),
                child: _buildTextField(
                  controller: _lgaController,
                  label: 'Local Government Area (L.G.A)',
                  hint: 'e.g., Onitsha North',
                  icon: Icons.map_outlined,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // State
              DelayedDisplay(
                delay: const Duration(milliseconds: 450),
                child: _buildStateDropdown(),
              ),
              const SizedBox(height: AdminDesignSystem.spacing32),

              // Continue Button
              DelayedDisplay(
                delay: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
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

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AdminDesignSystem.labelMedium),
        const SizedBox(height: AdminDesignSystem.spacing8),
        Row(
          children: Gender.values.where((g) => g != Gender.other).map((gender) {
            final isSelected = _gender == gender;
            final label = gender == Gender.preferNotToSay
                ? 'Prefer not to say'
                : gender.name[0].toUpperCase() + gender.name.substring(1);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: gender != Gender.preferNotToSay
                      ? AdminDesignSystem.spacing8
                      : 0,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _gender = gender),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AdminDesignSystem.spacing12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AdminDesignSystem.accentTeal.withAlpha(38)
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
                    child: Center(
                      child: Text(
                        label,
                        style: AdminDesignSystem.labelSmall.copyWith(
                          color: isSelected
                              ? AdminDesignSystem.accentTeal
                              : AdminDesignSystem.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth', style: AdminDesignSystem.labelMedium),
        const SizedBox(height: AdminDesignSystem.spacing8),
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
            child: TextFormField(
              controller: _dobController,
              style: AdminDesignSystem.bodyMedium.copyWith(
                color: AdminDesignSystem.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'DD/MM/YYYY',
                hintStyle: AdminDesignSystem.bodyMedium.copyWith(
                  color: AdminDesignSystem.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AdminDesignSystem.textTertiary,
                ),
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('State', style: AdminDesignSystem.labelMedium),
        const SizedBox(height: AdminDesignSystem.spacing8),
        DropdownButtonFormField<String>(
          value: _selectedState,
          hint: Text(
            'Select your state',
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textTertiary,
            ),
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.location_on_outlined,
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
          items: NigerianStates.states.map((state) {
            return DropdownMenuItem(value: state, child: Text(state));
          }).toList(),
          onChanged: (value) => setState(() => _selectedState = value),
        ),
      ],
    );
  }
}
