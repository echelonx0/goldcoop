// // lib/screens/admin/dashboard/widgets/stats_grid.dart

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/theme/admin_design_system.dart';

// class StatsGrid extends StatelessWidget {
//   final Map<String, dynamic> stats;

//   const StatsGrid({super.key, required this.stats});

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormatter = NumberFormat.currency(
//       symbol: '₦',
//       decimalDigits: 0,
//     );

//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AdminDesignSystem.spacing16,
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   label: 'Total Users',
//                   value: '${stats['totalUsers'] ?? 0}',
//                   icon: Icons.people_outline,
//                   color: AdminDesignSystem.primaryNavy,
//                 ),
//               ),
//               const SizedBox(width: AdminDesignSystem.spacing12),
//               Expanded(
//                 child: _StatCard(
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
//                 child: _StatCard(
//                   label: 'Investments',
//                   value: '${stats['totalInvestments'] ?? 0}',
//                   icon: Icons.account_balance_wallet_outlined,
//                   color: AdminDesignSystem.accentTeal,
//                 ),
//               ),
//               const SizedBox(width: AdminDesignSystem.spacing12),
//               Expanded(
//                 child: _StatCard(
//                   label: 'Transactions',
//                   value: '${stats['totalTransactions'] ?? 0}',
//                   icon: Icons.receipt_long_outlined,
//                   color: AdminDesignSystem.statusPending,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),

//           _LargeStatCard(
//             label: 'Total Invested',
//             value: currencyFormatter.format(stats['totalInvested'] ?? 0),
//             icon: Icons.attach_money,
//             color: AdminDesignSystem.primaryNavy,
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),

//           _LargeStatCard(
//             label: 'Platform Balance',
//             value: currencyFormatter.format(stats['totalBalance'] ?? 0),
//             icon: Icons.account_balance,
//             color: AdminDesignSystem.statusActive,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const _StatCard({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AdminCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
//             decoration: BoxDecoration(
//               color: color.withAlpha(38),
//               borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//             ),
//             child: Icon(icon, color: color, size: 20),
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
// }

// class _LargeStatCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const _LargeStatCard({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
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
// }

// lib/screens/admin/dashboard/widgets/stats_grid.dart (UPDATED)

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

    // Extract values
    final accountBalance = (stats['accountBalance'] ?? 0).toDouble();
    final totalInvested = (stats['totalInvested'] ?? 0).toDouble();
    final totalReturns = (stats['totalReturns'] ?? 0).toDouble();
    final platformBalance = (stats['platformBalance'] ?? 0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Users',
                  value: '${stats['totalUsers'] ?? 0}',
                  icon: Icons.people_outline,
                  color: AdminDesignSystem.primaryNavy,
                ),
              ),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(
                child: _StatCard(
                  label: 'Active',
                  value: '${stats['activeInvestors'] ?? 0}',
                  icon: Icons.trending_up,
                  color: AdminDesignSystem.statusActive,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Investments',
                  value: '${stats['totalInvestments'] ?? 0}',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AdminDesignSystem.accentTeal,
                ),
              ),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(
                child: _StatCard(
                  label: 'Transactions',
                  value: '${stats['totalTransactions'] ?? 0}',
                  icon: Icons.receipt_long_outlined,
                  color: AdminDesignSystem.statusPending,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // ✅ PLATFORM BALANCE WITH BREAKDOWN
          _LargeStatCard(
            label: 'Platform Balance',
            value: currencyFormatter.format(platformBalance),
            icon: Icons.account_balance,
            color: AdminDesignSystem.statusActive,
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          // Breakdown section
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: AdminDesignSystem.accentTeal,
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              border: Border.all(color: AdminDesignSystem.accentTeal),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breakdown',
                  style: AdminDesignSystem.labelMedium.copyWith(
                    color: AdminDesignSystem.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),
                _BreakdownRow(
                  label: 'Account Balance',
                  value: currencyFormatter.format(accountBalance),
                  color: AdminDesignSystem.accentTeal,
                ),
                SizedBox(height: AdminDesignSystem.spacing8),
                _BreakdownRow(
                  label: 'Invested',
                  value: currencyFormatter.format(totalInvested),
                  color: AdminDesignSystem.primaryNavy,
                ),
                SizedBox(height: AdminDesignSystem.spacing8),
                _BreakdownRow(
                  label: 'Returns',
                  value: currencyFormatter.format(totalReturns),
                  color: AdminDesignSystem.statusActive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: AdminDesignSystem.spacing12),
            Text(
              label,
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
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
