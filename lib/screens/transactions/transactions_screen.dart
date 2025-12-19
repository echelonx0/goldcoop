// // lib/screens/transactions/screens_08_transactions_screen.dart

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import '../../components/base/app_card.dart';
// import '../../components/base/app_button.dart';
// import '../../core/theme/app_colors.dart';
// import '../../models/transaction_model.dart';
// import '../../services/firestore_service.dart';

// class TransactionsScreen extends StatefulWidget {
//   final String uid;

//   const TransactionsScreen({super.key, required this.uid});

//   @override
//   State<TransactionsScreen> createState() => _TransactionsScreenState();
// }

// class _TransactionsScreenState extends State<TransactionsScreen> {
//   late final FirestoreService _firestoreService;
//   final TextEditingController _searchController = TextEditingController();

//   TransactionType? _selectedType;
//   TransactionStatus? _selectedStatus;
//   DateRange? _selectedDateRange;
//   bool _showFilters = false;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreService = FirestoreService();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundNeutral,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildSearchAndFilter(),
//           Expanded(child: _buildContent()),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: Text(
//         'Transactions',
//         style: AppTextTheme.heading2.copyWith(color: AppColors.deepNavy),
//       ),
//       elevation: 0,
//       backgroundColor: AppColors.backgroundWhite,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back),
//         onPressed: () => Navigator.pop(context),
//         color: AppColors.deepNavy,
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.download),
//           onPressed: _downloadTransactions,
//           color: AppColors.primaryOrange,
//           tooltip: 'Download transactions',
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchAndFilter() {
//     return Container(
//       color: AppColors.backgroundWhite,
//       padding: const EdgeInsets.all(AppSpacing.md),
//       child: Column(
//         children: [
//           // Search bar
//           _buildSearchBar(),
//           const SizedBox(height: AppSpacing.md),

//           // Active filters display
//           if (_selectedType != null ||
//               _selectedStatus != null ||
//               _selectedDateRange != null)
//             _buildActiveFilters(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Search transactions',
//               prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//                 borderSide: const BorderSide(color: AppColors.borderLight),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//                 borderSide: const BorderSide(color: AppColors.borderLight),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//                 borderSide: const BorderSide(
//                   color: AppColors.primaryOrange,
//                   width: 2,
//                 ),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: AppSpacing.md,
//                 vertical: AppSpacing.sm,
//               ),
//             ),
//             onChanged: (_) => setState(() {}),
//           ),
//         ),
//         const SizedBox(width: AppSpacing.sm),
//         GestureDetector(
//           onTap: () => setState(() => _showFilters = !_showFilters),
//           child: Container(
//             decoration: BoxDecoration(
//               color: _showFilters
//                   ? AppColors.primaryOrange
//                   : AppColors.backgroundNeutral,
//               border: Border.all(
//                 color: _showFilters
//                     ? AppColors.primaryOrange
//                     : AppColors.borderLight,
//               ),
//               borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//             ),
//             padding: const EdgeInsets.all(AppSpacing.sm),
//             child: Icon(
//               Icons.tune,
//               color: _showFilters
//                   ? AppColors.backgroundWhite
//                   : AppColors.textSecondary,
//               size: 20,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActiveFilters() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           if (_selectedType != null)
//             Padding(
//               padding: const EdgeInsets.only(right: AppSpacing.sm),
//               child: Chip(
//                 label: Text(_getTransactionTypeLabel(_selectedType!)),
//                 onDeleted: () {
//                   setState(() => _selectedType = null);
//                 },
//               ),
//             ),
//           if (_selectedStatus != null)
//             Padding(
//               padding: const EdgeInsets.only(right: AppSpacing.sm),
//               child: Chip(
//                 label: Text(_getStatusLabel(_selectedStatus!)),
//                 onDeleted: () {
//                   setState(() => _selectedStatus = null);
//                 },
//               ),
//             ),
//           if (_selectedDateRange != null)
//             Chip(
//               label: Text(_formatDateRange(_selectedDateRange!)),
//               onDeleted: () {
//                 setState(() => _selectedDateRange = null);
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (_showFilters) {
//       return _buildFilterPanel();
//     }

//     return StreamBuilder<List<TransactionModel>>(
//       stream: _firestoreService.getUserTransactionsStream(userId: widget.uid),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(color: AppColors.primaryOrange),
//           );
//         }

//         if (snapshot.hasError) {
//           log(snapshot.error.toString());
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, size: 48, color: AppColors.warmRed),
//                 const SizedBox(height: AppSpacing.md),
//                 Text(
//                   'Failed to load ${snapshot.error}',
//                   style: AppTextTheme.bodyRegular.copyWith(
//                     color: AppColors.warmRed,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         var transactions = snapshot.data ?? [];

//         // Apply filters
//         if (_selectedType != null) {
//           transactions = transactions
//               .where((t) => t.type == _selectedType)
//               .toList();
//         }

//         if (_selectedStatus != null) {
//           transactions = transactions
//               .where((t) => t.status == _selectedStatus)
//               .toList();
//         }

//         if (_selectedDateRange != null) {
//           transactions = transactions
//               .where(
//                 (t) =>
//                     t.createdAt.isAfter(_selectedDateRange!.start) &&
//                     t.createdAt.isBefore(
//                       _selectedDateRange!.end.add(const Duration(days: 1)),
//                     ),
//               )
//               .toList();
//         }

//         // Apply search
//         final searchTerm = _searchController.text.toLowerCase();
//         if (searchTerm.isNotEmpty) {
//           transactions = transactions
//               .where(
//                 (t) =>
//                     t.description.toLowerCase().contains(searchTerm) ||
//                     t.referenceNumber!.toLowerCase().contains(searchTerm) ||
//                     t.amount.toStringAsFixed(0).contains(searchTerm),
//               )
//               .toList();
//         }

//         // Sort by date descending (newest first)
//         transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//         if (transactions.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.history, size: 48, color: AppColors.textSecondary),
//                 const SizedBox(height: AppSpacing.md),
//                 Text(
//                   'No transactions found',
//                   style: AppTextTheme.bodyRegular.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: AppSpacing.sm),
//                 Text(
//                   'Try adjusting your filters',
//                   style: AppTextTheme.bodySmall.copyWith(
//                     color: AppColors.textTertiary,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(AppSpacing.md),
//           itemCount: transactions.length,
//           itemBuilder: (context, index) {
//             final transaction = transactions[index];
//             final previousTransaction = index > 0
//                 ? transactions[index - 1]
//                 : null;

//             // Show date header if transaction is from a different day
//             final showDateHeader =
//                 previousTransaction == null ||
//                 !_isSameDay(
//                   transaction.createdAt,
//                   previousTransaction.createdAt,
//                 );

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (showDateHeader)
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       top: AppSpacing.lg,
//                       bottom: AppSpacing.md,
//                     ),
//                     child: Text(
//                       _formatTransactionDate(transaction.createdAt),
//                       style: AppTextTheme.bodySmall.copyWith(
//                         color: AppColors.textSecondary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 _buildTransactionCard(context, transaction),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTransactionCard(
//     BuildContext context,
//     TransactionModel transaction,
//   ) {
//     final isIncoming = _isIncomingTransaction(transaction.type);

//     return GestureDetector(
//       onTap: () => _showTransactionDetails(context, transaction),
//       child: StandardCard(
//         child: Row(
//           children: [
//             // Icon
//             Container(
//               decoration: BoxDecoration(
//                 color: _getTransactionColor(transaction.type).withAlpha(25),
//                 borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//               ),
//               padding: const EdgeInsets.all(AppSpacing.md),
//               child: Icon(
//                 _getTransactionIcon(transaction.type),
//                 color: _getTransactionColor(transaction.type),
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: AppSpacing.md),

