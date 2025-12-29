// // lib/screens/dashboard/modals/withdrawal/withdrawal_modal.dart

// import 'package:flutter/material.dart';
// import 'package:delayed_display/delayed_display.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';
// import '../../../../core/theme/admin_design_system.dart';
// import '../../../../models/financial_wallet_models.dart';
// import '../../../../models/user_model.dart';
// import '../../../../models/transaction_model.dart';
// import '../../../../services/wallet_service.dart';
// import 'widgets/wallet_form_builder.dart';

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
//   int _currentStep =
//       0; // 0: check state, 1: amount, 2: wallet select, 3: review, 4: success

//   // Check state
//   late double _availableBalance;
//   List<FinancialWallet>? _wallets;
//   bool _isCheckingWallets = true;
//   String? _stateMessage;

//   // Form state
//   final _amountController = TextEditingController();
//   FinancialWallet? _selectedWallet;
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
//     _availableBalance = widget.user.financialProfile.accountBalance;
//     _checkWithdrawalEligibility();
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

//   Future<void> _checkWithdrawalEligibility() async {
//     try {
//       // Check 1: Available Balance
//       if (_availableBalance <= 0) {
//         setState(() {
//           _stateMessage = 'Insufficient Balance';
//           _isCheckingWallets = false;
//           _currentStep = 0;
//         });
//         return;
//       }

