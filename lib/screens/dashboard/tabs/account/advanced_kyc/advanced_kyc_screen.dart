// lib/screens/dashboard/tabs/account/advanced_kyc/advanced_kyc_screen.dart
// Multi-step Advanced KYC form screen

import 'package:flutter/material.dart';
import '../../../../../core/theme/admin_design_system.dart';
import '../../../../../models/advanced_kyc_model.dart';
import '../../../../../services/advanced_kyc_service.dart';

import 'steps/personal_details_step.dart';
import 'steps/next_of_kin_step.dart';
import 'steps/savings_profile_step.dart';

class AdvancedKYCScreen extends StatefulWidget {
  final String userId;

  const AdvancedKYCScreen({super.key, required this.userId});

  @override
  State<AdvancedKYCScreen> createState() => _AdvancedKYCScreenState();
}

class _AdvancedKYCScreenState extends State<AdvancedKYCScreen> {
  final AdvancedKYCService _kycService = AdvancedKYCService();
  final PageController _pageController = PageController();

  int _currentStep = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  late AdvancedKYCModel _kycData;

  final List<String> _stepTitles = [
    'Personal Details',
    'Next of Kin',
    'Savings Profile',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    try {
      final existing = await _kycService.getAdvancedKYC(widget.userId);
      setState(() {
        _kycData = existing ?? AdvancedKYCModel.empty(widget.userId);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _kycData = AdvancedKYCModel.empty(widget.userId);
        _isLoading = false;
      });
    }
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _stepTitles.length) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = step);
    }
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  Future<void> _saveAndContinue(AdvancedKYCModel updatedKyc) async {
    setState(() => _isSaving = true);

    try {
      await _kycService.saveAdvancedKYC(updatedKyc);
      setState(() {
        _kycData = updatedKyc;
        _isSaving = false;
      });

      if (_currentStep < _stepTitles.length - 1) {
        _nextStep();
      } else {
        _showCompletionDialog();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showErrorSnackbar('Failed to save. Please try again.');
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
              decoration: BoxDecoration(
                color: AdminDesignSystem.statusActive.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: AdminDesignSystem.statusActive,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing20),
            Text(
              'Profile Complete!',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            Text(
              'Thank you for completing your profile. We can now provide you with personalized content and recommendations.',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to account tab
              },
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
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminDesignSystem.statusError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      appBar: AppBar(
        backgroundColor: AdminDesignSystem.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complete Your Profile',
          style: AdminDesignSystem.headingMedium.copyWith(
            color: AdminDesignSystem.primaryNavy,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AdminDesignSystem.accentTeal,
              ),
            )
          : Column(
              children: [
                _buildProgressHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentStep = index);
                    },
                    children: [
                      PersonalDetailsStep(
                        initialData: _kycData.personalDetails,
                        onSave: (details) {
                          _saveAndContinue(
                            _kycData.copyWith(personalDetails: details),
                          );
                        },
                        isSaving: _isSaving,
                      ),
                      NextOfKinStep(
                        initialData: _kycData.nextOfKin,
                        onSave: (kin) {
                          _saveAndContinue(_kycData.copyWith(nextOfKin: kin));
                        },
                        onBack: _previousStep,
                        isSaving: _isSaving,
                      ),
                      SavingsProfileStep(
                        initialData: _kycData.savingsProfile,
                        onSave: (profile) {
                          _saveAndContinue(
                            _kycData.copyWith(savingsProfile: profile),
                          );
                        },
                        onBack: _previousStep,
                        isSaving: _isSaving,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      color: AdminDesignSystem.cardBackground,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(_stepTitles.length, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: GestureDetector(
                  onTap: index <= _currentStep ? () => _goToStep(index) : null,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (index > 0)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isCompleted || isActive
                                    ? AdminDesignSystem.accentTeal
                                    : AdminDesignSystem.divider,
                              ),
                            ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AdminDesignSystem.accentTeal
                                  : isActive
                                  ? AdminDesignSystem.accentTeal.withAlpha(38)
                                  : AdminDesignSystem.background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive || isCompleted
                                    ? AdminDesignSystem.accentTeal
                                    : AdminDesignSystem.divider,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: AdminDesignSystem.labelSmall
                                          .copyWith(
                                            color: isActive
                                                ? AdminDesignSystem.accentTeal
                                                : AdminDesignSystem
                                                      .textTertiary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                            ),
                          ),
                          if (index < _stepTitles.length - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isCompleted
                                    ? AdminDesignSystem.accentTeal
                                    : AdminDesignSystem.divider,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing8),
                      Text(
                        _stepTitles[index],
                        style: AdminDesignSystem.labelSmall.copyWith(
                          color: isActive
                              ? AdminDesignSystem.accentTeal
                              : AdminDesignSystem.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
