// lib/widgets/auth_options_modal.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../core/theme/app_colors.dart';

class AuthOptionsModal extends StatelessWidget {
  const AuthOptionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: DelayedDisplay(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 250),
                    slidingBeginOffset: const Offset(0.0, 0.2),
                    child: Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 300),
                    slidingBeginOffset: const Offset(0.0, 0.2),
                    child: Text(
                      'Continue to your account or create a new one',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 400),
                    slidingBeginOffset: const Offset(0.0, 0.15),
                    child: _buildOptionButton(
                      context: context,
                      icon: Icons.login_rounded,
                      title: 'Login',
                      subtitle: 'Access your existing account',
                      accentColor: AppColors.primaryOrange,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Register Button
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 500),
                    slidingBeginOffset: const Offset(0.0, 0.15),
                    child: _buildOptionButton(
                      context: context,
                      icon: Icons.person_add_rounded,
                      title: 'Create Account',
                      subtitle: 'Join Gold Savings today',
                      accentColor: AppColors.tealSuccess,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/signup');
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 550),
                    child: Divider(color: AppColors.borderLight, height: 1),
                  ),
                  const SizedBox(height: 16),

                  // Forgot Password
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 600),
                    slidingBeginOffset: const Offset(0.0, 0.15),
                    child: _buildForgotPasswordButton(context: context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Icon with background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton({required BuildContext context}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/forgot-password');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: AppColors.primaryOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Reset your password',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the modal
void showAuthOptionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const AuthOptionsModal(),
  );
}
