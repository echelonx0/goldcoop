// lib/screens/auth/components/auth_components.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../core/theme/app_colors.dart';

/// Hero section with animated icon and title
class AuthHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  const AuthHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DelayedDisplay(
          delay: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (iconColor ?? AppColors.primaryOrange).withAlpha(38),
                  (iconColor ?? AppColors.primaryOrange).withAlpha(13),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppBorderRadius.mediumRadius,
            ),
            child: Icon(
              icon,
              size: 32,
              color: iconColor ?? AppColors.primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        DelayedDisplay(
          delay: const Duration(milliseconds: 200),
          child: Text(
            title,
            style: AppTextTheme.heading1.copyWith(
              color: AppColors.deepNavy,
              fontSize: 32,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DelayedDisplay(
          delay: const Duration(milliseconds: 300),
          child: Text(
            subtitle,
            style: AppTextTheme.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated error card
class AuthErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const AuthErrorCard({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.warmRed.withAlpha(26),
          border: Border.all(color: AppColors.warmRed, width: 1),
          borderRadius: AppBorderRadius.mediumRadius,
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.warmRed, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.warmRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: AppColors.warmRed, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info box with icon
class AuthInfoBox extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const AuthInfoBox({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final boxColor = color ?? AppColors.info;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: boxColor.withAlpha(26),
        border: Border.all(color: boxColor, width: 1),
        borderRadius: AppBorderRadius.mediumRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: boxColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextTheme.bodySmall.copyWith(
                color: boxColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom checkbox with label
class AuthCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget label;

  const AuthCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: GestureDetector(onTap: () => onChanged(!value), child: label),
        ),
      ],
    );
  }
}

/// Bottom navigation link (e.g., "Don't have an account? Sign Up")
class AuthBottomLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;

  const AuthBottomLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: AppTextTheme.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: AppTextTheme.bodyRegular.copyWith(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

/// Decorative background gradient
class AuthBackgroundGradient extends StatelessWidget {
  const AuthBackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primaryOrange.withAlpha(26),
              AppColors.primaryOrange.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Success state with animation
class AuthSuccessState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? email;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final Widget? additionalContent;

  const AuthSuccessState({
    super.key,
    required this.title,
    required this.subtitle,
    this.email,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.additionalContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        DelayedDisplay(
          delay: const Duration(milliseconds: 100),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.tealSuccess.withAlpha(38),
                  AppColors.tealSuccess.withAlpha(13),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.tealSuccess,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        DelayedDisplay(
          delay: const Duration(milliseconds: 200),
          child: Text(
            title,
            style: AppTextTheme.heading1.copyWith(color: AppColors.deepNavy),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DelayedDisplay(
          delay: const Duration(milliseconds: 300),
          child: Text(
            subtitle,
            style: AppTextTheme.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (email != null) ...[
          const SizedBox(height: AppSpacing.sm),
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Text(
              email!,
              style: AppTextTheme.bodyLarge.copyWith(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (additionalContent != null)
          DelayedDisplay(
            delay: const Duration(milliseconds: 500),
            child: additionalContent!,
          ),
        const SizedBox(height: AppSpacing.xl),
        DelayedDisplay(
          delay: const Duration(milliseconds: 600),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.mediumRadius,
                ),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: AppTextTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
