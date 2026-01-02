// // lib/screens/admin/dashboard/tabs/support_tab.dart

// import 'package:flutter/material.dart';
// import '../../../../core/theme/admin_design_system.dart';
// import '../../../../services/admin_support_service.dart';
// import '../../../support/admin_support_inbox.dart';
// import '../../sections/admin_faq_manager.dart';

// class SupportTab extends StatelessWidget {
//   final String adminId;
//   final String adminName;
//   final String adminAvatar;
//   final AdminSupportService adminSupportService;

//   const SupportTab({
//     super.key,
//     required this.adminId,
//     required this.adminName,
//     required this.adminAvatar,
//     required this.adminSupportService,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
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
//           _QuickActionButton(
//             icon: Icons.mail_outline,
//             title: 'View Support Inbox',
//             subtitle: 'Manage all conversations',
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => AdminSupportInbox(
//                   adminId: adminId,
//                   adminName: adminName,
//                   adminAvatar: adminAvatar,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),

//           _QuickActionButton(
//             icon: Icons.help_outline,
//             title: 'Manage FAQ',
//             subtitle: 'Create and edit FAQ items',
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const AdminFAQManager()),
//             ),
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing24),

//           // Support Stats
//           FutureBuilder<Map<String, dynamic>>(
//             future: adminSupportService.getSupportStats(),
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
//                   _StatRow(
//                     label: 'Open Tickets',
//                     value: '${stats['openTickets'] ?? 0}',
//                     color: AdminDesignSystem.statusError,
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing12),
//                   _StatRow(
//                     label: 'Active Conversations',
//                     value: '${stats['activeConversations'] ?? 0}',
//                     color: AdminDesignSystem.accentTeal,
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing12),
//                   _StatRow(
//                     label: 'Resolved Tickets',
//                     value: '${stats['resolvedTickets'] ?? 0}',
//                     color: AdminDesignSystem.statusActive,
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _QuickActionButton extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   const _QuickActionButton({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
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
// }

// class _StatRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _StatRow({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
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
// }

// lib/screens/admin/dashboard/tabs/support_tab.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/admin_design_system.dart' hide AdminCard;
import '../../../../services/admin_support_service.dart';
import '../../../support/admin_support_inbox.dart';

import 'tickets/admin_tickets_manager.dart';
import '../../sections/admin_faq_manager.dart';
import '../../sections/investments_management.dart';

class SupportTab extends StatelessWidget {
  final String adminId;
  final String adminName;
  final String adminAvatar;
  final AdminSupportService adminSupportService;

  const SupportTab({
    super.key,
    required this.adminId,
    required this.adminName,
    required this.adminAvatar,
    required this.adminSupportService,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support Management',
            style: AdminDesignSystem.headingMedium.copyWith(
              color: AdminDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),

          // Quick Actions
          _QuickActionButton(
            icon: Icons.mail_outline,
            title: 'View Support Inbox',
            subtitle: 'Manage all conversations',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminSupportInbox(
                  adminId: adminId,
                  adminName: adminName,
                  adminAvatar: adminAvatar,
                ),
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          _QuickActionButton(
            icon: Icons.airplane_ticket,
            title: 'Manage Tickets',
            subtitle: 'View and update support tickets',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AdminTicketsManager(adminId: adminId, adminName: adminName),
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          _QuickActionButton(
            icon: Icons.help_outline,
            title: 'Manage FAQ',
            subtitle: 'Create and edit FAQ items',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminFAQManager()),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),

          _QuickActionButton(
            icon: Icons.help_outline,
            title: 'Manage Investments',
            subtitle: 'Create and edit Investment options',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InvestmentPlansManagement(),
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),

          // Support Stats
          FutureBuilder<Map<String, dynamic>>(
            future: adminSupportService.getSupportStats(),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AdminDesignSystem.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _StatRow(
                    label: 'Open Tickets',
                    value: '${stats['openTickets'] ?? 0}',
                    color: AdminDesignSystem.statusError,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _StatRow(
                    label: 'Active Conversations',
                    value: '${stats['activeConversations'] ?? 0}',
                    color: AdminDesignSystem.accentTeal,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  _StatRow(
                    label: 'Resolved Tickets',
                    value: '${stats['resolvedTickets'] ?? 0}',
                    color: AdminDesignSystem.statusActive,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AdminCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
              decoration: BoxDecoration(
                color: AdminDesignSystem.accentTeal.withAlpha(25),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              child: Icon(icon, color: AdminDesignSystem.accentTeal, size: 24),
            ),
            const SizedBox(width: AdminDesignSystem.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AdminDesignSystem.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AdminDesignSystem.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminDesignSystem.spacing12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: AdminDesignSystem.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
