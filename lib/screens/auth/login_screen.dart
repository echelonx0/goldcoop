// // lib/screens/auth/login_screen.dart
// // Login screen with Firebase authentication

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../components/base/app_button.dart';
// import '../../../components/base/app_text_field.dart';

// import '../../../providers/auth_provider.dart';
// import '../../core/theme/app_colors.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   late TextEditingController _emailController;
//   late TextEditingController _passwordController;
//   late FocusNode _emailFocusNode;
//   late FocusNode _passwordFocusNode;
//   bool _rememberMe = false;

//   @override
//   void initState() {
//     super.initState();
//     _emailController = TextEditingController();
//     _passwordController = TextEditingController();
//     _emailFocusNode = FocusNode();
//     _passwordFocusNode = FocusNode();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _emailFocusNode.dispose();
//     _passwordFocusNode.dispose();
//     super.dispose();
//   }

//   void _handleLogin() {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     // Validate
//     if (email.isEmpty) {
//       _showErrorSnackbar('Please enter your email');
//       return;
//     }

//     if (password.isEmpty) {
//       _showErrorSnackbar('Please enter your password');
//       return;
//     }

//     // Perform login
//     context.read<AuthProvider>().signIn(email: email, password: password).then((
//       success,
//     ) {
//       if (success) {
//         // Navigate to dashboard
//         _navigateToDashboard();
//       } else {
//         _showErrorSnackbar(
//           context.read<AuthProvider>().errorMessage ?? 'Login failed',
//         );
//       }
//     });
//   }

//   void _navigateToDashboard() {
//     // TODO: Replace with actual navigation route
//     Navigator.of(context).pushReplacementNamed('/dashboard');
//   }

//   void _navigateToSignUp() {
//     Navigator.of(context).pushNamed('/signup');
//   }

//   void _navigateToForgotPassword() {
//     Navigator.of(context).pushNamed('/password-reset');
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: AppColors.warmRed,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(AppSpacing.md),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundNeutral,
//       body: SafeArea(
//         child: Consumer<AuthProvider>(
//           builder: (context, authProvider, _) {
//             return SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppSpacing.lg,
//                 vertical: AppSpacing.lg,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   const SizedBox(height: AppSpacing.lg),
//                   Text(
//                     'Welcome Back',
//                     style: AppTextTheme.heading1.copyWith(
//                       color: AppColors.deepNavy,
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.sm),
//                   Text(
//                     'Log in to your Gold Savings account',
//                     style: AppTextTheme.bodyRegular.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.lg),

//                   // Error message (if any)
//                   if (authProvider.errorMessage != null)
//                     _buildErrorCard(authProvider.errorMessage!),
//                   const SizedBox(height: AppSpacing.lg),

//                   // Email field
//                   AppTextField(
//                     label: 'Email Address',
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     hint: 'you@example.com',
//                     focusNode: _emailFocusNode,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Email is required';
//                       }
//                       final emailRegex = RegExp(
//                         r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//                       );
//                       if (!emailRegex.hasMatch(value)) {
//                         return 'Enter a valid email address';
//                       }
//                       return null;
//                     },
//                     onSubmitted: (_) {
//                       _emailFocusNode.unfocus();
//                       FocusScope.of(context).requestFocus(_passwordFocusNode);
//                     },
//                   ),
//                   const SizedBox(height: AppSpacing.md),

//                   // Password field
//                   AppTextField(
//                     label: 'Password',
//                     controller: _passwordController,
//                     obscureText: true,
//                     hint: 'Enter your password',
//                     focusNode: _passwordFocusNode,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Password is required';
//                       }
//                       return null;
//                     },
//                     onSubmitted: (_) {
//                       _passwordFocusNode.unfocus();
//                       if (!authProvider.isLoading) {
//                         _handleLogin();
//                       }
//                     },
//                   ),
//                   const SizedBox(height: AppSpacing.md),

//                   // Remember me checkbox
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: _rememberMe,
//                         onChanged: (value) {
//                           setState(() => _rememberMe = value ?? false);
//                         },
//                         activeColor: AppColors.primaryOrange,
//                       ),
//                       Text(
//                         'Remember me',
//                         style: AppTextTheme.bodyRegular.copyWith(
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: _navigateToForgotPassword,
//                         child: Text(
//                           'Forgot password?',
//                           style: AppTextTheme.bodyRegular.copyWith(
//                             color: AppColors.primaryOrange,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: AppSpacing.lg),

//                   // Login button
//                   PrimaryButton(
//                     label: 'Log In',
//                     onPressed: authProvider.isLoading ? null : _handleLogin,
//                     isLoading: authProvider.isLoading,
//                   ),
//                   const SizedBox(height: AppSpacing.md),

//                   // Sign up link
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Don't have an account? ",
//                         style: AppTextTheme.bodyRegular.copyWith(
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: _navigateToSignUp,
//                         child: Text(
//                           'Sign Up',
//                           style: AppTextTheme.bodyRegular.copyWith(
//                             color: AppColors.primaryOrange,
//                             fontWeight: FontWeight.w600,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: AppSpacing.xl),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorCard(String errorMessage) {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.md),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFEBEE),
//         border: Border.all(color: AppColors.warmRed, width: 1),
//         borderRadius: AppBorderRadius.mediumRadius,
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: AppColors.warmRed, size: 20),
//           const SizedBox(width: AppSpacing.md),
//           Expanded(
//             child: Text(
//               errorMessage,
//               style: AppTextTheme.bodySmall.copyWith(color: AppColors.warmRed),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => context.read<AuthProvider>().clearError(),
//             child: Icon(Icons.close, color: AppColors.warmRed, size: 20),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../components/base/app_button.dart';
import '../../components/base/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
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
                            child: AuthBottomLink(
                              text: "Don't have an account? ",
                              linkText: 'Sign Up',
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/signup'),
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
