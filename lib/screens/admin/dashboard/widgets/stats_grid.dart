// // lib/screens/admin/dashboard/widgets/stats_grid.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/theme/admin_design_system.dart';
// import '../../../../services/firestore_service.dart';
// import '../../../../models/transaction_model.dart';

// class StatsGrid extends StatelessWidget {
//   final Map<String, dynamic> stats;

//   const StatsGrid({super.key, required this.stats});

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormatter = NumberFormat.currency(
//       symbol: '₦',
//       decimalDigits: 0,
//     );
//     final numberFormatter = NumberFormat('#,##0');

//     final cashBalance = (stats['cashBalance'] ?? 0).toDouble();
//     final totalDeposits = (stats['totalDeposits'] ?? 0).toDouble();
//     final totalWithdrawals = (stats['totalWithdrawals'] ?? 0).toDouble();

//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AdminDesignSystem.spacing16,
//       ),
//       child: Column(
//         children: [
//           // Row 1: Users + Active
//           Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   label: 'Total Users',
//                   value: numberFormatter.format(stats['totalUsers'] ?? 0),
//                   icon: Icons.people_outline,
//                   color: AdminDesignSystem.primaryNavy,
//                 ),
//               ),
//               const SizedBox(width: AdminDesignSystem.spacing12),
//               Expanded(
//                 child: _StatCard(
//                   label: 'Active',
//                   value: numberFormatter.format(stats['activeUsers'] ?? 0),
//                   icon: Icons.trending_up,
//                   color: AdminDesignSystem.statusActive,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),

//           // Row 2: Investments + Transactions
//           Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   label: 'Investments',
//                   value: numberFormatter.format(stats['totalInvestments'] ?? 0),
//                   icon: Icons.account_balance_wallet_outlined,
//                   color: AdminDesignSystem.accentTeal,
//                 ),
//               ),
//               const SizedBox(width: AdminDesignSystem.spacing12),
//               Expanded(
//                 child: _StatCard(
//                   label: 'Transactions',
//                   value: numberFormatter.format(
//                     stats['totalTransactions'] ?? 0,
//                   ),
//                   icon: Icons.receipt_long_outlined,
//                   color: AdminDesignSystem.statusPending,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing16),

//           // Main: Cash Balance
//           _LargeStatCard(
//             label: 'Platform Cash Balance',
//             value: currencyFormatter.format(cashBalance),
//             icon: Icons.account_balance,
//             color: AdminDesignSystem.statusActive,
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),

//           // Clickable: Cash Flow
//           _ClickableCashFlowCard(
//             totalDeposits: totalDeposits,
//             totalWithdrawals: totalWithdrawals,
//             currencyFormatter: currencyFormatter,
//             onTap: () =>
//                 _showCashFlowSheet(context, totalDeposits, totalWithdrawals),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCashFlowSheet(
//     BuildContext context,
//     double totalDeposits,
//     double totalWithdrawals,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.85,
//       ),
//       builder: (context) => _CashFlowDetailSheet(
//         totalDeposits: totalDeposits,
//         totalWithdrawals: totalWithdrawals,
//       ),
//     );
//   }
// }

// // ==================== CLICKABLE CASH FLOW CARD ====================

// class _ClickableCashFlowCard extends StatelessWidget {
//   final double totalDeposits;
//   final double totalWithdrawals;
//   final NumberFormat currencyFormatter;
//   final VoidCallback onTap;

