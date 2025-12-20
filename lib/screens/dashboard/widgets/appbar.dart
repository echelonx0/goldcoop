// lib/screens/dashboard/widgets/dashboard_app_bar.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../models/support_models.dart';
import '../../../services/support_service.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? user;
  final String uid;
  final SupportService supportService;
  final Function(SupportNotification, String, UserModel?) onNotificationTap;
  final VoidCallback onSettingsTap;

  const DashboardAppBar({
    super.key,
    required this.user,
    required this.uid,
    required this.supportService,
    required this.onNotificationTap,
    required this.onSettingsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      title: Text(
        user != null ? 'Welcome, ${user!.firstName}' : 'Welcome',
        style: AppTextTheme.bodyRegular.copyWith(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      actions: [
        NotificationBadge(
          userId: uid,
          supportService: supportService,
          onNotificationTap: (notification) {
            onNotificationTap(notification, uid, user);
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 22),
          color: AppColors.deepNavy,
          onPressed: onSettingsTap,
        ),
      ],
    );
  }
}

// Notification badge widget
class NotificationBadge extends StatelessWidget {
  final String userId;
  final SupportService supportService;
  final Function(SupportNotification) onNotificationTap;

  const NotificationBadge({
    super.key,
    required this.userId,
    required this.supportService,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SupportNotification>>(
      stream: supportService.getUserNotificationsStream(userId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22),
              color: AppColors.deepNavy,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _NotificationCenter(
                    userId: userId,
                    supportService: supportService,
                    onNotificationTap: onNotificationTap,
                  ),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warmRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: AppTextTheme.micro.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Notification center modal
class _NotificationCenter extends StatelessWidget {
  final String userId;
  final SupportService supportService;
  final Function(SupportNotification) onNotificationTap;

  const _NotificationCenter({
    required this.userId,
    required this.supportService,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.large),
          topRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: AppTextTheme.heading3.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SupportNotification>>(
              stream: supportService.getUserNotificationsStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  );
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No notifications',
                          style: AppTextTheme.bodyRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _NotificationTile(
                      notification: notification,
                      onTap: () {
                        onNotificationTap(notification);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final SupportNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.backgroundNeutral
                : AppColors.primaryOrange.withAlpha(12),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.borderLight
                  : AppColors.primaryOrange.withAlpha(51),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: AppTextTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
