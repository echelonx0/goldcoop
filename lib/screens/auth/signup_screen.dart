// lib/screens/auth/signup_screen.dart
// Sign up screen with multi-step form

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/base/app_button.dart';
import '../../components/base/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _phoneFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  bool _acceptTerms = false;
  bool _agreeMarketing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _handleSignup() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate all fields
    if (firstName.isEmpty) {
      _showErrorSnackbar('Please enter your first name');
      return;
    }

    if (lastName.isEmpty) {
      _showErrorSnackbar('Please enter your last name');
      return;
    }

    if (email.isEmpty) {
      _showErrorSnackbar('Please enter your email');
      return;
    }

    if (phone.isEmpty) {
      _showErrorSnackbar('Please enter your phone number');
      return;
    }

    if (password.isEmpty) {
      _showErrorSnackbar('Please enter a password');
      return;
    }

    if (password.length < 8) {
      _showErrorSnackbar('Password must be at least 8 characters');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackbar('Passwords do not match');
      return;
    }

    if (!_acceptTerms) {
      _showErrorSnackbar('Please accept the Terms and Conditions');
      return;
    }

    // Perform signup
    context
        .read<AuthProvider>()
        .signUp(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phone,
        )
        .then((success) {
          if (success) {
            _showSuccessDialog();
          } else {
            _showErrorSnackbar(
              context.read<AuthProvider>().errorMessage ?? 'Signup failed',
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.largeRadius,
        ),
        title: Text(
          'Welcome!',
          style: AppTextTheme.heading2.copyWith(color: AppColors.deepNavy),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.tealSuccess, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your account has been created successfully.',
              textAlign: TextAlign.center,
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Please verify your email to complete setup.',
              textAlign: TextAlign.center,
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Go to Login',
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.deepNavy,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Account',
          style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  if (authProvider.errorMessage != null)
                    _buildErrorCard(authProvider.errorMessage!),
                  const SizedBox(height: AppSpacing.lg),

                  // First name
                  AppTextField(
                    label: 'First Name',
                    controller: _firstNameController,
                    hint: 'John',
                    focusNode: _firstNameFocusNode,
                    required: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      if (value.length < 2) {
                        return 'First name must be at least 2 characters';
                      }
                      return null;
                    },
                    onSubmitted: (_) {
                      _firstNameFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_lastNameFocusNode);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Last name
                  AppTextField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    hint: 'Doe',
                    focusNode: _lastNameFocusNode,
                    required: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      if (value.length < 2) {
                        return 'Last name must be at least 2 characters';
                      }
                      return null;
                    },
                    onSubmitted: (_) {
                      _lastNameFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Email
                  AppTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hint: 'you@example.com',
                    focusNode: _emailFocusNode,
                    required: true,
                    validator: (value) {
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
                    },
                    onSubmitted: (_) {
                      _emailFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_phoneFocusNode);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Phone
                  AppTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    hint: '+234 123 456 7890',
                    focusNode: _phoneFocusNode,
                    required: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.length < 10) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                    onSubmitted: (_) {
                      _phoneFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Password
                  AppTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    hint: 'Create a strong password',
                    focusNode: _passwordFocusNode,
                    required: true,
                    helperText: 'Min. 8 characters, 1 uppercase, 1 number',
                    validator: (value) {
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
                    },
                    onSubmitted: (_) {
                      _passwordFocusNode.unfocus();
                      FocusScope.of(
                        context,
                      ).requestFocus(_confirmPasswordFocusNode);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Confirm password
                  AppTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    hint: 'Confirm your password',
                    focusNode: _confirmPasswordFocusNode,
                    required: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onSubmitted: (_) {
                      _confirmPasswordFocusNode.unfocus();
                      if (!authProvider.isLoading) {
                        _handleSignup();
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Terms and conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() => _acceptTerms = value ?? false);
                        },
                        activeColor: AppColors.primaryOrange,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _acceptTerms = !_acceptTerms),
                          child: RichText(
                            text: TextSpan(
                              style: AppTextTheme.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: AppTextTheme.bodySmall.copyWith(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Marketing opt-in
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeMarketing,
                        onChanged: (value) {
                          setState(() => _agreeMarketing = value ?? false);
                        },
                        activeColor: AppColors.primaryOrange,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _agreeMarketing = !_agreeMarketing,
                          ),
                          child: Text(
                            'Send me updates and promotional offers',
                            style: AppTextTheme.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Sign up button
                  PrimaryButton(
                    label: 'Create Account',
                    onPressed: authProvider.isLoading ? null : _handleSignup,
                    isLoading: authProvider.isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextTheme.bodyRegular.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/login'),
                        child: Text(
                          'Log In',
                          style: AppTextTheme.bodyRegular.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        border: Border.all(color: AppColors.warmRed, width: 1),
        borderRadius: AppBorderRadius.mediumRadius,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.warmRed, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              errorMessage,
              style: AppTextTheme.bodySmall.copyWith(color: AppColors.warmRed),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<AuthProvider>().clearError(),
            child: Icon(Icons.close, color: AppColors.warmRed, size: 20),
          ),
        ],
      ),
    );
  }
}
