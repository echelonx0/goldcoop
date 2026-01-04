// lib/screens/admin/dashboard/widgets/admin_loading_state.dart
// ✅ NEW: Premium animated loading state with skeleton loaders

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/admin_design_system.dart';
import 'stats_skeleton_loader.dart';

class AdminLoadingState extends StatefulWidget {
  final String? loadingMessage;
  final Duration animationDuration;

  const AdminLoadingState({
    super.key,
    this.loadingMessage = 'Loading platform metrics...',
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<AdminLoadingState> createState() => _AdminLoadingStateState();
}

class _AdminLoadingStateState extends State<AdminLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Animated header
          _buildAnimatedHeader(),

          const SizedBox(height: AdminDesignSystem.spacing24),

          // Skeleton loaders
          const StatsSkeletonLoader(),

          const SizedBox(height: AdminDesignSystem.spacing24),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated title skeleton
          Shimmer.fromColors(
            baseColor: AdminDesignSystem.background,
            highlightColor: AdminDesignSystem.cardBackground,
            child: Container(
              width: 220,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),

          // Animated subtitle skeleton
          Shimmer.fromColors(
            baseColor: AdminDesignSystem.background,
            highlightColor: AdminDesignSystem.cardBackground,
            child: Container(
              width: 150,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          // Animated loading indicator with pulse effect
          ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AdminDesignSystem.accentTeal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AdminDesignSystem.spacing8),
                Text(
                  widget.loadingMessage ?? 'Loading platform metrics...',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
