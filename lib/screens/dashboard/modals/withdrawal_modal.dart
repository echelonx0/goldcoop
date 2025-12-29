// // lib/screens/dashboard/modals/withdrawal_modal.dart

// import 'package:flutter/material.dart';
// import 'package:delayed_display/delayed_display.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';
// import '../../../core/theme/admin_design_system.dart';
// import '../../../models/financial_wallet_models.dart';
// import '../../../models/user_model.dart';
// import '../../../models/transaction_model.dart';
// import '../../../services/wallet_service.dart';

// class WithdrawalModal extends StatefulWidget {
//   final UserModel user;
//   final VoidCallback onSuccess;

//   const WithdrawalModal({
//     super.key,
//     required this.user,
//     required this.onSuccess,
//   });

//   @override
//   State<WithdrawalModal> createState() => _WithdrawalModalState();
// }

// class _WithdrawalModalState extends State<WithdrawalModal> {
//   late WalletService _walletService;
//   final _currencyFormatter = NumberFormat.currency(
//     symbol: '₦',
//     decimalDigits: 0,
//   );

//   // Flow state
//   int _currentStep = 0; // 0: amount, 1: wallet select, 2: review, 3: success

//   // Form state
//   final _amountController = TextEditingController();
//   FinancialWallet? _selectedWallet;
//   List<FinancialWallet> _wallets = [];
//   bool _isLoading = true;
//   bool _isSubmitting = false;

//   // New wallet form
//   final _walletNameController = TextEditingController();
//   final _accountNumberController = TextEditingController();
//   final _bankNameController = TextEditingController();
//   final _accountHolderController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _walletService = WalletService();
//     _loadWallets();
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _walletNameController.dispose();
//     _accountNumberController.dispose();
//     _bankNameController.dispose();
//     _accountHolderController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadWallets() async {
//     try {
//       final wallets = await _walletService.getUserWallets(widget.user.uid);
//       setState(() {
//         _wallets = wallets;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to load wallets: $e')));
//       }
//     }
//   }

