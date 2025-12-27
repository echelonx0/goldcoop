// // lib/screens/admin/dashboard/admin_dashboard.dart

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../core/theme/admin_design_system.dart';
// import '../../../services/admin_service.dart';
// import '../../../services/admin_support_service.dart';

// import '../../support/admin_support_inbox.dart';
// import '../sections/admin_faq_manager.dart';
// import '../sections/investments_management.dart';
// import '../sections/users_management.dart';

// class AdminDashboard extends StatefulWidget {
//   final String adminId;
//   final String adminName;
//   final String adminAvatar;

//   const AdminDashboard({
//     super.key,
//     required this.adminId,
//     required this.adminName,
//     required this.adminAvatar,
//   });

//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   final AdminService _adminService = AdminService();
//   final AdminSupportService _adminSupportService = AdminSupportService();
//   final _currencyFormatter = NumberFormat.currency(
//     symbol: '₦',
//     decimalDigits: 0,
//   );
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AdminDesignSystem.background,
//       appBar: _buildAppBar(),
//       body: _buildContent(),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: AdminDesignSystem.cardBackground,
//       elevation: 0,
//       title: Text(
//         'Admin Dashboard',
//         style: AdminDesignSystem.headingLarge.copyWith(
//           color: AdminDesignSystem.primaryNavy,
//         ),
//       ),
//       actions: [
//         // Support Inbox Badge
//         StreamBuilder<int>(
//           stream: _adminSupportService.getUnreadTicketCountStream(),
//           builder: (context, snapshot) {
//             final unreadCount = snapshot.data ?? 0;
//             return Padding(
//               padding: const EdgeInsets.only(right: AdminDesignSystem.spacing8),
//               child: Stack(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.support_agent, size: 22),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => AdminSupportInbox(
//                             adminId: widget.adminId,
//                             adminName: widget.adminName,
//                             adminAvatar: widget.adminAvatar,
//                           ),
//                         ),
//                       );
//                     },
//                     color: AdminDesignSystem.primaryNavy,
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
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const AdminFAQManager()),
//             );
//           },
//           color: AdminDesignSystem.primaryNavy,
//         ),
//         const SizedBox(width: AdminDesignSystem.spacing8),
//       ],
//     );
//   }

//   Widget _buildContent() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildOverview();
//       case 1:
//         return const InvestmentPlansManagement();
//       case 2:
//         return const UsersManagement();
//       case 3:
//         return _buildSupportDashboard();
//       default:
//         return _buildOverview();
//     }
//   }

//   Widget _buildOverview() {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _adminService.getAdminStats(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(
//               color: AdminDesignSystem.accentTeal,
//             ),
//           );
//         }

//         final stats = snapshot.data ?? {};

//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: AdminDesignSystem.spacing16),
//               SectionHeader(
//                 title: 'Platform Overview',
//                 subtitle: 'Real-time metrics',
//               ),
//               const SizedBox(height: AdminDesignSystem.spacing8),
//               _buildStatsGrid(stats),
//               const SizedBox(height: AdminDesignSystem.spacing24),

//               // Support Quick Stats
//               _buildSupportQuickStats(),
//               const SizedBox(height: AdminDesignSystem.spacing24),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSupportQuickStats() {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _adminSupportService.getSupportStats(),
//       builder: (context, snapshot) {
//         final stats = snapshot.data ?? {};
//         return Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: AdminDesignSystem.spacing16,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Support Overview',
//                 style: AdminDesignSystem.bodyMedium.copyWith(
//                   fontWeight: FontWeight.w600,
//                   color: AdminDesignSystem.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: AdminDesignSystem.spacing12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildQuickStatCard(
//                       label: 'Open Tickets',
//                       value: '${stats['openTickets'] ?? 0}',
//                       color: AdminDesignSystem.statusError,
//                       icon: Icons.support_sharp,
//                     ),
//                   ),
//                   const SizedBox(width: AdminDesignSystem.spacing12),
//                   Expanded(
//                     child: _buildQuickStatCard(
//                       label: 'Active Chats',
//                       value: '${stats['activeConversations'] ?? 0}',
//                       color: AdminDesignSystem.accentTeal,
//                       icon: Icons.chat_outlined,
//                     ),
//                   ),
//                   const SizedBox(width: AdminDesignSystem.spacing12),
//                   Expanded(
//                     child: _buildQuickStatCard(
//                       label: 'Resolved',
//                       value: '${stats['resolvedTickets'] ?? 0}',
//                       color: AdminDesignSystem.statusActive,
//                       icon: Icons.check_circle_outline,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildQuickStatCard({
//     required String label,
//     required String value,
//     required Color color,
//     required IconData icon,
//   }) {
//     return AdminCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(height: AdminDesignSystem.spacing8),
//           Text(
//             label,
//             style: AdminDesignSystem.labelSmall.copyWith(
//               color: AdminDesignSystem.textSecondary,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing4),
//           Text(
//             value,
//             style: AdminDesignSystem.headingMedium.copyWith(
//               color: color,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSupportDashboard() {
//     return Padding(
//       padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Support Management',
//             style: AdminDesignSystem.headingMedium.copyWith(
//               color: AdminDesignSystem.primaryNavy,
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing24),

