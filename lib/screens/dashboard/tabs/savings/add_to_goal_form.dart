// // lib/screens/dashboard/tabs/savings/add_to_goal_form.dart

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../../../../components/base/app_button.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../models/goals_model.dart';
// import '../../../../services/deposit_service.dart';
// import '../../modals/deposit_instructions_modal.dart';
// import '../../modals/upload_proof_modal.dart';

// class AddToGoalForm extends StatefulWidget {
//   final GoalModel goal;
//   final Function(double) onContribute;
//   final VoidCallback onCancel;

//   const AddToGoalForm({
//     super.key,

//     required this.goal,
//     required this.onContribute,
//     required this.onCancel,
//   });

//   @override
//   State<AddToGoalForm> createState() => _AddToGoalFormState();
// }

// class _AddToGoalFormState extends State<AddToGoalForm> {
//   late final TextEditingController _amountController;
//   late final DepositService _depositService;
//   String? _amountError;
//   bool _isLoading = false;
//   // Get current user ID from Firebase Auth
//   String get _userId => FirebaseAuth.instance.currentUser!.uid;
//   @override
//   void initState() {
//     super.initState();
//     _amountController = TextEditingController();
//     _depositService = DepositService();
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
//     if (amount > widget.goal.remainingAmount) {
//       setState(
//         () => _amountError =
//             'Amount exceeds remaining (₦${widget.goal.remainingAmount.toStringAsFixed(0)})',
//       );
//       return false;
//     }

//     return true;
//   }

//   Future<void> _handleContribute() async {
//     if (!_validateAmount()) return;

//     final amount = double.parse(_amountController.text.trim());

//     setState(() => _isLoading = true);

//     try {
//       // 1. Create pending deposit transaction
//       final transactionId = await _depositService.createPendingDeposit(
//         userId: _userId,
//         amount: amount,
//         description: 'Deposit for ${widget.goal.title}',
//         goalId: widget.goal.goalId,
//         goalTitle: widget.goal.title,
//       );

//       if (transactionId == null) {
//         _showError('Failed to create deposit. Please try again.');
//         setState(() => _isLoading = false);
//         return;
//       }

//       // 2. Show deposit instructions modal
//       if (mounted) {
//         await showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           backgroundColor: Colors.transparent,
//           builder: (context) => DepositInstructionsModal(
//             userId: _userId,
//             onClose: () => Navigator.pop(context),
//           ),
//         );
//       }

//       // 3. Show upload proof modal
//       if (mounted) {
//         await showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           backgroundColor: Colors.transparent,
//           isDismissible: false,
//           enableDrag: false,
//           builder: (context) => UploadProofModal(
//             transactionId: transactionId,
//             goalId: widget.goal.goalId,

//             // amount: amount, TODO: Have upload goal proof modal
//             goalTitle: widget.goal.title,
//             onSuccess: () {
//               // Close upload modal
//               Navigator.pop(context);
//               // Close add to goal form
//               Navigator.pop(context);
//               // Show success message
//               _showSuccessMessage();
//             },
//             onCancel: () {
//               Navigator.pop(context);
//               setState(() => _isLoading = false);
//             }, user: ,
//           ),
//         );
//       }
//     } catch (e) {
//       _showError('An error occurred: ${e.toString()}');
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showSuccessMessage() {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: AppSpacing.sm),
//             Expanded(
//               child: Text(
//                 'Proof uploaded! Your deposit will be verified shortly.',
//                 style: AppTextTheme.bodySmall.copyWith(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppColors.tealSuccess,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 4),
//       ),
//     );

//     // Call the original onContribute callback (for UI updates if needed)
//     // Note: Don't actually update the goal yet - wait for admin verification
//     // widget.onContribute(amount);
//   }

//   void _showError(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: AppSpacing.sm),
//             Expanded(
//               child: Text(
//                 message,
//                 style: AppTextTheme.bodySmall.copyWith(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppColors.warmRed,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//       ),
//     );
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

//               // Header
//               Text(
//                 'Add to ${widget.goal.title}',
//                 style: AppTextTheme.heading3.copyWith(
//                   color: AppColors.deepNavy,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               Text(
//                 'Enter amount to deposit into this goal',
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
//                   labelText: 'Amount',
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
//                       color: _amountError != null
//                           ? AppColors.warmRed
//                           : AppColors.borderLight,
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

//               // Goal progress card
//               _buildGoalProgressInfo(),
//               const SizedBox(height: AppSpacing.md),

//               // Info banner
//               _buildInfoBanner(),
//               const SizedBox(height: AppSpacing.lg),

//               // Quick access to deposit instructions
//               _buildViewInstructionsButton(),
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
//                       label: _isLoading ? 'Processing...' : 'Continue',
//                       onPressed: _isLoading ? null : _handleContribute,
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

//   Widget _buildGoalProgressInfo() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.backgroundNeutral,
//         borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//       ),
//       padding: const EdgeInsets.all(AppSpacing.md),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Goal Progress',
//             style: AppTextTheme.bodySmall.copyWith(
//               color: AppColors.textSecondary,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: AppSpacing.sm),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '₦${widget.goal.currentAmount.toStringAsFixed(0)} / ₦${widget.goal.targetAmount.toStringAsFixed(0)}',
//                 style: AppTextTheme.bodySmall.copyWith(
//                   color: AppColors.deepNavy,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 '${widget.goal.progressPercentage.toStringAsFixed(0)}%',
//                 style: AppTextTheme.bodySmall.copyWith(
//                   color: AppColors.primaryOrange,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppSpacing.sm),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(AppBorderRadius.small),
//             child: LinearProgressIndicator(
//               value: (widget.goal.progressPercentage / 100).clamp(0.0, 1.0),
//               minHeight: 6,
//               backgroundColor: AppColors.primaryOrange.withAlpha(20),
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 AppColors.primaryOrange,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoBanner() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.md),
//       decoration: BoxDecoration(
//         color: AppColors.navyLight,
//         borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//         border: Border.all(color: AppColors.deepNavy.withAlpha(50)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.info_outline, color: AppColors.deepNavy, size: 20),
//           const SizedBox(width: AppSpacing.sm),
//           Expanded(
//             child: Text(
//               'You\'ll need to upload proof of payment after making your deposit',
//               style: AppTextTheme.bodySmall.copyWith(color: AppColors.deepNavy),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildViewInstructionsButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: OutlinedButton.icon(
//         onPressed: _isLoading
//             ? null
//             : () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   backgroundColor: Colors.transparent,
//                   builder: (context) => DepositInstructionsModal(
//                     userId: _userId,
//                     onClose: () => Navigator.pop(context),
//                   ),
//                 );
//               },
//         icon: Icon(
//           Icons.account_balance,
//           size: 18,
//           color: _isLoading ? AppColors.textTertiary : AppColors.primaryOrange,
//         ),
//         label: Text(
//           'View Deposit Instructions',
//           style: AppTextTheme.bodySmall.copyWith(
//             color: _isLoading
//                 ? AppColors.textTertiary
//                 : AppColors.primaryOrange,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         style: OutlinedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(
//             vertical: AppSpacing.md,
//             horizontal: AppSpacing.md,
//           ),
//           side: BorderSide(
//             color: _isLoading ? AppColors.borderLight : AppColors.primaryOrange,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//           ),
//         ),
//       ),
//     );
//   }
// }