//   double get _availableBalance => widget.user.financialProfile.availableBalance;
//   double get _withdrawalAmount => double.tryParse(_amountController.text) ?? 0;
//   bool get _isAmountValid =>
//       _withdrawalAmount > 0 && _withdrawalAmount <= _availableBalance;

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.9,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(AdminDesignSystem.radius12),
//             ),
//           ),
//           child: SingleChildScrollView(
//             controller: scrollController,
//             child: Padding(
//               padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildHeader(),
//                   const SizedBox(height: AdminDesignSystem.spacing24),
//                   if (_currentStep == 0) _buildAmountStep(),
//                   if (_currentStep == 1) _buildWalletStep(),
//                   if (_currentStep == 2) _buildReviewStep(),
//                   if (_currentStep == 3) _buildSuccessStep(),
//                   const SizedBox(height: AdminDesignSystem.spacing20),
//                   _buildFooter(),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ==================== HEADER ====================
//   Widget _buildHeader() {
//     final titles = ['Amount', 'Wallet', 'Review', 'Success'];
//     return DelayedDisplay(
//       delay: const Duration(milliseconds: 100),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Withdraw Funds',
//                 style: AdminDesignSystem.headingMedium.copyWith(
//                   color: AdminDesignSystem.primaryNavy,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Icon(
//                   Icons.close,
//                   color: AdminDesignSystem.textSecondary,
//                   size: 24,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),
//           Text(
//             'Step ${_currentStep + 1} of 4: ${titles[_currentStep]}',
//             style: AdminDesignSystem.bodySmall.copyWith(
//               color: AdminDesignSystem.textSecondary,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//             child: LinearProgressIndicator(
//               value: (_currentStep + 1) / 4,
//               minHeight: 6,
//               backgroundColor: AdminDesignSystem.accentTeal.withAlpha(38),
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 AdminDesignSystem.accentTeal,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== AMOUNT STEP ====================
//   Widget _buildAmountStep() {
//     return DelayedDisplay(
//       delay: const Duration(milliseconds: 200),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'How much do you want to withdraw?',
//             style: AdminDesignSystem.bodyLarge.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: AdminDesignSystem.textTertiary),
//               borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//             ),
//             padding: const EdgeInsets.symmetric(
//               horizontal: AdminDesignSystem.spacing16,
//               vertical: AdminDesignSystem.spacing12,
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   '₦',
//                   style: AdminDesignSystem.displayLarge.copyWith(
//                     color: AdminDesignSystem.accentTeal,
//                   ),
//                 ),
//                 const SizedBox(width: AdminDesignSystem.spacing8),
//                 Expanded(
//                   child: TextField(
//                     controller: _amountController,
//                     keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: '0',
//                       border: InputBorder.none,
//                       hintStyle: AdminDesignSystem.displayLarge.copyWith(
//                         color: AdminDesignSystem.textTertiary,
//                       ),
//                     ),
//                     style: AdminDesignSystem.displayLarge,
//                     onChanged: (_) => setState(() {}),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Available Balance',
//                 style: AdminDesignSystem.bodySmall.copyWith(
//                   color: AdminDesignSystem.textSecondary,
//                 ),
//               ),
//               Text(
//                 _currencyFormatter.format(_availableBalance),
//                 style: AdminDesignSystem.bodyMedium.copyWith(
//                   fontWeight: FontWeight.w700,
//                   color: AdminDesignSystem.accentTeal,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing24),
//           if (_amountController.text.isNotEmpty && !_isAmountValid)
//             DelayedDisplay(
//               delay: const Duration(milliseconds: 300),
//               child: Container(
//                 padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
//                 decoration: BoxDecoration(
//                   color: AdminDesignSystem.statusError.withAlpha(25),
//                   borderRadius: BorderRadius.circular(
//                     AdminDesignSystem.radius8,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       color: AdminDesignSystem.statusError,
//                       size: 20,
//                     ),
//                     const SizedBox(width: AdminDesignSystem.spacing12),
//                     Expanded(
//                       child: Text(
//                         'Amount exceeds available balance',
//                         style: AdminDesignSystem.bodySmall.copyWith(
//                           color: AdminDesignSystem.statusError,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ==================== WALLET STEP ====================
//   Widget _buildWalletStep() {
//     return DelayedDisplay(
//       delay: const Duration(milliseconds: 200),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Select or add a withdrawal wallet',
//             style: AdminDesignSystem.bodyLarge.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),
//           if (_isLoading)
//             Center(
//               child: CircularProgressIndicator(
//                 color: AdminDesignSystem.accentTeal,
//               ),
//             )
//           else if (_wallets.isEmpty)
//             Text(
//               'No wallets yet. Add one below.',
//               style: AdminDesignSystem.bodySmall.copyWith(
//                 color: AdminDesignSystem.textSecondary,
//               ),
//             )
//           else
//             ..._wallets.map((wallet) {
//               return DelayedDisplay(
//                 delay: Duration(
//                   milliseconds: 250 + (_wallets.indexOf(wallet) * 100),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                     bottom: AdminDesignSystem.spacing12,
//                   ),
//                   child: _WalletSelectionTile(
//                     wallet: wallet,
//                     isSelected: _selectedWallet?.walletId == wallet.walletId,
//                     onSelected: () => setState(() => _selectedWallet = wallet),
//                   ),
//                 ),
//               );
//             }).toList(),
//           const SizedBox(height: AdminDesignSystem.spacing24),
//           _buildNewWalletForm(),
//         ],
//       ),
//     );
//   }