//   const _ClickableCashFlowCard({
//     required this.totalDeposits,
//     required this.totalWithdrawals,
//     required this.currencyFormatter,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//         decoration: BoxDecoration(
//           color: AdminDesignSystem.cardBackground,
//           borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//           boxShadow: [AdminDesignSystem.softShadow],
//           border: Border.all(color: AdminDesignSystem.divider),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Cash Flow',
//                   style: AdminDesignSystem.labelMedium.copyWith(
//                     color: AdminDesignSystem.textSecondary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Icon(
//                   Icons.chevron_right,
//                   size: 20,
//                   color: AdminDesignSystem.textTertiary,
//                 ),
//               ],
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _BreakdownItem(
//                     label: 'Total Deposits',
//                     value: currencyFormatter.format(totalDeposits),
//                     icon: Icons.arrow_downward,
//                     color: AdminDesignSystem.statusActive,
//                   ),
//                 ),
//                 const SizedBox(width: AdminDesignSystem.spacing12),
//                 Expanded(
//                   child: _BreakdownItem(
//                     label: 'Total Withdrawals',
//                     value: currencyFormatter.format(totalWithdrawals),
//                     icon: Icons.arrow_upward,
//                     color: AdminDesignSystem.primaryNavy,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==================== CASH FLOW DETAIL SHEET ====================

// class _CashFlowDetailSheet extends StatefulWidget {
//   final double totalDeposits;
//   final double totalWithdrawals;

//   const _CashFlowDetailSheet({
//     required this.totalDeposits,
//     required this.totalWithdrawals,
//   });

//   @override
//   State<_CashFlowDetailSheet> createState() => _CashFlowDetailSheetState();
// }

// class _CashFlowDetailSheetState extends State<_CashFlowDetailSheet> {
//   final FirestoreService _firestoreService = FirestoreService();
//   final _currencyFormatter = NumberFormat.currency(
//     symbol: '₦',
//     decimalDigits: 0,
//   );

//   String _selectedType = 'All';
//   DateTime? _startDate;
//   DateTime? _endDate;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AdminDesignSystem.background,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(AdminDesignSystem.radius16),
//           topRight: Radius.circular(AdminDesignSystem.radius16),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Handle bar
//           Center(
//             child: Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(top: AdminDesignSystem.spacing12),
//               decoration: BoxDecoration(
//                 color: AdminDesignSystem.divider,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           // Header
//           Container(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//             decoration: BoxDecoration(
//               color: AdminDesignSystem.cardBackground,
//               boxShadow: [AdminDesignSystem.softShadow],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Cash Flow Breakdown',
//                         style: AdminDesignSystem.headingMedium.copyWith(
//                           color: AdminDesignSystem.primaryNavy,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(height: AdminDesignSystem.spacing4),
//                       Text(
//                         'Deposits and withdrawals',
//                         style: AdminDesignSystem.labelMedium.copyWith(
//                           color: AdminDesignSystem.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.close, size: 20),
//                   color: AdminDesignSystem.textTertiary,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(
//                     minWidth: 40,
//                     minHeight: 40,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Filters
//           Container(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//             color: AdminDesignSystem.background,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Filter by type',
//                   style: AdminDesignSystem.labelMedium.copyWith(
//                     color: AdminDesignSystem.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing8),
//                 Row(
//                   children: [
//                     _buildFilterChip('All'),
//                     const SizedBox(width: AdminDesignSystem.spacing8),
//                     _buildFilterChip('Deposits'),
//                     const SizedBox(width: AdminDesignSystem.spacing8),
//                     _buildFilterChip('Withdrawals'),
//                   ],
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Filter by date',
//                       style: AdminDesignSystem.labelMedium.copyWith(
//                         color: AdminDesignSystem.textSecondary,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _startDate = null;
//                           _endDate = null;
//                         });
//                       },
//                       child: Text(
//                         'Clear',
//                         style: AdminDesignSystem.labelMedium.copyWith(
//                           color: AdminDesignSystem.accentTeal,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildDateButton(
//                         'Start Date',
//                         _startDate,
//                         () => _showStartDatePicker(context),
//                       ),
//                     ),
//                     const SizedBox(width: AdminDesignSystem.spacing8),
//                     Expanded(
//                       child: _buildDateButton(
//                         'End Date',
//                         _endDate,
//                         () => _showEndDatePicker(context),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ), // Transaction List
//           Expanded(
//             child: StreamBuilder<List<TransactionModel>>(
//               stream: _getFilteredTransactionsStream(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: AdminDesignSystem.accentTeal,
//                     ),
//                   );
//                 }

//                 final transactions = snapshot.data ?? [];
//                 if (transactions.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.receipt_long_outlined,
//                           size: 48,
//                           color: AdminDesignSystem.textTertiary,
//                         ),
//                         const SizedBox(height: AdminDesignSystem.spacing12),
//                         Text(
//                           'No transactions',
//                           style: AdminDesignSystem.bodyMedium,
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.separated(
//                   padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//                   itemCount: transactions.length,
//                   separatorBuilder: (_, __) =>
//                       const SizedBox(height: AdminDesignSystem.spacing12),
//                   itemBuilder: (context, index) {
//                     final txn = transactions[index];
//                     return _CashFlowTransactionRow(
//                       transaction: txn,
//                       currencyFormatter: _currencyFormatter,
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label) {
//     final isSelected = _selectedType == label;
//     return InkWell(
//       onTap: () => setState(() => _selectedType = label),
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AdminDesignSystem.spacing12,
//           vertical: AdminDesignSystem.spacing8,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AdminDesignSystem.accentTeal
//               : AdminDesignSystem.background,
//           borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//           border: Border.all(
//             color: isSelected
//                 ? AdminDesignSystem.accentTeal
//                 : AdminDesignSystem.divider,
//           ),
//         ),
//         child: Text(
//           label,
//           style: AdminDesignSystem.labelMedium.copyWith(
//             color: isSelected ? Colors.white : AdminDesignSystem.textSecondary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AdminDesignSystem.spacing12,
//           vertical: AdminDesignSystem.spacing8,
//         ),
//         decoration: BoxDecoration(
//           color: AdminDesignSystem.cardBackground,
//           borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//           border: Border.all(color: AdminDesignSystem.divider),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: AdminDesignSystem.labelSmall.copyWith(
//                 color: AdminDesignSystem.textSecondary,
//               ),
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing4),
//             Text(
//               date != null
//                   ? '${date.day}/${date.month}/${date.year}'
//                   : 'Select date',
//               style: AdminDesignSystem.bodySmall.copyWith(
//                 color: date != null
//                     ? AdminDesignSystem.textPrimary
//                     : AdminDesignSystem.textTertiary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _showStartDatePicker(BuildContext context) async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _startDate ?? DateTime(now.year, now.month - 1),
//       firstDate: DateTime(now.year - 2),
//       lastDate: now,
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.light(primary: AdminDesignSystem.accentTeal),
//         ),
//         child: child!,
//       ),
//     );

//     if (picked != null) {
//       setState(() => _startDate = picked);
//     }
//   }

//   Future<void> _showEndDatePicker(BuildContext context) async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _endDate ?? now,
//       firstDate: _startDate ?? DateTime(now.year - 2),
//       lastDate: now,
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.light(primary: AdminDesignSystem.accentTeal),
//         ),
//         child: child!,
//       ),
//     );

//     if (picked != null) {
//       setState(() => _endDate = picked);
//     }
//   }

//   Stream<List<TransactionModel>> _getFilteredTransactionsStream() {
//     Query query = _firestoreService.firestore
//         .collection('transactions')
//         .where('transactionStatus', isEqualTo: 'completed');

//     if (_selectedType == 'Deposits') {
//       query = query.where('transactionType', isEqualTo: 'deposit');
//     } else if (_selectedType == 'Withdrawals') {
//       query = query.where('transactionType', isEqualTo: 'withdrawal');
//     }

//     if (_startDate != null) {
//       query = query.where(
//         'transactionDate',
//         isGreaterThanOrEqualTo: _startDate,
//       );
//     }
//     if (_endDate != null) {
//       query = query.where(
//         'transactionDate',
//         isLessThanOrEqualTo: _endDate!.add(const Duration(days: 1)),
//       );
//     }

//     return (query as Query<Map<String, dynamic>>)
//         .orderBy('transactionDate', descending: true)
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map((doc) => TransactionModel.fromFirestore(doc))
//               .toList(),
//         );
//   }
// }

// // ==================== HELPER WIDGETS ====================

// class _BreakdownItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const _BreakdownItem({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
//               decoration: BoxDecoration(
//                 color: color.withAlpha(25),
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//               ),
//               child: Icon(icon, size: 16, color: color),
//             ),
//             const SizedBox(width: AdminDesignSystem.spacing8),
//             Expanded(
//               child: Text(
//                 label,
//                 style: AdminDesignSystem.labelSmall.copyWith(
//                   color: AdminDesignSystem.textSecondary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: AdminDesignSystem.spacing8),
//         Text(
//           value,
//           style: AdminDesignSystem.bodyLarge.copyWith(
//             color: color,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ],
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

// class _CashFlowTransactionRow extends StatelessWidget {
//   final TransactionModel transaction;
//   final NumberFormat currencyFormatter;

//   const _CashFlowTransactionRow({
//     required this.transaction,
//     required this.currencyFormatter,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDeposit = transaction.type == TransactionType.deposit;
//     final color = isDeposit
//         ? AdminDesignSystem.statusActive
//         : AdminDesignSystem.primaryNavy;

//     return Container(
//       decoration: BoxDecoration(
//         color: AdminDesignSystem.cardBackground,
//         borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//         boxShadow: [AdminDesignSystem.softShadow],
//       ),
//       padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
//             decoration: BoxDecoration(
//               color: color.withAlpha(38),
//               borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//             ),
//             child: Icon(
//               isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
//               size: 18,
//               color: color,
//             ),
//           ),
//           const SizedBox(width: AdminDesignSystem.spacing12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isDeposit ? 'Deposit' : 'Withdrawal',
//                   style: AdminDesignSystem.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: AdminDesignSystem.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing4),
//                 Text(
//                   _formatDate(transaction.createdAt),
//                   style: AdminDesignSystem.labelSmall.copyWith(
//                     color: AdminDesignSystem.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '${isDeposit ? '+' : '−'}${currencyFormatter.format(transaction.amount)}',
//                 style: AdminDesignSystem.bodyMedium.copyWith(
//                   fontWeight: FontWeight.w700,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: AdminDesignSystem.spacing4),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AdminDesignSystem.spacing8,
//                   vertical: AdminDesignSystem.spacing4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AdminDesignSystem.statusActive.withAlpha(25),
//                   borderRadius: BorderRadius.circular(
//                     AdminDesignSystem.radius8,
//                   ),
//                 ),
//                 child: Text(
//                   'Completed',
//                   style: AdminDesignSystem.labelSmall.copyWith(
//                     color: AdminDesignSystem.statusActive,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(now.year, now.month, now.day - 1);
//     final dateOnly = DateTime(date.year, date.month, date.day);

//     if (dateOnly == today) {
//       return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     } else if (dateOnly == yesterday) {
//       return 'Yesterday';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
// lib/screens/admin/dashboard/widgets/stats_grid.dart
// ✅ FIXED: Cash flow transactions no longer disappear, deposits/withdrawals now show

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../services/firestore_service.dart';
import '../../../../models/transaction_model.dart';

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
            onTap: () =>
                _showCashFlowSheet(context, totalDeposits, totalWithdrawals),
          ),
        ],
      ),
    );
  }

  void _showCashFlowSheet(
    BuildContext context,
    double totalDeposits,
    double totalWithdrawals,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => _CashFlowDetailSheet(
        totalDeposits: totalDeposits,
        totalWithdrawals: totalWithdrawals,
      ),
    );
  }
}

