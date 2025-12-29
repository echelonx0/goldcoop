// // lib/screens/dashboard/tabs/savings/set_savings_target_form.dart

// import 'package:flutter/material.dart';
// import '../../../../components/base/app_button.dart';
// import '../../../../core/theme/app_colors.dart';

// class SetSavingsTargetForm extends StatefulWidget {
//   final Function(double) onSetTarget;
//   final VoidCallback onCancel;

//   const SetSavingsTargetForm({
//     super.key,
//     required this.onSetTarget,
//     required this.onCancel,
//   });

//   @override
//   State<SetSavingsTargetForm> createState() => _SetSavingsTargetFormState();
// }

// class _SetSavingsTargetFormState extends State<SetSavingsTargetForm> {
//   late final TextEditingController _amountController;
//   String? _amountError;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _amountController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }

//   bool _validateAmount() {
//     setState(() => _amountError = null);

//     final amountStr = _amountController.text.trim();
//     final amount = double.tryParse(amountStr);

//     if (amountStr.isEmpty) {
//       setState(() => _amountError = 'Amount required');
//       return false;
//     }
//     if (amount == null) {
//       setState(() => _amountError = 'Invalid amount');
//       return false;
//     }
//     if (amount <= 0) {
//       setState(() => _amountError = 'Must be greater than 0');
//       return false;
//     }
//     if (amount > 999999999) {
//       setState(() => _amountError = 'Amount too large');
//       return false;
//     }

//     return true;
//   }

//   void _handleSetTarget() {
//     if (!_validateAmount()) return;

//     setState(() => _isLoading = true);
//     widget.onSetTarget(double.parse(_amountController.text.trim()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundWhite,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(AppBorderRadius.large),
//             topRight: Radius.circular(AppBorderRadius.large),
//           ),
//         ),
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
//           top: AppSpacing.lg,
//           left: AppSpacing.lg,
//           right: AppSpacing.lg,
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Drag handle
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: AppColors.borderLight,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.lg),

//               // Title
//               Text(
//                 'Set Savings Target',
//                 style: AppTextTheme.heading3.copyWith(
//                   color: AppColors.deepNavy,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               Text(
//                 'How much do you want to save?',
//                 style: AppTextTheme.bodySmall.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.lg),

//               // Amount input
//               TextField(
//                 controller: _amountController,
//                 keyboardType: const TextInputType.numberWithOptions(
//                   decimal: true,
//                 ),
//                 enabled: !_isLoading,
//                 decoration: InputDecoration(
//                   labelText: 'Target amount',
//                   hintText: 'Enter amount',
//                   prefixText: '₦ ',
//                   errorText: _amountError,
//                   hintStyle: AppTextTheme.bodySmall.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//                     borderSide: BorderSide(color: AppColors.borderLight),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//                     borderSide: BorderSide(
//                       color:
//                           _amountError != null
//                               ? AppColors.warmRed
//                               : AppColors.borderLight,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//                     borderSide: BorderSide(
//                       color: AppColors.primaryOrange,
//                       width: 2,
//                     ),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: AppSpacing.md,
//                     vertical: AppSpacing.md,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.lg),

//               // Action buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: SecondaryButton(
//                       label: 'Cancel',
//                       onPressed: _isLoading ? null : widget.onCancel,
//                     ),
//                   ),
//                   const SizedBox(width: AppSpacing.md),
//                   Expanded(
//                     child: PrimaryButton(
//                       label: _isLoading ? 'Setting...' : 'Set Target',
//                       onPressed: _isLoading ? null : _handleSetTarget,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSpacing.sm),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/dashboard/tabs/savings/set_savings_target_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_design_system.dart';

class SetSavingsTargetForm extends StatefulWidget {
  final Function(double amount, DateTime targetDate) onSetTarget;
  final VoidCallback onCancel;
  final double? currentTarget;
  final DateTime? currentTargetDate;

  const SetSavingsTargetForm({
    super.key,
    required this.onSetTarget,
    required this.onCancel,
    this.currentTarget,
    this.currentTargetDate,
  });

  @override
  State<SetSavingsTargetForm> createState() => _SetSavingsTargetFormState();
}

