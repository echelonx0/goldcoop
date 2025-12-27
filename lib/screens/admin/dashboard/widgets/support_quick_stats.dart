// lib/screens/admin/dashboard/widgets/support_quick_stats.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../services/admin_support_service.dart';

class SupportQuickStats extends StatelessWidget {
  const SupportQuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    final adminSupportService = AdminSupportService();

    return FutureBuilder<Map<String, dynamic>>(
      future: adminSupportService.getSupportStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {};

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminDesignSystem.spacing16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support Overview',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AdminDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing12),
              Row(
                children: [
                  Expanded(
                    child: _QuickStatCard(
                      label: 'Open Tickets',
                      value: '${stats['openTickets'] ?? 0}',
                      color: AdminDesignSystem.statusError,
                      icon: Icons.support_sharp,
                    ),
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing12),
                  Expanded(
                    child: _QuickStatCard(
                      label: 'Active Chats',
                      value: '${stats['activeConversations'] ?? 0}',
                      color: AdminDesignSystem.accentTeal,
                      icon: Icons.chat_outlined,
                    ),
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing12),
                  Expanded(
                    child: _QuickStatCard(
                      label: 'Resolved',
                      value: '${stats['resolvedTickets'] ?? 0}',
                      color: AdminDesignSystem.statusActive,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Text(
            label,
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing4),
          Text(
            value,
            style: AdminDesignSystem.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