//   Widget _buildNewWalletForm() {
//     return DelayedDisplay(
//       delay: Duration(milliseconds: 300 + (_wallets.length * 100)),
//       child: Container(
//         padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//         decoration: BoxDecoration(
//           border: Border.all(color: AdminDesignSystem.accentTeal.withAlpha(51)),
//           borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//           color: AdminDesignSystem.accentTeal.withAlpha(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Add New Wallet',
//               style: AdminDesignSystem.labelMedium.copyWith(
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing16),
//             TextField(
//               controller: _walletNameController,
//               decoration: _inputDecoration('Wallet Name (e.g., My GTBank)'),
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing12),
//             TextField(
//               controller: _bankNameController,
//               decoration: _inputDecoration('Bank Name'),
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing12),
//             TextField(
//               controller: _accountNumberController,
//               decoration: _inputDecoration('Account Number'),
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing12),
//             TextField(
//               controller: _accountHolderController,
//               decoration: _inputDecoration('Account Holder Name'),
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _addNewWallet,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AdminDesignSystem.accentTeal,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: AdminDesignSystem.spacing12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(
//                       AdminDesignSystem.radius8,
//                     ),
//                   ),
//                 ),
//                 child: Text(
//                   'Add Wallet',
//                   style: AdminDesignSystem.labelMedium.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: AdminDesignSystem.bodySmall.copyWith(
//         color: AdminDesignSystem.textTertiary,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//         borderSide: const BorderSide(color: AdminDesignSystem.textTertiary),
//       ),
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: AdminDesignSystem.spacing12,
//         vertical: AdminDesignSystem.spacing12,
//       ),
//     );
//   }

//   // ==================== REVIEW STEP ====================
//   Widget _buildReviewStep() {
//     return DelayedDisplay(
//       delay: const Duration(milliseconds: 200),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Review Your Withdrawal',
//             style: AdminDesignSystem.bodyLarge.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 300),
//             child: _ReviewRow(
//               label: 'Amount',
//               value: _currencyFormatter.format(_withdrawalAmount),
//               valueColor: AdminDesignSystem.accentTeal,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 350),
//             child: _ReviewRow(
//               label: 'To Wallet',
//               value: _selectedWallet?.walletName ?? 'N/A',
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 400),
//             child: _ReviewRow(
//               label: 'Details',
//               value: _selectedWallet?.displayDetails ?? 'N/A',
//               valueSize: 12,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 450),
//             child: Container(
//               padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//               decoration: BoxDecoration(
//                 color: AdminDesignSystem.statusActive.withAlpha(12),
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//                 border: Border.all(
//                   color: AdminDesignSystem.statusActive.withAlpha(51),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: AdminDesignSystem.statusActive,
//                     size: 20,
//                   ),
//                   const SizedBox(width: AdminDesignSystem.spacing12),
//                   Expanded(
//                     child: Text(
//                       'Withdrawals may take up to 24 hours to reflect in your wallet.',
//                       style: AdminDesignSystem.bodySmall.copyWith(
//                         color: AdminDesignSystem.statusActive,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== SUCCESS STEP ====================
//   Widget _buildSuccessStep() {
//     return DelayedDisplay(
//       delay: const Duration(milliseconds: 200),
//       child: Column(
//         children: [
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 300),
//             child: Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: AdminDesignSystem.statusActive.withAlpha(25),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.check_circle,
//                 color: AdminDesignSystem.statusActive,
//                 size: 48,
//               ),
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 400),
//             child: Text(
//               'Withdrawal Submitted!',
//               style: AdminDesignSystem.headingMedium.copyWith(
//                 color: AdminDesignSystem.primaryNavy,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 500),
//             child: Text(
//               'Your withdrawal request has been submitted successfully.',
//               style: AdminDesignSystem.bodySmall.copyWith(
//                 color: AdminDesignSystem.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 600),
//             child: Container(
//               padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//               decoration: BoxDecoration(
//                 color: AdminDesignSystem.accentTeal.withAlpha(12),
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _SuccessDetail(
//                     label: 'Amount',
//                     value: _currencyFormatter.format(_withdrawalAmount),
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing12),
//                   _SuccessDetail(
//                     label: 'Wallet',
//                     value: _selectedWallet?.walletName ?? 'N/A',
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing12),
//                   _SuccessDetail(
//                     label: 'Processing Time',
//                     value: 'Up to 24 hours',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== FOOTER ====================
//   Widget _buildFooter() {
//     return Row(
//       children: [
//         if (_currentStep > 0)
//           Expanded(
//             child: OutlinedButton(
//               onPressed: _previousStep,
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: AdminDesignSystem.spacing12,
//                 ),
//               ),
//               child: Text(
//                 'Back',
//                 style: AdminDesignSystem.labelMedium.copyWith(
//                   color: AdminDesignSystem.accentTeal,
//                 ),
//               ),
//             ),
//           ),
//         if (_currentStep > 0)
//           const SizedBox(width: AdminDesignSystem.spacing12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: _isSubmitting ? null : _nextStep,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AdminDesignSystem.accentTeal,
//               padding: const EdgeInsets.symmetric(
//                 vertical: AdminDesignSystem.spacing12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//               ),
//             ),
//             child: _isSubmitting
//                 ? SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                 : Text(
//                     _getButtonText(),
//                     style: AdminDesignSystem.labelMedium.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _getButtonText() {
//     switch (_currentStep) {
//       case 0:
//         return 'Continue';
//       case 1:
//         return 'Review';
//       case 2:
//         return 'Confirm';
//       case 3:
//         return 'Done';
//       default:
//         return 'Next';
//     }
//   }

//   // ==================== ACTIONS ====================
//   void _nextStep() async {
//     if (_currentStep == 0) {
//       if (!_isAmountValid) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter a valid amount')),
//         );
//         return;
//       }
//       setState(() => _currentStep = 1);
//     } else if (_currentStep == 1) {
//       if (_selectedWallet == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select or add a wallet')),
//         );
//         return;
//       }
//       setState(() => _currentStep = 2);
//     } else if (_currentStep == 2) {
//       await _submitWithdrawal();
//     } else if (_currentStep == 3) {
//       Navigator.pop(context);
//       widget.onSuccess();
//     }
//   }