//       // Check 2: Wallets
//       final wallets = await _walletService.getUserWallets(widget.user.uid);
//       setState(() {
//         _wallets = wallets;
//         _isCheckingWallets = false;
//         if (wallets.isEmpty) {
//           _stateMessage = 'No Withdrawal Wallet';
//           _currentStep = 0;
//         } else {
//           _currentStep = 1; // Proceed to amount step
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _isCheckingWallets = false;
//         _stateMessage = 'Error Loading Data';
//       });
//     }
//   }

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
//             color: AdminDesignSystem.cardBackground,
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(AdminDesignSystem.radius16),
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
//                   if (_isCheckingWallets) _buildLoadingState(),
//                   if (!_isCheckingWallets && _stateMessage != null)
//                     _buildBlockedState(),
//                   if (!_isCheckingWallets && _stateMessage == null) ...[
//                     if (_currentStep == 1) _buildAmountStep(),
//                     if (_currentStep == 2) _buildWalletStep(),
//                     if (_currentStep == 3) _buildReviewStep(),
//                     if (_currentStep == 4) _buildSuccessStep(),
//                   ],
//                   const SizedBox(height: AdminDesignSystem.spacing20),
//                   if (!_isCheckingWallets && _stateMessage == null)
//                     _buildFooter(),
//                   if (!_isCheckingWallets && _stateMessage != null)
//                     _buildBlockedFooter(),
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
//     final titles = ['', 'Amount', 'Wallet', 'Review', 'Success'];
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
//           if (!_isCheckingWallets && _stateMessage == null) ...[
//             const SizedBox(height: AdminDesignSystem.spacing12),
//             Text(
//               'Step $_currentStep of 4: ${titles[_currentStep]}',
//               style: AdminDesignSystem.bodySmall.copyWith(
//                 color: AdminDesignSystem.textSecondary,
//               ),
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing12),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//               child: LinearProgressIndicator(
//                 value: _currentStep / 4,
//                 minHeight: 6,
//                 backgroundColor: AdminDesignSystem.accentTeal.withAlpha(38),
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   AdminDesignSystem.accentTeal,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // ==================== LOADING STATE ====================
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         children: [
//           const SizedBox(height: 40),
//           CircularProgressIndicator(color: AdminDesignSystem.accentTeal),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           Text(
//             'Checking withdrawal eligibility...',
//             style: AdminDesignSystem.bodyMedium.copyWith(
//               color: AdminDesignSystem.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   // ==================== BLOCKED STATE ====================
//   Widget _buildBlockedState() {
//     final isNoBalance = _stateMessage == 'Insufficient Balance';
//     final isNoWallet = _stateMessage == 'No Withdrawal Wallet';

//     return DelayedDisplay(
//       delay: const Duration(milliseconds: 200),
//       child: Column(
//         children: [
//           const SizedBox(height: 40),
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: (isNoBalance || isNoWallet)
//                   ? AdminDesignSystem.statusError.withAlpha(25)
//                   : AdminDesignSystem.statusError.withAlpha(25),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               isNoBalance ? Icons.account_balance_wallet_outlined : Icons.add,
//               color: AdminDesignSystem.statusError,
//               size: 40,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           Text(
//             _stateMessage!,
//             style: AdminDesignSystem.headingMedium.copyWith(
//               color: AdminDesignSystem.primaryNavy,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),
//           Text(
//             isNoBalance
//                 ? 'You don\'t have sufficient balance to withdraw. Add funds to your account first.'
//                 : 'You haven\'t set up a withdrawal wallet yet. Add one below to proceed.',
//             style: AdminDesignSystem.bodySmall.copyWith(
//               color: AdminDesignSystem.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing24),
//           if (isNoWallet) _buildQuickWalletForm(),
//           const SizedBox(height: 40),
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
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           // Amount input
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: AdminDesignSystem.accentTeal),
//               borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
//             ),
//             padding: const EdgeInsets.symmetric(
//               horizontal: AdminDesignSystem.spacing16,
//               vertical: AdminDesignSystem.spacing16,
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   '₦',
//                   style: AdminDesignSystem.displayLarge.copyWith(
//                     color: AdminDesignSystem.accentTeal,
//                     fontSize: 28,
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
//                         fontSize: 28,
//                       ),
//                     ),
//                     style: AdminDesignSystem.displayLarge.copyWith(
//                       fontSize: 28,
//                     ),
//                     onChanged: (_) => setState(() {}),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           // Available balance card
//           Container(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//             decoration: BoxDecoration(
//               color: AdminDesignSystem.accentTeal.withAlpha(12),
//               borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//               border: Border.all(
//                 color: AdminDesignSystem.accentTeal.withAlpha(51),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Available Balance',
//                       style: AdminDesignSystem.labelSmall.copyWith(
//                         color: AdminDesignSystem.textSecondary,
//                       ),
//                     ),
//                     const SizedBox(height: AdminDesignSystem.spacing4),
//                     Text(
//                       _currencyFormatter.format(_availableBalance),
//                       style: AdminDesignSystem.bodyLarge.copyWith(
//                         fontWeight: FontWeight.w700,
//                         color: AdminDesignSystem.accentTeal,
//                       ),
//                     ),
//                   ],
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     _amountController.text = _availableBalance.toStringAsFixed(
//                       0,
//                     );
//                     setState(() {});
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AdminDesignSystem.accentTeal,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: AdminDesignSystem.spacing16,
//                       vertical: AdminDesignSystem.spacing8,
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Text(
//                     'Max',
//                     style: AdminDesignSystem.labelSmall.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           // Error if invalid
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
//             'Select your withdrawal wallet',
//             style: AdminDesignSystem.bodyLarge.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),
//           if (_wallets != null && _wallets!.isNotEmpty)
//             ..._wallets!.map((wallet) {
//               return DelayedDisplay(
//                 delay: Duration(
//                   milliseconds: 250 + (_wallets!.indexOf(wallet) * 100),
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
//             }),
//           const SizedBox(height: AdminDesignSystem.spacing24),
//           _buildAddWalletForm(),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickWalletForm() {
//     return WalletFormBuilder(
//       walletNameController: _walletNameController,
//       bankNameController: _bankNameController,
//       accountNumberController: _accountNumberController,
//       accountHolderController: _accountHolderController,
//       onAddWallet: _addNewWallet,
//       isQuick: true,
//     );
//   }

//   Widget _buildAddWalletForm() {
//     return WalletFormBuilder(
//       walletNameController: _walletNameController,
//       bankNameController: _bankNameController,
//       accountNumberController: _accountNumberController,
//       accountHolderController: _accountHolderController,
//       onAddWallet: _addNewWallet,
//       isQuick: false,
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
//           const SizedBox(height: AdminDesignSystem.spacing24),
//           // Amount card
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 300),
//             child: Container(
//               padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//               decoration: BoxDecoration(
//                 color: AdminDesignSystem.accentTeal.withAlpha(12),
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//                 border: Border.all(
//                   color: AdminDesignSystem.accentTeal.withAlpha(51),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   _ReviewRow(
//                     label: 'Withdrawal Amount',
//                     value: _currencyFormatter.format(_withdrawalAmount),
//                     valueColor: AdminDesignSystem.accentTeal,
//                     isBold: true,
//                   ),
//                   const Divider(height: 24),
//                   _ReviewRow(
//                     label: 'To Wallet',
//                     value: _selectedWallet?.walletName ?? 'N/A',
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing8),
//                   _ReviewRow(
//                     label: 'Bank Details',
//                     value: _selectedWallet?.displayDetails ?? 'N/A',
//                     valueSize: 12,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           // Info box
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 400),
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
//                       'Withdrawals typically arrive within 24 hours',
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
//         if (_currentStep > 1)
//           Expanded(
//             child: OutlinedButton(
//               onPressed: _previousStep,
//               style: OutlinedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(
//                   vertical: AdminDesignSystem.spacing12,
//                 ),
//                 side: const BorderSide(color: AdminDesignSystem.accentTeal),
//               ),
//               child: Text(
//                 'Back',
//                 style: AdminDesignSystem.labelMedium.copyWith(
//                   color: AdminDesignSystem.accentTeal,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         if (_currentStep > 1)
//           const SizedBox(width: AdminDesignSystem.spacing12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: _isSubmitting ? null : _nextStep,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AdminDesignSystem.accentTeal,
//               padding: EdgeInsets.symmetric(
//                 vertical: AdminDesignSystem.spacing12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//               ),
//               elevation: 0,
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

