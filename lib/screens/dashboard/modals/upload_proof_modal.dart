// // lib/screens/dashboard/modals/upload_proof_modal.dart
// // FIXED: Navigates to full-screen success screen on completion

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:delayed_display/delayed_display.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/admin_design_system.dart';
// import '../../../components/base/app_button.dart';
// import '../../../models/user_model.dart';
// import 'deposit/deposit_success_screen.dart';

// import '../../admin/sections/user_savings_deposits_service.dart';

// class UploadProofModal extends StatefulWidget {
//   final String transactionId; // Can be empty for general account funding
//   final String? goalId;
//   final double initialAmount; // Initial amount (can be 0)
//   final String? goalTitle;
//   final UserModel user; // Pass user for success screen
//   final VoidCallback onSuccess;
//   final VoidCallback onCancel;

//   const UploadProofModal({
//     super.key,
//     required this.transactionId,
//     this.goalId,
//     this.initialAmount = 0,
//     this.goalTitle,
//     required this.user,
//     required this.onSuccess,
//     required this.onCancel,
//   });

//   @override
//   State<UploadProofModal> createState() => _UploadProofModalState();
// }

// class _UploadProofModalState extends State<UploadProofModal> {
//   late final UserSavingsDepositsService _depositService;
//   File? _selectedFile;
//   String? _fileName;
//   bool _isUploading = false;
//   String? _errorMessage;

//   late final TextEditingController _amountController;

//   String get _userId => FirebaseAuth.instance.currentUser!.uid;

//   @override
//   void initState() {
//     super.initState();
//     _depositService = UserSavingsDepositsService();

//     final initialText = widget.initialAmount > 0
//         ? _formatAmountWithCommas(widget.initialAmount.toStringAsFixed(0))
//         : '';

//     _amountController = TextEditingController(text: initialText);
//     _amountController.addListener(_onAmountChanged);
//   }

//   String _formatAmountWithCommas(String value) {
//     if (value.isEmpty) return '';

//     final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
//     if (digitsOnly.isEmpty) return '';

//     final reversed = digitsOnly.split('').reversed.toList();
//     final buffer = StringBuffer();

//     for (int i = 0; i < reversed.length; i++) {
//       if (i > 0 && i % 3 == 0) {
//         buffer.write(',');
//       }
//       buffer.write(reversed[i]);
//     }

//     return buffer.toString().split('').reversed.join('');
//   }

//   void _onAmountChanged() {
//     final text = _amountController.text;
//     final cursorPosition = _amountController.selection.baseOffset;

//     final formatted = _formatAmountWithCommas(text);

//     if (formatted != text) {
//       final oldLength = text.length;
//       final newLength = formatted.length;
//       final difference = newLength - oldLength;

//       _amountController.value = TextEditingValue(
//         text: formatted,
//         selection: TextSelection.collapsed(
//           offset: (cursorPosition + difference).clamp(0, formatted.length),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }

//   double get _enteredAmount =>
//       double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
//   bool get _isAmountValid => _enteredAmount > 0;

//   Future<void> _pickFile() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
//         withData: false,
//         withReadStream: false,
//       );

//       if (result != null && result.files.single.path != null) {
//         final file = File(result.files.single.path!);

//         setState(() {
//           _selectedFile = file;
//           _fileName = result.files.single.name;
//           _errorMessage = null;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to pick file. Please try again.';
//       });
//     }
//   }

//   Future<void> _uploadProof() async {
//     if (!_isAmountValid) {
//       setState(() => _errorMessage = 'Please enter a valid amount');
//       return;
//     }

//     if (_selectedFile == null) {
//       setState(() => _errorMessage = 'Please select a file first');
//       return;
//     }

//     setState(() {
//       _isUploading = true;
//       _errorMessage = null;
//     });

//     try {
//       String transactionId = widget.transactionId;

//       if (transactionId.isEmpty) {
//         transactionId =
//             await _depositService.createPendingDeposit(
//               userId: _userId,
//               amount: _enteredAmount,
//               description: 'Account Funding - ${widget.goalTitle ?? 'General'}',
//             ) ??
//             '';