//   void _previousStep() {
//     if (_currentStep > 0) {
//       setState(() => _currentStep--);
//     }
//   }

//   Future<void> _addNewWallet() async {
//     if (_walletNameController.text.isEmpty ||
//         _accountNumberController.text.isEmpty ||
//         _bankNameController.text.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
//       return;
//     }

//     final wallet = FinancialWallet(
//       walletId: const Uuid().v4(),
//       userId: widget.user.uid,
//       type: WalletType.bankAccount,
//       walletName: _walletNameController.text,
//       bankName: _bankNameController.text,
//       accountNumber: _accountNumberController.text,
//       accountHolderName: _accountHolderController.text,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//       isVerified: false,
//     );

//     try {
//       await _walletService.createWallet(wallet);
//       setState(() {
//         _wallets.add(wallet);
//         _selectedWallet = wallet;
//         _walletNameController.clear();
//         _bankNameController.clear();
//         _accountNumberController.clear();
//         _accountHolderController.clear();
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Wallet added successfully')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error adding wallet: $e')));
//       }
//     }
//   }

//   Future<void> _submitWithdrawal() async {
//     if (_selectedWallet == null) return;

//     setState(() => _isSubmitting = true);

//     try {
//       final withdrawalId = const Uuid().v4();
//       final now = DateTime.now();

//       // Create withdrawal request
//       final withdrawal = WithdrawalRequest(
//         withdrawalId: withdrawalId,
//         userId: widget.user.uid,
//         walletId: _selectedWallet!.walletId,
//         amount: _withdrawalAmount,
//         currency: 'NGN',
//         status: WithdrawalStatus.pending,
//         description: 'Withdrawal to ${_selectedWallet!.walletName}',
//         walletName: _selectedWallet!.walletName,
//         walletDetails: _selectedWallet!.displayDetails,
//         walletType: _selectedWallet!.type,
//         requestedAt: now,
//       );

//       // Create transaction record
//       final transaction = TransactionModel(
//         transactionId: withdrawalId,
//         userId: widget.user.uid,
//         transactionType: TransactionType.withdrawal,
//         status: TransactionStatus.pending,
//         amount: _withdrawalAmount,
//         currency: 'NGN',
//         description: 'Withdrawal to ${_selectedWallet!.walletName}',
//         transactionDate: now,
//         createdAt: now,
//         referenceNumber: withdrawalId.substring(0, 8),
//       );

//       // Save both to Firestore using WalletService
//       await _walletService.createWithdrawalRequest(withdrawal);
//       await _walletService.createTransaction(transaction);

//       // Update wallet last used
//       final updatedWallet = _selectedWallet!.copyWith(
//         lastUsedAt: now.toIso8601String(),
//         transactionCount: _selectedWallet!.transactionCount + 1,
//       );
//       await _walletService.updateWallet(updatedWallet);

//       setState(() {
//         _isSubmitting = false;
//         _currentStep = 3;
//       });
//     } catch (e) {
//       setState(() => _isSubmitting = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error submitting withdrawal: $e')),
//         );
//       }
//     }
//   }
// }

// // ==================== HELPER WIDGETS ====================

// class _WalletSelectionTile extends StatelessWidget {
//   final FinancialWallet wallet;
//   final bool isSelected;
//   final VoidCallback onSelected;

//   const _WalletSelectionTile({
//     required this.wallet,
//     required this.isSelected,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onSelected,
//       child: Container(
//         padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected
//                 ? AdminDesignSystem.accentTeal
//                 : AdminDesignSystem.textTertiary.withAlpha(51),
//             width: isSelected ? 2 : 1,
//           ),
//           borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//           color: isSelected
//               ? AdminDesignSystem.accentTeal.withAlpha(12)
//               : Colors.transparent,
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: isSelected
//                       ? AdminDesignSystem.accentTeal
//                       : AdminDesignSystem.textTertiary,
//                   width: 2,
//                 ),
//                 shape: BoxShape.circle,
//                 color: isSelected
//                     ? AdminDesignSystem.accentTeal
//                     : Colors.transparent,
//               ),
//               child: isSelected
//                   ? Icon(Icons.check, size: 16, color: Colors.white)
//                   : null,
//             ),
//             const SizedBox(width: AdminDesignSystem.spacing12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     wallet.walletName,
//                     style: AdminDesignSystem.bodyMedium.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: AdminDesignSystem.primaryNavy,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     wallet.displayDetails,
//                     style: AdminDesignSystem.bodySmall.copyWith(
//                       color: AdminDesignSystem.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ReviewRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color? valueColor;
//   final double? valueSize;

