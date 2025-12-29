// lib/screens/dashboard/tabs/home_tab/general_savings_clock_card.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/admin_design_system.dart';
import '../../../../../models/user_model.dart';

class GeneralSavingsClockCard extends StatefulWidget {
  final UserModel? user;
  final int delay;
  final VoidCallback? onPressed;

  const GeneralSavingsClockCard({
    super.key,
    required this.user,
    required this.delay,
    this.onPressed,
  });

  @override
  State<GeneralSavingsClockCard> createState() =>
      _GeneralSavingsClockCardState();
}

class _GeneralSavingsClockCardState extends State<GeneralSavingsClockCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  static const Color _clockColor = Color(0xFFE67E22);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    final user = widget.user;
    final hasTarget =
        user != null && (user.financialProfile.savingsTarget ?? 0) > 0;
    final targetDate = user?.financialProfile.savingsTargetDate;

    // Calculate days remaining if target date exists
    int? daysRemaining;
    if (targetDate != null && hasTarget) {
      daysRemaining = targetDate.difference(DateTime.now()).inDays;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + widget.delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasTarget ? widget.onPressed : null,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          child: Container(
            decoration: AdminDesignSystem.cardDecoration,
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(
                        AdminDesignSystem.spacing12,
                      ),
                      decoration: BoxDecoration(
                        color: _clockColor.withAlpha(
                          (26 + (_pulseController.value * 12)).toInt(),
                        ),
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.watch_later_outlined,
                            color: _clockColor,
                            size: 32,
                          ),
                          if (hasTarget &&
                              daysRemaining != null &&
                              daysRemaining > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AdminDesignSystem.statusActive,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),
                Text(
                  'Savings Goal',
                  style: AdminDesignSystem.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                if (hasTarget && daysRemaining != null)
                  Text(
                    _buildSubtitle(daysRemaining),
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    'Set a target to begin',
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(int daysRemaining) {
    if (daysRemaining < 0) {
      return 'Goal overdue';
    } else if (daysRemaining == 0) {
      return 'Due today';
    } else if (daysRemaining == 1) {
      return '1 day remaining';
    } else if (daysRemaining <= 7) {
      return '$daysRemaining days left';
    } else if (daysRemaining <= 30) {
      final weeks = (daysRemaining / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} remaining';
    } else {
      final months = (daysRemaining / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} left';
    }
  }
}