//             // Description and details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     transaction.description,
//                     style: AppTextTheme.bodyRegular.copyWith(
//                       color: AppColors.deepNavy,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: AppSpacing.xs),
//                   Row(
//                     children: [
//                       Text(
//                         _getTransactionTypeLabel(transaction.type),
//                         style: AppTextTheme.bodySmall.copyWith(
//                           color: AppColors.textSecondary,
//                           fontSize: 12,
//                         ),
//                       ),
//                       const Text(
//                         ' • ',
//                         style: TextStyle(color: AppColors.textTertiary),
//                       ),
//                       Text(
//                         _formatTransactionTime(transaction.createdAt),
//                         style: AppTextTheme.bodySmall.copyWith(
//                           color: AppColors.textSecondary,
//                           fontSize: 12,
//                         ),
//                       ),
//                       if (transaction.status != TransactionStatus.completed)
//                         Padding(
//                           padding: const EdgeInsets.only(left: AppSpacing.sm),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: _getStatusColor(
//                                 transaction.status,
//                               ).withAlpha(25),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: AppSpacing.xs,
//                               vertical: 2,
//                             ),
//                             child: Text(
//                               _getStatusLabel(transaction.status),
//                               style: AppTextTheme.micro.copyWith(
//                                 color: _getStatusColor(transaction.status),
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Amount
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '${isIncoming ? '+' : '−'}₦${transaction.amount.toStringAsFixed(0)}',
//                   style: AppTextTheme.bodyRegular.copyWith(
//                     color: isIncoming
//                         ? AppColors.tealSuccess
//                         : AppColors.deepNavy,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 if (transaction.fees! > 0)
//                   Text(
//                     'Fee: ₦${transaction.fees!.toStringAsFixed(0)}',
//                     style: AppTextTheme.bodySmall.copyWith(
//                       color: AppColors.textSecondary,
//                       fontSize: 11,
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterPanel() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(AppSpacing.md),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Type filter
//           Text(
//             'Transaction Type',
//             style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
//           ),
//           const SizedBox(height: AppSpacing.md),
//           Wrap(
//             spacing: AppSpacing.sm,
//             runSpacing: AppSpacing.sm,
//             children: TransactionType.values
//                 .map(
//                   (type) => FilterChip(
//                     label: Text(_getTransactionTypeLabel(type)),
//                     selected: _selectedType == type,
//                     onSelected: (selected) {
//                       setState(() {
//                         _selectedType = selected ? type : null;
//                       });
//                     },
//                   ),
//                 )
//                 .toList(),
//           ),

//           const SizedBox(height: AppSpacing.lg),

//           // Status filter
//           Text(
//             'Status',
//             style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
//           ),
//           const SizedBox(height: AppSpacing.md),
//           Wrap(
//             spacing: AppSpacing.sm,
//             runSpacing: AppSpacing.sm,
//             children: TransactionStatus.values
//                 .map(
//                   (status) => FilterChip(
//                     label: Text(_getStatusLabel(status)),
//                     selected: _selectedStatus == status,
//                     onSelected: (selected) {
//                       setState(() {
//                         _selectedStatus = selected ? status : null;
//                       });
//                     },
//                   ),
//                 )
//                 .toList(),
//           ),

//           const SizedBox(height: AppSpacing.lg),

