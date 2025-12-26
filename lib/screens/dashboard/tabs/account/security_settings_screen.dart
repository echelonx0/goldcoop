// lib/screens/dashboard/tabs/account/security_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../components/base/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import 'controllers/security_settings_controller.dart';
import 'widgets/security_setting_item.dart';

class SecuritySettingsScreen extends StatefulWidget {
  final String userId;

  const SecuritySettingsScreen({super.key, required this.userId});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  late SecuritySettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SecuritySettingsController(widget.userId);
    _controller.loadSettings();
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
          'Security',
          style: AppTextTheme.heading3.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'Protect your account with additional security measures',
                        style: AppTextTheme.bodyRegular.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Two-factor authentication
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 200),
                      child: _buildSection('Two-Factor Authentication', [
                        SecuritySettingItem(
                          icon: Icons.phone_android,
                          title: 'SMS Authentication',
                          subtitle: _controller.settings.smsAuth
                              ? 'Enabled via ${_controller.settings.phoneNumber}'
                              : 'Add an extra layer of security',
                          isEnabled: _controller.settings.smsAuth,
                          onToggle: (value) => _showSMSAuthDialog(value),
                        ),
                        SecuritySettingItem(
                          icon: Icons.email_outlined,
                          title: 'Email Authentication',
                          subtitle: _controller.settings.emailAuth
                              ? 'Enabled via email'
                              : 'Verify login attempts via email',
                          isEnabled: _controller.settings.emailAuth,
                          onToggle: (value) =>
                              _controller.toggleEmailAuth(value),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Login security
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 300),
                      child: _buildSection('Login Security', [
                        SecuritySettingItem(
                          icon: Icons.fingerprint,
                          title: 'Biometric Login',
                          subtitle: 'Use fingerprint or face recognition',
                          isEnabled: _controller.settings.biometric,
                          onToggle: (value) =>
                              _controller.toggleBiometric(value),
                        ),
                        SecuritySettingItem(
                          icon: Icons.location_on_outlined,
                          title: 'Login Location Tracking',
                          subtitle: 'Track where your account is accessed',
                          isEnabled: _controller.settings.locationTracking,
                          onToggle: (value) =>
                              _controller.toggleLocationTracking(value),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Active sessions
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 400),
                      child: _buildActiveSessions(),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextTheme.heading3.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StandardCard(
          child: Column(
            children: items
                .expand(
                  (item) => [
                    item,
                    if (item != items.last)
                      Divider(
                        color: AppColors.backgroundNeutral,
                        height: 1,
                        thickness: 1,
                      ),
                  ],
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Active Sessions',
                style: AppTextTheme.heading3.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Flexible(
              child: TextButton(
                onPressed: _controller.logoutAllSessions,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
                child: Text(
                  'Logout All',
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.warmRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StandardCard(
          child: Column(
            children: [
              _buildSessionItem('Current Device', 'Active now', true),
              if (_controller.settings.activeSessions.isNotEmpty)
                Divider(
                  color: AppColors.backgroundNeutral,
                  height: 1,
                  thickness: 1,
                ),
              ..._controller.settings.activeSessions.map(
                (session) => _buildSessionItem(
                  session['device'] ?? 'Unknown Device',
                  session['lastActive'] ?? 'Recently',
                  false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionItem(String device, String time, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.devices,
              color: AppColors.primaryOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device,
                        style: AppTextTheme.bodyRegular.copyWith(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tealSuccess.withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            color: AppColors.tealSuccess,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSMSAuthDialog(bool enable) {
    if (enable) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.largeRadius,
          ),
          title: Text(
            'Enable SMS Authentication',
            style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
          ),
          content: Text(
            'You\'ll receive a verification code via SMS when logging in from a new device.',
            style: AppTextTheme.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextTheme.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _controller.toggleSMSAuth(true);
                _showSnackbar('SMS authentication enabled');
              },
              child: Text(
                'Enable',
                style: AppTextTheme.bodyRegular.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      _controller.toggleSMSAuth(false);
      _showSnackbar('SMS authentication disabled');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.tealSuccess,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
