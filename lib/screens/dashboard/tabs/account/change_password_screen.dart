// lib/screens/dashboard/tabs/account/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../components/base/app_button.dart';
import '../../../../components/base/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import 'controllers/change_password_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late ChangePasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChangePasswordController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.deepNavy,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Change Password',
          style: AppTextTheme.heading3.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.md),

                // Info card
                DelayedDisplay(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(26),
                      border: Border.all(color: AppColors.info, width: 1),
                      borderRadius: AppBorderRadius.mediumRadius,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'For security, you\'ll need to enter your current password',
                            style: AppTextTheme.bodySmall.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Current password
                DelayedDisplay(
                  delay: const Duration(milliseconds: 200),
                  child: AppTextField(
                    label: 'Current Password',
                    controller: _controller.currentPasswordController,
                    obscureText: true,
                    hint: 'Enter your current password',
                    focusNode: _controller.currentPasswordFocusNode,
                    prefixIcon: Icon(Icons.lock_outline),
                    onSubmitted: (_) {
                      _controller.currentPasswordFocusNode.unfocus();
                      FocusScope.of(
                        context,
                      ).requestFocus(_controller.newPasswordFocusNode);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // New password
                DelayedDisplay(
                  delay: const Duration(milliseconds: 300),
                  child: AppTextField(
                    label: 'New Password',
                    controller: _controller.newPasswordController,
                    obscureText: true,
                    hint: 'Create a strong password',
                    focusNode: _controller.newPasswordFocusNode,
                    prefixIcon: Icon(Icons.lock_reset),
                    helperText: 'Min. 8 characters, 1 uppercase, 1 number',
                    onSubmitted: (_) {
                      _controller.newPasswordFocusNode.unfocus();
                      FocusScope.of(
                        context,
                      ).requestFocus(_controller.confirmPasswordFocusNode);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Confirm password
                DelayedDisplay(
                  delay: const Duration(milliseconds: 400),
                  child: AppTextField(
                    label: 'Confirm New Password',
                    controller: _controller.confirmPasswordController,
                    obscureText: true,
                    hint: 'Re-enter your new password',
                    focusNode: _controller.confirmPasswordFocusNode,
                    prefixIcon: Icon(Icons.lock_outline),
                    onSubmitted: (_) {
                      _controller.confirmPasswordFocusNode.unfocus();
                      _handleChangePassword();
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit button
                DelayedDisplay(
                  delay: const Duration(milliseconds: 500),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return PrimaryButton(
                        label: 'Update Password',
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleChangePassword,
                        isLoading: authProvider.isLoading,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Cancel button
                DelayedDisplay(
                  delay: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    child: SecondaryButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChangePassword() {
    final validation = _controller.validate();

    if (validation != null) {
      _showSnackbar(validation, isError: true);
      return;
    }

    context
        .read<AuthProvider>()
        .changePassword(
          currentPassword: _controller.currentPasswordController.text,
          newPassword: _controller.newPasswordController.text,
        )
        .then((success) {
          if (success) {
            _showSnackbar('Password updated successfully', isError: false);
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.of(context).pop();
            });
          } else {
            _showSnackbar(
              context.read<AuthProvider>().errorMessage ??
                  'Failed to update password',
              isError: true,
            );
          }
        });
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.warmRed : AppColors.tealSuccess,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
