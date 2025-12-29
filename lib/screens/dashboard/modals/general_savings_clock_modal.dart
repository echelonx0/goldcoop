import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/user_model.dart';
import 'upload_proof_modal.dart';

class GeneralSavingsClockModal extends StatefulWidget {
  final UserModel user;
  final VoidCallback onEditTarget;
  final VoidCallback onClose;

  const GeneralSavingsClockModal({
    super.key,
    required this.user,
    required this.onEditTarget,
    required this.onClose,
  });

  @override
  State<GeneralSavingsClockModal> createState() =>
      GeneralSavingsClockModalState();
}

class GeneralSavingsClockModalState extends State<GeneralSavingsClockModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fp = widget.user.financialProfile;
    final hasTarget = (fp.savingsTarget) > 0;
    final targetAmount = fp.savingsTarget;
    final currentBalance = fp.accountBalance;
    final targetDate = fp.savingsTargetDate;

    if (!hasTarget || targetDate == null) {
      return _buildEmptyState();
    }

    return _buildClockContent(currentBalance, targetAmount, targetDate);
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AdminDesignSystem.radius24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        AdminDesignSystem.spacing24,
                      ),
                      decoration: BoxDecoration(
                        color: AdminDesignSystem.accentTeal.withAlpha(38),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.savings_outlined,
                        size: 64,
                        color: AdminDesignSystem.accentTeal,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing24),
                    Text(
                      'No savings target yet',
                      style: AdminDesignSystem.headingMedium.copyWith(
                        color: AdminDesignSystem.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing8),
                    Text(
                      'Set a savings target to track\nyour progress and stay motivated',
                      style: AdminDesignSystem.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onEditTarget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminDesignSystem.accentTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
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
                          'Set Target',
                          style: AdminDesignSystem.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _buildClockContent(
    double currentBalance,
    double targetAmount,
    DateTime targetDate,
  ) {
    final progress = (currentBalance / targetAmount).clamp(0.0, 1.0);

    final daysRemaining = targetDate.difference(DateTime.now()).inDays;
    final isCompleted = currentBalance >= targetAmount;
    final isOverdue = DateTime.now().isAfter(targetDate) && !isCompleted;

    final currencyFormatter = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: 0,
    );

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminDesignSystem.spacing20,
                vertical: AdminDesignSystem.spacing20,
              ),
              child: Column(
                children: [
                  // Clock display
                  _buildClockDisplay(progress, isCompleted, isOverdue),
                  const SizedBox(height: AdminDesignSystem.spacing24),

                  // Metrics row
                  _buildMetricsRow(
                    currentBalance,
                    targetAmount,
                    currencyFormatter,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing24),

                  // Edit target + Upload button row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onEditTarget,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AdminDesignSystem.accentTeal,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AdminDesignSystem.spacing12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AdminDesignSystem.radius12,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.edit_outlined, size: 18),
                              const SizedBox(width: AdminDesignSystem.spacing8),
                              Text(
                                'Edit Target',
                                style: AdminDesignSystem.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AdminDesignSystem.accentTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AdminDesignSystem.spacing12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showUploadProofModal(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminDesignSystem.accentTeal,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: AdminDesignSystem.spacing12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AdminDesignSystem.radius12,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file_outlined, size: 18),
                              const SizedBox(width: AdminDesignSystem.spacing8),
                              Text(
                                'Upload',
                                style: AdminDesignSystem.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AdminDesignSystem.spacing24),

                  // Target date
                  _buildTargetDateCard(targetDate, daysRemaining, isOverdue),
                  const SizedBox(height: AdminDesignSystem.spacing24),

                  // Achievement banner if completed
                  if (isCompleted) _buildAchievementBanner(),

                  const SizedBox(height: AdminDesignSystem.spacing16),
                ],
              ),
            ),
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

  Widget _buildClockDisplay(double progress, bool isCompleted, bool isOverdue) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getStatusColor(
                  isCompleted,
                  isOverdue,
                ).withAlpha((38 + (_pulseController.value * 25)).toInt()),
                blurRadius: 40 + (_pulseController.value * 20),
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _GeneralClockPainter(
              progressPercent: progress,
              statusColor: _getStatusColor(isCompleted, isOverdue),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text(
                          isCompleted
                              ? '🎉'
                              : isOverdue
                              ? '⏰'
                              : '✨',
                          style: const TextStyle(fontSize: 32),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress * 100),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        '${value.toStringAsFixed(1)}%',
                        style: AdminDesignSystem.displayLarge.copyWith(
                          color: AdminDesignSystem.primaryNavy,
                          fontSize: 36,
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

  Widget _buildMetricsRow(
    double currentBalance,
    double targetAmount,
    NumberFormat formatter,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
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
                    Icon(
                      Icons.savings_outlined,
                      size: 16,
                      color: AdminDesignSystem.accentTeal,
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing4),
                    Text(
                      'Saved',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDesignSystem.spacing8),
                Text(
                  formatter.format(currentBalance),
                  style: AdminDesignSystem.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AdminDesignSystem.accentTeal,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AdminDesignSystem.spacing12),
        Expanded(
          child: Container(
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
                    Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: AdminDesignSystem.primaryNavy,
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing4),
                    Text(
                      'Target',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDesignSystem.spacing8),
                Text(
                  formatter.format(targetAmount),
                  style: AdminDesignSystem.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AdminDesignSystem.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetDateCard(
    DateTime targetDate,
    int daysRemaining,
    bool isOverdue,
  ) {
    return Container(
      decoration: AdminDesignSystem.cardDecoration,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AdminDesignSystem.accentTeal,
            size: 20,
          ),
          const SizedBox(width: AdminDesignSystem.spacing12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(targetDate),
                style: AdminDesignSystem.bodyMedium.copyWith(
                  color: AdminDesignSystem.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing4),
              Text(
                _formatDaysRemaining(daysRemaining),
                style: AdminDesignSystem.labelSmall.copyWith(
                  color: isOverdue
                      ? AdminDesignSystem.statusError
                      : AdminDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminDesignSystem.statusActive,
            AdminDesignSystem.statusActive.withAlpha(230),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        boxShadow: [
          BoxShadow(
            color: AdminDesignSystem.statusActive.withAlpha(38),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
            padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
            child: Icon(Icons.emoji_events, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AdminDesignSystem.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal Achieved! 🎉',
                  style: AdminDesignSystem.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  'You\'ve reached your savings target',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: Colors.white.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadProofModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UploadProofModal(
        transactionId: '',
        goalId: '',
        goalTitle: 'General Account Funding',
        onSuccess: () {
          Navigator.pop(context); // Close upload modal
          Navigator.pop(context); // Close savings clock modal
        },
        onCancel: () {
          Navigator.pop(context);
        },
        user: widget.user,
      ),
    );
  }

  String _formatDaysRemaining(int days) {
    if (days < 0) {
      return '${(-days).abs()} days overdue';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return '1 day remaining';
    } else if (days <= 7) {
      return '$days days left';
    } else if (days <= 30) {
      final weeks = (days / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} remaining';
    } else {
      final months = (days / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} left';
    }
  }

  Color _getStatusColor(bool isCompleted, bool isOverdue) {
    if (isCompleted) return AdminDesignSystem.statusActive;
    if (isOverdue) return AdminDesignSystem.statusPending;
    return AdminDesignSystem.accentTeal;
  }
}

// ==================== CLOCK PAINTER ====================

class _GeneralClockPainter extends CustomPainter {
  final double progressPercent;
  final Color statusColor;

  _GeneralClockPainter({
    required this.progressPercent,
    required this.statusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background
    final bgPaint = Paint()
      ..color = const Color(0xFFF5F7FA)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Track
    final trackPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 20, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final progressRect = Rect.fromCircle(center: center, radius: radius - 45);
    progressPaint.shader = SweepGradient(
      startAngle: -math.pi / 2,
      colors: [statusColor.withAlpha(179), statusColor, statusColor],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(progressRect);

    final progressArc = math.pi * 2 * progressPercent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 45),
      -math.pi / 2,
      progressArc,
      false,
      progressPaint,
    );

    // Markers
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

    // Progress indicator
    if (progressPercent > 0) {
      final progressAngle = -math.pi / 2 + (math.pi * 2 * progressPercent);
      final progressIndicatorPos = Offset(
        center.dx + (radius - 45) * math.cos(progressAngle),
        center.dy + (radius - 45) * math.sin(progressAngle),
      );

      final glowPaint = Paint()
        ..color = statusColor.withAlpha(77)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(progressIndicatorPos, 14, glowPaint);

      final dotPaint = Paint()
        ..color = statusColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(progressIndicatorPos, 8, dotPaint);

      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(progressIndicatorPos, 4, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GeneralClockPainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent ||
        oldDelegate.statusColor != statusColor;
  }
}
