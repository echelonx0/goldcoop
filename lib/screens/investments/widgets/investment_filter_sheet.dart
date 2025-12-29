// lib/screens/investments/widgets/investment_filter_sheet.dart

import 'package:flutter/material.dart';
import '../../../components/base/app_button.dart';
import '../../../core/theme/app_colors.dart';

class InvestmentFilterSheet extends StatefulWidget {
  final double minInvestment;
  final double maxInvestment;
  final double minReturn;
  final double maxReturn;
  final int minDuration;
  final int maxDuration;
  final Function(double, double, double, int, int) onApply;

  const InvestmentFilterSheet({
    super.key,
    this.minInvestment = 0,
    this.maxInvestment = 10000000,
    this.minReturn = 0,
    this.maxReturn = 30,
    this.minDuration = 1,
    this.maxDuration = 24,
    required this.onApply,
  });

  @override
  State<InvestmentFilterSheet> createState() => _InvestmentFilterSheetState();
}

class _InvestmentFilterSheetState extends State<InvestmentFilterSheet> {
  late RangeValues _investmentRange;
  late double _returnThreshold;
  late RangeValues _durationRange;

  @override
  void initState() {
    super.initState();
    _investmentRange = RangeValues(widget.minInvestment, widget.maxInvestment);
    _returnThreshold = widget.minReturn;
    _durationRange = RangeValues(
      widget.minDuration.toDouble(),
      widget.maxDuration.toDouble(),
    );
  }

  void _resetFilters() {
    setState(() {
      _investmentRange = RangeValues(0, 10000000);
      _returnThreshold = 0;
      _durationRange = const RangeValues(1, 24);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.large),
          topRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Plans',
                  style: AppTextTheme.heading2.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.borderLight, height: 1),

          // Filters
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Investment range
                  _buildFilterSection(
                    title: 'Investment Range',
                    subtitle:
                        '${_formatCurrency(_investmentRange.start)} - ${_formatCurrency(_investmentRange.end)}',
                    child: RangeSlider(
                      values: _investmentRange,
                      min: 0,
                      max: 10000000,
                      divisions: 100,
                      activeColor: AppColors.primaryOrange,
                      inactiveColor: AppColors.borderLight,
                      onChanged: (values) {
                        setState(() => _investmentRange = values);
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Return threshold
                  _buildFilterSection(
                    title: 'Minimum Expected Return',
                    subtitle: '${_returnThreshold.toStringAsFixed(1)}% p.a.',
                    child: Slider(
                      value: _returnThreshold,
                      min: 0,
                      max: 30,
                      divisions: 30,
                      activeColor: AppColors.tealSuccess,
                      inactiveColor: AppColors.borderLight,
                      onChanged: (value) {
                        setState(() => _returnThreshold = value);
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Duration range
                  _buildFilterSection(
                    title: 'Duration (Months)',
                    subtitle:
                        '${_durationRange.start.toInt()} - ${_durationRange.end.toInt()} months',
                    child: RangeSlider(
                      values: _durationRange,
                      min: 1,
                      max: 24,
                      divisions: 23,
                      activeColor: AppColors.softAmber,
                      inactiveColor: AppColors.borderLight,
                      onChanged: (values) {
                        setState(() => _durationRange = values);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Apply Filters',
                onPressed: () {
                  widget.onApply(
                    _investmentRange.start,
                    _investmentRange.end,
                    _returnThreshold,
                    _durationRange.start.toInt(),
                    _durationRange.end.toInt(),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextTheme.bodyRegular.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.primaryOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
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