//         if (transactionId.isEmpty) {
//           throw Exception('Failed to create transaction');
//         }
//       }

//       final result = await _depositService.uploadPaymentProof(
//         userId: _userId,
//         transactionId: transactionId,
//         file: _selectedFile!,
//         amount: _enteredAmount,
//       );

//       if (result.success) {
//         // ✅ Dismiss keyboard FIRST
//         FocusManager.instance.primaryFocus?.unfocus();

//         // ✅ Wait for keyboard to fully dismiss before navigating
//         await Future.delayed(const Duration(milliseconds: 150));

//         // ✅ Navigate to success screen with replacement
//         if (mounted) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => DepositSuccessScreen(
//                 user: widget.user,
//                 depositAmount: _enteredAmount,
//                 goalTitle: widget.goalTitle,
//                 onDone: () {
//                   // Pop the success screen and return to dashboard
//                   Navigator.of(context).pop();
//                   widget.onSuccess();
//                 },
//               ),
//             ),
//           );
//         }
//       } else {
//         throw Exception(result.errorMessage ?? 'Upload failed');
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString().replaceFirst('Exception: ', '');
//         _isUploading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusManager.instance.primaryFocus?.unfocus();
//     });
//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       behavior: HitTestBehavior.translucent,
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

//               DelayedDisplay(
//                 delay: const Duration(milliseconds: 100),
//                 child: Text(
//                   'Upload Proof of Payment',
//                   style: AppTextTheme.heading3.copyWith(
//                     color: AppColors.deepNavy,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.sm),

//               DelayedDisplay(
//                 delay: const Duration(milliseconds: 150),
//                 child: Text(
//                   'Upload your bank deposit slip or transfer receipt',
//                   style: AppTextTheme.bodySmall.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.lg),

//               DelayedDisplay(
//                 delay: const Duration(milliseconds: 200),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Deposit Amount',
//                       style: AdminDesignSystem.labelMedium,
//                     ),
//                     const SizedBox(height: AdminDesignSystem.spacing8),
//                     TextField(
//                       controller: _amountController,
//                       enabled: !_isUploading,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       style: AdminDesignSystem.bodyMedium.copyWith(
//                         color: AdminDesignSystem.textPrimary,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                       ),
//                       decoration: InputDecoration(
//                         hintText: 'Enter amount',
//                         prefixText: '₦ ',
//                         hintStyle: AdminDesignSystem.bodyMedium.copyWith(
//                           color: AdminDesignSystem.textTertiary,
//                         ),
//                         filled: true,
//                         fillColor: AdminDesignSystem.background,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             AdminDesignSystem.radius12,
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             AdminDesignSystem.radius12,
//                           ),
//                           borderSide: BorderSide(
//                             color: AdminDesignSystem.accentTeal,
//                             width: 2,
//                           ),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             AdminDesignSystem.radius12,
//                           ),
//                           borderSide: BorderSide(
//                             color: AdminDesignSystem.statusError,
//                             width: 2,
//                           ),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: AdminDesignSystem.spacing16,
//                           vertical: AdminDesignSystem.spacing12,
//                         ),
//                       ),
//                       onChanged: (_) => setState(() => _errorMessage = null),
//                     ),
//                     const SizedBox(height: AdminDesignSystem.spacing12),
//                     Text(
//                       widget.goalTitle ?? 'General Savings',
//                       style: AdminDesignSystem.labelSmall.copyWith(
//                         color: AdminDesignSystem.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.lg),

