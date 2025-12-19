// lib/screens/support/notification_center_complete.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../core/theme/admin_design_system.dart';
import '../../models/support_models.dart';
import '../../services/support_service.dart';

class NotificationCenter extends StatefulWidget {
  final String userId;
  final Function(SupportNotification)? onNotificationTap;

  const NotificationCenter({
    super.key,
    required this.userId,
    this.onNotificationTap,
  });

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  late final SupportService _supportService;

  @override
  void initState() {
    super.initState();
    _supportService = SupportService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      appBar: _buildAppBar(),
      body: _buildNotificationsList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AdminDesignSystem.cardBackground,
      elevation: 0,
      title: Text(
        'Notifications',
        style: AdminDesignSystem.headingMedium.copyWith(
          color: AdminDesignSystem.primaryNavy,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AdminDesignSystem.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<List<SupportNotification>>(
      stream: _supportService.getUserNotificationsStream(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
          itemCount: notifications.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AdminDesignSystem.spacing12),
          itemBuilder: (context, index) {
            return DelayedDisplay(
              delay: Duration(milliseconds: 100 * (index + 1)),
              child: _NotificationItem(
                notification: notifications[index],
                onTap: () {
                  widget.onNotificationTap?.call(notifications[index]);
                  _supportService.markNotificationAsRead(
                    notifications[index].notificationId,
                  );
                },
                onDelete: () {
                  _supportService.deleteNotification(
                    notifications[index].notificationId,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Icon(
              Icons.notifications_none,
              size: 48,
              color: AdminDesignSystem.textTertiary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'No notifications',
              style: AdminDesignSystem.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AdminDesignSystem.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'You\'re all caught up!',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== NOTIFICATION ITEM ====================

class _NotificationItem extends StatelessWidget {
  final SupportNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _NotificationItem({
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead
              ? AdminDesignSystem.cardBackground
              : AdminDesignSystem.accentTeal.withAlpha(12),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(
            color: notification.isRead
                ? AdminDesignSystem.divider
                : AdminDesignSystem.accentTeal.withAlpha(50),
          ),
        ),
        padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withAlpha(25),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: AdminDesignSystem.spacing12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AdminDesignSystem.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AdminDesignSystem.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AdminDesignSystem.accentTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing4),
                  Text(
                    notification.body,
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: AdminDesignSystem.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Delete button
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: AdminDesignSystem.textTertiary,
                ),
                padding: EdgeInsets.zero,
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.faqHelpful:
        return AdminDesignSystem.statusActive;
      case NotificationType.ticketUpdate:
        return AdminDesignSystem.accentTeal;
      case NotificationType.messageReceived:
        return const Color(0xFFF39C12);
      case NotificationType.ticketResolved:
        return AdminDesignSystem.statusActive;
      case NotificationType.newTicketAssigned:
        return const Color(0xFF3498DB);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.faqHelpful:
        return Icons.check_circle_outline;
      case NotificationType.ticketUpdate:
        return Icons.update;
      case NotificationType.messageReceived:
        return Icons.chat_bubble_outline;
      case NotificationType.ticketResolved:
        return Icons.done_all;
      case NotificationType.newTicketAssigned:
        return Icons.assignment;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

// ==================== NOTIFICATION BADGE ====================

class NotificationBadge extends StatelessWidget {
  final String userId;
  final SupportService supportService;
  final Function(SupportNotification)? onNotificationTap;

  const NotificationBadge({
    super.key,
    required this.userId,
    required this.supportService,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: supportService.getUnreadNotificationCount(userId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22),
              color: AdminDesignSystem.textPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationCenter(
                      userId: userId,
                      onNotificationTap: onNotificationTap,
                    ),
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
                    color: AdminDesignSystem.statusError,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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

// ==================== NOTIFICATION PANEL ====================

class NotificationPanel extends StatelessWidget {
  final String userId;
  final SupportService supportService;
  final Function(SupportNotification)? onNotificationTap;

  const NotificationPanel({
    super.key,
    required this.userId,
    required this.supportService,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SupportNotification>>(
      stream: supportService.getUserNotificationsStream(userId),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final unreadNotifications = notifications
            .where((n) => !n.isRead)
            .toList();

        if (unreadNotifications.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(AdminDesignSystem.spacing12),
          decoration: BoxDecoration(
            color: AdminDesignSystem.cardBackground,
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            border: Border.all(color: AdminDesignSystem.divider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Notifications (${unreadNotifications.length})',
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AdminDesignSystem.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationCenter(userId: userId),
                        ),
                      ),
                      child: Text(
                        'View all',
                        style: AdminDesignSystem.bodySmall.copyWith(
                          color: AdminDesignSystem.accentTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: unreadNotifications.take(3).length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AdminDesignSystem.divider),
                itemBuilder: (context, index) {
                  final notification = unreadNotifications[index];
                  return GestureDetector(
                    onTap: () {
                      onNotificationTap?.call(notification);
                      supportService.markNotificationAsRead(
                        notification.notificationId,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AdminDesignSystem.spacing12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getNotificationIcon(notification.type),
                            size: 18,
                            color: _getNotificationColor(notification.type),
                          ),
                          const SizedBox(width: AdminDesignSystem.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: AdminDesignSystem.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AdminDesignSystem.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  notification.body,
                                  style: AdminDesignSystem.labelSmall.copyWith(
                                    color: AdminDesignSystem.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.faqHelpful:
        return AdminDesignSystem.statusActive;
      case NotificationType.ticketUpdate:
        return AdminDesignSystem.accentTeal;
      case NotificationType.messageReceived:
        return const Color(0xFFF39C12);
      case NotificationType.ticketResolved:
        return AdminDesignSystem.statusActive;
      case NotificationType.newTicketAssigned:
        return const Color(0xFF3498DB);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.faqHelpful:
        return Icons.check_circle_outline;
      case NotificationType.ticketUpdate:
        return Icons.update;
      case NotificationType.messageReceived:
        return Icons.chat_bubble_outline;
      case NotificationType.ticketResolved:
        return Icons.done_all;
      case NotificationType.newTicketAssigned:
        return Icons.assignment;
    }
  }
}
