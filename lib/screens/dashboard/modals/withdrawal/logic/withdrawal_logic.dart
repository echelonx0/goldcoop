// lib/screens/dashboard/modals/withdrawal/logic/withdrawal_logic.dart

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../../models/financial_wallet_models.dart';
import '../../../../../models/user_model.dart';
import '../../../../../models/transaction_model.dart';
import '../../../../../services/wallet_service.dart';
import '../state/withdrawal_state.dart';

class WithdrawalLogic {
  final WalletService walletService;
  final UserModel user;

  WithdrawalLogic({required this.walletService, required this.user});

  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  String formatCurrency(double amount) => _currencyFormatter.format(amount);

  /// Check withdrawal eligibility: balance and wallet availability
  Future<WithdrawalState> checkEligibility(WithdrawalState state) async {
    try {
      // Check 1: Available Balance
      final availableBalance = user.financialProfile.accountBalance;
      if (availableBalance <= 0) {
        return state.copyWith(
          availableBalance: availableBalance,
          isCheckingWallets: false,
          stateMessage: 'Insufficient Balance',
          currentStep: 0,
        );
      }

      // Check 2: Wallets
      final wallets = await walletService.getUserWallets(user.uid);
      if (wallets.isEmpty) {
        return state.copyWith(
          availableBalance: availableBalance,
          wallets: wallets,
          isCheckingWallets: false,
          stateMessage: 'No Withdrawal Wallet',
          currentStep: 0,
        );
      }

      // Proceed to amount step
      return state.copyWith(
        availableBalance: availableBalance,
        wallets: wallets,
        isCheckingWallets: false,
        currentStep: 1,
      );
    } catch (e) {
      return state.copyWith(
        isCheckingWallets: false,
        stateMessage: 'Error Loading Data',
      );
    }
  }

  /// Move to next step with validation
  WithdrawalState validateAndAdvance(WithdrawalState state) {
    if (state.currentStep == 1 && !state.isAmountValid) {
      return state; // Return unchanged, caller shows error
    }
    if (state.currentStep == 2 && state.selectedWallet == null) {
      return state; // Return unchanged, caller shows error
    }
    return state.copyWith(currentStep: state.currentStep + 1);
  }

  /// Move to previous step
  WithdrawalState goBack(WithdrawalState state) {
    if (state.currentStep > 1) {
      return state.copyWith(currentStep: state.currentStep - 1);
    }
    return state;
  }

  /// Create new wallet and update state
  Future<WithdrawalState> addWallet(WithdrawalState state) async {
    if (!state.isWalletFormValid) {
      throw Exception('Please fill all wallet fields');
    }

    final wallet = FinancialWallet(
      walletId: const Uuid().v4(),
      userId: user.uid,
      type: WalletType.bankAccount,
      walletName: state.walletName,
      bankName: state.bankName,
      accountNumber: state.accountNumber,
      accountHolderName: state.accountHolder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isVerified: false,
    );

    try {
      await walletService.createWallet(wallet);

      // ✅ FIX: Explicitly type the list as List<FinancialWallet>
      final updatedWallets = <FinancialWallet>[
        ...(state.wallets ?? []),
        wallet,
      ];

      final newState = state.copyWith(
        wallets: updatedWallets,
        selectedWallet: wallet,
        walletName: '',
        accountNumber: '',
        bankName: '',
        accountHolder: '',
      );

      // If blocked due to no wallet, unblock and go to amount step
      if (state.isNoWallet) {
        return newState.copyWith(stateMessage: null, currentStep: 1);
      }

      return newState;
    } catch (e) {
      throw Exception('Error adding wallet: $e');
    }
  }

  /// Submit withdrawal transaction
  Future<WithdrawalState> submitWithdrawal(WithdrawalState state) async {
    if (state.selectedWallet == null) {
      throw Exception('No wallet selected');
    }

    final newState = state.copyWith(isSubmitting: true);

    try {
      final withdrawalId = const Uuid().v4();
      final now = DateTime.now();

      // Create transaction record
      final transaction = TransactionModel(
        transactionId: withdrawalId,
        userId: user.uid,
        transactionType: TransactionType.withdrawal,
        status: TransactionStatus.pending,
        amount: state.withdrawalAmount,
        currency: 'NGN',
        description: 'Withdrawal to ${state.selectedWallet!.walletName}',
        transactionDate: now,
        createdAt: now,
        referenceNumber: withdrawalId.substring(0, 8),
      );

      await walletService.createTransaction(transaction);

      // Update wallet metadata
      final updatedWallet = state.selectedWallet!.copyWith(
        lastUsedAt: now.toIso8601String(),
        transactionCount: state.selectedWallet!.transactionCount + 1,
      );
      await walletService.updateWallet(updatedWallet);

      return newState.copyWith(isSubmitting: false, currentStep: 4);
    } catch (e) {
      return newState.copyWith(isSubmitting: false);
    }
  }

  /// Set withdrawal amount and validate
  WithdrawalState setAmount(WithdrawalState state, String amountString) {
    final amount = double.tryParse(amountString) ?? 0;
    return state.copyWith(withdrawalAmount: amount);
  }

  /// Set amount to maximum available
  WithdrawalState setMaxAmount(WithdrawalState state) {
    return state.copyWith(withdrawalAmount: state.availableBalance);
  }

  /// Update wallet form fields
  WithdrawalState updateWalletForm(
    WithdrawalState state, {
    String? walletName,
    String? bankName,
    String? accountNumber,
    String? accountHolder,
  }) {
    return state.copyWith(
      walletName: walletName ?? state.walletName,
      bankName: bankName ?? state.bankName,
      accountNumber: accountNumber ?? state.accountNumber,
      accountHolder: accountHolder ?? state.accountHolder,
    );
  }

  /// Select wallet
  WithdrawalState selectWallet(WithdrawalState state, FinancialWallet wallet) {
    return state.copyWith(selectedWallet: wallet);
  }
}