//               DelayedDisplay(
//                 delay: const Duration(milliseconds: 250),
//                 child: GestureDetector(
//                   onTap: _isUploading ? null : _pickFile,
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(AppSpacing.lg),
//                     decoration: BoxDecoration(
//                       color: _selectedFile != null
//                           ? AppColors.tealSuccess.withAlpha(25)
//                           : AppColors.backgroundNeutral,
//                       border: Border.all(
//                         color: _selectedFile != null
//                             ? AppColors.tealSuccess
//                             : AppColors.borderLight,
//                         width: 2,
//                         style: BorderStyle.solid,
//                       ),
//                       borderRadius: BorderRadius.circular(
//                         AppBorderRadius.medium,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Icon(
//                           _selectedFile != null
//                               ? Icons.check_circle
//                               : Icons.upload_file,
//                           size: 48,
//                           color: _selectedFile != null
//                               ? AppColors.tealSuccess
//                               : AppColors.textSecondary,
//                         ),
//                         const SizedBox(height: AppSpacing.md),
//                         Text(
//                           _selectedFile != null
//                               ? _fileName!
//                               : 'Tap to select file',
//                           style: AppTextTheme.bodyRegular.copyWith(
//                             color: _selectedFile != null
//                                 ? AppColors.tealSuccess
//                                 : AppColors.textSecondary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: AppSpacing.xs),
//                         Text(
//                           'PDF, JPG, or PNG (Max 5MB)',
//                           style: AppTextTheme.bodySmall.copyWith(
//                             color: AppColors.textTertiary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               if (_errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: AppSpacing.md),
//                   child: Container(
//                     padding: const EdgeInsets.all(AppSpacing.md),
//                     decoration: BoxDecoration(
//                       color: AppColors.warmRed.withAlpha(25),
//                       borderRadius: BorderRadius.circular(
//                         AppBorderRadius.small,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.error_outline,
//                           color: AppColors.warmRed,
//                           size: 20,
//                         ),
//                         const SizedBox(width: AppSpacing.sm),
//                         Expanded(
//                           child: Text(
//                             _errorMessage!,
//                             style: AppTextTheme.bodySmall.copyWith(
//                               color: AppColors.warmRed,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//               const SizedBox(height: AppSpacing.lg),

//               DelayedDisplay(
//                 delay: const Duration(milliseconds: 300),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: SecondaryButton(
//                         label: 'Cancel',
//                         onPressed: _isUploading ? null : widget.onCancel,
//                       ),
//                     ),
//                     const SizedBox(width: AppSpacing.md),
//                     Expanded(
//                       child: PrimaryButton(
//                         label: _isUploading ? 'Uploading...' : 'Upload',
//                         onPressed: _isUploading || !_isAmountValid
//                             ? null
//                             : _uploadProof,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/dashboard/modals/upload_proof_modal.dart
// FIXED: Navigates to full-screen success screen on completion

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../components/base/app_button.dart';
import '../../../models/user_model.dart';
import 'deposit/deposit_success_screen.dart';

import '../../admin/sections/user_savings_deposits_service.dart';

class UploadProofModal extends StatefulWidget {
  final String transactionId;
  final String? goalId;
  final double initialAmount;
  final String? goalTitle;
  final UserModel user;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const UploadProofModal({
    super.key,
    required this.transactionId,
    this.goalId,
    this.initialAmount = 0,
    this.goalTitle,
    required this.user,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<UploadProofModal> createState() => _UploadProofModalState();
}

class _UploadProofModalState extends State<UploadProofModal> {
  late final UserSavingsDepositsService _depositService;
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  String? _errorMessage;

  late final TextEditingController _amountController;

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _depositService = UserSavingsDepositsService();

    final initialText = widget.initialAmount > 0
        ? _formatAmountWithCommas(widget.initialAmount.toStringAsFixed(0))
        : '';

    _amountController = TextEditingController(text: initialText);
    _amountController.addListener(_onAmountChanged);
  }

  String _formatAmountWithCommas(String value) {
    if (value.isEmpty) return '';

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return '';

    final reversed = digitsOnly.split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(reversed[i]);
    }

    return buffer.toString().split('').reversed.join('');
  }

  void _onAmountChanged() {
    final text = _amountController.text;
    final cursorPosition = _amountController.selection.baseOffset;

    final formatted = _formatAmountWithCommas(text);

    if (formatted != text) {
      final oldLength = text.length;
      final newLength = formatted.length;
      final difference = newLength - oldLength;

      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: (cursorPosition + difference).clamp(0, formatted.length),
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _enteredAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
  bool get _isAmountValid => _enteredAmount > 0;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        setState(() {
          _selectedFile = file;
          _fileName = result.files.single.name;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick file. Please try again.';
      });
    }
  }

