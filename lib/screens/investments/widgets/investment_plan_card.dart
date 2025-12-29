// lib/screens/investments/widgets/investment_plan_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/investment_plan_model.dart';
import '../../../models/investment_category.dart';

class InvestmentPlanCard extends StatelessWidget {
  final InvestmentPlanModel plan;
  final VoidCallback onTap;
  final bool isFeatured;

  const InvestmentPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = InvestmentCategoryExtension.fromDuration(
      plan.durationMonths,
    );
    final categoryColor = category.color;

    if (isFeatured) {
      return _buildFeaturedCard(context, category, categoryColor);
    }

    return _buildStandardCard(context, category, categoryColor);
  }

  Widget _buildFeaturedCard(
    BuildContext context,
    InvestmentCategory category,
    Color categoryColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              categoryColor,
              categoryColor.withAlpha(204),
            ],
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withAlpha(76),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated gradient background
            Positioned.fill(
              child: CustomPaint(
                painter: _GradientCirclesPainter(
                  color1: Colors.white.withAlpha(38),
                  color2: Colors.white.withAlpha(25),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured badge
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.small,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Featured',
                          style: AppTextTheme.micro.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Hero icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.medium,
                      ),
                    ),
                    child: Icon(
                      category.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  const Spacer(),

                  // Plan name
                  Text(
                    plan.planName,
                    style: AppTextTheme.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Key metric
                  Row(
                    children: [
                      Text(
                        '${plan.expectedAnnualReturn.toStringAsFixed(1)}% p.a.',
                        style: AppTextTheme.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '· ${plan.durationMonths} months',
                        style: AppTextTheme.bodySmall.copyWith(
                          color: Colors.white.withAlpha(204),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard(
    BuildContext context,
    InvestmentCategory category,
    Color categoryColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero illustration section
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor.withAlpha(38),
                    categoryColor.withAlpha(25),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppBorderRadius.medium),
                  topRight: Radius.circular(AppBorderRadius.medium),
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GradientCirclesPainter(
                        color1: categoryColor.withAlpha(25),
                        color2: categoryColor.withAlpha(12),
                      ),
                    ),
                  ),

                  // Icon
                  Center(
                    child: Icon(
                      category.icon,
                      size: 56,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Details section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan name
                  Text(
                    plan.planName,
                    style: AppTextTheme.heading3.copyWith(
                      color: AppColors.deepNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  Text(
                    plan.description,
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric(
                        'Return',
                        '${plan.expectedAnnualReturn.toStringAsFixed(1)}%',
                        AppColors.tealSuccess,
                      ),
                      _buildMetric(
                        'Duration',
                        '${plan.durationMonths}m',
                        categoryColor,
                      ),
                      _buildMetric(
                        'Min',
                        _formatCurrency(plan.minimumInvestment),
                        AppColors.primaryOrange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextTheme.micro.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextTheme.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₦${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₦${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₦${amount.toStringAsFixed(0)}';
  }
}

/// Custom painter for gradient circles background pattern
class _GradientCirclesPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  _GradientCirclesPainter({
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [color1, color1.withAlpha(0)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.2, size.height * 0.3),
          radius: size.width * 0.4,
        ),
      );

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [color2, color2.withAlpha(0)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.7),
          radius: size.width * 0.5,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      size.width * 0.4,
      paint1,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      size.width * 0.5,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