//   const _ReviewRow({
//     required this.label,
//     required this.value,
//     this.valueColor,
//     this.valueSize,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: AdminDesignSystem.bodySmall.copyWith(
//             color: AdminDesignSystem.textSecondary,
//           ),
//         ),
//         Text(
//           value,
//           style: AdminDesignSystem.bodyMedium.copyWith(
//             fontWeight: FontWeight.w700,
//             color: valueColor ?? AdminDesignSystem.primaryNavy,
//             fontSize: valueSize,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _SuccessDetail extends StatelessWidget {
//   final String label;
//   final String value;

//   const _SuccessDetail({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: AdminDesignSystem.bodySmall.copyWith(
//             color: AdminDesignSystem.textSecondary,
//           ),
//         ),
//         Text(
//           value,
//           style: AdminDesignSystem.bodyMedium.copyWith(
//             fontWeight: FontWeight.w700,
//             color: AdminDesignSystem.primaryNavy,
//           ),
//         ),
//       ],
//     );
//   }
// }

// lib/screens/dashboard/modals/withdrawal_modal.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/financial_wallet_models.dart';
import '../../../models/user_model.dart';
import '../../../models/transaction_model.dart';
import '../../../services/wallet_service.dart';

class WithdrawalModal extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSuccess;

  const WithdrawalModal({
    super.key,
    required this.user,
    required this.onSuccess,
  });

  @override
  State<WithdrawalModal> createState() => _WithdrawalModalState();
}

class _WithdrawalModalState extends State<WithdrawalModal> {
  late WalletService _walletService;
  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  // Flow state
  int _currentStep =
      0; // 0: check state, 1: amount, 2: wallet select, 3: review, 4: success

  // Check state
  late double _availableBalance;
  List<FinancialWallet>? _wallets;
  bool _isCheckingWallets = true;
  String? _stateMessage;

  // Form state
  final _amountController = TextEditingController();
  FinancialWallet? _selectedWallet;
  bool _isSubmitting = false;

  // New wallet form
  final _walletNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _walletService = WalletService();
    _availableBalance = widget.user.financialProfile.accountBalance ?? 0;
    _checkWithdrawalEligibility();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _walletNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _checkWithdrawalEligibility() async {
    try {
      // Check 1: Available Balance
      if (_availableBalance <= 0) {
        setState(() {
          _stateMessage = 'Insufficient Balance';
          _isCheckingWallets = false;
          _currentStep = 0;
        });
        return;
      }

      // Check 2: Wallets
      final wallets = await _walletService.getUserWallets(widget.user.uid);
      setState(() {
        _wallets = wallets;
        _isCheckingWallets = false;
        if (wallets.isEmpty) {
          _stateMessage = 'No Withdrawal Wallet';
          _currentStep = 0;
        } else {
          _currentStep = 1; // Proceed to amount step
        }
      });
    } catch (e) {
      setState(() {
        _isCheckingWallets = false;
        _stateMessage = 'Error Loading Data';
      });
    }
  }

