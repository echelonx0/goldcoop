// lib/screens/dashboard/tabs/savings/goal_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../components/base/app_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../models/goals_model.dart';
import '../../../../../models/payment_proof_model.dart';
import '../../../../../services/deposit_service.dart';
import '../../../../../services/firestore_service.dart';
import 'widgets/goal_category_card.dart';
import 'widgets/goal_completion_header.dart';
import 'widgets/goal_header_section.dart';
import 'widgets/goal_progress_section.dart';
import 'widgets/goal_stats_grid.dart';
import 'widgets/goal_transaction_history.dart';

class GoalDetailSheet extends StatefulWidget {
  final GoalModel goal;
  final VoidCallback onAddFunds;
  final VoidCallback onClose;

  const GoalDetailSheet({
    super.key,
    required this.goal,
    required this.onAddFunds,
    required this.onClose,
  });

  @override
  State<GoalDetailSheet> createState() => _GoalDetailSheetState();
}

class _GoalDetailSheetState extends State<GoalDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late final DepositService _depositService;
  late final FirestoreService _firestoreService;

  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _depositService = DepositService();
    _firestoreService = FirestoreService();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppBorderRadius.large),
              topRight: Radius.circular(AppBorderRadius.large),
            ),
          ),
          child: Column(
            children: [
              // Fixed header
              _buildDragHandle(),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GoalHeaderSection(
                        goal: widget.goal,
                        onClose: widget.onClose,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      GoalProgressSection(goal: widget.goal),
                      const SizedBox(height: AppSpacing.lg),

                      GoalStatsGrid(
                        goal: widget.goal,
                        currencyFormatter: _currencyFormatter,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      GoalCategoryCard(goal: widget.goal),
                      const SizedBox(height: AppSpacing.lg),

                      // Transaction History Section
                      _buildTransactionHistorySection(),
                      const SizedBox(height: AppSpacing.lg),

                      // Action button or completion banner
                      _buildActionSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.md),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTransactionHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaction History',
              style: AppTextTheme.heading3.copyWith(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withAlpha(25),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: StreamBuilder<List<PaymentProofModel>>(
                stream: _getGoalProofsStream(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Text(
                    '$count ${count == 1 ? 'deposit' : 'deposits'}',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GoalTransactionHistory(
          goalId: widget.goal.goalId,
          userId: widget.goal.userId,
        ),
      ],
    );
  }

  Stream<List<PaymentProofModel>> _getGoalProofsStream() {
    // Get all proofs for this user, then filter by goalId
    return _depositService
        .getUserPaymentProofsStream(widget.goal.userId)
        .map(
          (proofs) =>
              proofs.where((p) => p.goalId == widget.goal.goalId).toList(),
        );
  }

  Widget _buildActionSection() {
    if (widget.goal.isCompleted) {
      return GoalCompletionBanner();
    }

    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(label: 'Add Funds', onPressed: widget.onAddFunds),
    );
  }
}
