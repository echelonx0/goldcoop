// lib/screens/admin/dashboard/widgets/stats_skeleton_loader.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/admin_design_system.dart';

class StatsSkeletonLoader extends StatelessWidget {
  const StatsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing16,
      ),
      child: Column(
        children: [
          // Small cards row
          Row(
            children: [
              Expanded(child: _buildSmallCardSkeleton()),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(child: _buildSmallCardSkeleton()),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          // Small cards row
          Row(
            children: [
              Expanded(child: _buildSmallCardSkeleton()),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(child: _buildSmallCardSkeleton()),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Large card
          _buildLargeCardSkeleton(),
          const SizedBox(height: AdminDesignSystem.spacing12),

          // Large card
          _buildLargeCardSkeleton(),
          const SizedBox(height: AdminDesignSystem.spacing24),

          // Support section
          Align(
            alignment: Alignment.centerLeft,
            child: _buildTextSkeleton(width: 150, height: 16),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          // Support stats row
          Row(
            children: [
              Expanded(child: _buildSmallCardSkeleton()),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(child: _buildSmallCardSkeleton()),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(child: _buildSmallCardSkeleton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: AdminDesignSystem.background,
      highlightColor: AdminDesignSystem.cardBackground,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(color: AdminDesignSystem.divider),
        ),
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // ✅ FIX: Use min instead of fixed height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon skeleton
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),

            // Label skeleton
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),

            // Value skeleton
            Container(
              width: 80,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: AdminDesignSystem.background,
      highlightColor: AdminDesignSystem.cardBackground,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(color: AdminDesignSystem.divider),
        ),
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        child: IntrinsicHeight(
          // ✅ FIX: Use IntrinsicHeight for proper sizing
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // ✅ FIX: Center alignment
            children: [
              // Icon skeleton
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius12,
                  ),
                ),
              ),
              const SizedBox(width: AdminDesignSystem.spacing16),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ FIX: Use min
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Label skeleton
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing8),

                    // Value skeleton
                    Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextSkeleton({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: AdminDesignSystem.background,
      highlightColor: AdminDesignSystem.cardBackground,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
