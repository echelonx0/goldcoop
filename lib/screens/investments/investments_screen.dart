// lib/screens/investments/screens/investments_screen.dart

import 'package:flutter/material.dart';
import '../../components/base/app_card.dart';
import '../../components/base/app_button.dart';
import '../../core/theme/app_colors.dart';
import '../../models/investment_plan_model.dart';
import '../../services/investment_plan_service.dart';
import 'investment_checkout_screen.dart';

class InvestmentsScreen extends StatefulWidget {
  final String uid;

  const InvestmentsScreen({super.key, required this.uid});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  late final InvestmentPlanService _planService;
  final TextEditingController _searchController = TextEditingController();

  // ROI calculator state
  final Map<String, double> _investmentAmounts = {};
  final Map<String, int> _investmentMonths = {};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Investment Plans',
        style: AppTextTheme.heading2.copyWith(
          color: AppColors.deepNavy,
          fontSize: 14,
        ),
      ),
      elevation: 0,
      backgroundColor: AppColors.backgroundWhite,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        color: AppColors.deepNavy,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search plans',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            borderSide: const BorderSide(
              color: AppColors.primaryOrange,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<List<InvestmentPlanModel>>(
      stream: _planService.getActivePlansStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.warmRed),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Failed to load plans',
                  style: AppTextTheme.bodyRegular.copyWith(
                    color: AppColors.warmRed,
                  ),
                ),
              ],
            ),
          );
        }

        var plans = snapshot.data ?? [];

        // Apply search filter
        final searchTerm = _searchController.text.toLowerCase();
        if (searchTerm.isNotEmpty) {
          plans = plans
              .where(
                (plan) =>
                    plan.planName.toLowerCase().contains(searchTerm) ||
                    plan.description.toLowerCase().contains(searchTerm),
              )
              .toList();
        }

        if (plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
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

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: plans.length,
          itemBuilder: (context, index) =>
              _buildPlanCard(context, plans[index]),
        );
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, InvestmentPlanModel plan) {
    final isFeatured = plan.isFeatured;

    return GestureDetector(
      onTap: () => _showPlanDetails(context, plan),
      child: StandardCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured badge
            if (isFeatured)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.softAmber.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: AppColors.softAmber),
                      const SizedBox(width: 4),
                      Text(
                        'Featured',
                        style: AppTextTheme.micro.copyWith(
                          color: AppColors.softAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Plan name
            Text(
              plan.planName,
              style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
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

            const SizedBox(height: AppSpacing.lg),

            // Key metrics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildMetricBadge(
                    label: 'Range',
                    value: plan.getInvestmentRangeText(),
                    valueColor: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildMetricBadge(
                    label: 'Return',
                    value: '${plan.expectedAnnualReturn.toStringAsFixed(1)}%',
                    valueColor: AppColors.tealSuccess,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildMetricBadge(
                    label: 'Payout',
                    value: plan.payoutFrequency,
                    valueColor: AppColors.deepNavy,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // CTA button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'View & Invest',
                onPressed: () => _showPlanDetails(context, plan),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBadge({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextTheme.bodySmall.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showPlanDetails(BuildContext context, InvestmentPlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildDetailsSheet(context, plan),
    );
  }

  Widget _buildDetailsSheet(
    BuildContext parentContext,
    InvestmentPlanModel plan,
  ) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        final amount =
            _investmentAmounts[plan.planId] ?? plan.minimumInvestment;
        final months = _investmentMonths[plan.planId] ?? plan.durationMonths;
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
                // Handle bar
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

                // Title & description
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

                // Key details grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  children: [
                    _buildDetailCard(
                      'Expected Return',
                      '${plan.expectedAnnualReturn.toStringAsFixed(1)}% p.a.',
                      AppColors.tealSuccess,
                    ),
                    _buildDetailCard(
                      'Duration',
                      '${plan.durationMonths} months',
                      AppColors.primaryOrange,
                    ),
                    _buildDetailCard(
                      'Min Investment',
                      _formatCurrency(plan.minimumInvestment),
                      AppColors.deepNavy,
                    ),
                    _buildDetailCard(
                      'Max Investment',
                      _formatCurrency(plan.maximumInvestment),
                      AppColors.primaryOrange,
                    ),
                  ],
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
                ),

                const SizedBox(height: AppSpacing.lg),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Invest Now',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvestmentCheckoutScreen(
                            uid: widget.uid,
                            plan: plan,
                            investmentAmount: amount,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    label: 'Request Callback',
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text('Callback request sent'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ROI Calculator',
          style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
        ),
        const SizedBox(height: AppSpacing.md),

        // Investment amount slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Investment Amount',
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
            Slider(
              value: amount,
              min: plan.minimumInvestment,
              max: plan.maximumInvestment,
              divisions: 99,
              onChanged: (value) {
                setModalState(() {
                  _investmentAmounts[plan.planId] = value;
                });
                setState(() {
                  _investmentAmounts[plan.planId] = value;
                });
              },
              activeColor: AppColors.primaryOrange,
              inactiveColor: AppColors.borderLight,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Duration slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Investment Period',
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$months months',
                  style: AppTextTheme.bodySmall.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Slider(
              value: months.toDouble(),
              min: 1,
              max: plan.durationMonths.toDouble(),
              divisions: plan.durationMonths - 1,
              onChanged: (value) {
                setModalState(() {
                  _investmentMonths[plan.planId] = value.toInt();
                });
                setState(() {
                  _investmentMonths[plan.planId] = value.toInt();
                });
              },
              activeColor: AppColors.primaryOrange,
              inactiveColor: AppColors.borderLight,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Principal',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _formatCurrency(amount),
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expected Return',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _formatCurrency(expectedReturn),
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.tealSuccess,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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

  Widget _buildDetailCard(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: color.withAlpha(25)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextTheme.bodyRegular.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
