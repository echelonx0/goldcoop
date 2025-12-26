// lib/screens/dashboard/tabs/balance_card_skeleton.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/admin_design_system.dart';

class BalanceCardSkeleton extends StatefulWidget {
  final List<Color> gradientColors;

  const BalanceCardSkeleton({super.key, required this.gradientColors});

  /// Fiat balance card skeleton with teal gradient
  factory BalanceCardSkeleton.fiat() {
    return BalanceCardSkeleton(
      gradientColors: [
        AdminDesignSystem.accentTeal,
        AdminDesignSystem.accentTeal.withAlpha(230),
      ],
    );
  }

  /// Token balance card skeleton with purple gradient
  factory BalanceCardSkeleton.token() {
    return BalanceCardSkeleton(
      gradientColors: [
        const Color(0xFF9B59B6),
        const Color(0xFF9B59B6).withAlpha(230),
      ],
    );
  }

  @override
  State<BalanceCardSkeleton> createState() => _BalanceCardSkeletonState();
}

class _BalanceCardSkeletonState extends State<BalanceCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors.first.withAlpha(38),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(
                          width: 100,
                          height: 14,
                          shimmerValue: _shimmerAnimation.value,
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing12),
                        _SkeletonBox(
                          width: 160,
                          height: 32,
                          shimmerValue: _shimmerAnimation.value,
                        ),
                      ],
                    ),
                  ),
                  _SkeletonBox(
                    width: 52,
                    height: 52,
                    borderRadius: AdminDesignSystem.radius12,
                    shimmerValue: _shimmerAnimation.value,
                  ),
                ],
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),
              Row(
                children: [
                  Expanded(
                    child: _SkeletonBox(
                      height: 56,
                      borderRadius: AdminDesignSystem.radius12,
                      shimmerValue: _shimmerAnimation.value,
                    ),
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing8),
                  Expanded(
                    child: _SkeletonBox(
                      height: 56,
                      borderRadius: AdminDesignSystem.radius12,
                      shimmerValue: _shimmerAnimation.value,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================== SKELETON BOX ====================

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final double shimmerValue;

  const _SkeletonBox({
    this.width,
    required this.height,
    this.borderRadius = 8,
    required this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(shimmerValue - 1, 0),
          end: Alignment(shimmerValue, 0),
          colors: [
            Colors.white.withAlpha(25),
            Colors.white.withAlpha(51),
            Colors.white.withAlpha(25),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ==================== ERROR CARD ====================

class BalanceCardError extends StatelessWidget {
  final String message;
  final List<Color> gradientColors;
  final VoidCallback? onRetry;

  const BalanceCardError({
    super.key,
    required this.message,
    required this.gradientColors,
    this.onRetry,
  });

  /// Fiat balance error card with teal gradient
  factory BalanceCardError.fiat({VoidCallback? onRetry}) {
    return BalanceCardError(
      message: 'Unable to load balance',
      gradientColors: [
        AdminDesignSystem.accentTeal,
        AdminDesignSystem.accentTeal.withAlpha(230),
      ],
      onRetry: onRetry,
    );
  }

  /// Token balance error card with purple gradient
  factory BalanceCardError.token({VoidCallback? onRetry}) {
    return BalanceCardError(
      message: 'Unable to load tokens',
      gradientColors: [
        const Color(0xFF9B59B6),
        const Color(0xFF9B59B6).withAlpha(230),
      ],
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withAlpha(38),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                color: Colors.white.withAlpha(179),
                size: 28,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            Text(
              message,
              style: AdminDesignSystem.bodyMedium.copyWith(
                color: Colors.white.withAlpha(179),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AdminDesignSystem.spacing12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminDesignSystem.spacing16,
                      vertical: AdminDesignSystem.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius8,
                      ),
                    ),
                    child: Text(
                      'Tap to retry',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
