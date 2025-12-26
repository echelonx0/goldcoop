// lib/screens/dashboard/tabs/account/notification_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../components/base/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import 'controllers/notification_settings_controller.dart';
import 'widgets/notification_toggle_item.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final String userId;

  const NotificationSettingsScreen({super.key, required this.userId});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationSettingsController(widget.userId);
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
          'Notifications',
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
                        'Manage your notification preferences',
                        style: AppTextTheme.bodyRegular.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Transaction notifications
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 200),
                      child: _buildSection('Transaction Updates', [
                        NotificationToggleItem(
                          title: 'Deposits',
                          subtitle: 'Get notified when deposits are processed',
                          value: _controller.settings.deposits,
                          onChanged: (value) =>
                              _controller.updateSetting('deposits', value),
                        ),
                        NotificationToggleItem(
                          title: 'Withdrawals',
                          subtitle:
                              'Get notified when withdrawals are approved',
                          value: _controller.settings.withdrawals,
                          onChanged: (value) =>
                              _controller.updateSetting('withdrawals', value),
                        ),
                        NotificationToggleItem(
                          title: 'Investments',
                          subtitle: 'Updates on your investment contributions',
                          value: _controller.settings.investments,
                          onChanged: (value) =>
                              _controller.updateSetting('investments', value),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Account notifications
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 300),
                      child: _buildSection('Account Activity', [
                        NotificationToggleItem(
                          title: 'Security Alerts',
                          subtitle: 'Login attempts and security changes',
                          value: _controller.settings.security,
                          onChanged: (value) =>
                              _controller.updateSetting('security', value),
                        ),
                        NotificationToggleItem(
                          title: 'KYC Updates',
                          subtitle: 'Verification status changes',
                          value: _controller.settings.kyc,
                          onChanged: (value) =>
                              _controller.updateSetting('kyc', value),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Goals notifications
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 400),
                      child: _buildSection('Savings Goals', [
                        NotificationToggleItem(
                          title: 'Goal Milestones',
                          subtitle: 'Celebrate when you reach milestones',
                          value: _controller.settings.goalMilestones,
                          onChanged: (value) => _controller.updateSetting(
                            'goalMilestones',
                            value,
                          ),
                        ),
                        NotificationToggleItem(
                          title: 'Goal Reminders',
                          subtitle: 'Reminders to contribute to your goals',
                          value: _controller.settings.goalReminders,
                          onChanged: (value) =>
                              _controller.updateSetting('goalReminders', value),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Marketing notifications
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 500),
                      child: _buildSection('Marketing', [
                        NotificationToggleItem(
                          title: 'Promotions & Offers',
                          subtitle: 'Special offers and promotions',
                          value: _controller.settings.promotions,
                          onChanged: (value) =>
                              _controller.updateSetting('promotions', value),
                        ),
                        NotificationToggleItem(
                          title: 'Product Updates',
                          subtitle: 'New features and improvements',
                          value: _controller.settings.productUpdates,
                          onChanged: (value) => _controller.updateSetting(
                            'productUpdates',
                            value,
                          ),
                        ),
                        NotificationToggleItem(
                          title: 'Newsletter',
                          subtitle: 'Weekly newsletter via email',
                          value: _controller.settings.newsletter,
                          onChanged: (value) =>
                              _controller.updateSetting('newsletter', value),
                        ),
                      ]),
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
}
