// lib/screens/dashboard/modals/savings_clock_modal.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/goals_model.dart';

class SavingsClockModal extends StatefulWidget {
  final List<GoalModel> goals;
  final VoidCallback? onCreateGoal;
  final Function(GoalModel)? onViewGoal;

  const SavingsClockModal({
    super.key,
    required this.goals,
    this.onCreateGoal,
    this.onViewGoal,
  });

  @override
  State<SavingsClockModal> createState() => _SavingsClockModalState();
}

class _SavingsClockModalState extends State<SavingsClockModal>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  int _selectedGoalIndex = 0;

  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    // Entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    // Pulse animation for the glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Subtle rotation for the clock hand
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _entryController.forward();
    _rotationController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  GoalModel? get _selectedGoal =>
      widget.goals.isNotEmpty ? widget.goals[_selectedGoalIndex] : null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AdminDesignSystem.radius24),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: widget.goals.isEmpty
                ? _buildEmptyState()
                : _buildClockContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AdminDesignSystem.spacing12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AdminDesignSystem.textTertiary.withAlpha(77),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AdminDesignSystem.accentTeal,
                  AdminDesignSystem.accentTeal.withAlpha(179),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
            child: const Icon(
              Icons.watch_later_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Savings Clock',
                  style: AdminDesignSystem.headingLarge.copyWith(
                    color: AdminDesignSystem.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track your progress against time',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AdminDesignSystem.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildClockContent() {
    final goal = _selectedGoal!;
    final clockData = _calculateClockData(goal);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminDesignSystem.spacing20,
          ),
          child: Column(
            children: [
              // Goal selector (if multiple goals)
              if (widget.goals.length > 1) ...[
                _buildGoalSelector(),
                const SizedBox(height: AdminDesignSystem.spacing24),
              ],

              // The Clock
              _buildSavingsClock(goal, clockData),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // Status insight card
              _buildInsightCard(clockData),
              const SizedBox(height: AdminDesignSystem.spacing16),

              // Metrics row
              _buildMetricsRow(goal, clockData),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // Action button
              _buildActionButton(goal),
              const SizedBox(height: AdminDesignSystem.spacing32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.goals.length,
        itemBuilder: (context, index) {
          final goal = widget.goals[index];
          final isSelected = index == _selectedGoalIndex;

          return Padding(
            padding: EdgeInsets.only(right: AdminDesignSystem.spacing8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedGoalIndex = index),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AdminDesignSystem.spacing16,
                    vertical: AdminDesignSystem.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AdminDesignSystem.accentTeal
                        : AdminDesignSystem.background,
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius12,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AdminDesignSystem.accentTeal
                          : AdminDesignSystem.divider,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(goal.category),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : AdminDesignSystem.textSecondary,
                      ),
                      const SizedBox(width: AdminDesignSystem.spacing8),
                      Text(
                        goal.title,
                        style: AdminDesignSystem.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AdminDesignSystem.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavingsClock(GoalModel goal, _ClockData clockData) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // Outer glow based on status
              BoxShadow(
                color: clockData.statusColor.withAlpha(
                  (38 + (_pulseController.value * 25)).toInt(),
                ),
                blurRadius: 40 + (_pulseController.value * 20),
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _SavingsClockPainter(
              progressPercent: clockData.savingsProgress,
              timePercent: clockData.timeProgress,
              statusColor: clockData.statusColor,
              animationValue: _rotationController.value,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status emoji
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text(
                          clockData.statusEmoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing8),

                  // Progress percentage
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: clockData.savingsProgress * 100,
                    ),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        '${value.toStringAsFixed(0)}%',
                        style: AdminDesignSystem.displayLarge.copyWith(
                          color: AdminDesignSystem.primaryNavy,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                  Text(
                    'saved',
                    style: AdminDesignSystem.labelMedium.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightCard(_ClockData clockData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            clockData.statusColor.withAlpha(26),
            clockData.statusColor.withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
        border: Border.all(color: clockData.statusColor.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
            decoration: BoxDecoration(
              color: clockData.statusColor.withAlpha(38),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
            child: Icon(
              clockData.statusIcon,
              color: clockData.statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clockData.statusTitle,
                  style: AdminDesignSystem.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminDesignSystem.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  clockData.statusMessage,
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(GoalModel goal, _ClockData clockData) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.savings_outlined,
            label: 'Saved',
            value: _currencyFormatter.format(goal.currentAmount),
            color: AdminDesignSystem.accentTeal,
          ),
        ),
        const SizedBox(width: AdminDesignSystem.spacing12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.flag_outlined,
            label: 'Target',
            value: _currencyFormatter.format(goal.targetAmount),
            color: AdminDesignSystem.primaryNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: AdminDesignSystem.background,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AdminDesignSystem.spacing4),
              Text(
                label,
                style: AdminDesignSystem.labelSmall.copyWith(
                  color: AdminDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Text(
            value,
            style: AdminDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(GoalModel goal) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          widget.onViewGoal?.call(goal);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminDesignSystem.accentTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AdminDesignSystem.spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 20),
            const SizedBox(width: AdminDesignSystem.spacing8),
            Text(
              'Add to ${goal.title}',
              style: AdminDesignSystem.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing24),
              decoration: BoxDecoration(
                color: AdminDesignSystem.accentTeal.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.watch_later_outlined,
                size: 64,
                color: AdminDesignSystem.accentTeal,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing24),
            Text(
              'No goals to track',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            Text(
              'Create a savings goal to see\nyour progress on the clock',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AdminDesignSystem.spacing24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onCreateGoal?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminDesignSystem.accentTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminDesignSystem.spacing24,
                  vertical: AdminDesignSystem.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius12,
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                'Create Your First Goal',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ClockData _calculateClockData(GoalModel goal) {
    // Calculate savings progress (0 to 1)
    final savingsProgress = (goal.currentAmount / goal.targetAmount).clamp(
      0.0,
      1.0,
    );

    // Calculate time progress (0 to 1)
    final totalDuration = goal.targetDate.difference(goal.createdAt).inDays;
    final elapsedDuration = DateTime.now().difference(goal.createdAt).inDays;
    final timeProgress = totalDuration > 0
        ? (elapsedDuration / totalDuration).clamp(0.0, 1.0)
        : 1.0;

    // Determine status
    final difference = savingsProgress - timeProgress;
    final daysRemaining = goal.daysRemaining;

    if (savingsProgress >= 1.0) {
      return _ClockData(
        savingsProgress: savingsProgress,
        timeProgress: timeProgress,
        statusColor: AdminDesignSystem.statusActive,
        statusIcon: Icons.celebration,
        statusEmoji: '🎉',
        statusTitle: 'Goal Completed!',
        statusMessage: 'Congratulations! You\'ve reached your target.',
      );
    } else if (difference > 0.1) {
      // Ahead of schedule
      final daysAhead = ((difference) * totalDuration).round();
      return _ClockData(
        savingsProgress: savingsProgress,
        timeProgress: timeProgress,
        statusColor: AdminDesignSystem.statusActive,
        statusIcon: Icons.rocket_launch,
        statusEmoji: '🚀',
        statusTitle: '$daysAhead days ahead!',
        statusMessage: 'You\'re saving faster than planned. Keep it up!',
      );
    } else if (difference > -0.1) {
      // On track
      return _ClockData(
        savingsProgress: savingsProgress,
        timeProgress: timeProgress,
        statusColor: AdminDesignSystem.accentTeal,
        statusIcon: Icons.check_circle_outline,
        statusEmoji: '✨',
        statusTitle: 'On Track',
        statusMessage: '$daysRemaining days left. You\'re doing great!',
      );
    } else {
      // Behind schedule
      final weeklyNeeded = goal.remainingAmount / (daysRemaining / 7);
      return _ClockData(
        savingsProgress: savingsProgress,
        timeProgress: timeProgress,
        statusColor: AdminDesignSystem.statusPending,
        statusIcon: Icons.speed,
        statusEmoji: '⏰',
        statusTitle: 'Time to catch up',
        statusMessage:
            'Save ${_currencyFormatter.format(weeklyNeeded)}/week to reach your goal.',
      );
    }
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.vacation:
        return Icons.flight;
      case GoalCategory.realestate:
        return Icons.home;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.vehicle:
        return Icons.directions_car;
      case GoalCategory.wedding:
        return Icons.favorite;
      case GoalCategory.business:
        return Icons.business_center;
      case GoalCategory.investment:
        return Icons.trending_up;
      case GoalCategory.retirement:
        return Icons.beach_access;
      case GoalCategory.emergency:
        return Icons.health_and_safety;
      case GoalCategory.other:
        return Icons.flag;
    }
  }
}

// ==================== CLOCK PAINTER ====================

class _SavingsClockPainter extends CustomPainter {
  final double progressPercent;
  final double timePercent;
  final Color statusColor;
  final double animationValue;

  _SavingsClockPainter({
    required this.progressPercent,
    required this.timePercent,
    required this.statusColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFF5F7FA)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Outer ring (time track)
    final trackPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 20, trackPaint);

    // Time progress arc (gray, showing elapsed time)
    if (timePercent > 0) {
      final timePaint = Paint()
        ..color = const Color(0xFFD1D5DB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      final timeArc = math.pi * 2 * timePercent * animationValue;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 20),
        -math.pi / 2,
        timeArc,
        false,
        timePaint,
      );
    }

    // Inner progress arc (savings progress with gradient effect)
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    // Create gradient for progress arc
    final progressRect = Rect.fromCircle(center: center, radius: radius - 45);
    progressPaint.shader = SweepGradient(
      startAngle: -math.pi / 2,
      colors: [statusColor.withAlpha(179), statusColor, statusColor],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(progressRect);

    // Draw savings progress
    final progressArc = math.pi * 2 * progressPercent * animationValue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 45),
      -math.pi / 2,
      progressArc,
      false,
      progressPaint,
    );

    // Draw clock markers (12 positions)
    final markerPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * math.pi * 2 - math.pi / 2;
      final isQuarter = i % 3 == 0;
      final outerRadius = radius - 6;
      final innerRadius = isQuarter ? radius - 14 : radius - 10;

      final outer = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      final inner = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );

      markerPaint.strokeWidth = isQuarter ? 3 : 2;
      markerPaint.color = isQuarter
          ? const Color(0xFF9CA3AF)
          : const Color(0xFFD1D5DB);
      canvas.drawLine(inner, outer, markerPaint);
    }

    // Draw time indicator (small dot on outer track)
    if (timePercent > 0 && timePercent < 1) {
      final timeAngle = -math.pi / 2 + (math.pi * 2 * timePercent);
      final timeIndicatorPos = Offset(
        center.dx + (radius - 20) * math.cos(timeAngle),
        center.dy + (radius - 20) * math.sin(timeAngle),
      );

      // Outer glow
      final glowPaint = Paint()
        ..color = Colors.white.withAlpha(128)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(timeIndicatorPos, 10, glowPaint);

      // Inner dot
      final dotPaint = Paint()
        ..color = const Color(0xFF6B7280)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(timeIndicatorPos, 6, dotPaint);
    }

    // Draw savings indicator (larger dot on inner track)
    if (progressPercent > 0) {
      final progressAngle =
          -math.pi / 2 + (math.pi * 2 * progressPercent * animationValue);
      final progressIndicatorPos = Offset(
        center.dx + (radius - 45) * math.cos(progressAngle),
        center.dy + (radius - 45) * math.sin(progressAngle),
      );

      // Outer glow
      final glowPaint = Paint()
        ..color = statusColor.withAlpha(77)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(progressIndicatorPos, 14, glowPaint);

      // Inner dot
      final dotPaint = Paint()
        ..color = statusColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(progressIndicatorPos, 8, dotPaint);

      // White center
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(progressIndicatorPos, 4, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SavingsClockPainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent ||
        oldDelegate.timePercent != timePercent ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.statusColor != statusColor;
  }
}

// ==================== DATA CLASSES ====================

class _ClockData {
  final double savingsProgress;
  final double timeProgress;
  final Color statusColor;
  final IconData statusIcon;
  final String statusEmoji;
  final String statusTitle;
  final String statusMessage;

  _ClockData({
    required this.savingsProgress,
    required this.timeProgress,
    required this.statusColor,
    required this.statusIcon,
    required this.statusEmoji,
    required this.statusTitle,
    required this.statusMessage,
  });
}

// ==================== HELPER EXTENSION ====================

// extension on Color {
//   static const int _divider = 0xFFE5E7EB;
// }
