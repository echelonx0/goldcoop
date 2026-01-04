// lib/screens/admin/dashboard/widgets/stats_grid.dart
// Clean implementation using CashFlowService

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../models/cash_flow_model.dart';
import '../../services/cash_flow_service.dart';

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
          // Row 1: Users + Active
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

          // Row 2: Investments + Transactions
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

          // Clickable: Cash Flow
          _ClickableCashFlowCard(
            totalDeposits: totalDeposits,
            totalWithdrawals: totalWithdrawals,
            currencyFormatter: currencyFormatter,
            onTap: () => _showCashFlowSheet(context),
          ),
        ],
      ),
    );
  }

  void _showCashFlowSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => const _CashFlowDetailSheet(),
    );
  }
}

// ==================== CASH FLOW CARD ====================

class _ClickableCashFlowCard extends StatelessWidget {
  final double totalDeposits;
  final double totalWithdrawals;
  final NumberFormat currencyFormatter;
  final VoidCallback onTap;

  const _ClickableCashFlowCard({
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.currencyFormatter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: AdminDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          boxShadow: [AdminDesignSystem.softShadow],
          border: Border.all(color: AdminDesignSystem.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cash Flow',
                  style: AdminDesignSystem.labelMedium.copyWith(
                    color: AdminDesignSystem.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AdminDesignSystem.textTertiary,
                ),
              ],
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
    );
  }
}

// ==================== CASH FLOW DETAIL SHEET ====================

class _CashFlowDetailSheet extends StatefulWidget {
  const _CashFlowDetailSheet();

  @override
  State<_CashFlowDetailSheet> createState() => _CashFlowDetailSheetState();
}

class _CashFlowDetailSheetState extends State<_CashFlowDetailSheet> {
  final CashFlowService _cashFlowService = CashFlowService();
  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AdminDesignSystem.radius16),
          topRight: Radius.circular(AdminDesignSystem.radius16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AdminDesignSystem.spacing12),
              decoration: BoxDecoration(
                color: AdminDesignSystem.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          _buildHeader(),

          // Filters
          _buildFilters(),

          // List
          Expanded(
            child: StreamBuilder<List<CashFlowModel>>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AdminDesignSystem.spacing12),
                  itemBuilder: (context, index) {
                    return _CashFlowRow(
                      cashFlow: items[index],
                      currencyFormatter: _currencyFormatter,
                      onReverse: () => _showReverseDialog(items[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        boxShadow: [AdminDesignSystem.softShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash Flow History',
                  style: AdminDesignSystem.headingMedium.copyWith(
                    color: AdminDesignSystem.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  'Completed deposits and withdrawals',
                  style: AdminDesignSystem.labelMedium.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20),
            color: AdminDesignSystem.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      color: AdminDesignSystem.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by type',
            style: AdminDesignSystem.labelMedium.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Row(
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: AdminDesignSystem.spacing8),
              _buildFilterChip('Deposits'),
              const SizedBox(width: AdminDesignSystem.spacing8),
              _buildFilterChip('Withdrawals'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedType == label;
    return InkWell(
      onTap: () => setState(() => _selectedType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminDesignSystem.spacing12,
          vertical: AdminDesignSystem.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminDesignSystem.accentTeal
              : AdminDesignSystem.background,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
          border: Border.all(
            color: isSelected
                ? AdminDesignSystem.accentTeal
                : AdminDesignSystem.divider,
          ),
        ),
        child: Text(
          label,
          style: AdminDesignSystem.labelMedium.copyWith(
            color: isSelected ? Colors.white : AdminDesignSystem.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AdminDesignSystem.textTertiary,
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          Text('No transactions', style: AdminDesignSystem.bodyMedium),
        ],
      ),
    );
  }

  Stream<List<CashFlowModel>> _getFilteredStream() {
    CashFlowType? type;
    if (_selectedType == 'Deposits') {
      type = CashFlowType.deposit;
    } else if (_selectedType == 'Withdrawals') {
      type = CashFlowType.withdrawal;
    }
    return _cashFlowService.streamCompleted(type: type);
  }

  void _showReverseDialog(CashFlowModel cashFlow) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reverse ${cashFlow.isDeposit ? 'Deposit' : 'Withdrawal'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${_currencyFormatter.format(cashFlow.amount)}',
              style: AdminDesignSystem.bodyMedium,
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for reversal *',
                hintText: 'Enter reason...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reason is required')),
                );
                return;
              }

              Navigator.pop(context);
              await _performReversal(cashFlow, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminDesignSystem.statusError,
            ),
            child: const Text('Reverse'),
          ),
        ],
      ),
    );
  }

  Future<void> _performReversal(CashFlowModel cashFlow, String reason) async {
    // TODO: Get actual admin ID and email from auth
    const adminId = 'admin_id';
    const adminEmail = 'admin@example.com';

    bool success;
    if (cashFlow.isDeposit) {
      success = await _cashFlowService.reverseDeposit(
        cashFlowId: cashFlow.id,
        adminId: adminId,
        adminEmail: adminEmail,
        reason: reason,
      );
    } else {
      success = await _cashFlowService.reverseWithdrawal(
        cashFlowId: cashFlow.id,
        adminId: adminId,
        adminEmail: adminEmail,
        reason: reason,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Reversal successful' : 'Reversal failed'),
          backgroundColor: success
              ? AdminDesignSystem.statusActive
              : AdminDesignSystem.statusError,
        ),
      );
    }
  }
}

// ==================== CASH FLOW ROW ====================

class _CashFlowRow extends StatelessWidget {
  final CashFlowModel cashFlow;
  final NumberFormat currencyFormatter;
  final VoidCallback onReverse;

  const _CashFlowRow({
    required this.cashFlow,
    required this.currencyFormatter,
    required this.onReverse,
  });

  @override
  Widget build(BuildContext context) {
    final isDeposit = cashFlow.isDeposit;
    final color = isDeposit
        ? AdminDesignSystem.statusActive
        : AdminDesignSystem.primaryNavy;

    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        boxShadow: [AdminDesignSystem.softShadow],
      ),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
            child: Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit ? 'Deposit' : 'Withdrawal',
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  _formatDate(cashFlow.processedAt ?? cashFlow.createdAt),
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Amount + Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDeposit ? '+' : '−'}${currencyFormatter.format(cashFlow.amount)}',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusBadge(),
                  if (cashFlow.canBeReversed) ...[
                    const SizedBox(width: AdminDesignSystem.spacing8),
                    GestureDetector(
                      onTap: onReverse,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AdminDesignSystem.statusError.withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.undo,
                          size: 14,
                          color: AdminDesignSystem.statusError,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String label;

    switch (cashFlow.status) {
      case CashFlowStatus.completed:
        badgeColor = AdminDesignSystem.statusActive;
        label = 'Completed';
        break;
      case CashFlowStatus.reversed:
        badgeColor = AdminDesignSystem.statusError;
        label = 'Reversed';
        break;
      default:
        badgeColor = AdminDesignSystem.statusPending;
        label = cashFlow.status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing8,
        vertical: AdminDesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
      ),
      child: Text(
        label,
        style: AdminDesignSystem.labelSmall.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ==================== HELPER WIDGETS ====================

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