//           // Quick Actions
//           _buildQuickActionButton(
//             icon: Icons.mail_outline,
//             title: 'View Support Inbox',
//             subtitle: 'Manage all conversations',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AdminSupportInbox(
//                     adminId: widget.adminId,
//                     adminName: widget.adminName,
//                     adminAvatar: widget.adminAvatar,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),

//           _buildQuickActionButton(
//             icon: Icons.help_outline,
//             title: 'Manage FAQ',
//             subtitle: 'Create and edit FAQ items',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AdminFAQManager()),
//               );
//             },
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing24),

//           // Support Stats
//           FutureBuilder<Map<String, dynamic>>(
//             future: _adminSupportService.getSupportStats(),
//             builder: (context, snapshot) {
//               final stats = snapshot.data ?? {};
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Statistics',
//                     style: AdminDesignSystem.bodyMedium.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: AdminDesignSystem.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing12),
//                   _buildStatRow(
//                     'Open Tickets',
//                     '${stats['openTickets'] ?? 0}',
//                     AdminDesignSystem.statusError,
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing12),
//                   _buildStatRow(
//                     'Active Conversations',
//                     '${stats['activeConversations'] ?? 0}',
//                     AdminDesignSystem.accentTeal,
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing12),
//                   _buildStatRow(
//                     'Resolved Tickets',
//                     '${stats['resolvedTickets'] ?? 0}',
//                     AdminDesignSystem.statusActive,
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActionButton({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AdminCard(
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
//               decoration: BoxDecoration(
//                 color: AdminDesignSystem.accentTeal.withAlpha(25),
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//               ),
//               child: Icon(icon, color: AdminDesignSystem.accentTeal, size: 24),
//             ),
//             const SizedBox(width: AdminDesignSystem.spacing16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: AdminDesignSystem.bodyMedium.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: AdminDesignSystem.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: AdminDesignSystem.bodySmall.copyWith(
//                       color: AdminDesignSystem.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 18,
//               color: AdminDesignSystem.textTertiary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatRow(String label, String value, Color color) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: AdminDesignSystem.bodySmall.copyWith(
//             color: AdminDesignSystem.textPrimary,
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: AdminDesignSystem.spacing12,
//             vertical: 6,
//           ),
//           decoration: BoxDecoration(
//             color: color.withAlpha(25),
//             borderRadius: BorderRadius.circular(4),
//           ),
//           child: Text(
//             value,
//             style: AdminDesignSystem.bodySmall.copyWith(
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatsGrid(Map<String, dynamic> stats) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AdminDesignSystem.spacing16,
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   label: 'Total Users',
//                   value: '${stats['totalUsers'] ?? 0}',
//                   icon: Icons.people_outline,
//                   color: AdminDesignSystem.primaryNavy,
//                 ),
//               ),
//               const SizedBox(width: AdminDesignSystem.spacing12),
//               Expanded(
//                 child: _buildStatCard(
//                   label: 'Active',
//                   value: '${stats['activeInvestors'] ?? 0}',
//                   icon: Icons.trending_up,
//                   color: AdminDesignSystem.statusActive,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   label: 'Investments',
//                   value: '${stats['totalInvestments'] ?? 0}',
//                   icon: Icons.account_balance_wallet_outlined,
//                   color: AdminDesignSystem.accentTeal,
//                 ),
//               ),
//               const SizedBox(width: AdminDesignSystem.spacing12),
//               Expanded(
//                 child: _buildStatCard(
//                   label: 'Transactions',
//                   value: '${stats['totalTransactions'] ?? 0}',
//                   icon: Icons.receipt_long_outlined,
//                   color: AdminDesignSystem.statusPending,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),
//           _buildLargeStatCard(
//             label: 'Total Invested',
//             value: _currencyFormatter.format(stats['totalInvested'] ?? 0),
//             icon: Icons.attach_money,
//             color: AdminDesignSystem.primaryNavy,
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),
//           _buildLargeStatCard(
//             label: 'Platform Balance',
//             value: _currencyFormatter.format(stats['totalBalance'] ?? 0),
//             icon: Icons.account_balance,
//             color: AdminDesignSystem.statusActive,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required String label,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return AdminCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
//                 decoration: BoxDecoration(
//                   color: color.withAlpha(38),
//                   borderRadius: BorderRadius.circular(
//                     AdminDesignSystem.radius8,
//                   ),
//                 ),
//                 child: Icon(icon, color: color, size: 20),
//               ),
//             ],
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),
//           Text(label, style: AdminDesignSystem.labelSmall),
//           const SizedBox(height: AdminDesignSystem.spacing4),
//           Text(
//             value,
//             style: AdminDesignSystem.headingMedium.copyWith(
//               color: color,
//               fontWeight: FontWeight.w700,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLargeStatCard({
//     required String label,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return AdminCard(
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
//             decoration: BoxDecoration(
//               color: color.withAlpha(38),
//               borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           const SizedBox(width: AdminDesignSystem.spacing16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: AdminDesignSystem.labelMedium),
//                 const SizedBox(height: AdminDesignSystem.spacing4),
//                 Text(
//                   value,
//                   style: AdminDesignSystem.headingLarge.copyWith(
//                     color: color,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNav() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AdminDesignSystem.cardBackground,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             blurRadius: 12,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                 icon: Icons.dashboard_outlined,
//                 activeIcon: Icons.dashboard,
//                 label: 'Dashboard',
//                 index: 0,
//               ),
//               _buildNavItem(
//                 icon: Icons.trending_up_outlined,
//                 activeIcon: Icons.trending_up,
//                 label: 'Investments',
//                 index: 1,
//               ),
//               _buildNavItem(
//                 icon: Icons.people_outline,
//                 activeIcon: Icons.people,
//                 label: 'Users',
//                 index: 2,
//               ),
//               _buildNavItem(
//                 icon: Icons.support_agent_outlined,
//                 activeIcon: Icons.support_agent,
//                 label: 'Support',
//                 index: 3,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     required IconData activeIcon,
//     required String label,
//     required int index,
//   }) {
//     final isSelected = _selectedIndex == index;
//     return InkWell(
//       onTap: () => setState(() => _selectedIndex = index),
//       borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AdminDesignSystem.spacing16,
//           vertical: AdminDesignSystem.spacing8,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isSelected ? activeIcon : icon,
//               color: isSelected
//                   ? AdminDesignSystem.accentTeal
//                   : AdminDesignSystem.textTertiary,
//               size: 24,
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing4),
//             Text(
//               label,
//               style: AdminDesignSystem.labelSmall.copyWith(
//                 color: isSelected
//                     ? AdminDesignSystem.accentTeal
//                     : AdminDesignSystem.textTertiary,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==================== ADMIN CARD WIDGET ====================

