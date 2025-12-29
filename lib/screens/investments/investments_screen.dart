// lib/screens/investments/investments_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/investment_plan_model.dart';
import '../../models/investment_category.dart';
import '../../services/investment_plan_service.dart';
import 'widgets/investment_plan_card.dart';
import 'widgets/featured_plan_carousel.dart';
import 'widgets/investment_filter_sheet.dart';
import 'investment_checkout_screen.dart';

class InvestmentsScreen extends StatefulWidget {
  final String uid;

  const InvestmentsScreen({super.key, required this.uid});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen>
    with SingleTickerProviderStateMixin {
  late final InvestmentPlanService _planService;
  final TextEditingController _searchController = TextEditingController();

  // Filter state (not persisted)
  double _minInvestmentFilter = 0;
  double _maxInvestmentFilter = 10000000;
  double _minReturnFilter = 0;
  int _minDurationFilter = 1;
  int _maxDurationFilter = 24;

  // Tab state
  InvestmentCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _planService = InvestmentPlanService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvestmentFilterSheet(
        minInvestment: _minInvestmentFilter,
        maxInvestment: _maxInvestmentFilter,
        minReturn: _minReturnFilter,
        minDuration: _minDurationFilter,
        maxDuration: _maxDurationFilter,
        onApply: (minInv, maxInv, minRet, minDur, maxDur) {
          setState(() {
            _minInvestmentFilter = minInv;
            _maxInvestmentFilter = maxInv;
            _minReturnFilter = minRet;
            _minDurationFilter = minDur;
            _maxDurationFilter = maxDur;
          });
        },
      ),
    );
  }

  void _showPlanDetails(InvestmentPlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailsSheet(plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      body: CustomScrollView(
        slivers: [_buildAppBar(), _buildSearchAndFilter(), _buildContent()],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: false,
      elevation: 0,
      backgroundColor: AppColors.backgroundWhite,
      title: Text(
        'Investment Plans',
        style: AppTextTheme.heading2.copyWith(color: AppColors.deepNavy),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        color: AppColors.deepNavy,
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.backgroundWhite,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            // Search field
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search plans',
                  hintStyle: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundNeutral,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Filter button
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: _showFilterSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<List<InvestmentPlanModel>>(
      stream: _planService.getActivePlansStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(child: _buildErrorState());
        }

        var allPlans = snapshot.data ?? [];

        // Apply search
        final searchTerm = _searchController.text.toLowerCase();
        if (searchTerm.isNotEmpty) {
          allPlans = allPlans
              .where(
                (plan) =>
                    plan.planName.toLowerCase().contains(searchTerm) ||
                    plan.description.toLowerCase().contains(searchTerm),
              )
              .toList();
        }

        // Apply filters
        allPlans = allPlans.where((plan) {
          return plan.minimumInvestment >= _minInvestmentFilter &&
              plan.maximumInvestment <= _maxInvestmentFilter &&
              plan.expectedAnnualReturn >= _minReturnFilter &&
              plan.durationMonths >= _minDurationFilter &&
              plan.durationMonths <= _maxDurationFilter;
        }).toList();

        if (allPlans.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyState());
        }

        // Separate featured plans
        final featuredPlans = allPlans.where((p) => p.isFeatured).toList();
        final regularPlans = allPlans.where((p) => !p.isFeatured).toList();

        // Categorize regular plans
        final categorizedPlans = _categorizePlans(regularPlans);

        return SliverList(
          delegate: SliverChildListDelegate([
            // Featured carousel
            if (featuredPlans.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: FeaturedPlanCarousel(
                  featuredPlans: featuredPlans,
                  onPlanTap: _showPlanDetails,
                ),
              ),
            ],

            // Category tabs
            _buildCategoryTabs(categorizedPlans),

            // Plans list
            _buildPlansList(categorizedPlans),
          ]),
        );
      },
    );
  }

  Map<InvestmentCategory, List<InvestmentPlanModel>> _categorizePlans(
    List<InvestmentPlanModel> plans,
  ) {
    final categorized = <InvestmentCategory, List<InvestmentPlanModel>>{};

    for (var plan in plans) {
      final category = InvestmentCategoryExtension.fromDuration(
        plan.durationMonths,
      );
      categorized.putIfAbsent(category, () => []).add(plan);
    }

    return categorized;
  }

  Widget _buildCategoryTabs(
    Map<InvestmentCategory, List<InvestmentPlanModel>> categorizedPlans,
  ) {
    // Only show tabs for categories that have plans
    final availableCategories = InvestmentCategory.values
        .where((cat) => categorizedPlans[cat]?.isNotEmpty ?? false)
        .toList();

    if (availableCategories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: availableCategories.map((category) {
            final isSelected = _selectedCategory == category;
            final count = categorizedPlans[category]?.length ?? 0;

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = isSelected ? null : category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color
                        : AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    border: Border.all(
                      color: isSelected
                          ? category.color
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        size: 18,
                        color: isSelected ? Colors.white : category.color,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${category.displayName} ($count)',
                        style: AppTextTheme.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPlansList(
    Map<InvestmentCategory, List<InvestmentPlanModel>> categorizedPlans,
  ) {
    List<InvestmentPlanModel> plansToShow;

    if (_selectedCategory != null) {
      plansToShow = categorizedPlans[_selectedCategory] ?? [];
    } else {
      plansToShow = categorizedPlans.values.expand((list) => list).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(
          plansToShow.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: InvestmentPlanCard(
                plan: plansToShow[index],
                onTap: () => _showPlanDetails(plansToShow[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.warmRed),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load plans',
            style: AppTextTheme.bodyRegular.copyWith(color: AppColors.warmRed),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No plans found',
            style: AppTextTheme.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSheet(InvestmentPlanModel plan) {
    final Map<String, double> investmentAmounts = {};
    final Map<String, int> investmentMonths = {};

    return StatefulBuilder(
      builder: (context, setModalState) {
        // Ensure valid bounds (handle data errors where min > max)
        final minBound = plan.minimumInvestment;
        final maxBound = plan.maximumInvestment;
        final safeMin = minBound < maxBound ? minBound : maxBound;
        final safeMax = maxBound > minBound ? maxBound : minBound;

        // Ensure valid investment amount
        final defaultAmount = safeMin;
        final currentAmount = investmentAmounts[plan.planId] ?? defaultAmount;
        final amount = currentAmount.clamp(safeMin, safeMax);

        final months = investmentMonths[plan.planId] ?? plan.durationMonths;
        final expectedReturn = plan.calculateExpectedReturn(amount, months);
        final totalValue = amount + expectedReturn;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppBorderRadius.large),
              topRight: Radius.circular(AppBorderRadius.large),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  plan.planName,
                  style: AppTextTheme.heading2.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  plan.description,
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ROI Calculator
                _buildROICalculator(
                  setModalState,
                  plan,
                  amount,
                  months,
                  expectedReturn,
                  totalValue,
                  investmentAmounts,
                  investmentMonths,
                ),

                const SizedBox(height: AppSpacing.lg),

                // CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvestmentCheckoutScreen(
                            plan: plan,
                            investmentAmount: amount,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                      ),
                    ),
                    child: Text(
                      'Invest Now',
                      style: AppTextTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildROICalculator(
    StateSetter setModalState,
    InvestmentPlanModel plan,
    double amount,
    int months,
    double expectedReturn,
    double totalValue,
    Map<String, double> investmentAmounts,
    Map<String, int> investmentMonths,
  ) {
    // Ensure valid bounds (handle data errors where min > max)
    final minBound = plan.minimumInvestment;
    final maxBound = plan.maximumInvestment;
    final safeMin = minBound < maxBound ? minBound : maxBound;
    final safeMax = maxBound > minBound ? maxBound : minBound;

    final hasValidRange = safeMax > safeMin;
    final sliderValue = amount.clamp(safeMin, safeMax);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Calculator',
          style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
        ),
        const SizedBox(height: AppSpacing.md),

        // Amount slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatCurrency(amount),
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (hasValidRange)
              Slider(
                value: sliderValue,
                min: safeMin,
                max: safeMax,
                divisions: 99,
                onChanged: (value) {
                  setModalState(() {
                    investmentAmounts[plan.planId] = value;
                  });
                },
                activeColor: AppColors.primaryOrange,
                inactiveColor: AppColors.borderLight,
              )
            else
              // Fixed amount (no slider if min == max)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundNeutral,
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                child: Text(
                  'Fixed investment amount',
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Results
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withAlpha(12),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: AppColors.primaryOrange.withAlpha(25)),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _buildDetailRow('Principal', _formatCurrency(amount)),
              const SizedBox(height: AppSpacing.sm),
              _buildDetailRow(
                'Expected Return',
                _formatCurrency(expectedReturn),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 1,
                color: AppColors.primaryOrange.withAlpha(25),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Value',
                    style: AppTextTheme.bodyRegular.copyWith(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatCurrency(totalValue),
                    style: AppTextTheme.heading3.copyWith(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.tealSuccess,
            fontWeight: FontWeight.w600,
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
