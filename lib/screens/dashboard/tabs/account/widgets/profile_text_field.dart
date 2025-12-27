// lib/screens/dashboard/tabs/account/widgets/profile_text_field.dart
// Reusable text field for profile editing with consistent styling

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final bool enabled;
  final TextCapitalization textCapitalization;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.words,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          enabled: enabled,
          textCapitalization: textCapitalization,
          style: AppTextTheme.bodyRegular.copyWith(
            color: enabled ? AppColors.deepNavy : AppColors.textSecondary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextTheme.bodyRegular.copyWith(
              color: AppColors.textSecondary.withAlpha(128),
              fontSize: 15,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled
                ? AppColors.backgroundNeutral
                : AppColors.backgroundNeutral.withAlpha(128),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              borderSide: BorderSide(color: AppColors.borderLight, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              borderSide: BorderSide(color: AppColors.primaryOrange, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              borderSide: BorderSide(color: AppColors.warmRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              borderSide: BorderSide(color: AppColors.warmRed, width: 2),
            ),
            errorStyle: TextStyle(color: AppColors.warmRed, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// Dropdown field with consistent styling
class ProfileDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? hintText;
  final IconData? prefixIcon;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const ProfileDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only use value if it exists in items, otherwise use null
    final effectiveValue = (value != null && items.contains(value))
        ? value
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.backgroundNeutral
                : AppColors.backgroundNeutral.withAlpha(128),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonFormField<String>(
            value: effectiveValue,
            hint: hintText != null
                ? Text(
                    hintText!,
                    style: AppTextTheme.bodyRegular.copyWith(
                      color: AppColors.textSecondary.withAlpha(128),
                      fontSize: 15,
                    ),
                  )
                : null,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: AppColors.deepNavy,
                    fontSize: 15,
                  ),
                ),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: InputBorder.none,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
        ),
      ],
    );
  }
}

/// Read-only info row (for non-editable fields like email)
class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final String? helperText;

  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.backgroundNeutral.withAlpha(128),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: AppColors.borderLight.withAlpha(128)),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  value,
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.textSecondary.withAlpha(128),
              ),
            ],
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helperText!,
            style: TextStyle(
              color: AppColors.textSecondary.withAlpha(179),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
