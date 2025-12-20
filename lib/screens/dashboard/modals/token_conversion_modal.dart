// lib/screens/dashboard/modals/token_conversion_modal.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/user_model.dart';
import '../../../models/token_conversion_model.dart';
import '../../../services/token_conversion_service.dart';

class TokenConversionModal extends StatefulWidget {
  final UserModel user;
  final TokenConversionService tokenConversionService;
  final Function(String conversionId) onSuccess;

  const TokenConversionModal({
    super.key,
    required this.user,
    required this.tokenConversionService,
    required this.onSuccess,
  });

  @override
  State<TokenConversionModal> createState() => _TokenConversionModalState();
}

class _TokenConversionModalState extends State<TokenConversionModal> {
  int _currentStep =
      0; // 0: amount, 1: phone, 2: network, 3: review, 4: success
  bool _isSubmitting = false;

  // Form state
  int _selectedTokenCount = 10;
  final _phoneController = TextEditingController();
  PhoneNetwork _selectedNetwork = PhoneNetwork.mtn;

  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  int get _availableTokens => widget.user.financialProfile.tokenBalance;
  double get _nairaValue => _selectedTokenCount * 10.0;
  bool get _isPhoneValid => _phoneController.text.isValidNigerianPhone;

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
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AdminDesignSystem.radius12),
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
                  if (_currentStep == 0) _buildAmountStep(),
                  if (_currentStep == 1) _buildPhoneStep(),
                  if (_currentStep == 2) _buildNetworkStep(),
                  if (_currentStep == 3) _buildReviewStep(),
                  if (_currentStep == 4) _buildSuccessStep(),
                  const SizedBox(height: AdminDesignSystem.spacing20),
                  _buildFooter(),
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
    final titles = ['Amount', 'Phone', 'Network', 'Review', 'Success'];
    return DelayedDisplay(
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Convert Tokens',
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
          const SizedBox(height: AdminDesignSystem.spacing12),
          Text(
            'Step ${_currentStep + 1} of ${_currentStep == 4 ? 5 : 4}: ${titles[_currentStep]}',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              minHeight: 6,
              backgroundColor: AdminDesignSystem.accentTeal.withAlpha(38),
              valueColor: AlwaysStoppedAnimation<Color>(
                AdminDesignSystem.accentTeal,
              ),
            ),
          ),
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
            'How many tokens to convert?',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),

          // Token slider
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
            decoration: BoxDecoration(
              color: AdminDesignSystem.accentTeal.withAlpha(12),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              border: Border.all(
                color: AdminDesignSystem.accentTeal.withAlpha(51),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$_selectedTokenCount',
                  style: AdminDesignSystem.displayLarge.copyWith(
                    color: AdminDesignSystem.accentTeal,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing8),
                Text(
                  'tokens',
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),
                Slider(
                  value: _selectedTokenCount.toDouble(),
                  min: 10,
                  max: _availableTokens.toDouble(),
                  divisions: (_availableTokens - 10) ~/ 10,
                  activeColor: AdminDesignSystem.accentTeal,
                  inactiveColor: AdminDesignSystem.accentTeal.withAlpha(38),
                  onChanged: (value) {
                    setState(() {
                      _selectedTokenCount = (value ~/ 10) * 10;
                    });
                  },
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '10 tokens',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textTertiary,
                      ),
                    ),
                    Text(
                      '$_availableTokens tokens',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AdminDesignSystem.spacing24),

          // Value breakdown
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: AdminDesignSystem.background,
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'Tokens', value: '$_selectedTokenCount'),
                const SizedBox(height: AdminDesignSystem.spacing12),
                _DetailRow(
                  label: 'Airtime Value',
                  value: _currencyFormatter.format(_nairaValue),
                  valueColor: AdminDesignSystem.accentTeal,
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),
                _DetailRow(
                  label: 'Available Balance',
                  value: '$_availableTokens tokens',
                  valueColor: AdminDesignSystem.accentTeal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PHONE STEP ====================
  Widget _buildPhoneStep() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your phone number',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Text(
            'The airtime will be sent to this number',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),

          // Phone input
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '08012345678 or +2348012345678',
              hintStyle: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textTertiary,
              ),
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: AdminDesignSystem.textSecondary,
              ),
              suffixIcon: _phoneController.text.isNotEmpty
                  ? Icon(
                      _isPhoneValid ? Icons.check_circle : Icons.error_outline,
                      color: _isPhoneValid
                          ? Colors.green
                          : AdminDesignSystem.statusError,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                borderSide: const BorderSide(
                  color: AdminDesignSystem.textTertiary,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AdminDesignSystem.spacing16,
                vertical: AdminDesignSystem.spacing16,
              ),
            ),
            style: AdminDesignSystem.bodyMedium,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: AdminDesignSystem.spacing16),

          // Info
          if (_phoneController.text.isNotEmpty && _isPhoneValid)
            DelayedDisplay(
              delay: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: AdminDesignSystem.spacing12),
                    Expanded(
                      child: Text(
                        'Valid Nigerian phone number',
                        style: AdminDesignSystem.bodySmall.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_phoneController.text.isNotEmpty && !_isPhoneValid)
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
                        'Invalid phone number format',
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

  // ==================== NETWORK STEP ====================
  Widget _buildNetworkStep() {
    final detectedNetwork = _phoneController.text.isValidNigerianPhone
        ? _phoneController.text.detectNetwork()
        : PhoneNetwork.mtn;

    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select network',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Text(
            detectedNetwork != PhoneNetwork.other
                ? 'Detected: ${detectedNetwork.name.toUpperCase()}'
                : 'Please select your network provider',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),

          // Network options
          ...[
            PhoneNetwork.mtn,
            PhoneNetwork.airtel,
            PhoneNetwork.glo,
            PhoneNetwork.etisalat,
          ].asMap().entries.map((entry) {
            final index = entry.key;
            final network = entry.value;
            return DelayedDisplay(
              delay: Duration(milliseconds: 250 + (index * 100)),
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: AdminDesignSystem.spacing12,
                ),
                child: _NetworkOption(
                  network: network,
                  isSelected: _selectedNetwork == network,
                  isDetected: detectedNetwork == network,
                  onSelected: () {
                    setState(() => _selectedNetwork = network);
                  },
                ),
              ),
            );
          }).toList(),
        ],
      ),
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
            'Review your conversion',
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),

          // Review card
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
            decoration: BoxDecoration(
              color: AdminDesignSystem.accentTeal.withAlpha(12),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              border: Border.all(
                color: AdminDesignSystem.accentTeal.withAlpha(51),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DelayedDisplay(
                  delay: const Duration(milliseconds: 300),
                  child: _DetailRow(
                    label: 'Tokens',
                    value: '$_selectedTokenCount',
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),
                DelayedDisplay(
                  delay: const Duration(milliseconds: 350),
                  child: _DetailRow(
                    label: 'Airtime Value',
                    value: _currencyFormatter.format(_nairaValue),
                    valueColor: AdminDesignSystem.accentTeal,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),
                DelayedDisplay(
                  delay: const Duration(milliseconds: 400),
                  child: _DetailRow(
                    label: 'Phone Number',
                    value: _phoneController.text,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),
                DelayedDisplay(
                  delay: const Duration(milliseconds: 450),
                  child: _DetailRow(
                    label: 'Network',
                    value: _selectedNetwork.name.toUpperCase(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AdminDesignSystem.spacing24),

          // Info banner
          DelayedDisplay(
            delay: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                border: Border.all(color: Colors.amber.withAlpha(51)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: AdminDesignSystem.spacing12),
                  Expanded(
                    child: Text(
                      'Airtime will arrive within 5-30 minutes after approval.',
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: Colors.amber[800],
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
                color: AdminDesignSystem.accentTeal.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AdminDesignSystem.accentTeal,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Conversion Submitted!',
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
              'Your token conversion request has been submitted.\nYou\'ll receive airtime once approved.',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),
          DelayedDisplay(
            delay: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              decoration: BoxDecoration(
                color: AdminDesignSystem.background,
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SuccessDetail(
                    label: 'Tokens Converted',
                    value: '$_selectedTokenCount',
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _SuccessDetail(
                    label: 'Airtime Value',
                    value: _currencyFormatter.format(_nairaValue),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _SuccessDetail(
                    label: 'Phone Number',
                    value: _phoneController.text,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _SuccessDetail(label: 'Status', value: 'Pending Approval'),
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
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AdminDesignSystem.spacing12,
                ),
              ),
              child: Text(
                'Back',
                style: AdminDesignSystem.labelMedium.copyWith(
                  color: AdminDesignSystem.accentTeal,
                ),
              ),
            ),
          ),
        if (_currentStep > 0)
          const SizedBox(width: AdminDesignSystem.spacing12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminDesignSystem.accentTeal,
              padding: const EdgeInsets.symmetric(
                vertical: AdminDesignSystem.spacing12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
              ),
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

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Continue';
      case 1:
        return 'Continue';
      case 2:
        return 'Review';
      case 3:
        return 'Confirm';
      case 4:
        return 'Done';
      default:
        return 'Next';
    }
  }

  // ==================== ACTIONS ====================
  void _nextStep() async {
    // Validation for each step
    if (_currentStep == 0) {
      if (_selectedTokenCount <= 0 || _selectedTokenCount > _availableTokens) {
        _showError('Please select a valid token amount');
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (!_isPhoneValid) {
        _showError('Please enter a valid phone number');
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      await _submitConversion();
    } else if (_currentStep == 4) {
      Navigator.pop(context);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitConversion() async {
    setState(() => _isSubmitting = true);

    try {
      final conversionId = await widget.tokenConversionService
          .convertTokensAtomically(
            userId: widget.user.uid,
            tokenCount: _selectedTokenCount,
            phoneNumber: _phoneController.text,
            network: _selectedNetwork,
            user: widget.user,
          );

      if (!mounted) return;

      if (conversionId != null) {
        setState(() {
          _isSubmitting = false;
          _currentStep = 4;
        });
        widget.onSuccess(conversionId);
      } else {
        _showError('Failed to create conversion request');
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: ${e.toString()}');
      }
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminDesignSystem.statusError,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ==================== HELPER WIDGETS ====================

class _NetworkOption extends StatelessWidget {
  final PhoneNetwork network;
  final bool isSelected;
  final bool isDetected;
  final VoidCallback onSelected;

  const _NetworkOption({
    required this.network,
    required this.isSelected,
    required this.isDetected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
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
            const SizedBox(width: AdminDesignSystem.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network.name.toUpperCase(),
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AdminDesignSystem.primaryNavy,
                    ),
                  ),
                  if (isDetected)
                    Text(
                      'Detected from your phone number',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.accentTeal,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

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
            color: valueColor ?? AdminDesignSystem.primaryNavy,
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