  Future<void> _uploadProof() async {
    if (!_isAmountValid) {
      setState(() => _errorMessage = 'Please enter a valid amount');
      return;
    }

    if (_selectedFile == null) {
      setState(() => _errorMessage = 'Please select a file first');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      String transactionId = widget.transactionId;

      if (transactionId.isEmpty) {
        transactionId =
            await _depositService.createPendingDeposit(
              userId: _userId,
              amount: _enteredAmount,
              description: 'Account Funding - ${widget.goalTitle ?? 'General'}',
            ) ??
            '';

        if (transactionId.isEmpty) {
          throw Exception('Failed to create transaction');
        }
      }

      final result = await _depositService.uploadPaymentProof(
        userId: _userId,
        transactionId: transactionId,
        file: _selectedFile!,
        amount: _enteredAmount,
      );

      if (result.success) {
        if (!mounted) return;

        // 1. Release keyboard focus
        FocusScope.of(context).unfocus();

        // 2. Close bottom sheet
        Navigator.of(context).pop();

        // 3. Allow keyboard + sheet animation to complete
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;

        // 4. Navigate from root
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => DepositSuccessScreen(
              user: widget.user,
              depositAmount: _enteredAmount,
              goalTitle: widget.goalTitle,
              onDone: () {
                Navigator.of(context, rootNavigator: true).pop();
                widget.onSuccess();
              },
            ),
          ),
        );
      } else {
        throw Exception(result.errorMessage ?? 'Upload failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isUploading = false;
      });
    }
  }

  Future<void> _simulateFileSelection() async {
    final tempDir = Directory.systemTemp;
    final fakeFile = File('${tempDir.path}/fake_receipt.png');

    await fakeFile.writeAsBytes(List.generate(100, (i) => i));

    setState(() {
      _selectedFile = fakeFile;
      _fileName = 'fake_receipt.png';
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
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

              DelayedDisplay(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Upload Proof of Payment',
                  style: AppTextTheme.heading3.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              DelayedDisplay(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  'Upload your bank deposit slip or transfer receipt',
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              DelayedDisplay(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deposit Amount',
                      style: AdminDesignSystem.labelMedium,
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing8),
                    TextField(
                      controller: _amountController,
                      enabled: !_isUploading,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        color: AdminDesignSystem.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        prefixText: '₦ ',
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AdminDesignSystem.radius12,
                          ),
                          borderSide: BorderSide(
                            color: AdminDesignSystem.accentTeal,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AdminDesignSystem.radius12,
                          ),
                          borderSide: BorderSide(
                            color: AdminDesignSystem.statusError,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AdminDesignSystem.spacing16,
                          vertical: AdminDesignSystem.spacing12,
                        ),
                      ),
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing12),
                    Text(
                      widget.goalTitle ?? 'General Savings',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              DelayedDisplay(
                delay: const Duration(milliseconds: 250),
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: _selectedFile != null
                          ? AppColors.tealSuccess.withAlpha(25)
                          : AppColors.backgroundNeutral,
                      border: Border.all(
                        color: _selectedFile != null
                            ? AppColors.tealSuccess
                            : AppColors.borderLight,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.medium,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _selectedFile != null
                              ? Icons.check_circle
                              : Icons.upload_file,
                          size: 48,
                          color: _selectedFile != null
                              ? AppColors.tealSuccess
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _selectedFile != null
                              ? _fileName!
                              : 'Tap to select file',
                          style: AppTextTheme.bodyRegular.copyWith(
                            color: _selectedFile != null
                                ? AppColors.tealSuccess
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'PDF, JPG, or PNG (Max 5MB)',
                          style: AppTextTheme.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.warmRed.withAlpha(25),
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.small,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.warmRed,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextTheme.bodySmall.copyWith(
                              color: AppColors.warmRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),

              DelayedDisplay(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        onPressed: _isUploading ? null : widget.onCancel,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        label: _isUploading ? 'Uploading...' : 'Upload',
                        onPressed: _isUploading || !_isAmountValid
                            ? null
                            : _uploadProof,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
