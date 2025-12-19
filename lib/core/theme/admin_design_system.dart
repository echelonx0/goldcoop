// lib/core/theme/admin_design_system.dart

import 'package:flutter/material.dart';

class AdminDesignSystem {
  // Colors
  static const background = Color(0xFFF5F7FA);
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryNavy = Color(0xFF1E3A5F);
  static const accentTeal = Color(0xff41A67E);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const divider = Color(0xFFE5E7EB);

  // Status colors
  static const statusActive = Color(0xFF10B981);
  static const statusPending = Color(0xFFF59E0B);
  static const statusInactive = Color(0xFF6B7280);
  static const statusError = Color(0xFFEF4444);

  // Shadows
  static final cardShadow = BoxShadow(
    color: Colors.black.withAlpha(13),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static final softShadow = BoxShadow(
    color: Colors.black.withAlpha(8),
    blurRadius: 4,
    offset: const Offset(0, 1),
  );

  // Spacing
  static const spacing4 = 4.0;
  static const spacing8 = 8.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing20 = 20.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;

  // Border radius
  static const radius8 = 8.0;
  static const radius12 = 12.0;
  static const radius16 = 16.0;
  static const radius24 = 24.0;

  // Typography
  static const fontFamily = 'Inter';

  static const displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.3,
  );

  static const labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.1,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    letterSpacing: 0.3,
  );

  // Components
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radius12),
    boxShadow: [cardShadow],
  );

  static BoxDecoration softCardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radius12),
    boxShadow: [softShadow],
  );
}

// Reusable Widgets
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AdminCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        child: Container(
          decoration: AdminDesignSystem.cardDecoration,
          padding: padding ?? const EdgeInsets.all(AdminDesignSystem.spacing16),
          child: child,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing8,
        vertical: AdminDesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AdminDesignSystem.spacing4),
          ],
          Text(
            label,
            style: AdminDesignSystem.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarCircle extends StatelessWidget {
  final String initials;
  final Color backgroundColor;
  final double size;

  const AvatarCircle({
    super.key,
    required this.initials,
    this.backgroundColor = AdminDesignSystem.accentTeal,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor.withAlpha(38),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: backgroundColor,
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing16,
        vertical: AdminDesignSystem.spacing12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AdminDesignSystem.headingLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: AdminDesignSystem.spacing4),
                  Text(subtitle!, style: AdminDesignSystem.bodyMedium),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
