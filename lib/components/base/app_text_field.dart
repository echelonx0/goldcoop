// lib/components/base/app_text_field.dart
// Text input field with validation, error states, and helpers

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showCharacterCount;
  final bool required;
  final FocusNode? focusNode;

  const AppTextField({
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.showCharacterCount = false,
    this.required = false,
    this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isObscured = true;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _isObscured = widget.obscureText;
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _validateInput(String value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() => _validationError = error);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _validationError != null && _validationError!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              widget.label,
              style: AppTextTheme.bodyRegular.copyWith(
                color: widget.enabled
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.required)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.warmRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Input Field
        Container(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.smallRadius,
            boxShadow: _isFocused && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.primaryOrange.withAlpha(26),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : hasError
                ? [
                    BoxShadow(
                      color: AppColors.warmRed.withAlpha(26),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText && _isObscured,
            enabled: widget.enabled,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            onChanged: (value) {
              _validateInput(value);
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
            textInputAction: TextInputAction.next,
            style: AppTextTheme.bodyRegular.copyWith(
              color: widget.enabled
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
            cursorColor: AppColors.primaryOrange,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textTertiary.withAlpha(180),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: widget.prefixIcon,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              filled: true,
              fillColor: widget.enabled
                  ? AppColors.backgroundWhite
                  : AppColors.backgroundNeutral,
              border: OutlineInputBorder(
                borderRadius: AppBorderRadius.smallRadius,
                borderSide: const BorderSide(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppBorderRadius.smallRadius,
                borderSide: BorderSide(
                  color: hasError ? AppColors.warmRed : AppColors.borderLight,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppBorderRadius.smallRadius,
                borderSide: BorderSide(
                  color: hasError ? AppColors.warmRed : AppColors.primaryOrange,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: AppBorderRadius.smallRadius,
                borderSide: const BorderSide(
                  color: AppColors.borderMedium,
                  width: 1,
                ),
              ),
              counterText: widget.showCharacterCount ? null : '',
              counterStyle: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),

        // Helper / Error text
        const SizedBox(height: AppSpacing.xs),
        if (hasError)
          Text(
            _validationError!,
            style: AppTextTheme.bodySmall.copyWith(color: AppColors.warmRed),
          )
        else if (widget.helperText != null && widget.helperText!.isNotEmpty)
          Text(
            widget.helperText!,
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // Show/hide password icon
    if (widget.obscureText) {
      return GestureDetector(
        onTap: () => setState(() => _isObscured = !_isObscured),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ),
      );
    }

    // Success checkmark
    if (widget.controller != null && widget.controller!.text.isNotEmpty) {
      if (widget.validator != null) {
        final error = widget.validator!(widget.controller!.text);
        if (error == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              Icons.check_circle,
              color: AppColors.tealSuccess,
              size: 20,
            ),
          );
        }
      }
    }

    return widget.suffixIcon != null
        ? Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: widget.suffixIcon,
          )
        : null;
  }
}

// Validators
class AppValidators {
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    return null;
  }

  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9+\-\s\(\)]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? notEmptyValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? passwordMatchValidator(String? value, String otherPassword) {
    if (value != otherPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