//   Widget _buildBlockedFooter() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () => Navigator.pop(context),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AdminDesignSystem.accentTeal,
//           padding: EdgeInsets.symmetric(vertical: AdminDesignSystem.spacing12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//           ),
//           elevation: 0,
//         ),
//         child: Text(
//           'Close',
//           style: AdminDesignSystem.labelMedium.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//     );
//   }

//   String _getButtonText() {
//     switch (_currentStep) {
//       case 1:
//         return 'Continue';
//       case 2:
//         return 'Review';
//       case 3:
//         return 'Confirm Withdrawal';
//       case 4:
//         return 'Done';
//       default:
//         return 'Next';
//     }
//   }

//   // ==================== ACTIONS ====================
//   void _nextStep() async {
//     if (_currentStep == 1) {
//       if (!_isAmountValid) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter a valid amount')),
//         );
//         return;
//       }
//       setState(() => _currentStep = 2);
//     } else if (_currentStep == 2) {
//       if (_selectedWallet == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select or add a wallet')),
//         );
//         return;
//       }
//       setState(() => _currentStep = 3);
//     } else if (_currentStep == 3) {
//       await _submitWithdrawal();
//     } else if (_currentStep == 4) {
//       Navigator.pop(context);
//       widget.onSuccess();
//     }
//   }

//   void _previousStep() {
//     if (_currentStep > 1) {
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
//         _wallets ??= [];
//         _wallets!.add(wallet);
//         _selectedWallet = wallet;
//         _walletNameController.clear();
//         _bankNameController.clear();
//         _accountNumberController.clear();
//         _accountHolderController.clear();

//         // If we're on blocked state, move to amount step
//         if (_stateMessage == 'No Withdrawal Wallet') {
//           _stateMessage = null;
//           _currentStep = 1;
//         }
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

//       await _walletService.createTransaction(transaction);

//       final updatedWallet = _selectedWallet!.copyWith(
//         lastUsedAt: now.toIso8601String(),
//         transactionCount: _selectedWallet!.transactionCount + 1,
//       );
//       await _walletService.updateWallet(updatedWallet);