// class AdminCard extends StatelessWidget {
//   final Widget child;
//   final VoidCallback? onTap;

//   const AdminCard({super.key, required this.child, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//         decoration: BoxDecoration(
//           color: AdminDesignSystem.cardBackground,
//           borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//           border: Border.all(color: AdminDesignSystem.divider),
//         ),
//         child: child,
//       ),
//     );
//   }
// }

// // ==================== SECTION HEADER ====================

// class SectionHeader extends StatelessWidget {
//   final String title;
//   final String? subtitle;

//   const SectionHeader({super.key, required this.title, this.subtitle});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AdminDesignSystem.spacing16,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: AdminDesignSystem.headingMedium.copyWith(
//               color: AdminDesignSystem.primaryNavy,
//             ),
//           ),
//           if (subtitle != null) ...[
//             const SizedBox(height: 4),
//             Text(
//               subtitle!,
//               style: AdminDesignSystem.bodySmall.copyWith(
//                 color: AdminDesignSystem.textSecondary,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// lib/screens/admin/dashboard/admin_dashboard.dart

import 'package:flutter/material.dart';

import '../../../core/theme/admin_design_system.dart';
import '../../../services/admin_service.dart';
import '../../../services/admin_support_service.dart';

import '../sections/deposits_management.dart';
import '../sections/investments_management.dart';
import '../sections/users_management.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'tabs/overview_tab.dart';
import 'tabs/support_tab.dart';

class AdminDashboard extends StatefulWidget {
  final String adminId;
  final String adminName;
  final String adminAvatar;

  const AdminDashboard({
    super.key,
    required this.adminId,
    required this.adminName,
    required this.adminAvatar,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  final AdminSupportService _adminSupportService = AdminSupportService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      appBar: AdminAppBar(
        adminId: widget.adminId,
        adminName: widget.adminName,
        adminAvatar: widget.adminAvatar,
        adminSupportService: _adminSupportService,
      ),
      body: _buildContent(),
      bottomNavigationBar: AdminBottomNav(
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return OverviewTab(adminService: _adminService);
      case 1:
        return const InvestmentPlansManagement();
      case 2:
        return const UsersManagement();
      case 3: // ✅ NEW - Deposits Management
        return AdminDepositsScreen(adminUserId: widget.adminId);
      // case 4: // ✅ CHANGED from case 3
      //   return SupportTab(
      //     adminId: widget.adminId,
      //     adminName: widget.adminName,
      //     adminAvatar: widget.adminAvatar,
      //     adminSupportService: _adminSupportService,
      //   );
      default:
        return OverviewTab(adminService: _adminService);
    }
  }
}
