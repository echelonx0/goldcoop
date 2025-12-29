import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:gsa/screens/transactions/utilities.dart';
import '../../core/theme/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';
import 'widgets/transaction_card.dart';
import 'widgets/transaction_detail_sheet.dart';
import 'widgets/transaction_filter_panel.dart';
import 'widgets/transactions_search_bar.dart';

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
          TransactionSearchBar(
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
                ? TransactionFilterPanel(
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
          return ErrorState(error: snapshot.error.toString());
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
          return EmptyState();
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
                    child: TransactionCard(
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
      builder: (context) => TransactionDetailsSheet(transaction: transaction),
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
