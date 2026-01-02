// lib/screens/admin/dashboard/widgets/stats_grid.dart (WITH NUMBER FORMATTING)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_design_system.dart';

class StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: 0,
    );

    final numberFormatter = NumberFormat('#,##0');

    final cashBalance = (stats['cashBalance'] ?? 0).toDouble();
    final totalDeposits = (stats['totalDeposits'] ?? 0).toDouble();
    final totalWithdrawals = (stats['totalWithdrawals'] ?? 0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing16,
      ),
      child: Column(
        children: [
          // Top row: Users + Active
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Users',
                  value: numberFormatter.format(stats['totalUsers'] ?? 0),
                  icon: Icons.people_outline,
                  color: AdminDesignSystem.primaryNavy,
                ),
              ),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(
                child: _StatCard(
                  label: 'Active',
                  value: numberFormatter.format(stats['activeUsers'] ?? 0),
                  icon: Icons.trending_up,
                  color: AdminDesignSystem.statusActive,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          // Second row: Investments + Transactions
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Investments',
                  value: numberFormatter.format(stats['totalInvestments'] ?? 0),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AdminDesignSystem.accentTeal,
                ),
              ),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(
                child: _StatCard(
                  label: 'Transactions',
                  value: numberFormatter.format(
                    stats['totalTransactions'] ?? 0,
                  ),
                  icon: Icons.receipt_long_outlined,
                  color: AdminDesignSystem.statusPending,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Main: Cash Balance
          _LargeStatCard(
            label: 'Platform Cash Balance',
            value: currencyFormatter.format(cashBalance),
            icon: Icons.account_balance,
            color: AdminDesignSystem.statusActive,
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          // Breakdown: Deposits & Withdrawals
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: AdminDesignSystem.cardBackground,
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              boxShadow: [AdminDesignSystem.softShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash Flow',
                  style: AdminDesignSystem.labelMedium.copyWith(
                    color: AdminDesignSystem.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),
                Row(
                  children: [
                    Expanded(
                      child: _BreakdownItem(
                        label: 'Total Deposits',
                        value: currencyFormatter.format(totalDeposits),
                        icon: Icons.arrow_downward,
                        color: AdminDesignSystem.statusActive,
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),
                    Expanded(
                      child: _BreakdownItem(
                        label: 'Total Withdrawals',
                        value: currencyFormatter.format(totalWithdrawals),
                        icon: Icons.arrow_upward,
                        color: AdminDesignSystem.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BreakdownItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: AdminDesignSystem.spacing8),
            Expanded(
              child: Text(
                label,
                style: AdminDesignSystem.labelSmall.copyWith(
                  color: AdminDesignSystem.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminDesignSystem.spacing8),
        Text(
          value,
          style: AdminDesignSystem.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          Text(label, style: AdminDesignSystem.labelSmall),
          const SizedBox(height: AdminDesignSystem.spacing4),
          Text(
            value,
            style: AdminDesignSystem.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LargeStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _LargeStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AdminDesignSystem.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AdminDesignSystem.labelMedium),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  value,
                  style: AdminDesignSystem.headingLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
