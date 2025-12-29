// import 'package:flutter/material.dart';
// import 'package:delayed_display/delayed_display.dart';
// import '../../../../core/theme/admin_design_system.dart';
// import '../../../../services/admin_support_service.dart';
// import '../../../support/admin_support_inbox.dart';
// import '../../sections/admin_faq_manager.dart';
// import '../../widgets/learning_center_submissions_widget.dart';

// class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String adminId;
//   final String adminName;
//   final String adminAvatar;
//   final AdminSupportService adminSupportService;

//   const AdminAppBar({
//     super.key,
//     required this.adminId,
//     required this.adminName,
//     required this.adminAvatar,
//     required this.adminSupportService,
//   });

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: AdminDesignSystem.cardBackground,
//       elevation: 0,
//       title: Text(
//         'Admin',
//         style: AdminDesignSystem.headingMedium.copyWith(
//           color: AdminDesignSystem.primaryNavy,
//         ),
//       ),
//       actions: [
//         // Menu Icon (Admin Widgets)
//         IconButton(
//           icon: const Icon(Icons.menu, size: 24),
//           onPressed: () => _showAdminWidgetsModal(context),
//           color: AdminDesignSystem.primaryNavy,
//           tooltip: 'Admin Tools',
//         ),
//         const SizedBox(width: AdminDesignSystem.spacing4),

//         // Support Inbox Badge
//         StreamBuilder<int>(
//           stream: adminSupportService.getUnreadTicketCountStream(),
//           builder: (context, snapshot) {
//             final unreadCount = snapshot.data ?? 0;
//             return Padding(
//               padding: const EdgeInsets.only(right: AdminDesignSystem.spacing8),
//               child: Stack(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.support_agent, size: 22),
//                     onPressed: () => _navigateToSupportInbox(context),
//                     color: AdminDesignSystem.primaryNavy,
//                     tooltip: 'Support Inbox',
//                   ),
//                   if (unreadCount > 0)
//                     Positioned(
//                       right: 8,
//                       top: 8,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 6,
//                           vertical: 2,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AdminDesignSystem.statusError,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           unreadCount > 9 ? '9+' : '$unreadCount',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),

//         // FAQ Manager
//         IconButton(
//           icon: const Icon(Icons.help_outline, size: 22),
//           onPressed: () => _navigateToFAQManager(context),
//           color: AdminDesignSystem.primaryNavy,
//           tooltip: 'FAQ Manager',
//         ),
//         const SizedBox(width: AdminDesignSystem.spacing8),
//       ],
//     );
//   }

//   void _showAdminWidgetsModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(AdminDesignSystem.radius24),
//         ),
//       ),
//       builder: (context) =>
//           AdminWidgetsBottomSheet(adminId: adminId, adminName: adminName),
//     );
//   }

//   void _navigateToSupportInbox(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AdminSupportInbox(
//           adminId: adminId,
//           adminName: adminName,
//           adminAvatar: adminAvatar,
//         ),
//       ),
//     );
//   }

//   void _navigateToFAQManager(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AdminFAQManager()),
//     );
//   }
// }

// // ==================== ADMIN WIDGETS BOTTOM SHEET ====================

// class AdminWidgetsBottomSheet extends StatefulWidget {
//   final String adminId;
//   final String adminName;

//   const AdminWidgetsBottomSheet({
//     super.key,
//     required this.adminId,
//     required this.adminName,
//   });

//   @override
//   State<AdminWidgetsBottomSheet> createState() =>
//       _AdminWidgetsBottomSheetState();
// }

// class _AdminWidgetsBottomSheetState extends State<AdminWidgetsBottomSheet> {
//   int _selectedTabIndex = 0;

//   final List<_AdminTab> _tabs = [
//     _AdminTab(
//       id: 'learning_center',
//       label: 'Learning Center',
//       icon: Icons.school_outlined,
//     ),
//     _AdminTab(id: 'users', label: 'Users', icon: Icons.people_outline),
//     _AdminTab(id: 'investments', label: 'Investments', icon: Icons.trending_up),
//     _AdminTab(id: 'transactions', label: 'Transactions', icon: Icons.payment),
//     _AdminTab(
//       id: 'support',
//       label: 'Support Tickets',
//       icon: Icons.support_agent,
//     ),
//     _AdminTab(
//       id: 'analytics',
//       label: 'Analytics',
//       icon: Icons.analytics_outlined,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;

