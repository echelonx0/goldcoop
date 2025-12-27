// lib/screens/dashboard/tabs/account/account_tab.dart

import 'package:flutter/material.dart';
import '../../../../components/base/app_card.dart';
import '../../../../components/base/app_button.dart';
import '../../../../components/modals/legal_modal.dart';
import '../../../../core/coordinators/support_coordinator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/firestore_service.dart';
import '../../../admin/dashboard/admin_dashboard.dart';

import 'change_password_screen.dart';
import 'controllers/account_tab_controller.dart';
import 'edit-profile/edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'security_settings_screen.dart';
import 'widgets/settings_list_tile.dart';

class AccountTab extends StatelessWidget {
  final AuthProvider authProvider;
  final SupportCoordinator? supportCoordinator;
  final VoidCallback? onEditProfile;
  final VoidCallback? onSignOut;

  const AccountTab({
    super.key,
    required this.authProvider,
    this.supportCoordinator,
    this.onEditProfile,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: FirestoreService().getUserStream(authProvider.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        }

        final user = snapshot.data;
        final uid = authProvider.currentUser!.uid;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.smPlus),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              _buildProfileCard(user, context),
              const SizedBox(height: AppSpacing.lg),
              _buildAccountInfo(user),
              const SizedBox(height: AppSpacing.lg),
              _buildSettingsSection(context, uid),
              const SizedBox(height: AppSpacing.lg),
              _buildDangerSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: AppTextTheme.heading2.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Manage your profile and preferences',
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserModel? user, BuildContext context) {
    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Icon(
                  Icons.account_circle,
                  size: 32,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User',
                      style: AppTextTheme.heading3.copyWith(
                        color: AppColors.deepNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user?.email ?? 'No email',
                      style: AppTextTheme.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildKYCBadge(user?.kycStatus ?? KYCStatus.pending),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Edit Profile',
            onPressed: () => _navigateToEditProfile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildKYCBadge(KYCStatus status) {
    final badgeData = AccountTabController.getKYCBadgeData(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeData.color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeData.icon, size: 12, color: badgeData.color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            badgeData.text,
            style: TextStyle(
              color: badgeData.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(UserModel? user) {
    if (user == null) return const SizedBox.shrink();

    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: AppTextTheme.heading3.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            'Phone Number',
            AccountTabController.getPhoneDisplay(user),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Country',
            AccountTabController.getCountryDisplay(user),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Account Status',
            AccountTabController.getAccountStatusDisplay(user),
            statusColor: AccountTabController.getAccountStatusColor(
              user.accountStatus,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Member Since',
            AccountTabController.formatDate(user.createdAt),
          ),
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
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: AppTextTheme.bodySmall.copyWith(
            color: statusColor ?? AppColors.deepNavy,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: AppTextTheme.heading3.copyWith(
            color: AppColors.deepNavy,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StandardCard(
          child: Column(
            children: [
              SettingsListTile(
                icon: Icons.admin_panel_settings,
                title: 'Admin Dashboard',
                subtitle: 'Manage investments and users',
                iconColor: AppColors.deepNavy,
                onTap: () => _navigateToAdmin(context),
              ),
              const SettingsListDivider(),
              SettingsListTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password regularly',
                onTap: () => _navigateToChangePassword(context),
              ),
              const SettingsListDivider(),
              SettingsListTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () => _navigateToNotifications(context, uid),
              ),
              const SettingsListDivider(),
              SettingsListTile(
                icon: Icons.security_outlined,
                title: 'Security',
                subtitle: 'Two-factor authentication & more',
                onTap: () => _navigateToSecurity(context, uid),
              ),
              const SettingsListDivider(),
              SettingsListTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help with your account',
                onTap: () => supportCoordinator?.showSupportMenu(),
              ),
              const SettingsListDivider(),
              SettingsListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Review our privacy practices',
                onTap: () =>
                    LegalModal.show(context, LegalDocumentType.privacy),
              ),
              const SettingsListDivider(),
              SettingsListTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'View our terms of service',
                onTap: () => LegalModal.show(context, LegalDocumentType.terms),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerSection() {
    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryOrangeActive,
                side: BorderSide(color: AppColors.softAmber),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== NAVIGATION ====================
  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(authProvider: authProvider),
      ),
    );
  }

  void _navigateToAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AdminDashboard(adminId: '', adminName: '', adminAvatar: ''),
      ),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  void _navigateToNotifications(BuildContext context, String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationSettingsScreen(userId: uid),
      ),
    );
  }

  void _navigateToSecurity(BuildContext context, String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecuritySettingsScreen(userId: uid),
      ),
    );
  }
}