  double get _withdrawalAmount => double.tryParse(_amountController.text) ?? 0;
  bool get _isAmountValid =>
      _withdrawalAmount > 0 && _withdrawalAmount <= _availableBalance;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AdminDesignSystem.cardBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AdminDesignSystem.radius16),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AdminDesignSystem.spacing24),
                  if (_isCheckingWallets) _buildLoadingState(),
                  if (!_isCheckingWallets && _stateMessage != null)
                    _buildBlockedState(),
                  if (!_isCheckingWallets && _stateMessage == null) ...[
                    if (_currentStep == 1) _buildAmountStep(),
                    if (_currentStep == 2) _buildWalletStep(),
                    if (_currentStep == 3) _buildReviewStep(),
                    if (_currentStep == 4) _buildSuccessStep(),
                  ],
                  const SizedBox(height: AdminDesignSystem.spacing20),
                  if (!_isCheckingWallets && _stateMessage == null)
                    _buildFooter(),
                  if (!_isCheckingWallets && _stateMessage != null)
                    _buildBlockedFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    final titles = ['', 'Amount', 'Wallet', 'Review', 'Success'];
    return DelayedDisplay(
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Withdraw Funds',
                style: AdminDesignSystem.headingMedium.copyWith(
                  color: AdminDesignSystem.primaryNavy,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  color: AdminDesignSystem.textSecondary,
                  size: 24,
                ),
              ),
            ],
          ),
          if (!_isCheckingWallets && _stateMessage == null) ...[
            const SizedBox(height: AdminDesignSystem.spacing12),
            Text(
              'Step ${_currentStep} of 4: ${titles[_currentStep]}',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
              child: LinearProgressIndicator(
                value: _currentStep / 4,
                minHeight: 6,
                backgroundColor: AdminDesignSystem.accentTeal.withAlpha(38),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AdminDesignSystem.accentTeal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircularProgressIndicator(color: AdminDesignSystem.accentTeal),
          const SizedBox(height: AdminDesignSystem.spacing20),
          Text(
            'Checking withdrawal eligibility...',
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==================== BLOCKED STATE ====================
  Widget _buildBlockedState() {
    final isNoBalance = _stateMessage == 'Insufficient Balance';
    final isNoWallet = _stateMessage == 'No Withdrawal Wallet';

    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (isNoBalance || isNoWallet)
                  ? AdminDesignSystem.statusError.withAlpha(25)
                  : AdminDesignSystem.statusError.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNoBalance ? Icons.account_balance_wallet_outlined : Icons.add,
              color: AdminDesignSystem.statusError,
              size: 40,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          Text(
            _stateMessage!,
            style: AdminDesignSystem.headingMedium.copyWith(
              color: AdminDesignSystem.primaryNavy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          Text(
            isNoBalance
                ? 'You don\'t have sufficient balance to withdraw. Add funds to your account first.'
                : 'You haven\'t set up a withdrawal wallet yet. Add one below to proceed.',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),
          if (isNoWallet) _buildQuickWalletForm(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==================== AMOUNT STEP ====================
  Widget _buildAmountStep() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How much do you want to withdraw?',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          // Amount input
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AdminDesignSystem.accentTeal),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing16,
              vertical: AdminDesignSystem.spacing16,
            ),
            child: Row(
              children: [
                Text(
                  '₦',
                  style: AdminDesignSystem.displayLarge.copyWith(
                    color: AdminDesignSystem.accentTeal,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(width: AdminDesignSystem.spacing8),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      border: InputBorder.none,
                      hintStyle: AdminDesignSystem.displayLarge.copyWith(
                        color: AdminDesignSystem.textTertiary,
                        fontSize: 28,
                      ),
                    ),
                    style: AdminDesignSystem.displayLarge.copyWith(
                      fontSize: 28,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          // Available balance card
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: AdminDesignSystem.accentTeal.withAlpha(12),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              border: Border.all(
                color: AdminDesignSystem.accentTeal.withAlpha(51),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing4),
                    Text(
                      _currencyFormatter.format(_availableBalance),
                      style: AdminDesignSystem.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AdminDesignSystem.accentTeal,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _amountController.text = _availableBalance.toStringAsFixed(
                      0,
                    );
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminDesignSystem.accentTeal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminDesignSystem.spacing16,
                      vertical: AdminDesignSystem.spacing8,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Max',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          // Error if invalid
          if (_amountController.text.isNotEmpty && !_isAmountValid)
            DelayedDisplay(
              delay: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.statusError.withAlpha(25),
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AdminDesignSystem.statusError,
                      size: 20,
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),
                    Expanded(
                      child: Text(
                        'Amount exceeds available balance',
                        style: AdminDesignSystem.bodySmall.copyWith(
                          color: AdminDesignSystem.statusError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== WALLET STEP ====================
  Widget _buildWalletStep() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your withdrawal wallet',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),
          if (_wallets != null && _wallets!.isNotEmpty)
            ..._wallets!.map((wallet) {
              return DelayedDisplay(
                delay: Duration(
                  milliseconds: 250 + (_wallets!.indexOf(wallet) * 100),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: AdminDesignSystem.spacing12,
                  ),
                  child: _WalletSelectionTile(
                    wallet: wallet,
                    isSelected: _selectedWallet?.walletId == wallet.walletId,
                    onSelected: () => setState(() => _selectedWallet = wallet),
                  ),
                ),
              );
            }).toList(),
          const SizedBox(height: AdminDesignSystem.spacing24),
          _buildAddWalletForm(),
        ],
      ),
    );
  }

  Widget _buildQuickWalletForm() {
    return _WalletFormBuilder(
      walletNameController: _walletNameController,
      bankNameController: _bankNameController,
      accountNumberController: _accountNumberController,
      accountHolderController: _accountHolderController,
      onAddWallet: _addNewWallet,
      isQuick: true,
    );
  }

  Widget _buildAddWalletForm() {
    return _WalletFormBuilder(
      walletNameController: _walletNameController,
      bankNameController: _bankNameController,
      accountNumberController: _accountNumberController,
      accountHolderController: _accountHolderController,
      onAddWallet: _addNewWallet,
      isQuick: false,
    );
  }

  // ==================== REVIEW STEP ====================
  Widget _buildReviewStep() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Withdrawal',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),
          // Amount card
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              decoration: BoxDecoration(
                color: AdminDesignSystem.accentTeal.withAlpha(12),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                border: Border.all(
                  color: AdminDesignSystem.accentTeal.withAlpha(51),
                ),
              ),
              child: Column(
                children: [
                  _ReviewRow(
                    label: 'Withdrawal Amount',
                    value: _currencyFormatter.format(_withdrawalAmount),
                    valueColor: AdminDesignSystem.accentTeal,
                    isBold: true,
                  ),
                  const Divider(height: 24),
                  _ReviewRow(
                    label: 'To Wallet',
                    value: _selectedWallet?.walletName ?? 'N/A',
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing8),
                  _ReviewRow(
                    label: 'Bank Details',
                    value: _selectedWallet?.displayDetails ?? 'N/A',
                    valueSize: 12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          // Info box
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              decoration: BoxDecoration(
                color: AdminDesignSystem.statusActive.withAlpha(12),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                border: Border.all(
                  color: AdminDesignSystem.statusActive.withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AdminDesignSystem.statusActive,
                    size: 20,
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing12),
                  Expanded(
                    child: Text(
                      'Withdrawals typically arrive within 24 hours',
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.statusActive,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUCCESS STEP ====================
  Widget _buildSuccessStep() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AdminDesignSystem.statusActive.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AdminDesignSystem.statusActive,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Withdrawal Submitted!',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          DelayedDisplay(
            delay: const Duration(milliseconds: 500),
            child: Text(
              'Your withdrawal request has been submitted successfully.',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          DelayedDisplay(
            delay: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              decoration: BoxDecoration(
                color: AdminDesignSystem.accentTeal.withAlpha(12),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SuccessDetail(
                    label: 'Amount',
                    value: _currencyFormatter.format(_withdrawalAmount),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _SuccessDetail(
                    label: 'Wallet',
                    value: _selectedWallet?.walletName ?? 'N/A',
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _SuccessDetail(
                    label: 'Processing Time',
                    value: 'Up to 24 hours',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FOOTER ====================
  Widget _buildFooter() {
    return Row(
      children: [
        if (_currentStep > 1)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: AdminDesignSystem.spacing12,
                ),
                side: const BorderSide(color: AdminDesignSystem.accentTeal),
              ),
              child: Text(
                'Back',
                style: AdminDesignSystem.labelMedium.copyWith(
                  color: AdminDesignSystem.accentTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (_currentStep > 1)
          const SizedBox(width: AdminDesignSystem.spacing12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminDesignSystem.accentTeal,
              padding: EdgeInsets.symmetric(
                vertical: AdminDesignSystem.spacing12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _getButtonText(),
                    style: AdminDesignSystem.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockedFooter() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminDesignSystem.accentTeal,
          padding: EdgeInsets.symmetric(vertical: AdminDesignSystem.spacing12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Close',
          style: AdminDesignSystem.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 1:
        return 'Continue';
      case 2:
        return 'Review';
      case 3:
        return 'Confirm Withdrawal';
      case 4:
        return 'Done';
      default:
        return 'Next';
    }
  }

  // ==================== ACTIONS ====================
  void _nextStep() async {
    if (_currentStep == 1) {
      if (!_isAmountValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_selectedWallet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select or add a wallet')),
        );
        return;
      }
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      await _submitWithdrawal();
    } else if (_currentStep == 4) {
      Navigator.pop(context);
      widget.onSuccess();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _addNewWallet() async {
    if (_walletNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _bankNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final wallet = FinancialWallet(
      walletId: const Uuid().v4(),
      userId: widget.user.uid,
      type: WalletType.bankAccount,
      walletName: _walletNameController.text,
      bankName: _bankNameController.text,
      accountNumber: _accountNumberController.text,
      accountHolderName: _accountHolderController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isVerified: false,
    );

    try {
      await _walletService.createWallet(wallet);
      setState(() {
        _wallets ??= [];
        _wallets!.add(wallet);
        _selectedWallet = wallet;
        _walletNameController.clear();
        _bankNameController.clear();
        _accountNumberController.clear();
        _accountHolderController.clear();

        // If we're on blocked state, move to amount step
        if (_stateMessage == 'No Withdrawal Wallet') {
          _stateMessage = null;
          _currentStep = 1;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding wallet: $e')));
      }
    }
  }

  Future<void> _submitWithdrawal() async {
    if (_selectedWallet == null) return;

    setState(() => _isSubmitting = true);

    try {
      final withdrawalId = const Uuid().v4();
      final now = DateTime.now();

      final transaction = TransactionModel(
        transactionId: withdrawalId,
        userId: widget.user.uid,
        transactionType: TransactionType.withdrawal,
        status: TransactionStatus.pending,
        amount: _withdrawalAmount,
        currency: 'NGN',
        description: 'Withdrawal to ${_selectedWallet!.walletName}',
        transactionDate: now,
        createdAt: now,
        referenceNumber: withdrawalId.substring(0, 8),
      );

      await _walletService.createTransaction(transaction);

      final updatedWallet = _selectedWallet!.copyWith(
        lastUsedAt: now.toIso8601String(),
        transactionCount: _selectedWallet!.transactionCount + 1,
      );
      await _walletService.updateWallet(updatedWallet);

      setState(() {
        _isSubmitting = false;
        _currentStep = 4;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting withdrawal: $e')),
        );
      }
    }
  }
}

// ==================== HELPER WIDGETS ====================

class _WalletSelectionTile extends StatelessWidget {
  final FinancialWallet wallet;
  final bool isSelected;
  final VoidCallback onSelected;

  const _WalletSelectionTile({
    required this.wallet,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: EdgeInsets.all(AdminDesignSystem.spacing12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AdminDesignSystem.accentTeal
                : AdminDesignSystem.textTertiary.withAlpha(51),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          color: isSelected
              ? AdminDesignSystem.accentTeal.withAlpha(12)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AdminDesignSystem.accentTeal
                      : AdminDesignSystem.textTertiary,
                  width: 2,
                ),
                shape: BoxShape.circle,
                color: isSelected
                    ? AdminDesignSystem.accentTeal
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AdminDesignSystem.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.walletName,
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AdminDesignSystem.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wallet.displayDetails,
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletFormBuilder extends StatefulWidget {
  final TextEditingController walletNameController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController accountHolderController;
  final VoidCallback onAddWallet;
  final bool isQuick;

  const _WalletFormBuilder({
    required this.walletNameController,
    required this.bankNameController,
    required this.accountNumberController,
    required this.accountHolderController,
    required this.onAddWallet,
    required this.isQuick,
  });

  @override
  State<_WalletFormBuilder> createState() => _WalletFormBuilderState();
}

class _WalletFormBuilderState extends State<_WalletFormBuilder> {
  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: Duration(milliseconds: widget.isQuick ? 200 : 300),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          border: Border.all(color: AdminDesignSystem.accentTeal.withAlpha(51)),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          color: AdminDesignSystem.accentTeal.withAlpha(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Withdrawal Wallet',
              style: AdminDesignSystem.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            _buildTextField(
              'Wallet Name (e.g., My GTBank)',
              widget.walletNameController,
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            _buildTextField('Bank Name', widget.bankNameController),
            const SizedBox(height: AdminDesignSystem.spacing12),
            _buildTextField('Account Number', widget.accountNumberController),
            const SizedBox(height: AdminDesignSystem.spacing12),
            _buildTextField(
              'Account Holder Name',
              widget.accountHolderController,
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onAddWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminDesignSystem.accentTeal,
                  padding: const EdgeInsets.symmetric(
                    vertical: AdminDesignSystem.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius8,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Add Wallet',
                  style: AdminDesignSystem.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AdminDesignSystem.bodySmall.copyWith(
          color: AdminDesignSystem.textTertiary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
          borderSide: const BorderSide(color: AdminDesignSystem.textTertiary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdminDesignSystem.spacing12,
          vertical: AdminDesignSystem.spacing12,
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final double? valueSize;
  final bool isBold;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueSize,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
        Text(
          value,
          style: AdminDesignSystem.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AdminDesignSystem.primaryNavy,
            fontSize: valueSize,
          ),
        ),
      ],
    );
  }
}

class _SuccessDetail extends StatelessWidget {
  final String label;
  final String value;

  const _SuccessDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
        Text(
          value,
          style: AdminDesignSystem.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AdminDesignSystem.primaryNavy,
          ),
        ),
      ],
    );
  }
}