//     return Container(
//       height: height * 0.65,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(AdminDesignSystem.radius24),
//         ),
//       ),
//       child: Column(
//         children: [
//           _buildHandle(),
//           Expanded(
//             child: Column(
//               children: [
//                 _buildTabBar(),
//                 const SizedBox(height: AdminDesignSystem.spacing12),
//                 Expanded(child: _buildTabContent()),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHandle() {
//     return Container(
//       margin: const EdgeInsets.only(top: AdminDesignSystem.spacing12),
//       width: 40,
//       height: 4,
//       decoration: BoxDecoration(
//         color: AdminDesignSystem.textTertiary.withAlpha(77),
//         borderRadius: BorderRadius.circular(2),
//       ),
//     );
//   }

//   Widget _buildTabBar() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.symmetric(
//         horizontal: AdminDesignSystem.spacing16,
//       ),
//       child: Row(
//         children: List.generate(
//           _tabs.length,
//           (index) => DelayedDisplay(
//             delay: Duration(milliseconds: 100 + (index * 50)),
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 right: AdminDesignSystem.spacing12,
//               ),
//               child: _buildTabButton(index),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabButton(int index) {
//     final isSelected = _selectedTabIndex == index;
//     final tab = _tabs[index];

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => setState(() => _selectedTabIndex = index),
//         borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeOutCubic,
//           padding: const EdgeInsets.symmetric(
//             horizontal: AdminDesignSystem.spacing16,
//             vertical: AdminDesignSystem.spacing12,
//           ),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? AdminDesignSystem.accentTeal.withAlpha(26)
//                 : AdminDesignSystem.background,
//             borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//             border: Border.all(
//               color: isSelected
//                   ? AdminDesignSystem.accentTeal
//                   : AdminDesignSystem.divider,
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 tab.icon,
//                 size: 18,
//                 color: isSelected
//                     ? AdminDesignSystem.accentTeal
//                     : AdminDesignSystem.textSecondary,
//               ),
//               const SizedBox(width: AdminDesignSystem.spacing8),
//               Text(
//                 tab.label,
//                 style: AdminDesignSystem.labelMedium.copyWith(
//                   color: isSelected
//                       ? AdminDesignSystem.accentTeal
//                       : AdminDesignSystem.textSecondary,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent() {
//     return DelayedDisplay(
//       delay: const Duration(milliseconds: 300),
//       child: _getTabWidget(_tabs[_selectedTabIndex].id),
//     );
//   }

//   Widget _getTabWidget(String tabId) {
//     switch (tabId) {
//       case 'learning_center':
//         return const Padding(
//           padding: EdgeInsets.all(AdminDesignSystem.spacing16),
//           child: LearningCenterSubmissionsWidget(),
//         );

//       case 'users':
//         return _buildPlaceholder(
//           icon: Icons.people_outline,
//           title: 'Users Management',
//           description: 'View and manage user accounts',
//         );

//       case 'investments':
//         return _buildPlaceholder(
//           icon: Icons.trending_up,
//           title: 'Investment Dashboard',
//           description: 'Monitor active investments',
//         );

//       case 'transactions':
//         return _buildPlaceholder(
//           icon: Icons.payment,
//           title: 'Transaction History',
//           description: 'View all user transactions',
//         );

//       case 'support':
//         return _buildPlaceholder(
//           icon: Icons.support_agent,
//           title: 'Support Tickets',
//           description: 'Manage user support requests',
//         );

//       case 'analytics':
//         return _buildPlaceholder(
//           icon: Icons.analytics_outlined,
//           title: 'Analytics Dashboard',
//           description: 'View app metrics and insights',
//         );

//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildPlaceholder({
//     required IconData icon,
//     required String title,
//     required String description,
//   }) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing24),
//             decoration: BoxDecoration(
//               color: AdminDesignSystem.accentTeal.withAlpha(26),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 48, color: AdminDesignSystem.accentTeal),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),
//           Text(
//             title,
//             style: AdminDesignSystem.headingMedium.copyWith(
//               color: AdminDesignSystem.primaryNavy,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing8),
//           Text(
//             description,
//             style: AdminDesignSystem.bodySmall.copyWith(
//               color: AdminDesignSystem.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing20),
//           Container(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
//             decoration: BoxDecoration(
//               color: AdminDesignSystem.accentTeal.withAlpha(13),
//               borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//             ),
//             child: Text(
//               'Placeholder - Add widget here',
//               style: AdminDesignSystem.labelSmall.copyWith(
//                 color: AdminDesignSystem.accentTeal,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AdminTab {
//   final String id;
//   final String label;
//   final IconData icon;

//   _AdminTab({required this.id, required this.label, required this.icon});
// }

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