// ==================== CLICKABLE CASH FLOW CARD ====================

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
  final double totalDeposits;
  final double totalWithdrawals;

  const _CashFlowDetailSheet({
    required this.totalDeposits,
    required this.totalWithdrawals,
  });

  @override
  State<_CashFlowDetailSheet> createState() => _CashFlowDetailSheetState();
}

class _CashFlowDetailSheetState extends State<_CashFlowDetailSheet> {
  final FirestoreService _firestoreService = FirestoreService();
  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  String _selectedType = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

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
          Container(
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
                        'Cash Flow Breakdown',
                        style: AdminDesignSystem.headingMedium.copyWith(
                          color: AdminDesignSystem.primaryNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing4),
                      Text(
                        'Deposits and withdrawals',
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

          // Filters
          Container(
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
                const SizedBox(height: AdminDesignSystem.spacing16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter by date',
                      style: AdminDesignSystem.labelMedium.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                      child: Text(
                        'Clear',
                        style: AdminDesignSystem.labelMedium.copyWith(
                          color: AdminDesignSystem.accentTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDesignSystem.spacing8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateButton(
                        'Start Date',
                        _startDate,
                        () => _showStartDatePicker(context),
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing8),
                    Expanded(
                      child: _buildDateButton(
                        'End Date',
                        _endDate,
                        () => _showEndDatePicker(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ FIXED: Transaction List - Now properly streams without disappearing
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: _getFilteredTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AdminDesignSystem.accentTeal,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                    child: Text(
                      'Error loading transactions',
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.statusError,
                      ),
                    ),
                  );
                }

                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
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
                        Text(
                          'No transactions',
                          style: AdminDesignSystem.bodyMedium,
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
                    return _CashFlowTransactionRow(
                      transaction: txn,
                      currencyFormatter: _currencyFormatter,
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

  Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminDesignSystem.spacing12,
          vertical: AdminDesignSystem.spacing8,
        ),
        decoration: BoxDecoration(
          color: AdminDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
          border: Border.all(color: AdminDesignSystem.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AdminDesignSystem.labelSmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: date != null
                    ? AdminDesignSystem.textPrimary
                    : AdminDesignSystem.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStartDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime(now.year, now.month - 1),
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AdminDesignSystem.accentTeal),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _showEndDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: _startDate ?? DateTime(now.year - 2),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AdminDesignSystem.accentTeal),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  // ✅ FIXED: Better stream handling - avoid compound Firestore queries
  // Use simpler base query + in-memory filtering for dates
  Stream<List<TransactionModel>> _getFilteredTransactionsStream() {
    // Start with base query: only completed transactions
    Query query = _firestoreService.firestore
        .collection('transactions')
        .where('transactionStatus', isEqualTo: 'completed');

    // Add type filter if selected
    if (_selectedType == 'Deposits') {
      query = query.where('transactionType', isEqualTo: 'deposit');
    } else if (_selectedType == 'Withdrawals') {
      query = query.where('transactionType', isEqualTo: 'withdrawal');
    }

    // Return stream - apply date filtering in-memory to avoid Firestore limits
    return (query as Query<Map<String, dynamic>>)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) {
          var docs = snapshot.docs;

          // Filter by start date in-memory
          if (_startDate != null) {
            docs = docs.where((doc) {
              final txnDate = doc.data()['transactionDate'] as Timestamp?;
              return txnDate != null && txnDate.toDate().isAfter(_startDate!);
            }).toList();
          }

          // Filter by end date in-memory
          if (_endDate != null) {
            docs = docs.where((doc) {
              final txnDate = doc.data()['transactionDate'] as Timestamp?;
              return txnDate != null &&
                  txnDate.toDate().isBefore(
                    _endDate!.add(const Duration(days: 1)),
                  );
            }).toList();
          }

          return docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList();
        });
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

class _CashFlowTransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final NumberFormat currencyFormatter;

  const _CashFlowTransactionRow({
    required this.transaction,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.transactionType == TransactionType.deposit;
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
                  _formatDate(transaction.transactionDate),
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDeposit ? '+' : '−'}${currencyFormatter.format(transaction.amount)}',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminDesignSystem.spacing8,
                  vertical: AdminDesignSystem.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.statusActive.withAlpha(25),
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius8,
                  ),
                ),
                child: Text(
                  'Completed',
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: AdminDesignSystem.statusActive,
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