//           // Date range filter
//           Text(
//             'Date Range',
//             style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
//           ),
//           const SizedBox(height: AppSpacing.md),
//           Wrap(
//             spacing: AppSpacing.sm,
//             runSpacing: AppSpacing.sm,
//             children:
//                 [
//                       (
//                         label: 'Last 7 days',
//                         range: DateRange(
//                           start: DateTime.now().subtract(
//                             const Duration(days: 7),
//                           ),
//                           end: DateTime.now(),
//                         ),
//                       ),
//                       (
//                         label: 'Last 30 days',
//                         range: DateRange(
//                           start: DateTime.now().subtract(
//                             const Duration(days: 30),
//                           ),
//                           end: DateTime.now(),
//                         ),
//                       ),
//                       (
//                         label: 'Last 3 months',
//                         range: DateRange(
//                           start: DateTime.now().subtract(
//                             const Duration(days: 90),
//                           ),
//                           end: DateTime.now(),
//                         ),
//                       ),
//                       (
//                         label: 'Last year',
//                         range: DateRange(
//                           start: DateTime.now().subtract(
//                             const Duration(days: 365),
//                           ),
//                           end: DateTime.now(),
//                         ),
//                       ),
//                     ]
//                     .map(
//                       (item) => FilterChip(
//                         label: Text(item.label),
//                         selected: _selectedDateRange == item.range,
//                         onSelected: (selected) {
//                           setState(() {
//                             _selectedDateRange = selected ? item.range : null;
//                           });
//                         },
//                       ),
//                     )
//                     .toList(),
//           ),

//           const SizedBox(height: AppSpacing.lg),

//           // Custom date picker
//           ListTile(
//             title: Text(
//               'Custom Date Range',
//               style: AppTextTheme.bodyRegular.copyWith(
//                 color: AppColors.deepNavy,
//               ),
//             ),
//             trailing: const Icon(Icons.calendar_today),
//             onTap: _showCustomDatePicker,
//             contentPadding: EdgeInsets.zero,
//           ),

//           const SizedBox(height: AppSpacing.lg),

//           // Clear filters button
//           SizedBox(
//             width: double.infinity,
//             child: SecondaryButton(
//               label: 'Clear All Filters',
//               onPressed: () {
//                 setState(() {
//                   _selectedType = null;
//                   _selectedStatus = null;
//                   _selectedDateRange = null;
//                   _searchController.clear();
//                 });
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showTransactionDetails(
//     BuildContext context,
//     TransactionModel transaction,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => _buildDetailsSheet(transaction),
//     );
//   }

//   Widget _buildDetailsSheet(TransactionModel transaction) {
//     final isIncoming = _isIncomingTransaction(transaction.type);

//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.75,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundWhite,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(AppBorderRadius.large),
//           topRight: Radius.circular(AppBorderRadius.large),
//         ),
//       ),
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(AppSpacing.lg),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Handle bar
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: AppColors.borderLight,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: AppSpacing.lg),

//             // Amount display
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: _getTransactionColor(transaction.type).withAlpha(12),
//                 borderRadius: BorderRadius.circular(AppBorderRadius.large),
//                 border: Border.all(
//                   color: _getTransactionColor(transaction.type).withAlpha(25),
//                 ),
//               ),
//               padding: const EdgeInsets.all(AppSpacing.lg),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     '${isIncoming ? '+' : '−'}₦${transaction.amount.toStringAsFixed(0)}',
//                     style: AppTextTheme.display.copyWith(
//                       color: _getTransactionColor(transaction.type),
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.sm),
//                   Text(
//                     transaction.description,
//                     style: AppTextTheme.heading3.copyWith(
//                       color: AppColors.deepNavy,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: AppSpacing.lg),

//             // Status badge
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: _getStatusColor(transaction.status).withAlpha(12),
//                 borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//                 border: Border.all(
//                   color: _getStatusColor(transaction.status).withAlpha(25),
//                 ),
//               ),
//               padding: const EdgeInsets.all(AppSpacing.md),
//               child: Row(
//                 children: [
//                   Icon(
//                     _getStatusIcon(transaction.status),
//                     color: _getStatusColor(transaction.status),
//                     size: 20,
//                   ),
//                   const SizedBox(width: AppSpacing.md),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Status',
//                           style: AppTextTheme.bodySmall.copyWith(
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                         Text(
//                           _getStatusLabel(transaction.status),
//                           style: AppTextTheme.bodyRegular.copyWith(
//                             color: _getStatusColor(transaction.status),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: AppSpacing.lg),

//             // Details grid
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               mainAxisSpacing: AppSpacing.md,
//               crossAxisSpacing: AppSpacing.md,
//               children: [
//                 _buildDetailItem(
//                   'Type',
//                   _getTransactionTypeLabel(transaction.type),
//                 ),
//                 _buildDetailItem(
//                   'Date & Time',
//                   _formatDetailedDateTime(transaction.createdAt),
//                 ),
//                 _buildDetailItem(
//                   'Amount',
//                   '₦${transaction.amount.toStringAsFixed(0)}',
//                 ),
//                 if (transaction.fees! > 0)
//                   _buildDetailItem(
//                     'Fees',
//                     '₦${transaction.fees!.toStringAsFixed(0)}',
//                   )
//                 else
//                   _buildDetailItem('Fees', 'None'),
//                 _buildDetailItem(
//                   'Net Amount',
//                   '₦${transaction.netAmount!.toStringAsFixed(0)}',
//                 ),
//                 _buildDetailItem(
//                   'Reference',
//                   transaction.referenceNumber.toString(),
//                 ),
//               ],
//             ),

//             const SizedBox(height: AppSpacing.lg),

//             // Additional info
//             if (transaction.investmentId != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Investment',
//                     style: AppTextTheme.heading3.copyWith(
//                       color: AppColors.deepNavy,
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.md),
//                   Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: AppColors.navyLight,
//                       borderRadius: BorderRadius.circular(
//                         AppBorderRadius.medium,
//                       ),
//                     ),
//                     padding: const EdgeInsets.all(AppSpacing.md),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'ID: ${transaction.investmentId!}',
//                           style: AppTextTheme.bodySmall.copyWith(
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                         if (transaction.description.contains('Investment'))
//                           Padding(
//                             padding: const EdgeInsets.only(top: AppSpacing.sm),
//                             child: Text(
//                               'View investment details',
//                               style: AppTextTheme.bodyRegular.copyWith(
//                                 color: AppColors.primaryOrange,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.lg),
//                 ],
//               ),

