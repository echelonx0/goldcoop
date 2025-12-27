// lib/components/cards/animated_goal_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/admin_design_system.dart';
import '../../../models/goals_model.dart';
import '../tabs/savings/add_to_goal_form.dart';
import '../tabs/savings/goal-detail/goal_detail_sheet.dart';

class AnimatedGoalCard extends StatefulWidget {
  final GoalModel goal;
  final NumberFormat currencyFormatter;
  final int index;
  final VoidCallback? onAddFunds;
  final VoidCallback? onViewDetails;

  const AnimatedGoalCard({
    super.key,
    required this.goal,
    required this.currencyFormatter,
    required this.index,
    this.onAddFunds,
    this.onViewDetails,
  });

  @override
  State<AnimatedGoalCard> createState() => _AnimatedGoalCardState();
}

class _AnimatedGoalCardState extends State<AnimatedGoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = widget.goal.progressPercentage;
    final isCompleted = widget.goal.isCompleted;
    final isOverdue = widget.goal.isOverdue;
    final categoryColor = _getGoalCategoryColor(widget.goal.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AdminDesignSystem.spacing12),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showGoalDetailsSheet(context),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              child: Container(
                decoration: AdminDesignSystem.cardDecoration,
                padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon, title, and status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                            AdminDesignSystem.spacing12,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withAlpha(38),
                            borderRadius: BorderRadius.circular(
                              AdminDesignSystem.radius12,
                            ),
                          ),
                          child: Icon(
                            _getGoalCategoryIcon(widget.goal.category),
                            color: categoryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AdminDesignSystem.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.goal.title,
                                style: AdminDesignSystem.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AdminDesignSystem.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: AdminDesignSystem.spacing4,
                              ),
                              _buildStatusBadge(isCompleted, isOverdue),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AdminDesignSystem.textTertiary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing16),

                    // Saved vs Target amounts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Saved', style: AdminDesignSystem.labelSmall),
                            const SizedBox(height: AdminDesignSystem.spacing4),
                            Text(
                              widget.currencyFormatter.format(
                                widget.goal.currentAmount,
                              ),
                              style: AdminDesignSystem.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Target', style: AdminDesignSystem.labelSmall),
                            const SizedBox(height: AdminDesignSystem.spacing4),
                            Text(
                              widget.currencyFormatter.format(
                                widget.goal.targetAmount,
                              ),
                              style: AdminDesignSystem.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AdminDesignSystem.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing12),

                    // Animated progress bar
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progressPercent / 100),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AdminDesignSystem.radius8,
                              ),
                              child: LinearProgressIndicator(
                                value: value.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: categoryColor.withAlpha(38),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCompleted
                                      ? AdminDesignSystem.statusActive
                                      : isOverdue
                                      ? AdminDesignSystem.statusError
                                      : categoryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: AdminDesignSystem.spacing8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(value * 100).toStringAsFixed(0)}% completed',
                                  style: AdminDesignSystem.labelSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.currencyFormatter.format(
                                    (widget.goal.targetAmount -
                                            widget.goal.currentAmount)
                                        .clamp(0, double.infinity),
                                  ),
                                  style: AdminDesignSystem.labelSmall.copyWith(
                                    color: AdminDesignSystem.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  Widget _buildStatusBadge(bool isCompleted, bool isOverdue) {
    if (isCompleted) {
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AdminDesignSystem.statusActive,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing4),
          Text(
            'Completed',
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.statusActive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (isOverdue) {
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AdminDesignSystem.statusError,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing4),
          Text(
            'Overdue',
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.statusError,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      return Text(
        '${widget.goal.daysRemaining} days remaining',
        style: AdminDesignSystem.bodySmall,
      );
    }
  }

  void _showGoalDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalDetailSheet(
        goal: widget.goal,
        onAddFunds: () {
          Navigator.pop(context);
          _showAddToGoalSheet(context);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showAddToGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToGoalForm(
        goal: widget.goal,
        onContribute: (amount) {
          Navigator.pop(context);
          widget.onAddFunds?.call();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Color _getGoalCategoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.vacation:
        return const Color(0xFF3498DB);
      case GoalCategory.realestate:
        return const Color(0xFF9B59B6);
      case GoalCategory.education:
        return const Color(0xFFE74C3C);
      case GoalCategory.vehicle:
        return const Color(0xFFF39C12);
      case GoalCategory.wedding:
        return const Color(0xFFE91E63);
      case GoalCategory.business:
        return AdminDesignSystem.statusActive;
      case GoalCategory.investment:
        return AdminDesignSystem.accentTeal;
      case GoalCategory.retirement:
        return AdminDesignSystem.primaryNavy;
      case GoalCategory.emergency:
        return AdminDesignSystem.statusError;
      case GoalCategory.other:
        return AdminDesignSystem.textSecondary;
    }
  }

  IconData _getGoalCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.vacation:
        return Icons.flight_takeoff;
      case GoalCategory.realestate:
        return Icons.home_outlined;
      case GoalCategory.education:
        return Icons.school_outlined;
      case GoalCategory.vehicle:
        return Icons.directions_car_outlined;
      case GoalCategory.wedding:
        return Icons.favorite_outline;
      case GoalCategory.business:
        return Icons.business_center_outlined;
      case GoalCategory.investment:
        return Icons.trending_up;
      case GoalCategory.retirement:
        return Icons.beach_access_outlined;
      case GoalCategory.emergency:
        return Icons.health_and_safety_outlined;
      case GoalCategory.other:
        return Icons.flag_outlined;
    }
  }
}
