// lib/screens/dashboard/tabs/account/widgets/security_setting_item.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class SecuritySettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const SecuritySettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryOrange, size: 20),
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
          const SizedBox(width: AppSpacing.sm),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeThumbColor: AppColors.primaryOrange,
            activeTrackColor: AppColors.primaryOrange.withAlpha(128),
          ),
        ],
      ),
    );
  }
}
