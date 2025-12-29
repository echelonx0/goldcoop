// lib/screens/investments/widgets/featured_plan_carousel.dart

import 'package:flutter/material.dart';
import '../../../models/investment_plan_model.dart';
import 'investment_plan_card.dart';

class FeaturedPlanCarousel extends StatefulWidget {
  final List<InvestmentPlanModel> featuredPlans;
  final Function(InvestmentPlanModel) onPlanTap;

  const FeaturedPlanCarousel({
    super.key,
    required this.featuredPlans,
    required this.onPlanTap,
  });

  @override
  State<FeaturedPlanCarousel> createState() => _FeaturedPlanCarouselState();
}

class _FeaturedPlanCarouselState extends State<FeaturedPlanCarousel> {
  final PageController _pageController = PageController(
    viewportFraction: 0.92,
  );
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredPlans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.featuredPlans.length,
            itemBuilder: (context, index) {
              final plan = widget.featuredPlans[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InvestmentPlanCard(
                  plan: plan,
                  isFeatured: true,
                  onTap: () => widget.onPlanTap(plan),
                ),
              );
            },
          ),
        ),

        // Page indicators
        if (widget.featuredPlans.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.featuredPlans.length,
              (index) => _buildIndicator(index == _currentPage),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withAlpha(128),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