//             // Failure reason (if applicable)
//             if (transaction.status == TransactionStatus.failed &&
//                 transaction.failureReason != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Failure Reason',
//                     style: AppTextTheme.heading3.copyWith(
//                       color: AppColors.deepNavy,
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.md),
//                   Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: AppColors.warmRed.withAlpha(12),
//                       borderRadius: BorderRadius.circular(
//                         AppBorderRadius.medium,
//                       ),
//                       border: Border.all(
//                         color: AppColors.warmRed.withAlpha(25),
//                       ),
//                     ),
//                     padding: const EdgeInsets.all(AppSpacing.md),
//                     child: Text(
//                       transaction.failureReason!,
//                       style: AppTextTheme.bodyRegular.copyWith(
//                         color: AppColors.warmRed,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.lg),
//                 ],
//               ),

//             // Action buttons
//             if (transaction.status == TransactionStatus.failed)
//               SizedBox(
//                 width: double.infinity,
//                 child: PrimaryButton(
//                   label: 'Retry Transaction',
//                   onPressed: () {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Retry coming soon')),
//                     );
//                   },
//                 ),
//               )
//             else if (transaction.status == TransactionStatus.pending)
//               SizedBox(
//                 width: double.infinity,
//                 child: PrimaryButton(
//                   label: 'Check Status',
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Status check coming soon')),
//                     );
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailItem(String label, String value) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.backgroundNeutral,
//         borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//         border: Border.all(color: AppColors.borderLight),
//       ),
//       padding: const EdgeInsets.all(AppSpacing.md),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             label,
//             style: AppTextTheme.bodySmall.copyWith(
//               color: AppColors.textSecondary,
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(height: AppSpacing.sm),
//           Text(
//             value,
//             style: AppTextTheme.bodyRegular.copyWith(
//               color: AppColors.deepNavy,
//               fontWeight: FontWeight.w600,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showCustomDatePicker() async {
//     final now = DateTime.now();
//     final firstDate = DateTime(now.year - 5);
//     final startDate = await showDatePicker(
//       context: context,
//       initialDate: now.subtract(const Duration(days: 30)),
//       firstDate: firstDate,
//       lastDate: now,
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.light(primary: AppColors.primaryOrange),
//         ),
//         child: child!,
//       ),
//     );

//     if (startDate == null) return;

//     if (mounted) {
//       final endDate = await showDatePicker(
//         context: context,
//         initialDate: now,
//         firstDate: startDate,
//         lastDate: now,
//         builder: (context, child) => Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(primary: AppColors.primaryOrange),
//           ),
//           child: child!,
//         ),
//       );

//       if (endDate != null) {
//         setState(() {
//           _selectedDateRange = DateRange(start: startDate, end: endDate);
//         });
//       }
//     }
//   }

//   void _downloadTransactions() {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Download coming soon')));
//   }

//   // Helper methods
//   bool _isSameDay(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   bool _isIncomingTransaction(TransactionType type) {
//     return type == TransactionType.deposit ||
//         type == TransactionType.investment_return ||
//         type == TransactionType.interest_earned ||
//         type == TransactionType.referral_bonus ||
//         type == TransactionType.token_conversion ||
//         type == TransactionType.transfer_from_user;
//   }

//   String _getTransactionTypeLabel(TransactionType type) {
//     switch (type) {
//       case TransactionType.deposit:
//         return 'Deposit';
//       case TransactionType.withdrawal:
//         return 'Withdrawal';
//       case TransactionType.investment:
//         return 'Investment';
//       case TransactionType.investment_return:
//         return 'Investment Return';
//       case TransactionType.interest_earned:
//         return 'Interest Earned';
//       case TransactionType.referral_bonus:
//         return 'Referral Bonus';
//       case TransactionType.token_conversion:
//         return 'Token Conversion';
//       case TransactionType.token_purchase:
//         return 'Token Purchase';
//       case TransactionType.transfer_to_user:
//         return 'Transfer To User';
//       case TransactionType.transfer_from_user:
//         return 'Transfer From User';
//       case TransactionType.fee:
//         return 'Fee';
//       case TransactionType.adjustment:
//         return 'Adjustment';
//     }
//   }

//   String _getStatusLabel(TransactionStatus status) {
//     switch (status) {
//       case TransactionStatus.pending:
//         return 'Pending';
//       case TransactionStatus.processing:
//         return 'Processing';
//       case TransactionStatus.completed:
//         return 'Completed';
//       case TransactionStatus.failed:
//         return 'Failed';
//       case TransactionStatus.reversed:
//         return 'Reversed';
//       case TransactionStatus.cancelled:
//         return 'Cancelled';
//     }
//   }

