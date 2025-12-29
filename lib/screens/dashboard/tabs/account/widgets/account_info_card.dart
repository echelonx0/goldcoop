// lib/screens/dashboard/tabs/account/widgets/account_info_card.dart
// Account Information card with Advanced KYC completion prompt

import 'package:flutter/material.dart';

import '../../../../../core/theme/admin_design_system.dart';
import '../../../../../models/user_model.dart';
import '../../../../../models/advanced_kyc_model.dart';
import '../../../../../services/advanced_kyc_service.dart';
import '../advanced_kyc/advanced_kyc_screen.dart';
import '../controllers/account_tab_controller.dart';

class AccountInfoCard extends StatelessWidget {
  final UserModel? user;

  const AccountInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return Container(
      decoration: AdminDesignSystem.cardDecoration,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: AdminDesignSystem.headingMedium.copyWith(
              color: AdminDesignSystem.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),
          _buildInfoRow(
            'Phone Number',
            AccountTabController.getPhoneDisplay(user!),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          _buildInfoRow(
            'Country',
            AccountTabController.getCountryDisplay(user!),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          _buildInfoRow(
            'Account Status',
            AccountTabController.getAccountStatusDisplay(user!),
            statusColor: AccountTabController.getAccountStatusColor(
              user!.accountStatus,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          _buildInfoRow(
            'Member Since',
            AccountTabController.formatDate(user!.createdAt),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),
          const Divider(color: AdminDesignSystem.divider, height: 1),
          const SizedBox(height: AdminDesignSystem.spacing16),
          _AdvancedKYCPrompt(userId: user!.uid),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AdminDesignSystem.labelMedium.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
        Text(
          value,
          style: AdminDesignSystem.bodyMedium.copyWith(
            color: statusColor ?? AdminDesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AdvancedKYCPrompt extends StatelessWidget {
  final String userId;

  const _AdvancedKYCPrompt({required this.userId});

  void _navigateToAdvancedKYC(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedKYCScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AdvancedKYCModel?>(
      stream: AdvancedKYCService().streamAdvancedKYC(userId),
      builder: (context, snapshot) {
        final kyc = snapshot.data;
        final completionPercentage = kyc?.completionPercentage ?? 0;
        final isComplete = kyc?.isComplete ?? false;

        if (isComplete) {
          return _buildCompletedState(context, kyc!);
        }

        return _buildIncompleteState(context, completionPercentage);
      },
    );
  }

  Widget _buildIncompleteState(BuildContext context, int percentage) {
    final hasStarted = percentage > 0;

    return GestureDetector(
      onTap: () => _navigateToAdvancedKYC(context),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AdminDesignSystem.accentTeal.withAlpha(25),
              AdminDesignSystem.accentTeal.withAlpha(13),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(
            color: AdminDesignSystem.accentTeal.withAlpha(51),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
                  decoration: BoxDecoration(
                    color: AdminDesignSystem.accentTeal.withAlpha(38),
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius8,
                    ),
                  ),
                  child: Icon(
                    hasStarted ? Icons.pending_actions : Icons.person_add,
                    size: 20,
                    color: AdminDesignSystem.accentTeal,
                  ),
                ),
                const SizedBox(width: AdminDesignSystem.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasStarted
                            ? 'Continue Your Profile'
                            : 'Complete Your Profile',
                        style: AdminDesignSystem.bodyMedium.copyWith(
                          color: AdminDesignSystem.primaryNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing4),
                      Text(
                        hasStarted
                            ? '$percentage% complete'
                            : 'Unlock personalized recommendations',
                        style: AdminDesignSystem.labelSmall.copyWith(
                          color: AdminDesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AdminDesignSystem.accentTeal,
                ),
              ],
            ),
            if (hasStarted) ...[
              const SizedBox(height: AdminDesignSystem.spacing12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6,
                  backgroundColor: AdminDesignSystem.accentTeal.withAlpha(38),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AdminDesignSystem.accentTeal,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AdminDesignSystem.spacing12),
            Wrap(
              spacing: AdminDesignSystem.spacing8,
              runSpacing: AdminDesignSystem.spacing8,
              children: [
                _buildBenefitChip('Personalized content'),
                _buildBenefitChip('Better recommendations'),
                _buildBenefitChip('Priority support'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context, AdvancedKYCModel kyc) {
    return GestureDetector(
      onTap: () => _navigateToAdvancedKYC(context),
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: AdminDesignSystem.statusActive.withAlpha(13),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(
            color: AdminDesignSystem.statusActive.withAlpha(51),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
              decoration: BoxDecoration(
                color: AdminDesignSystem.statusActive.withAlpha(38),
                borderRadius: BorderRadius.circular(
                  AdminDesignSystem.radius8,
                ),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 20,
                color: AdminDesignSystem.statusActive,
              ),
            ),
            const SizedBox(width: AdminDesignSystem.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Complete',
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      color: AdminDesignSystem.statusActive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing4),
                  Text(
                    'Tap to view or update your details',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: AdminDesignSystem.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing8,
        vertical: AdminDesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius24),
        border: Border.all(color: AdminDesignSystem.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            size: 12,
            color: AdminDesignSystem.accentTeal,
          ),
          const SizedBox(width: AdminDesignSystem.spacing4),
          Text(
            label,
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
