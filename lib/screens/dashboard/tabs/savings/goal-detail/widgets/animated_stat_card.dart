// lib/screens/dashboard/tabs/savings/widgets/animated_stat_card.dart

import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';

class AnimatedStatCard extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final int delay;
  final double targetValue;

  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.delay,
    required this.targetValue,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color.withAlpha(12),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: widget.color.withAlpha(25)),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    widget.icon,
                    color: widget.color.withAlpha(180),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.value,
                style: AppTextTheme.bodyRegular.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
