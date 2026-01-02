// lib/screens/admin/dashboard/widgets/admin_app_bar.dart

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../services/admin_support_service.dart';
import '../../../support/admin_support_inbox.dart';
import '../../sections/admin_faq_manager.dart';
import '../../widgets/learning_center_submissions_widget.dart';

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
        'Admin',
        style: AdminDesignSystem.headingMedium.copyWith(
          color: AdminDesignSystem.primaryNavy,
        ),
      ),
      actions: [
        // Learning Center
        IconButton(
          icon: const Icon(Icons.school_outlined, size: 24),
          onPressed: () => _navigateToLearningCenter(context),
          color: AdminDesignSystem.primaryNavy,
          tooltip: 'Learning Center',
        ),
        const SizedBox(width: AdminDesignSystem.spacing4),

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
                    tooltip: 'Support Inbox',
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
          tooltip: 'FAQ Manager',
        ),
        const SizedBox(width: AdminDesignSystem.spacing8),
      ],
    );
  }

  void _navigateToLearningCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLearningCenterScreen()),
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

class AdminLearningCenterScreen extends StatelessWidget {
  const AdminLearningCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AdminDesignSystem.cardBackground,
        elevation: 0,
        title: Text(
          'Learning Center',
          style: AdminDesignSystem.headingMedium.copyWith(
            color: AdminDesignSystem.primaryNavy,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AdminDesignSystem.primaryNavy,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        child: DelayedDisplay(
          delay: const Duration(milliseconds: 100),
          child: const LearningCenterSubmissionsWidget(),
        ),
      ),
    );
  }
}
