// // lib/screens/auth/password_reset_screen.dart
// // Password reset flow with email verification

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../components/base/app_button.dart';
// import '../../components/base/app_text_field.dart';
// import '../../core/theme/app_colors.dart';
// import '../../providers/auth_provider.dart';

// class PasswordResetScreen extends StatefulWidget {
//   const PasswordResetScreen({super.key});

//   @override
//   State<PasswordResetScreen> createState() => _PasswordResetScreenState();
// }

// class _PasswordResetScreenState extends State<PasswordResetScreen> {
//   late TextEditingController _emailController;
//   late FocusNode _emailFocusNode;
//   bool _emailSent = false;

//   @override
//   void initState() {
//     super.initState();
//     _emailController = TextEditingController();
//     _emailFocusNode = FocusNode();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _emailFocusNode.dispose();
//     super.dispose();
//   }

//   void _handlePasswordReset() {
//     final email = _emailController.text.trim();

//     // Validate
//     if (email.isEmpty) {
//       _showErrorSnackbar('Please enter your email address');
//       return;
//     }

//     final emailRegex = RegExp(
//       r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//     );
//     if (!emailRegex.hasMatch(email)) {
//       _showErrorSnackbar('Enter a valid email address');
//       return;
//     }

//     // Send reset email
//     context.read<AuthProvider>().sendPasswordResetEmail(email: email).then((
//       success,
//     ) {
//       if (success) {
//         setState(() => _emailSent = true);
//       } else {
//         _showErrorSnackbar(
//           context.read<AuthProvider>().errorMessage ??
//               'Failed to send reset email',
//         );
//       }
//     });
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

//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: AppColors.tealSuccess,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(AppSpacing.md),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundNeutral,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundWhite,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           color: AppColors.deepNavy,
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Reset Password',
//           style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
//         ),
//       ),
//       body: SafeArea(
//         child: Consumer<AuthProvider>(
//           builder: (context, authProvider, _) {
//             return SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppSpacing.lg,
//                 vertical: AppSpacing.lg,
//               ),
//               child: _emailSent
//                   ? _buildSuccessState()
//                   : _buildResetForm(authProvider),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildResetForm(AuthProvider authProvider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header
//         const SizedBox(height: AppSpacing.lg),
//         Text(
//           'Forgot Your Password?',
//           style: AppTextTheme.heading1.copyWith(color: AppColors.deepNavy),
//         ),
//         const SizedBox(height: AppSpacing.sm),
//         Text(
//           'Enter your email address and we\'ll send you a link to reset your password.',
//           style: AppTextTheme.bodyRegular.copyWith(
//             color: AppColors.textSecondary,
//           ),
//         ),
//         const SizedBox(height: AppSpacing.lg),

//         // Error message
//         if (authProvider.errorMessage != null)
//           Column(
//             children: [
//               _buildErrorCard(authProvider.errorMessage!),
//               const SizedBox(height: AppSpacing.lg),
//             ],
//           ),

//         // Email field
//         AppTextField(
//           label: 'Email Address',
//           controller: _emailController,
//           keyboardType: TextInputType.emailAddress,
//           hint: 'you@example.com',
//           focusNode: _emailFocusNode,
//           required: true,
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Email is required';
//             }
//             final emailRegex = RegExp(
//               r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//             );
//             if (!emailRegex.hasMatch(value)) {
//               return 'Enter a valid email address';
//             }
//             return null;
//           },
//           onSubmitted: (_) {
//             _emailFocusNode.unfocus();
//             if (!authProvider.isLoading) {
//               _handlePasswordReset();
//             }
//           },
//         ),
//         const SizedBox(height: AppSpacing.lg),

//         // Info box
//         Container(
//           padding: const EdgeInsets.all(AppSpacing.md),
//           decoration: BoxDecoration(
//             color: const Color(0xFFE3F2FD),
//             border: Border.all(color: AppColors.info, width: 1),
//             borderRadius: AppBorderRadius.mediumRadius,
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(Icons.info_outline, color: AppColors.info, size: 20),
//               const SizedBox(width: AppSpacing.md),
//               Expanded(
//                 child: Text(
//                   'Check your spam folder if you don\'t see the email.',
//                   style: AppTextTheme.bodySmall.copyWith(color: AppColors.info),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: AppSpacing.lg),

//         // Reset button
//         PrimaryButton(
//           label: 'Send Reset Link',
//           onPressed: authProvider.isLoading ? null : _handlePasswordReset,
//           isLoading: authProvider.isLoading,
//         ),
//         const SizedBox(height: AppSpacing.md),

//         // Back to login link
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Remember your password? ',
//               style: AppTextTheme.bodyRegular.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             GestureDetector(
//               onTap: () => Navigator.of(context).pop(),
//               child: Text(
//                 'Back to Login',
//                 style: AppTextTheme.bodyRegular.copyWith(
//                   color: AppColors.primaryOrange,
//                   fontWeight: FontWeight.w600,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: AppSpacing.xl),
//       ],
//     );
//   }

//   Widget _buildSuccessState() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const SizedBox(height: AppSpacing.xl),

//         // Success icon
//         Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             color: AppColors.primaryOrangeLighter,
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             Icons.mail_outline,
//             color: AppColors.primaryOrange,
//             size: 40,
//           ),
//         ),
//         const SizedBox(height: AppSpacing.lg),