//   Color _getTransactionColor(TransactionType type) {
//     switch (type) {
//       case TransactionType.deposit:
//       case TransactionType.investment_return:
//       case TransactionType.interest_earned:
//       case TransactionType.referral_bonus:
//       case TransactionType.transfer_from_user:
//         return AppColors.tealSuccess;

//       case TransactionType.withdrawal:
//       case TransactionType.investment:
//       case TransactionType.transfer_to_user:
//       case TransactionType.token_purchase:
//         return AppColors.deepNavy;

//       case TransactionType.token_conversion:
//         return AppColors.primaryOrange;

//       case TransactionType.fee:
//       case TransactionType.adjustment:
//         return AppColors.textSecondary;
//     }
//   }

//   Color _getStatusColor(TransactionStatus status) {
//     switch (status) {
//       case TransactionStatus.pending:
//       case TransactionStatus.processing:
//         return AppColors.softAmber;
//       case TransactionStatus.completed:
//         return AppColors.tealSuccess;
//       case TransactionStatus.failed:
//       case TransactionStatus.cancelled:
//         return AppColors.warmRed;
//       case TransactionStatus.reversed:
//         return AppColors.textSecondary;
//     }
//   }

//   IconData _getTransactionIcon(TransactionType type) {
//     switch (type) {
//       case TransactionType.deposit:
//         return Icons.arrow_downward;
//       case TransactionType.withdrawal:
//         return Icons.arrow_upward;
//       case TransactionType.investment:
//         return Icons.trending_up;
//       case TransactionType.investment_return:
//         return Icons.trending_up;
//       case TransactionType.interest_earned:
//         return Icons.percent;
//       case TransactionType.referral_bonus:
//         return Icons.card_giftcard;
//       case TransactionType.token_conversion:
//         return Icons.swap_horiz;
//       case TransactionType.token_purchase:
//         return Icons.shopping_cart;
//       case TransactionType.transfer_to_user:
//         return Icons.send;
//       case TransactionType.transfer_from_user:
//         return Icons.call_received;
//       case TransactionType.fee:
//         return Icons.receipt;
//       case TransactionType.adjustment:
//         return Icons.tune;
//     }
//   }

//   IconData _getStatusIcon(TransactionStatus status) {
//     switch (status) {
//       case TransactionStatus.pending:
//         return Icons.schedule;
//       case TransactionStatus.processing:
//         return Icons.hourglass_bottom;
//       case TransactionStatus.completed:
//         return Icons.check_circle;
//       case TransactionStatus.failed:
//         return Icons.cancel;
//       case TransactionStatus.reversed:
//         return Icons.undo;
//       case TransactionStatus.cancelled:
//         return Icons.cancel;
//     }
//   }

//   String _formatTransactionDate(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(now.year, now.month, now.day - 1);
//     final dateOnly = DateTime(date.year, date.month, date.day);

//     if (dateOnly == today) {
//       return 'Today';
//     } else if (dateOnly == yesterday) {
//       return 'Yesterday';
//     } else {
//       return '${date.day} ${_getMonthName(date.month)} ${date.year}';
//     }
//   }

//   String _formatTransactionTime(DateTime date) {
//     return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   String _formatDetailedDateTime(DateTime date) {
//     return '${_formatTransactionDate(date)} at ${_formatTransactionTime(date)}';
//   }

//   String _formatDateRange(DateRange range) {
//     final start = range.start;
//     final end = range.end;
//     return '${start.day}/${start.month} - ${end.day}/${end.month}';
//   }

//   String _getMonthName(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }
// }

// // Helper classes
// class DateRange {
//   final DateTime start;
//   final DateTime end;

//   DateRange({required this.start, required this.end});

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is DateRange && other.start == start && other.end == end;
//   }

//   @override
//   int get hashCode => start.hashCode ^ end.hashCode;
// }
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../components/base/app_card.dart';
import '../../components/base/app_button.dart';
import '../../core/theme/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class TransactionsScreen extends StatefulWidget {
  final String uid;

  const TransactionsScreen({super.key, required this.uid});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final FirestoreService _firestoreService;
  final TextEditingController _searchController = TextEditingController();

  TransactionType? _selectedType;
  TransactionStatus? _selectedStatus;
  DateRange? _selectedDateRange;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _TransactionSearchBar(
            searchController: _searchController,
            showFilters: _showFilters,
            onFilterTapped: () => setState(() => _showFilters = !_showFilters),
            selectedType: _selectedType,
            selectedStatus: _selectedStatus,
            selectedDateRange: _selectedDateRange,
            onTypeRemoved: () => setState(() => _selectedType = null),
            onStatusRemoved: () => setState(() => _selectedStatus = null),
            onDateRangeRemoved: () => setState(() => _selectedDateRange = null),
          ),
          Expanded(
            child: _showFilters
                ? _TransactionFilterPanel(
                    selectedType: _selectedType,
                    selectedStatus: _selectedStatus,
                    selectedDateRange: _selectedDateRange,
                    onTypeChanged: (type) =>
                        setState(() => _selectedType = type),
                    onStatusChanged: (status) =>
                        setState(() => _selectedStatus = status),
                    onDateRangeChanged: (range) =>
                        setState(() => _selectedDateRange = range),
                    onClearFilters: () {
                      setState(() {
                        _selectedType = null;
                        _selectedStatus = null;
                        _selectedDateRange = null;
                        _searchController.clear();
                      });
                    },
                    onCustomDatePicker: _showCustomDatePicker,
                  )
                : _TransactionList(
                    uid: widget.uid,
                    firestoreService: _firestoreService,
                    selectedType: _selectedType,
                    selectedStatus: _selectedStatus,
                    selectedDateRange: _selectedDateRange,
                    searchTerm: _searchController.text.toLowerCase(),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Transactions',
        style: AppTextTheme.heading2.copyWith(color: AppColors.deepNavy),
      ),
      elevation: 0,
      backgroundColor: AppColors.backgroundWhite,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        color: AppColors.deepNavy,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: _downloadTransactions,
          color: AppColors.primaryOrange,
          tooltip: 'Download transactions',
        ),
      ],
    );
  }

  Future<void> _showCustomDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5);
    final startDate = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 30)),
      firstDate: firstDate,
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primaryOrange),
        ),
        child: child!,
      ),
    );

    if (startDate == null) return;

    if (mounted) {
      final endDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: startDate,
        lastDate: now,
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryOrange),
          ),
          child: child!,
        ),
      );

      if (endDate != null) {
        setState(() {
          _selectedDateRange = DateRange(start: startDate, end: endDate);
        });
      }
    }
  }

  void _downloadTransactions() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Download coming soon')));
  }
}

