// lib/screens/dashboard/tabs/account/widgets/notification_toggle_item.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class NotificationToggleItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationToggleItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
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
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryOrange,
            activeTrackColor: AppColors.primaryOrange.withAlpha(128),
          ),
        ],
      ),
    );
  }
}
