// lib/screens/investments/investment_checkout_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/base/app_button.dart';
import '../../core/theme/app_colors.dart';
import '../../models/investment_plan_model.dart';
import '../../models/user_model.dart';
import '../../models/callback_and_request_models.dart';
import '../../services/investment_plan_service.dart';
import '../../services/firestore_service.dart';

class InvestmentCheckoutScreen extends StatefulWidget {
  final InvestmentPlanModel plan;
  final double investmentAmount;

  const InvestmentCheckoutScreen({
    super.key,

    required this.plan,
    required this.investmentAmount,
  });

  @override
  State<InvestmentCheckoutScreen> createState() =>
      _InvestmentCheckoutScreenState();
}

class _InvestmentCheckoutScreenState extends State<InvestmentCheckoutScreen> {
  late final InvestmentPlanService _planService;
  late final FirestoreService _firestoreService;

  UserModel? _user;
  bool _isLoading = true;
  String? _error;
  bool _agreeToTerms = false;
  bool _requestCallback = false;
  // Get current user ID
  String get _userId => FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _planService = InvestmentPlanService();
    _firestoreService = FirestoreService();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _firestoreService.getUser(_userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load user data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : _error != null
          ? _buildErrorState()
          : _buildCheckoutContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Investment Checkout',
        style: AppTextTheme.heading2.copyWith(
          color: AppColors.deepNavy,
          fontSize: 14,
        ),
      ),
      elevation: 0,
      backgroundColor: AppColors.backgroundWhite,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        color: AppColors.deepNavy,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.warmRed),
          const SizedBox(height: AppSpacing.md),
          Text(
            'User is not found',
            style: AppTextTheme.bodyRegular.copyWith(color: AppColors.warmRed),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SecondaryButton(
            label: 'Go Back',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutContent() {
    if (_user == null) {
      return _buildErrorState();
    }

    final amountInRange = widget.plan.isValidInvestmentAmount(
      widget.investmentAmount,
    );
    final canAfford =
        _user!.financialProfile.accountBalance >= widget.investmentAmount;
    final expectedReturn = widget.plan.calculateExpectedReturn(
      widget.investmentAmount,
      widget.plan.durationMonths,
    );
    final totalValue = widget.investmentAmount + expectedReturn;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan summary
          _buildSummaryCard(),
          const SizedBox(height: AppSpacing.lg),

          // Range validation (if out of range)
          if (!amountInRange) _buildRangeValidationError(),
          if (!amountInRange) const SizedBox(height: AppSpacing.lg),

          // Investment details
          _buildInvestmentDetails(expectedReturn, totalValue),
          const SizedBox(height: AppSpacing.lg),

          // Balance check
          _buildBalanceCheckCard(canAfford),
          const SizedBox(height: AppSpacing.lg),

          // Breakdown if insufficient balance
          if (!canAfford) _buildInsufficientBalanceWarning(),
          if (!canAfford) const SizedBox(height: AppSpacing.lg),

          // Terms & conditions
          _buildTermsCheckbox(),
          const SizedBox(height: AppSpacing.md),

          // Callback request
          _buildCallbackCheckbox(),
          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          if (amountInRange && canAfford)
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Confirm Investment',
                onPressed: _agreeToTerms ? _handleInvestment : null,
              ),
            )
          else if (amountInRange)
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Request Approval',
                onPressed: _agreeToTerms ? _handleInvestmentRequest : null,
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: _buildDisabledButtonText(),
                onPressed: null,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investment Plan',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.plan.planName,
            style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.plan.description,
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRangeValidationError() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmRed.withAlpha(12),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.warmRed.withAlpha(25)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warmRed, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Amount Out of Range',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.warmRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your investment amount (${_formatCurrency(widget.investmentAmount)}) is outside the allowed range.',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Allowed range: ${widget.plan.getInvestmentRangeText()}',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.warmRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentDetails(double expectedReturn, double totalValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Breakdown',
          style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withAlpha(12),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: AppColors.primaryOrange.withAlpha(25)),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _buildDetailRow(
                'Principal',
                _formatCurrency(widget.investmentAmount),
                AppColors.deepNavy,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow(
                'Expected Return (${widget.plan.durationMonths}m)',
                _formatCurrency(expectedReturn),
                AppColors.tealSuccess,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 1,
                color: AppColors.primaryOrange.withAlpha(25),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow(
                'Total Value at Maturity',
                _formatCurrency(totalValue),
                AppColors.primaryOrange,
                isTotal: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Payout: ${widget.plan.payoutFrequency} | Duration: ${widget.plan.durationMonths} months',
                style: AppTextTheme.micro.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextTheme.bodyRegular.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                )
              : AppTextTheme.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextTheme.heading3.copyWith(color: color)
              : AppTextTheme.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  Widget _buildBalanceCheckCard(bool canAfford) {
    final user = _user!;
    final balanceAfter =
        user.financialProfile.accountBalance - widget.investmentAmount;

    return Container(
      decoration: BoxDecoration(
        color: canAfford
            ? AppColors.tealSuccess.withAlpha(12)
            : AppColors.warmRed.withAlpha(12),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: canAfford
              ? AppColors.tealSuccess.withAlpha(25)
              : AppColors.warmRed.withAlpha(25),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                canAfford ? Icons.check_circle : Icons.info,
                color: canAfford ? AppColors.tealSuccess : AppColors.warmRed,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  canAfford
                      ? 'Sufficient balance available'
                      : 'Insufficient balance',
                  style: AppTextTheme.bodySmall.copyWith(
                    color: canAfford
                        ? AppColors.tealSuccess
                        : AppColors.warmRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            'Current Balance',
            _formatCurrency(user.financialProfile.accountBalance),
            AppColors.deepNavy,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            'Investment Amount',
            _formatCurrency(widget.investmentAmount),
            AppColors.primaryOrange,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 1,
            color: canAfford
                ? AppColors.tealSuccess.withAlpha(25)
                : AppColors.warmRed.withAlpha(25),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            'Balance After Investment',
            _formatCurrency(balanceAfter.clamp(0, double.infinity)),
            canAfford ? AppColors.tealSuccess : AppColors.warmRed,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInsufficientBalanceWarning() {
    final shortfall =
        widget.investmentAmount - _user!.financialProfile.accountBalance;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmRed.withAlpha(12),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.warmRed.withAlpha(25)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warmRed, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Shortfall',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.warmRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'You need an additional ${_formatCurrency(shortfall)} to complete this investment.',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'You can:',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '• Request approval for investment above balance',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Add funds to your account first',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Invest a smaller amount',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: CheckboxListTile(
        title: RichText(
          text: TextSpan(
            text: 'I agree to the ',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: 'Terms & Conditions',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        value: _agreeToTerms,
        onChanged: (value) {
          setState(() => _agreeToTerms = value ?? false);
        },
        activeColor: AppColors.primaryOrange,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildCallbackCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: CheckboxListTile(
        title: Text(
          'Request callback for questions',
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          'Our team will contact you before processing',
          style: AppTextTheme.micro.copyWith(color: AppColors.textTertiary),
        ),
        value: _requestCallback,
        onChanged: (value) {
          setState(() => _requestCallback = value ?? false);
        },
        activeColor: AppColors.primaryOrange,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Future<void> _handleInvestment() async {
    _showProcessingDialog();

    try {
      final investmentId = await _planService.investWithBalance(
        userId: _userId,
        planId: widget.plan.planId,
        planName: widget.plan.planName,
        amount: widget.investmentAmount,
        user: _user!,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (investmentId != null) {
        _showSuccessDialog(investmentId);
      } else {
        _showErrorDialog('Investment failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorDialog('Error: $e');
    }
  }

  Future<void> _handleInvestmentRequest() async {
    _showProcessingDialog();

    try {
      final requestId = await _planService.requestInvestment(
        userId: _userId,
        planId: widget.plan.planId,
        planName: widget.plan.planName,
        amount: widget.investmentAmount,
        user: _user,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (requestId != null) {
        if (_requestCallback && _user != null) {
          await _planService.createCallbackRequest(
            CallbackRequestModel(
              callbackId: '',
              userId: _userId,
              userEmail: _user!.email,
              userPhone: _user!.phoneNumber,
              userName: _user!.displayName,
              subject: 'Investment Help - Insufficient Balance',
              message:
                  'I want to invest ${_formatCurrency(widget.investmentAmount)} in ${widget.plan.planName} but need assistance with funding.',
              requestType: CallbackRequestType.investment_help,
              preferredCallbackDate: DateTime.now().add(
                const Duration(days: 1),
              ),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }

        _showRequestSubmittedDialog(requestId);
      } else {
        _showErrorDialog('Request failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorDialog('Error: $e');
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primaryOrange),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Processing your investment...',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String investmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.tealSuccess, size: 24),
            const SizedBox(width: AppSpacing.sm),
            const Text('Investment Confirmed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your investment of ${_formatCurrency(widget.investmentAmount)} in ${widget.plan.planName} has been processed.',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.tealSuccess.withAlpha(12),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                'ID: $investmentId',
                style: AppTextTheme.micro.copyWith(
                  color: AppColors.tealSuccess,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestSubmittedDialog(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: AppColors.softAmber, size: 24),
            const SizedBox(width: AppSpacing.sm),
            const Text('Request Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your investment request has been submitted for review.',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Our team will review your request and contact you shortly.',
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (_requestCallback) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.softAmber.withAlpha(12),
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text(
                  'Callback request submitted as well',
                  style: AppTextTheme.micro.copyWith(
                    color: AppColors.softAmber,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: AppColors.primaryOrange)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.warmRed, size: 24),
            const SizedBox(width: AppSpacing.sm),
            const Text('Error'),
          ],
        ),
        content: Text(
          message,
          style: AppTextTheme.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primaryOrange)),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₦${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₦${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₦${amount.toStringAsFixed(0)}';
  }

  String _buildDisabledButtonText() {
    if (!widget.plan.isValidInvestmentAmount(widget.investmentAmount)) {
      return 'Amount Out of Range';
    }
    return 'Confirm Investment';
  }
}