// ==================== SEARCH BAR WIDGET ====================

class _TransactionSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool showFilters;
  final VoidCallback onFilterTapped;
  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final DateRange? selectedDateRange;
  final VoidCallback onTypeRemoved;
  final VoidCallback onStatusRemoved;
  final VoidCallback onDateRangeRemoved;

  const _TransactionSearchBar({
    required this.searchController,
    required this.showFilters,
    required this.onFilterTapped,
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.onTypeRemoved,
    required this.onStatusRemoved,
    required this.onDateRangeRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        selectedType != null ||
        selectedStatus != null ||
        selectedDateRange != null;

    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search transactions',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.primaryOrange,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: onFilterTapped,
                  child: Container(
                    decoration: BoxDecoration(
                      color: showFilters
                          ? AppColors.primaryOrange
                          : AppColors.backgroundNeutral,
                      border: Border.all(
                        color: showFilters
                            ? AppColors.primaryOrange
                            : AppColors.borderLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.medium,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.tune,
                      color: showFilters
                          ? AppColors.backgroundWhite
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasFilters)
            DelayedDisplay(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (selectedType != null)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Chip(
                            label: Text(
                              _getTransactionTypeLabel(selectedType!),
                            ),
                            onDeleted: onTypeRemoved,
                          ),
                        ),
                      if (selectedStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Chip(
                            label: Text(_getStatusLabel(selectedStatus!)),
                            onDeleted: onStatusRemoved,
                          ),
                        ),
                      if (selectedDateRange != null)
                        Chip(
                          label: Text(_formatDateRange(selectedDateRange!)),
                          onDeleted: onDateRangeRemoved,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.investment_return:
        return 'Investment Return';
      case TransactionType.interest_earned:
        return 'Interest Earned';
      case TransactionType.referral_bonus:
        return 'Referral Bonus';
      case TransactionType.token_conversion:
        return 'Token Conversion';
      case TransactionType.token_purchase:
        return 'Token Purchase';
      case TransactionType.transfer_to_user:
        return 'Transfer To User';
      case TransactionType.transfer_from_user:
        return 'Transfer From User';
      case TransactionType.fee:
        return 'Fee';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.reversed:
        return 'Reversed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDateRange(DateRange range) {
    final start = range.start;
    final end = range.end;
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }
}

// ==================== FILTER PANEL WIDGET ====================

class _TransactionFilterPanel extends StatelessWidget {
  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final DateRange? selectedDateRange;
  final Function(TransactionType?) onTypeChanged;
  final Function(TransactionStatus?) onStatusChanged;
  final Function(DateRange?) onDateRangeChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onCustomDatePicker;

  const _TransactionFilterPanel({
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
    required this.onCustomDatePicker,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Transaction Type',
              style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 150),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: TransactionType.values
                  .map(
                    (type) => FilterChip(
                      label: Text(_getTransactionTypeLabel(type)),
                      selected: selectedType == type,
                      onSelected: (selected) {
                        onTypeChanged(selected ? type : null);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Status',
              style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 250),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: TransactionStatus.values
                  .map(
                    (status) => FilterChip(
                      label: Text(_getStatusLabel(status)),
                      selected: selectedStatus == status,
                      onSelected: (selected) {
                        onStatusChanged(selected ? status : null);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Date Range',
              style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 350),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children:
                  [
                        (
                          label: 'Last 7 days',
                          range: DateRange(
                            start: DateTime.now().subtract(
                              const Duration(days: 7),
                            ),
                            end: DateTime.now(),
                          ),
                        ),
                        (
                          label: 'Last 30 days',
                          range: DateRange(
                            start: DateTime.now().subtract(
                              const Duration(days: 30),
                            ),
                            end: DateTime.now(),
                          ),
                        ),
                        (
                          label: 'Last 3 months',
                          range: DateRange(
                            start: DateTime.now().subtract(
                              const Duration(days: 90),
                            ),
                            end: DateTime.now(),
                          ),
                        ),
                        (
                          label: 'Last year',
                          range: DateRange(
                            start: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            end: DateTime.now(),
                          ),
                        ),
                      ]
                      .map(
                        (item) => FilterChip(
                          label: Text(item.label),
                          selected: selectedDateRange == item.range,
                          onSelected: (selected) {
                            onDateRangeChanged(selected ? item.range : null);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: ListTile(
              title: Text(
                'Custom Date Range',
                style: AppTextTheme.bodyRegular.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: onCustomDatePicker,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayedDisplay(
            delay: const Duration(milliseconds: 450),
            child: SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                label: 'Clear All Filters',
                onPressed: onClearFilters,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.investment_return:
        return 'Investment Return';
      case TransactionType.interest_earned:
        return 'Interest Earned';
      case TransactionType.referral_bonus:
        return 'Referral Bonus';
      case TransactionType.token_conversion:
        return 'Token Conversion';
      case TransactionType.token_purchase:
        return 'Token Purchase';
      case TransactionType.transfer_to_user:
        return 'Transfer To User';
      case TransactionType.transfer_from_user:
        return 'Transfer From User';
      case TransactionType.fee:
        return 'Fee';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.reversed:
        return 'Reversed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

// ==================== TRANSACTION LIST WIDGET ====================

class _TransactionList extends StatelessWidget {
  final String uid;
  final FirestoreService firestoreService;
  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final DateRange? selectedDateRange;
  final String searchTerm;

  const _TransactionList({
    required this.uid,
    required this.firestoreService,
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: firestoreService.getUserTransactionsStream(userId: uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        }

        if (snapshot.hasError) {
          log(snapshot.error.toString());
          return _ErrorState(error: snapshot.error.toString());
        }

        var transactions = snapshot.data ?? [];

        // Apply filters
        if (selectedType != null) {
          transactions = transactions
              .where((t) => t.type == selectedType)
              .toList();
        }

        if (selectedStatus != null) {
          transactions = transactions
              .where((t) => t.status == selectedStatus)
              .toList();
        }

        if (selectedDateRange != null) {
          transactions = transactions
              .where(
                (t) =>
                    t.createdAt.isAfter(selectedDateRange!.start) &&
                    t.createdAt.isBefore(
                      selectedDateRange!.end.add(const Duration(days: 1)),
                    ),
              )
              .toList();
        }

        // Apply search
        if (searchTerm.isNotEmpty) {
          transactions = transactions
              .where(
                (t) =>
                    t.description.toLowerCase().contains(searchTerm) ||
                    t.referenceNumber!.toLowerCase().contains(searchTerm) ||
                    t.amount.toStringAsFixed(0).contains(searchTerm),
              )
              .toList();
        }

        // Sort by date descending
        transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (transactions.isEmpty) {
          return _EmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final previousTransaction = index > 0
                ? transactions[index - 1]
                : null;
            final showDateHeader =
                previousTransaction == null ||
                !_isSameDay(
                  transaction.createdAt,
                  previousTransaction.createdAt,
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDateHeader)
                  DelayedDisplay(
                    delay: Duration(milliseconds: 50 + (index * 25)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.lg,
                        bottom: AppSpacing.md,
                      ),
                      child: Text(
                        _formatTransactionDate(transaction.createdAt),
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                DelayedDisplay(
                  delay: Duration(milliseconds: 100 + (index * 50)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _TransactionCard(
                      transaction: transaction,
                      onTap: () =>
                          _showTransactionDetails(context, transaction),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

// ==================== TRANSACTION CARD WIDGET ====================

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const _TransactionCard({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncoming = _isIncomingTransaction(transaction.type);

    return GestureDetector(
      onTap: onTap,
      child: StandardCard(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _getTransactionColor(transaction.type).withAlpha(25),
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Icon(
                _getTransactionIcon(transaction.type),
                color: _getTransactionColor(transaction.type),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: AppTextTheme.bodyRegular.copyWith(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        _getTransactionTypeLabel(transaction.type),
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        ' • ',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                      Text(
                        _formatTransactionTime(transaction.createdAt),
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      if (transaction.status != TransactionStatus.completed)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                transaction.status,
                              ).withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            child: Text(
                              _getStatusLabel(transaction.status),
                              style: AppTextTheme.micro.copyWith(
                                color: _getStatusColor(transaction.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncoming ? '+' : '−'}₦${transaction.amount.toStringAsFixed(0)}',
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: isIncoming
                        ? AppColors.tealSuccess
                        : AppColors.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (transaction.fees! > 0)
                  Text(
                    'Fee: ₦${transaction.fees!.toStringAsFixed(0)}',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isIncomingTransaction(TransactionType type) {
    return type == TransactionType.deposit ||
        type == TransactionType.investment_return ||
        type == TransactionType.interest_earned ||
        type == TransactionType.referral_bonus ||
        type == TransactionType.token_conversion ||
        type == TransactionType.transfer_from_user;
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
      case TransactionType.investment_return:
      case TransactionType.interest_earned:
      case TransactionType.referral_bonus:
      case TransactionType.transfer_from_user:
        return AppColors.tealSuccess;
      case TransactionType.withdrawal:
      case TransactionType.investment:
      case TransactionType.transfer_to_user:
      case TransactionType.token_purchase:
        return AppColors.deepNavy;
      case TransactionType.token_conversion:
        return AppColors.primaryOrange;
      case TransactionType.fee:
      case TransactionType.adjustment:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColors.softAmber;
      case TransactionStatus.completed:
        return AppColors.tealSuccess;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppColors.warmRed;
      case TransactionStatus.reversed:
        return AppColors.textSecondary;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.investment:
        return Icons.trending_up;
      case TransactionType.investment_return:
        return Icons.trending_up;
      case TransactionType.interest_earned:
        return Icons.percent;
      case TransactionType.referral_bonus:
        return Icons.card_giftcard;
      case TransactionType.token_conversion:
        return Icons.swap_horiz;
      case TransactionType.token_purchase:
        return Icons.shopping_cart;
      case TransactionType.transfer_to_user:
        return Icons.send;
      case TransactionType.transfer_from_user:
        return Icons.call_received;
      case TransactionType.fee:
        return Icons.receipt;
      case TransactionType.adjustment:
        return Icons.tune;
    }
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.investment_return:
        return 'Investment Return';
      case TransactionType.interest_earned:
        return 'Interest Earned';
      case TransactionType.referral_bonus:
        return 'Referral Bonus';
      case TransactionType.token_conversion:
        return 'Token Conversion';
      case TransactionType.token_purchase:
        return 'Token Purchase';
      case TransactionType.transfer_to_user:
        return 'Transfer To User';
      case TransactionType.transfer_from_user:
        return 'Transfer From User';
      case TransactionType.fee:
        return 'Fee';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.reversed:
        return 'Reversed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatTransactionTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ==================== TRANSACTION DETAILS SHEET ====================

class _TransactionDetailsSheet extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncoming = _isIncomingTransaction(transaction.type);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.large),
          topRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DelayedDisplay(
              delay: const Duration(milliseconds: 100),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getTransactionColor(transaction.type).withAlpha(12),
                  borderRadius: BorderRadius.circular(AppBorderRadius.large),
                  border: Border.all(
                    color: _getTransactionColor(transaction.type).withAlpha(25),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${isIncoming ? '+' : '−'}₦${transaction.amount.toStringAsFixed(0)}',
                      style: AppTextTheme.display.copyWith(
                        color: _getTransactionColor(transaction.type),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      transaction.description,
                      style: AppTextTheme.heading3.copyWith(
                        color: AppColors.deepNavy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DelayedDisplay(
              delay: const Duration(milliseconds: 200),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withAlpha(12),
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  border: Border.all(
                    color: _getStatusColor(transaction.status).withAlpha(25),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(transaction.status),
                      color: _getStatusColor(transaction.status),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: AppTextTheme.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _getStatusLabel(transaction.status),
                            style: AppTextTheme.bodyRegular.copyWith(
                              color: _getStatusColor(transaction.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DelayedDisplay(
              delay: const Duration(milliseconds: 300),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                children: [
                  _DetailItem(
                    label: 'Type',
                    value: _getTransactionTypeLabel(transaction.type),
                  ),
                  _DetailItem(
                    label: 'Date & Time',
                    value: _formatDetailedDateTime(transaction.createdAt),
                  ),
                  _DetailItem(
                    label: 'Amount',
                    value: '₦${transaction.amount.toStringAsFixed(0)}',
                  ),
                  _DetailItem(
                    label: 'Fees',
                    value: transaction.fees! > 0
                        ? '₦${transaction.fees!.toStringAsFixed(0)}'
                        : 'None',
                  ),
                  _DetailItem(
                    label: 'Net Amount',
                    value: '₦${transaction.netAmount!.toStringAsFixed(0)}',
                  ),
                  _DetailItem(
                    label: 'Reference',
                    value: transaction.referenceNumber.toString(),
                  ),
                ],
              ),
            ),
            if (transaction.status == TransactionStatus.failed &&
                transaction.failureReason != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.warmRed.withAlpha(12),
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        border: Border.all(
                          color: AppColors.warmRed.withAlpha(25),
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        transaction.failureReason!,
                        style: AppTextTheme.bodyRegular.copyWith(
                          color: AppColors.warmRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool _isIncomingTransaction(TransactionType type) {
    return type == TransactionType.deposit ||
        type == TransactionType.investment_return ||
        type == TransactionType.interest_earned ||
        type == TransactionType.referral_bonus ||
        type == TransactionType.token_conversion ||
        type == TransactionType.transfer_from_user;
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
      case TransactionType.investment_return:
      case TransactionType.interest_earned:
      case TransactionType.referral_bonus:
      case TransactionType.transfer_from_user:
        return AppColors.tealSuccess;
      case TransactionType.withdrawal:
      case TransactionType.investment:
      case TransactionType.transfer_to_user:
      case TransactionType.token_purchase:
        return AppColors.deepNavy;
      case TransactionType.token_conversion:
        return AppColors.primaryOrange;
      case TransactionType.fee:
      case TransactionType.adjustment:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColors.softAmber;
      case TransactionStatus.completed:
        return AppColors.tealSuccess;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppColors.warmRed;
      case TransactionStatus.reversed:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.processing:
        return Icons.hourglass_bottom;
      case TransactionStatus.completed:
        return Icons.check_circle;
      case TransactionStatus.failed:
        return Icons.cancel;
      case TransactionStatus.reversed:
        return Icons.undo;
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.investment_return:
        return 'Investment Return';
      case TransactionType.interest_earned:
        return 'Interest Earned';
      case TransactionType.referral_bonus:
        return 'Referral Bonus';
      case TransactionType.token_conversion:
        return 'Token Conversion';
      case TransactionType.token_purchase:
        return 'Token Purchase';
      case TransactionType.transfer_to_user:
        return 'Transfer To User';
      case TransactionType.transfer_from_user:
        return 'Transfer From User';
      case TransactionType.fee:
        return 'Fee';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.reversed:
        return 'Reversed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDetailedDateTime(DateTime date) {
    return '${_formatTransactionDate(date)} at ${_formatTransactionTime(date)}';
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _formatTransactionTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

// ==================== HELPER WIDGETS ====================

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextTheme.bodyRegular.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Icon(
              Icons.history,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'No transactions found',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Try adjusting your filters',
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.warmRed,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Failed to load $error',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.warmRed,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HELPER CLASSES ====================

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
