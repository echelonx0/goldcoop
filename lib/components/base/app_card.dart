// lib/components/base/app_card.dart
// Card component with all variants

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum CardVariant { standard, elevated, accent, success }

class AppCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderWidth;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const AppCard({
    required this.child,
    this.variant = CardVariant.standard,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderWidth,
    this.borderColor,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.mdPlus);
    final effectiveBorderRadius = borderRadius ?? AppBorderRadius.mediumRadius;

    Color bg = _getBackgroundColor();
    Color border = _getBorderColor();
    List<BoxShadow> shadows = _getShadows();
    double borderW = borderWidth ?? 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? bg,
          border: Border.all(color: borderColor ?? border, width: borderW),
          borderRadius: effectiveBorderRadius,
          boxShadow: onTap != null ? shadows : shadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: effectiveBorderRadius,
            child: Padding(padding: effectivePadding, child: child),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case CardVariant.standard:
        return AppColors.backgroundWhite;
      case CardVariant.elevated:
        return AppColors.backgroundWhite;
      case CardVariant.accent:
        return AppColors.primaryOrangeLighter;
      case CardVariant.success:
        return const Color(0xFFE8F9F5);
    }
  }

  Color _getBorderColor() {
    switch (variant) {
      case CardVariant.standard:
        return AppColors.borderLight;
      case CardVariant.elevated:
        return AppColors.borderLight;
      case CardVariant.accent:
        return AppColors.primaryOrangeLight;
      case CardVariant.success:
        return const Color(0xFFB3E5D8);
    }
  }

  List<BoxShadow> _getShadows() {
    switch (variant) {
      case CardVariant.standard:
        return AppShadows.elevation1;
      case CardVariant.elevated:
        return AppShadows.elevation3;
      case CardVariant.accent:
        return AppShadows.elevation1;
      case CardVariant.success:
        return AppShadows.elevation1;
    }
  }
}

// Quick constructors
class StandardCard extends AppCard {
  const StandardCard({
    required super.child,
    super.padding,
    super.onTap,
    super.key,
  }) : super(variant: CardVariant.standard);
}

class ElevatedCard extends AppCard {
  const ElevatedCard({
    required super.child,
    EdgeInsets? padding,
    super.onTap,
    super.key,
  }) : super(
         variant: CardVariant.elevated,
         padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
         borderRadius: AppBorderRadius.largeRadius,
       );
}

class AccentCard extends AppCard {
  const AccentCard({
    required super.child,
    EdgeInsets? padding,
    super.onTap,
    super.key,
  }) : super(
         variant: CardVariant.accent,
         padding: padding ?? const EdgeInsets.all(AppSpacing.md),
       );
}

class SuccessCard extends AppCard {
  const SuccessCard({
    required super.child,
    EdgeInsets? padding,
    super.onTap,
    super.key,
  }) : super(
         variant: CardVariant.success,
         padding: padding ?? const EdgeInsets.all(AppSpacing.md),
       );
}
