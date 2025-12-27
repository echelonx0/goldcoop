// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../components/base/app_button.dart';
import '../../components/base/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/onboarding_service.dart';
import 'components/auth_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _showOnboardingOption() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Icon(Icons.info_outline, size: 48, color: AppColors.primaryOrange),
            const SizedBox(height: AppSpacing.md),
            Text(
              'View Onboarding?',
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'See the app tour again to learn about features.',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextTheme.bodyRegular.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await OnboardingService.resetOnboarding();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed('/onboarding');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'View Tour',
                      style: AppTextTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showErrorSnackbar('Please enter your email');
      return;
    }

    if (password.isEmpty) {
      _showErrorSnackbar('Please enter your password');
      return;
    }

    context.read<AuthProvider>().signIn(email: email, password: password).then((
      success,
    ) {
      if (success) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        _showErrorSnackbar(
          context.read<AuthProvider>().errorMessage ?? 'Login failed',
        );
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warmRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: Stack(
        children: [
          const AuthBackgroundGradient(),
          SafeArea(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: AppSpacing.xxl),

                          // Hero section
                          const AuthHero(
                            icon: Icons.login_rounded,
                            title: 'Welcome Back',
                            subtitle:
                                'We are glad you are part of our community.',
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Error card
                          if (authProvider.errorMessage != null) ...[
                            AuthErrorCard(
                              message: authProvider.errorMessage!,
                              onDismiss: () =>
                                  context.read<AuthProvider>().clearError(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],

                          // Email field
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 400),
                            child: AppTextField(
                              label: 'Email Address',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              hint: 'you@example.com',
                              focusNode: _emailFocusNode,
                              prefixIcon: Icon(Icons.email_outlined),
                              onSubmitted: (_) {
                                _emailFocusNode.unfocus();
                                FocusScope.of(
                                  context,
                                ).requestFocus(_passwordFocusNode);
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Password field
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 500),
                            child: AppTextField(
                              label: 'Password',
                              controller: _passwordController,
                              obscureText: true,
                              hint: 'Enter your password',
                              focusNode: _passwordFocusNode,
                              prefixIcon: Icon(Icons.lock_outline),
                              onSubmitted: (_) {
                                _passwordFocusNode.unfocus();
                                if (!authProvider.isLoading) _handleLogin();
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Remember me & Forgot password
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 600),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) => setState(
                                      () => _rememberMe = value ?? false,
                                    ),
                                    activeColor: AppColors.primaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _rememberMe = !_rememberMe,
                                  ),
                                  child: Text(
                                    'Remember me',
                                    style: AppTextTheme.bodyRegular.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed('/password-reset'),
                                  child: Text(
                                    'Forgot password?',
                                    style: AppTextTheme.bodyRegular.copyWith(
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Login button
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 700),
                            child: PrimaryButton(
                              label: 'Log In',
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _handleLogin,
                              isLoading: authProvider.isLoading,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Sign up link
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 800),
                            child: Column(
                              children: [
                                AuthBottomLink(
                                  text: "Don't have an account? ",
                                  linkText: 'Sign Up',
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed('/signup'),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                GestureDetector(
                                  onTap: _showOnboardingOption,
                                  child: Text(
                                    'New here? View app tour',
                                    style: AppTextTheme.bodySmall.copyWith(
                                      color: AppColors.textTertiary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
