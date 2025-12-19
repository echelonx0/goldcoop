// lib/components/base/app_button.dart
// Base button widget - all variants in one place

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Enum for button variants
enum ButtonVariant { primary, secondary, tertiary, success, danger }

/// Enum for button sizes
enum ButtonSize { small, medium, large }

/// [AppButton] - Universal button component
///
/// Usage:
/// ```dart
/// AppButton(
///   label: 'Sign Up',
///   onPressed: () => handleSignUp(),
///   variant: ButtonVariant.primary,
/// )
/// ```
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? customPadding;
  final TextStyle? customTextStyle;

  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.prefixIcon,
    this.suffixIcon,
    this.customPadding,
    this.customTextStyle,
    Key? key,
  }) : super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabledEffective = widget.isDisabled || widget.isLoading;
    final effectiveWidth = widget.width ?? double.infinity;

    return SizedBox(
      width: effectiveWidth,
      child: _buildButton(isDisabledEffective),
    );
  }

  Widget _buildButton(bool isDisabled) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _buildPrimaryButton(isDisabled);
      case ButtonVariant.secondary:
        return _buildSecondaryButton(isDisabled);
      case ButtonVariant.tertiary:
        return _buildTertiaryButton(isDisabled);
      case ButtonVariant.success:
        return _buildSuccessButton(isDisabled);
      case ButtonVariant.danger:
        return _buildDangerButton(isDisabled);
    }
  }

  Widget _buildPrimaryButton(bool isDisabled) {
    final padding = _getPadding();
    final textStyle =
        widget.customTextStyle ??
        AppTextTheme.bodyLarge.copyWith(
          color: isDisabled ? AppColors.textTertiary : Colors.white,
          fontWeight: FontWeight.w600,
        );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.disabled
              : _isPressed
              ? AppColors.primaryOrangeActive
              : AppColors.primaryOrange,
          borderRadius: AppBorderRadius.mediumRadius,
          boxShadow: isDisabled
              ? AppShadows.elevation0
              : _isPressed
              ? AppShadows.elevation2
              : AppShadows.elevation2,
        ),
        child: _buildButtonContent(textStyle, isDisabled),
      ),
    );
  }

  Widget _buildSecondaryButton(bool isDisabled) {
    final padding = _getPadding();
    final textStyle =
        widget.customTextStyle ??
        AppTextTheme.bodyLarge.copyWith(
          color: isDisabled ? AppColors.textTertiary : AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDisabled
            ? AppColors.disabled.withAlpha(77)
            : AppColors.navyLight,
        borderRadius: AppBorderRadius.mediumRadius,
        boxShadow: isDisabled ? AppShadows.elevation0 : AppShadows.elevation1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : widget.onPressed,
          borderRadius: AppBorderRadius.mediumRadius,
          child: _buildButtonContent(textStyle, isDisabled),
        ),
      ),
    );
  }

  Widget _buildTertiaryButton(bool isDisabled) {
    final padding = _getPadding();
    final textStyle =
        widget.customTextStyle ??
        AppTextTheme.bodyLarge.copyWith(
          color: isDisabled ? AppColors.textTertiary : AppColors.primaryOrange,
          fontWeight: FontWeight.w600,
        );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: isDisabled ? AppColors.disabled : AppColors.primaryOrange,
          width: 1,
        ),
        borderRadius: AppBorderRadius.mediumRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : widget.onPressed,
          borderRadius: AppBorderRadius.mediumRadius,
          child: _buildButtonContent(textStyle, isDisabled),
        ),
      ),
    );
  }

  Widget _buildSuccessButton(bool isDisabled) {
    final padding = _getPadding();
    final textStyle =
        widget.customTextStyle ??
        AppTextTheme.bodyLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );

    return GestureDetector(
      onTap: isDisabled ? null : widget.onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.disabled : AppColors.tealSuccess,
          borderRadius: AppBorderRadius.mediumRadius,
          boxShadow: isDisabled ? AppShadows.elevation0 : AppShadows.elevation2,
        ),
        child: _buildButtonContent(textStyle, isDisabled),
      ),
    );
  }

  Widget _buildDangerButton(bool isDisabled) {
    final padding = _getPadding();
    final textStyle =
        widget.customTextStyle ??
        AppTextTheme.bodyLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );

    return GestureDetector(
      onTap: isDisabled ? null : widget.onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.disabled : AppColors.warmRed,
          borderRadius: AppBorderRadius.mediumRadius,
          boxShadow: isDisabled ? AppShadows.elevation0 : AppShadows.elevation2,
        ),
        child: _buildButtonContent(textStyle, isDisabled),
      ),
    );
  }

  Widget _buildButtonContent(TextStyle textStyle, bool isDisabled) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.variant == ButtonVariant.primary ||
                      widget.variant == ButtonVariant.success ||
                      widget.variant == ButtonVariant.danger
                  ? Colors.white
                  : AppColors.primaryOrange,
            ),
          ),
        ),
      );
    }

    final children = <Widget>[];

    if (widget.prefixIcon != null) {
      children.add(widget.prefixIcon!);
      children.add(const SizedBox(width: AppSpacing.sm));
    }

    children.add(
      Flexible(
        child: Text(
          widget.label,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (widget.suffixIcon != null) {
      children.add(const SizedBox(width: AppSpacing.sm));
      children.add(widget.suffixIcon!);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  EdgeInsets _getPadding() {
    if (widget.customPadding != null) return widget.customPadding!;

    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
    }
  }
}

/// Quick constructor for Primary button
class PrimaryButton extends AppButton {
  const PrimaryButton({
    required super.label,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.width,
    super.key,
  }) : super(variant: ButtonVariant.primary);
}

/// Quick constructor for Secondary button
class SecondaryButton extends AppButton {
  const SecondaryButton({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    Key? key,
  }) : super(
         label: label,
         onPressed: onPressed,
         variant: ButtonVariant.secondary,
         isLoading: isLoading,
         isDisabled: isDisabled,
         width: width,
         key: key,
       );
}

/// Quick constructor for Tertiary button
class TertiaryButton extends AppButton {
  const TertiaryButton({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    Key? key,
  }) : super(
         label: label,
         onPressed: onPressed,
         variant: ButtonVariant.tertiary,
         isLoading: isLoading,
         isDisabled: isDisabled,
         width: width,
         key: key,
       );
}
