// lib/screens/admin/dashboard/widgets/admin_app_bar.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../services/admin_support_service.dart';
import '../../../support/admin_support_inbox.dart';
import '../../sections/admin_faq_manager.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String adminId;
  final String adminName;
  final String adminAvatar;
  final AdminSupportService adminSupportService;

  const AdminAppBar({
    super.key,
    required this.adminId,
    required this.adminName,
    required this.adminAvatar,
    required this.adminSupportService,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AdminDesignSystem.cardBackground,
      elevation: 0,

      title: Text(
        'Admin Dashboard',
        style: AdminDesignSystem.headingLarge.copyWith(
          color: AdminDesignSystem.primaryNavy,
        ),
      ),
      actions: [
        // Support Inbox Badge
        StreamBuilder<int>(
          stream: adminSupportService.getUnreadTicketCountStream(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            return Padding(
              padding: const EdgeInsets.only(right: AdminDesignSystem.spacing8),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.support_agent, size: 22),
                    onPressed: () => _navigateToSupportInbox(context),
                    color: AdminDesignSystem.primaryNavy,
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
              ),
            );
          },
        ),

        // FAQ Manager
        IconButton(
          icon: const Icon(Icons.help_outline, size: 22),
          onPressed: () => _navigateToFAQManager(context),
          color: AdminDesignSystem.primaryNavy,
        ),
        const SizedBox(width: AdminDesignSystem.spacing8),
      ],
    );
  }

  void _navigateToSupportInbox(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSupportInbox(
          adminId: adminId,
          adminName: adminName,
          adminAvatar: adminAvatar,
        ),
      ),
    );
  }

  void _navigateToFAQManager(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminFAQManager()),
    );
  }
}
