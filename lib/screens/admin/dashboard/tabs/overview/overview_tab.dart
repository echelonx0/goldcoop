// lib/screens/admin/dashboard/tabs/overview_tab.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../../core/theme/admin_design_system.dart';

import '../../../services/admin_service.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/stats_grid.dart';
import '../../widgets/support_quick_stats.dart';

class OverviewTab extends StatelessWidget {
  final AdminService adminService;

  const OverviewTab({super.key, required this.adminService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: adminService.getAdminStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AdminLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final stats = snapshot.data ?? {};

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AdminDesignSystem.spacing16),

              DelayedDisplay(
                delay: const Duration(milliseconds: 100),
                child: const SectionHeader(
                  title: 'Platform Overview',
                  subtitle: 'Real-time metrics',
                ),
              ),

              const SizedBox(height: AdminDesignSystem.spacing8),

              DelayedDisplay(
                delay: const Duration(milliseconds: 150),
                child: StatsGrid(stats: stats),
              ),

              const SizedBox(height: AdminDesignSystem.spacing24),

              DelayedDisplay(
                delay: const Duration(milliseconds: 200),
                child: const SupportQuickStats(),
              ),

              const SizedBox(height: AdminDesignSystem.spacing24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AdminDesignSystem.statusError,
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            Text(
              'Failed to load dashboard metrics',
              style: AdminDesignSystem.bodyLarge.copyWith(
                color: AdminDesignSystem.statusError,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            Text(
              error,
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