//       setState(() {
//         _isSubmitting = false;
//         _currentStep = 4;
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
//         padding: EdgeInsets.all(AdminDesignSystem.spacing12),
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
//   final bool isBold;

//   const _ReviewRow({
//     required this.label,
//     required this.value,
//     this.valueColor,
//     this.valueSize,
//     this.isBold = false,
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
//             fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
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
// lib/screens/dashboard/modals/withdrawal/withdrawal_modal.dart

import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../../../services/wallet_service.dart';
import 'state/blocked_state.dart';
import 'state/withdrawal_state.dart';
import 'logic/withdrawal_logic.dart';
import 'steps/amount_step.dart';
import 'steps/wallet_step.dart';
import 'steps/review_step.dart';
import 'steps/success_step.dart';
import 'widgets/withdrawal_widgets.dart';

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
  late WithdrawalLogic _logic;
  late WithdrawalState _state;

  @override
  void initState() {
    super.initState();
    _logic = WithdrawalLogic(walletService: WalletService(), user: widget.user);
    _state = WithdrawalState(
      availableBalance: widget.user.financialProfile.accountBalance,
    );
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    final newState = await _logic.checkEligibility(_state);
    setState(() => _state = newState);
  }

  void _handleStateChange(WithdrawalState newState) {
    setState(() => _state = newState);
  }

  void _handleError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _nextStep() async {
    final newState = _logic.validateAndAdvance(_state);

    if (newState == _state) {
      // Validation failed
      if (_state.currentStep == 1 && !_state.isAmountValid) {
        _handleError('Please enter a valid amount');
      } else if (_state.currentStep == 2 && _state.selectedWallet == null) {
        _handleError('Please select or add a wallet');
      }
      return;
    }

    // Advance step or submit
    if (_state.currentStep == 3) {
      await _submitWithdrawal();
    } else if (_state.currentStep == 4) {
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      _handleStateChange(newState);
    }
  }

  void _previousStep() {
    final newState = _logic.goBack(_state);
    _handleStateChange(newState);
  }

  Future<void> _submitWithdrawal() async {
    try {
      final newState = await _logic.submitWithdrawal(_state);
      if (newState.currentStep == 4) {
        _handleStateChange(newState);
      } else {
        _handleError('Error submitting withdrawal');
      }
    } catch (e) {
      _handleError('Error: $e');
    }
  }

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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  WithdrawalHeader(
                    currentStep: _state.currentStep,
                    stepTitle: _state.getStepTitle(),
                    progressValue: _state.getProgressValue(),
                    onClose: () => Navigator.pop(context),
                    isLoading: _state.isCheckingWallets,
                  ),
                  const SizedBox(height: 24),

                  // Content
                  if (_state.isCheckingWallets)
                    const LoadingState()
                  else if (_state.isBlocked)
                    BlockedState(
                      state: _state,
                      logic: _logic,
                      onStateChanged: _handleStateChange,
                      onError: _handleError,
                    )
                  else ...[
                    if (_state.currentStep == 1)
                      AmountStep(
                        state: _state,
                        logic: _logic,
                        onStateChanged: _handleStateChange,
                      )
                    else if (_state.currentStep == 2)
                      WalletStep(
                        state: _state,
                        logic: _logic,
                        onStateChanged: _handleStateChange,
                        onError: _handleError,
                      )
                    else if (_state.currentStep == 3)
                      ReviewStep(state: _state, logic: _logic)
                    else if (_state.currentStep == 4)
                      SuccessStep(state: _state, logic: _logic),
                  ],

                  const SizedBox(height: 20),

                  // Footer
                  if (!_state.isCheckingWallets && !_state.isBlocked)
                    WithdrawalFooter(
                      nextButtonText: _state.getButtonText(),
                      onNext: _nextStep,
                      onBack: _state.showBackButton ? _previousStep : null,
                      isLoading: _state.isSubmitting,
                      canGoBack: _state.showBackButton,
                    )
                  else if (!_state.isCheckingWallets && _state.isBlocked)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF48cfcb),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
