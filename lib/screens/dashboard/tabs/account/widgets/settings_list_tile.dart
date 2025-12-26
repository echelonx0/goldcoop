// lib/components/account/settings_list_tile.dart
// Reusable settings list tile widget

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// A reusable settings list tile with icon, title, subtitle, and tap action.
/// Used in account settings and other list-based screens.
class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Widget? trailing;
  final bool showChevron;

  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primaryOrange;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.small),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            _buildIconContainer(color),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _buildContent()),
            if (trailing != null) trailing!,
            if (showChevron && trailing == null) _buildChevron(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildContent() {
    return Column(
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
    );
  }

  Widget _buildChevron() {
    return const Icon(
      Icons.chevron_right,
      color: AppColors.textSecondary,
      size: 20,
    );
  }
}

/// A divider styled for settings lists
class SettingsListDivider extends StatelessWidget {
  const SettingsListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.backgroundNeutral, height: 1, thickness: 1);
  }
}
