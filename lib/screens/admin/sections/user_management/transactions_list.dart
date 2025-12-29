// ==================== ADMIN USER TRANSACTIONS SHEET (UPDATED) ====================

import 'package:flutter/material.dart';

import '../../../../core/theme/admin_design_system.dart';
import '../../../../services/firestore_service.dart';

class AdminUserTransactionsSheet extends StatefulWidget {
  final String userId;
  final String userName;
  final FirestoreService firestoreService;

  const AdminUserTransactionsSheet({
    super.key,
    required this.userId,
    required this.userName,
    required this.firestoreService,
  });

  @override
  State<AdminUserTransactionsSheet> createState() =>
      _AdminUserTransactionsSheetState();
}

class _AdminUserTransactionsSheetState
    extends State<AdminUserTransactionsSheet> {
  late final FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = widget.firestoreService;
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: AdminDesignSystem.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction History',
                        style: AdminDesignSystem.headingMedium.copyWith(
                          color: AdminDesignSystem.primaryNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing4),
                      Text(
                        widget.userName,
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
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
          // Transactions list
          Expanded(
            child: StreamBuilder(
              stream: _firestoreService.getUserTransactionsStream(
                userId: widget.userId,
                limit: 50,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AdminDesignSystem.accentTeal,
                      strokeWidth: 2,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                            AdminDesignSystem.spacing16,
                          ),
                          decoration: BoxDecoration(
                            color: AdminDesignSystem.statusError.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 32,
                            color: AdminDesignSystem.statusError,
                          ),
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing12),
                        Text(
                          'Failed to load transactions',
                          style: AdminDesignSystem.bodyMedium.copyWith(
                            color: AdminDesignSystem.statusError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                            AdminDesignSystem.spacing16,
                          ),
                          decoration: BoxDecoration(
                            color: AdminDesignSystem.accentTeal.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 32,
                            color: AdminDesignSystem.accentTeal,
                          ),
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing12),
                        Text(
                          'No transactions yet',
                          style: AdminDesignSystem.bodyMedium.copyWith(
                            color: AdminDesignSystem.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AdminDesignSystem.spacing12),
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    return _AdminTransactionRow(transaction: txn);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ADMIN TRANSACTION ROW (UPDATED) ====================

class _AdminTransactionRow extends StatelessWidget {
  final dynamic transaction;

  const _AdminTransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncoming = _isIncomingType(transaction.type);
    final statusColor = _getStatusColor(transaction.status);
    final typeColor = _getTypeColor(transaction.type);

    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        boxShadow: [AdminDesignSystem.softShadow],
      ),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
      child: Row(
        children: [
          // Type Icon
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
            decoration: BoxDecoration(
              color: typeColor.withAlpha(38),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
            child: Icon(
              _getTypeIcon(transaction.type),
              size: 18,
              color: typeColor,
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing12),
          // Description & Metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminDesignSystem.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Row(
                  children: [
                    Text(
                      _formatTypeLabel(transaction.type),
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(
                        color: AdminDesignSystem.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing12),
          // Amount & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncoming ? '+' : '−'}₦${transaction.amount.toStringAsFixed(0)}',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isIncoming
                      ? AdminDesignSystem.statusActive
                      : AdminDesignSystem.primaryNavy,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminDesignSystem.spacing8,
                  vertical: AdminDesignSystem.spacing4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius8,
                  ),
                ),
                child: Text(
                  _formatStatus(transaction.status),
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isIncomingType(dynamic type) {
    final typeStr = type.toString().split('.').last;
    return [
      'deposit',
      'investment_return',
      'interest_earned',
      'referral_bonus',
      'transfer_from_user',
    ].contains(typeStr);
  }

  IconData _getTypeIcon(dynamic type) {
    final typeStr = type.toString().split('.').last;
    switch (typeStr) {
      case 'deposit':
        return Icons.arrow_downward;
      case 'withdrawal':
        return Icons.arrow_upward;
      case 'investment':
      case 'investment_return':
        return Icons.trending_up;
      case 'interest_earned':
        return Icons.percent;
      case 'referral_bonus':
        return Icons.card_giftcard;
      case 'transfer_to_user':
        return Icons.send;
      case 'transfer_from_user':
        return Icons.call_received;
      case 'fee':
        return Icons.receipt;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getTypeColor(dynamic type) {
    if (_isIncomingType(type)) {
      return AdminDesignSystem.statusActive;
    }
    return AdminDesignSystem.primaryNavy;
  }

  Color _getStatusColor(dynamic status) {
    final statusStr = status.toString().split('.').last;
    switch (statusStr) {
      case 'completed':
        return AdminDesignSystem.statusActive;
      case 'pending':
      case 'processing':
        return AdminDesignSystem.statusPending;
      case 'failed':
      case 'cancelled':
        return AdminDesignSystem.statusError;
      case 'reversed':
        return AdminDesignSystem.textSecondary;
      default:
        return AdminDesignSystem.textSecondary;
    }
  }

  String _formatTypeLabel(dynamic type) {
    final typeStr = type.toString().split('.').last;
    const typeLabels = {
      'deposit': 'Deposit',
      'withdrawal': 'Withdrawal',
      'investment': 'Investment',
      'investment_return': 'Investment Return',
      'interest_earned': 'Interest Earned',
      'referral_bonus': 'Referral Bonus',
      'transfer_to_user': 'Transfer Out',
      'transfer_from_user': 'Transfer In',
      'fee': 'Fee',
      'token_conversion': 'Token Conversion',
      'token_purchase': 'Token Purchase',
      'adjustment': 'Adjustment',
    };
    return typeLabels[typeStr] ?? 'Transaction';
  }

  String _formatStatus(dynamic status) {
    final statusStr = status.toString().split('.').last;
    const statusLabels = {
      'pending': 'Pending',
      'processing': 'Processing',
      'completed': 'Completed',
      'failed': 'Failed',
      'cancelled': 'Cancelled',
      'reversed': 'Reversed',
    };
    return statusLabels[statusStr] ?? 'Unknown';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
