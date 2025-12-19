// lib/screens/dashboard/tabs/account_tab.dart

import 'package:flutter/material.dart';
import '../../../components/base/app_card.dart';
import '../../../components/base/app_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../screens/admin/admin_dashboard.dart';

class AccountTab extends StatelessWidget {
  final AuthProvider authProvider;
  final VoidCallback? onEditProfile;
  final VoidCallback? onChangePassword;
  final VoidCallback? onSignOut;

  const AccountTab({
    super.key,
    required this.authProvider,
    this.onEditProfile,
    this.onChangePassword,
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.smPlus),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              _buildProfileCard(user),
              const SizedBox(height: AppSpacing.lg),
              _buildAccountInfo(user),
              const SizedBox(height: AppSpacing.lg),
              _buildSettingsSection(context),
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

  Widget _buildProfileCard(UserModel? user) {
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
          PrimaryButton(label: 'Edit Profile', onPressed: onEditProfile),
        ],
      ),
    );
  }

  Widget _buildKYCBadge(KYCStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case KYCStatus.verified:
        color = AppColors.tealSuccess;
        text = 'Verified';
        icon = Icons.verified_user;
        break;
      case KYCStatus.pending:
        color = AppColors.softAmber;
        text = 'Pending Verification';
        icon = Icons.pending;
        break;
      case KYCStatus.submitted:
        color = AppColors.primaryOrange;
        text = 'Under Review';
        icon = Icons.hourglass_empty;
        break;
      case KYCStatus.rejected:
        color = AppColors.warmRed;
        text = 'Verification Failed';
        icon = Icons.error_outline;
        break;
      case KYCStatus.expired:
        color = AppColors.textSecondary;
        text = 'Expired';
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: TextStyle(
              color: color,
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
            user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Not set',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Country',
            user.country?.isNotEmpty == true ? user.country! : 'Not set',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Account Status',
            user.accountStatus.name.toUpperCase(),
            statusColor: _getStatusColor(user.accountStatus),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow('Member Since', _formatDate(user.createdAt)),
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

  Color _getStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return AppColors.tealSuccess;
      case AccountStatus.suspended:
      case AccountStatus.locked:
        return AppColors.warmRed;
      case AccountStatus.closed:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildSettingsSection(BuildContext context) {
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
              _buildSettingItem(
                icon: Icons.admin_panel_settings,
                title: 'Admin Dashboard',
                subtitle: 'Manage investments and users',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboard(
                        adminId: '',
                        adminName: '',
                        adminAvatar: '',
                      ),
                    ),
                  );
                },
                color: AppColors.deepNavy,
              ),
              Divider(
                color: AppColors.backgroundNeutral,
                height: 1,
                thickness: 1,
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password regularly',
                onTap: onChangePassword,
              ),
              Divider(
                color: AppColors.backgroundNeutral,
                height: 1,
                thickness: 1,
              ),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {
                  // TODO: Navigate to notifications
                },
              ),
              Divider(
                color: AppColors.backgroundNeutral,
                height: 1,
                thickness: 1,
              ),
              _buildSettingItem(
                icon: Icons.security_outlined,
                title: 'Security',
                subtitle: 'Two-factor authentication & more',
                onTap: () {
                  // TODO: Navigate to security settings
                },
              ),
              Divider(
                color: AppColors.backgroundNeutral,
                height: 1,
                thickness: 1,
              ),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help with your account',
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
              Divider(
                color: AppColors.backgroundNeutral,
                height: 1,
                thickness: 1,
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Review our privacy practices',
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
              Divider(
                color: AppColors.backgroundNeutral,
                height: 1,
                thickness: 1,
              ),
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'View our terms of service',
                onTap: () {
                  // TODO: Show terms
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: (color ?? AppColors.primaryOrange).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: color ?? AppColors.primaryOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextTheme.bodyRegular.copyWith(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerSection() {
    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: AppTextTheme.heading2.copyWith(
              color: AppColors.warmRed,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Once you sign out, you\'ll need to sign in again to access your account.',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warmRed,
                side: BorderSide(color: AppColors.warmRed),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