//         // Success title
//         Text(
//           'Check Your Email',
//           style: AppTextTheme.heading2.copyWith(color: AppColors.deepNavy),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: AppSpacing.sm),

//         // Success description
//         Text(
//           'We\'ve sent a password reset link to:',
//           style: AppTextTheme.bodyRegular.copyWith(
//             color: AppColors.textSecondary,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: AppSpacing.sm),

//         Text(
//           _emailController.text,
//           style: AppTextTheme.bodyLarge.copyWith(
//             color: AppColors.deepNavy,
//             fontWeight: FontWeight.w600,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: AppSpacing.lg),

//         // Instructions
//         Container(
//           padding: const EdgeInsets.all(AppSpacing.md),
//           decoration: BoxDecoration(
//             color: AppColors.backgroundWhite,
//             border: Border.all(color: AppColors.borderLight, width: 1),
//             borderRadius: AppBorderRadius.mediumRadius,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'What\'s next?',
//                 style: AppTextTheme.heading3.copyWith(
//                   color: AppColors.deepNavy,
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               Text(
//                 '1. Click the link in the email\n'
//                 '2. Enter your new password\n'
//                 '3. Log in with your new password',
//                 style: AppTextTheme.bodySmall.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: AppSpacing.xl),

//         // Note about spam
//         Text(
//           'Didn\'t receive the email? Check your spam folder or ',
//           style: AppTextTheme.bodySmall.copyWith(
//             color: AppColors.textSecondary,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         GestureDetector(
//           onTap: () {
//             setState(() => _emailSent = false);
//             _showSuccessSnackbar('Reset link sent to ${_emailController.text}');
//           },
//           child: Text(
//             'send again',
//             style: AppTextTheme.bodySmall.copyWith(
//               color: AppColors.primaryOrange,
//               fontWeight: FontWeight.w600,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ),
//         const SizedBox(height: AppSpacing.xl),

//         // Back to login button
//         SizedBox(
//           width: double.infinity,
//           child: SecondaryButton(
//             label: 'Back to Login',
//             onPressed: () =>
//                 Navigator.of(context).pushReplacementNamed('/login'),
//           ),
//         ),

//         const SizedBox(height: AppSpacing.xl),
//       ],
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
// lib/screens/auth/password_reset_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../components/base/app_button.dart';
import '../../components/base/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'components/auth_components.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  late TextEditingController _emailController;
  late FocusNode _emailFocusNode;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _handlePasswordReset() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorSnackbar('Please enter your email address');
      return;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      _showErrorSnackbar('Enter a valid email address');
      return;
    }

    context.read<AuthProvider>().sendPasswordResetEmail(email: email).then((
      success,
    ) {
      if (success) {
        setState(() => _emailSent = true);
      } else {
        _showErrorSnackbar(
          context.read<AuthProvider>().errorMessage ??
              'Failed to send reset email',
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
      appBar: _emailSent
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.deepNavy,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
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
                          _emailSent
                              ? _buildSuccessState()
                              : _buildResetForm(authProvider),
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

  Widget _buildResetForm(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),

        // Hero section
        const AuthHero(
          icon: Icons.key_rounded,
          title: 'Reset Password',
          subtitle:
              'Enter your email and we\'ll send you a link to reset your password',
          iconColor: AppColors.info,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Error card
        if (authProvider.errorMessage != null) ...[
          AuthErrorCard(
            message: authProvider.errorMessage!,
            onDismiss: () => context.read<AuthProvider>().clearError(),
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
              if (!authProvider.isLoading) _handlePasswordReset();
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Info box
        DelayedDisplay(
          delay: const Duration(milliseconds: 500),
          child: const AuthInfoBox(
            message:
                'Check your spam folder if you don\'t see the email within a few minutes.',
            icon: Icons.info_outline,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Reset button
        DelayedDisplay(
          delay: const Duration(milliseconds: 600),
          child: PrimaryButton(
            label: 'Send Reset Link',
            onPressed: authProvider.isLoading ? null : _handlePasswordReset,
            isLoading: authProvider.isLoading,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Back to login link
        DelayedDisplay(
          delay: const Duration(milliseconds: 700),
          child: AuthBottomLink(
            text: 'Remember your password? ',
            linkText: 'Back to Login',
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildSuccessState() {
    return AuthSuccessState(
      title: 'Check Your Email',
      subtitle: 'We\'ve sent a password reset link to:',
      email: _emailController.text,
      buttonLabel: 'Back to Login',
      onButtonPressed: () =>
          Navigator.of(context).pushReplacementNamed('/login'),
      additionalContent: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              border: Border.all(color: AppColors.borderLight, width: 1),
              borderRadius: AppBorderRadius.mediumRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.checklist_rounded,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'What\'s next?',
                      style: AppTextTheme.bodyLarge.copyWith(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildStep('1', 'Click the link in your email'),
                const SizedBox(height: AppSpacing.sm),
                _buildStep('2', 'Enter your new password'),
                const SizedBox(height: AppSpacing.sm),
                _buildStep('3', 'Log in with your new credentials'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Didn\'t receive the email? ',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _emailSent = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reset link sent to ${_emailController.text}',
                      ),
                      backgroundColor: AppColors.tealSuccess,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Send again',
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
