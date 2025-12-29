import 'package:flutter/material.dart';
import '../../../../../core/theme/admin_design_system.dart';

/// A reusable settings list tile with icon, title, subtitle, and tap action.
/// Follows AdminDesignSystem for colors, spacing, and typography.
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
    final color = iconColor ?? AdminDesignSystem.accentTeal;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AdminDesignSystem.spacing16,
            vertical: AdminDesignSystem.spacing16,
          ),
          child: Row(
            children: [
              _buildIconContainer(color),
              SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(child: _buildContent()),
              if (trailing != null) trailing!,
              if (showChevron && trailing == null) _buildChevron(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
      ),
      padding: EdgeInsets.all(AdminDesignSystem.spacing8),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AdminDesignSystem.bodyMedium.copyWith(
            color: AdminDesignSystem.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          subtitle,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChevron() {
    return Icon(
      Icons.chevron_right,
      color: AdminDesignSystem.textTertiary,
      size: 20,
    );
  }
}

/// A divider styled for settings lists
/// Uses background color from AdminDesignSystem for consistency
class SettingsListDivider extends StatelessWidget {
  const SettingsListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AdminDesignSystem.background,
      height: 1,
      thickness: 1,
    );
  }
}
