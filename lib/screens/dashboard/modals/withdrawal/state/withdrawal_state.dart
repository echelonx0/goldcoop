// lib/screens/dashboard/modals/withdrawal/state/withdrawal_state.dart

import '../../../../../models/financial_wallet_models.dart';

class WithdrawalState {
  // Step flow
  final int
  currentStep; // 0: check, 1: amount, 2: wallet, 3: review, 4: success
  final String? stateMessage; // Blocked state reason

  // Check state
  final double availableBalance;
  final List<FinancialWallet>? wallets;
  final bool isCheckingWallets;

  // Form state
  final double withdrawalAmount;
  final FinancialWallet? selectedWallet;
  final bool isSubmitting;

  // New wallet form
  final String walletName;
  final String accountNumber;
  final String bankName;
  final String accountHolder;

  WithdrawalState({
    this.currentStep = 0,
    this.stateMessage,
    this.availableBalance = 0,
    this.wallets,
    this.isCheckingWallets = true,
    this.withdrawalAmount = 0,
    this.selectedWallet,
    this.isSubmitting = false,
    this.walletName = '',
    this.accountNumber = '',
    this.bankName = '',
    this.accountHolder = '',
  });

  WithdrawalState copyWith({
    int? currentStep,
    String? stateMessage,
    double? availableBalance,
    List<FinancialWallet>? wallets,
    bool? isCheckingWallets,
    double? withdrawalAmount,
    FinancialWallet? selectedWallet,
    bool? isSubmitting,
    String? walletName,
    String? accountNumber,
    String? bankName,
    String? accountHolder,
  }) {
    return WithdrawalState(
      currentStep: currentStep ?? this.currentStep,
      stateMessage: stateMessage ?? this.stateMessage,
      availableBalance: availableBalance ?? this.availableBalance,
      wallets: wallets ?? this.wallets,
      isCheckingWallets: isCheckingWallets ?? this.isCheckingWallets,
      withdrawalAmount: withdrawalAmount ?? this.withdrawalAmount,
      selectedWallet: selectedWallet ?? this.selectedWallet,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      walletName: walletName ?? this.walletName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      accountHolder: accountHolder ?? this.accountHolder,
    );
  }

  bool get isAmountValid =>
      withdrawalAmount > 0 && withdrawalAmount <= availableBalance;

  bool get isBlocked => stateMessage != null;

  bool get isNoBalance => stateMessage == 'Insufficient Balance';

  bool get isNoWallet => stateMessage == 'No Withdrawal Wallet';

  bool get canProceedToWalletStep => wallets != null && wallets!.isNotEmpty;

  String getButtonText() {
    switch (currentStep) {
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

  String getStepTitle() {
    final titles = ['', 'Amount', 'Wallet', 'Review', 'Success'];
    return titles[currentStep];
  }

  double getProgressValue() => currentStep / 4;

  bool get showBackButton => currentStep > 1;

  bool get isWalletFormValid =>
      walletName.isNotEmpty &&
      accountNumber.isNotEmpty &&
      bankName.isNotEmpty &&
      accountHolder.isNotEmpty;
}
