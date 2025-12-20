// lib/screens/dashboard/widgets/dashboard_support_menu.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DashboardSupportMenu extends StatelessWidget {
  final VoidCallback onFAQ;
  final VoidCallback onCreateTicket;
  final VoidCallback onViewTickets;

  const DashboardSupportMenu({
    super.key,
    required this.onFAQ,
    required this.onCreateTicket,
    required this.onViewTickets,
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
            'Help & Support',
            style: AppTextTheme.heading3.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuTile(
            icon: Icons.help_center_outlined,
            title: 'View FAQ',
            onTap: onFAQ,
          ),
          _MenuTile(
            icon: Icons.chat_bubble_outline,
            title: 'Create Support Ticket',
            onTap: onCreateTicket,
          ),
          _MenuTile(
            icon: Icons.history,
            title: 'View My Tickets',
            onTap: onViewTickets,
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

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.deepNavy, size: 22),
      title: Text(
        title,
        style: AppTextTheme.bodyRegular.copyWith(
          color: AppColors.deepNavy,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
