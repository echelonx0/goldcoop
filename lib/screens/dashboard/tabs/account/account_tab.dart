// lib/screens/dashboard/tabs/account/account_tab.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';

import '../../../../components/modals/legal_modal.dart';
import '../../../../core/coordinators/support_coordinator.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/firestore_service.dart';
import '../../../admin/dashboard/admin_dashboard.dart';

import 'change_password_screen.dart';
import 'controllers/account_tab_controller.dart';
import 'edit-profile/edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'security_settings_screen.dart';
import 'widgets/account_info_card.dart';

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
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        final user = snapshot.data;
        final uid = authProvider.currentUser!.uid;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(AdminDesignSystem.spacing16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  DelayedDisplay(
                    delay: Duration(milliseconds: 100),
                    child: _buildHeader(),
                  ),
                  SizedBox(height: AdminDesignSystem.spacing24),

                  // Profile Card
                  DelayedDisplay(
                    delay: Duration(milliseconds: 180),
                    child: _buildProfileCard(user, context),
                  ),
                  SizedBox(height: AdminDesignSystem.spacing24),

                  // Account Info with Advanced KYC prompt
                  DelayedDisplay(
                    delay: Duration(milliseconds: 260),
                    child: AccountInfoCard(user: user),
                  ),
                  SizedBox(height: AdminDesignSystem.spacing24),

                  // Settings Section with staggered list
                  DelayedDisplay(
                    delay: Duration(milliseconds: 340),
                    child: _buildSettingsSectionHeader(),
                  ),
                  SizedBox(height: AdminDesignSystem.spacing12),
                  _buildSettingsListWithStagger(context, uid),
                  SizedBox(height: AdminDesignSystem.spacing24),

                  // Danger Section
                  DelayedDisplay(
                    delay: Duration(milliseconds: 800),
                    child: _buildDangerSection(),
                  ),
                  SizedBox(height: AdminDesignSystem.spacing32),
                ]),
              ),
            ),
          ],
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
          style: AdminDesignSystem.headingLarge.copyWith(
            color: AdminDesignSystem.primaryNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AdminDesignSystem.spacing8),
        Text(
          'Manage your profile and preferences',
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserModel? user, BuildContext context) {
    return Container(
      decoration: AdminDesignSystem.cardDecoration,
      padding: EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AdminDesignSystem.accentTeal.withAlpha(38),
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius12,
                  ),
                ),
                padding: EdgeInsets.all(AdminDesignSystem.spacing12),
                child: Icon(
                  Icons.account_circle,
                  size: 32,
                  color: AdminDesignSystem.accentTeal,
                ),
              ),
              SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User',
                      style: AdminDesignSystem.bodyLarge.copyWith(
                        color: AdminDesignSystem.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AdminDesignSystem.spacing4),
                    Text(
                      user?.email ?? 'No email',
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                    SizedBox(height: AdminDesignSystem.spacing8),
                    _buildKYCBadge(user?.kycStatus ?? KYCStatus.pending),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AdminDesignSystem.spacing16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToEditProfile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminDesignSystem.accentTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: AdminDesignSystem.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius12,
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                'Edit Profile',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKYCBadge(KYCStatus status) {
    final badgeData = AccountTabController.getKYCBadgeData(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: badgeData.color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AdminDesignSystem.spacing4),
        Text(
          badgeData.text,
          style: AdminDesignSystem.labelSmall.copyWith(
            color: badgeData.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: AdminDesignSystem.headingMedium.copyWith(
            color: AdminDesignSystem.primaryNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          'Customize your experience',
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsListWithStagger(BuildContext context, String uid) {
    final settingsItems = [
      _SettingItem(
        icon: Icons.admin_panel_settings,
        title: 'Admin Dashboard',
        subtitle: 'Manage investments and users',
        onTap: () => _navigateToAdmin(context),
      ),
      _SettingItem(
        icon: Icons.lock_outline,
        title: 'Change Password',
        subtitle: 'Update your password regularly',
        onTap: () => _navigateToChangePassword(context),
      ),
      _SettingItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Manage notification preferences',
        onTap: () => _navigateToNotifications(context, uid),
      ),
      _SettingItem(
        icon: Icons.security_outlined,
        title: 'Security',
        subtitle: 'Two-factor authentication & more',
        onTap: () => _navigateToSecurity(context, uid),
      ),
      _SettingItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get help with your account',
        onTap: () => supportCoordinator?.showSupportMenu(),
      ),
      _SettingItem(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy Policy',
        subtitle: 'Review our privacy practices',
        onTap: () => LegalModal.show(context, LegalDocumentType.privacy),
      ),
      _SettingItem(
        icon: Icons.description_outlined,
        title: 'Terms & Conditions',
        subtitle: 'View our terms of service',
        onTap: () => LegalModal.show(context, LegalDocumentType.terms),
      ),
    ];

    return Container(
      decoration: AdminDesignSystem.cardDecoration,
      child: Column(
        children: List.generate(
          settingsItems.length,
          (index) => DelayedDisplay(
            delay: Duration(milliseconds: 420 + (index * 80)),
            child: Column(
              children: [
                _buildSettingsTile(settingsItems[index]),
                if (index < settingsItems.length - 1)
                  Divider(
                    color: AdminDesignSystem.background,
                    height: 1,
                    thickness: 1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(_SettingItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AdminDesignSystem.spacing16,
            vertical: AdminDesignSystem.spacing16,
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AdminDesignSystem.accentTeal.withAlpha(38),
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius12,
                  ),
                ),
                padding: EdgeInsets.all(AdminDesignSystem.spacing8),
                child: Icon(
                  item.icon,
                  color: AdminDesignSystem.accentTeal,
                  size: 20,
                ),
              ),
              SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        color: AdminDesignSystem.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AdminDesignSystem.spacing4),
                    Text(
                      item.subtitle,
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AdminDesignSystem.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerSection() {
    return Container(
      decoration: AdminDesignSystem.cardDecoration,
      padding: EdgeInsets.all(AdminDesignSystem.spacing16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout, size: 18),
          label: Text(
            'Sign Out',
            style: AdminDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AdminDesignSystem.statusError,
            side: BorderSide(
              color: AdminDesignSystem.statusError.withAlpha(51),
            ),
            padding: EdgeInsets.symmetric(
              vertical: AdminDesignSystem.spacing16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
          ),
        ),
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

// ==================== INTERNAL MODEL ====================
class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}