class _SetSavingsTargetFormState extends State<SetSavingsTargetForm> {
  late final TextEditingController _amountController;
  late DateTime _selectedDate;
  String? _amountError;
  String? _dateError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.currentTarget != null ? widget.currentTarget.toString() : '',
    );
    _selectedDate =
        widget.currentTargetDate ?? DateTime.now().add(Duration(days: 30));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _amountError = null;
      _dateError = null;
    });

    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr);

    // Validate amount
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

    // Validate date
    if (_selectedDate.isBefore(DateTime.now())) {
      setState(() => _dateError = 'Target date must be in the future');
      return false;
    }

    return true;
  }

  void _handleSetTarget() {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    widget.onSetTarget(
      double.parse(_amountController.text.trim()),
      _selectedDate,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AdminDesignSystem.accentTeal,
              surface: AdminDesignSystem.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final daysFromNow = _selectedDate.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: AdminDesignSystem.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AdminDesignSystem.radius16),
            topRight: Radius.circular(AdminDesignSystem.radius16),
          ),
        ),
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              AdminDesignSystem.spacing20,
          top: AdminDesignSystem.spacing16,
          left: AdminDesignSystem.spacing16,
          right: AdminDesignSystem.spacing16,
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
                    color: AdminDesignSystem.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Title
              Text(
                'Savings Target',
                style: AdminDesignSystem.headingMedium.copyWith(
                  color: AdminDesignSystem.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing4),
              Text(
                'Set your savings goal and target date',
                style: AdminDesignSystem.bodySmall.copyWith(
                  color: AdminDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing20),

              // Amount input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target Amount', style: AdminDesignSystem.labelMedium),
                  const SizedBox(height: AdminDesignSystem.spacing8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    enabled: !_isLoading,
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      color: AdminDesignSystem.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixText: '₦ ',
                      errorText: _amountError,
                      hintStyle: AdminDesignSystem.bodyMedium.copyWith(
                        color: AdminDesignSystem.textTertiary,
                      ),
                      filled: true,
                      fillColor: AdminDesignSystem.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                        borderSide: BorderSide(
                          color: _amountError != null
                              ? AdminDesignSystem.statusError
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                        borderSide: BorderSide(
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
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Date picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target Date', style: AdminDesignSystem.labelMedium),
                  const SizedBox(height: AdminDesignSystem.spacing8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _pickDate,
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius12,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AdminDesignSystem.background,
                          borderRadius: BorderRadius.circular(
                            AdminDesignSystem.radius12,
                          ),
                          border: Border.all(
                            color: _dateError != null
                                ? AdminDesignSystem.statusError
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AdminDesignSystem.spacing16,
                          vertical: AdminDesignSystem.spacing12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFormatter.format(_selectedDate),
                                  style: AdminDesignSystem.bodyMedium.copyWith(
                                    color: AdminDesignSystem.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: AdminDesignSystem.spacing4,
                                ),
                                Text(
                                  daysFromNow == 1
                                      ? 'In 1 day'
                                      : daysFromNow <= 7
                                      ? 'In $daysFromNow days'
                                      : daysFromNow <= 30
                                      ? 'In ${(daysFromNow / 7).floor()} weeks'
                                      : 'In ${(daysFromNow / 30).floor()} months',
                                  style: AdminDesignSystem.labelSmall.copyWith(
                                    color: AdminDesignSystem.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.calendar_today_outlined,
                              color: AdminDesignSystem.accentTeal,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_dateError != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AdminDesignSystem.spacing8,
                      ),
                      child: Text(
                        _dateError!,
                        style: AdminDesignSystem.labelSmall.copyWith(
                          color: AdminDesignSystem.statusError,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AdminDesignSystem.spacing16,
                        ),
                        side: BorderSide(color: AdminDesignSystem.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AdminDesignSystem.radius12,
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AdminDesignSystem.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AdminDesignSystem.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSetTarget,
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
                      child: Text(
                        _isLoading ? 'Setting...' : 'Set Target',
                        style: AdminDesignSystem.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
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
    );
  }
}
