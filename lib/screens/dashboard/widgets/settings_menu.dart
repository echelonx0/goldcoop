// lib/screens/dashboard/widgets/dashboard_settings_menu.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';

class DashboardSettingsMenu extends StatelessWidget {
  final String uid;
  final UserModel? user;
  final VoidCallback onHelpAndSupport;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final VoidCallback onSignOut;

  const DashboardSettingsMenu({
    super.key,
    required this.uid,
    required this.user,
    required this.onHelpAndSupport,
    required this.onTerms,
    required this.onPrivacy,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.large),
          topRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Settings',
            style: AppTextTheme.heading3.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: onHelpAndSupport,
          ),
          _MenuTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: onTerms,
          ),
          _MenuTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: onPrivacy,
          ),
          _MenuTile(
            icon: Icons.logout,
            title: 'Sign Out',
            onTap: onSignOut,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.warmRed : AppColors.deepNavy,
        size: 22,
      ),
      title: Text(
        title,
        style: AppTextTheme.bodyRegular.copyWith(
          color: isDestructive ? AppColors.warmRed : AppColors.deepNavy,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
