// lib/screens/tools/savings_investment_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/admin_design_system.dart';
import '../../services/calculator_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:delayed_display/delayed_display.dart';

class SavingsInvestmentCalculatorScreen extends StatefulWidget {
  const SavingsInvestmentCalculatorScreen({super.key});

  @override
  State<SavingsInvestmentCalculatorScreen> createState() =>
      _SavingsInvestmentCalculatorScreenState();
}

class _SavingsInvestmentCalculatorScreenState
    extends State<SavingsInvestmentCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Shared inputs
  double _annualRate = 12.0;
  int _months = 12;
  CompoundingFrequency _compounding = CompoundingFrequency.annual;

  // Mode 1: Future Value
  double _principal = 100000;
  double _monthlyContribution = 10000;
  CalculationResult? _fvResult;

  // Mode 2: Principal Needed
  double _targetAmount = 500000;
  CalculationResult? _pnResult;

  // Mode 3: Returns Only
  CalculationResult? _roResult;

  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
    locale: 'en_NG',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateFutureValue();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateFutureValue() {
    _fvResult = SavingsInvestmentCalculator.calculateFutureValue(
      principal: _principal,
      monthlyContribution: _monthlyContribution,
      annualInterestRate: _annualRate,
      months: _months,
      compounding: _compounding,
    );
    setState(() {});
  }

  void _calculatePrincipalNeeded() {
    _pnResult = SavingsInvestmentCalculator.calculatePrincipalNeeded(
      targetAmount: _targetAmount,
      monthlyContribution: _monthlyContribution,
      annualInterestRate: _annualRate,
      months: _months,
      compounding: _compounding,
    );
    setState(() {});
  }

  void _calculateReturnsOnly() {
    _roResult = SavingsInvestmentCalculator.calculateReturnsOnly(
      monthlyContribution: _monthlyContribution,
      annualInterestRate: _annualRate,
      months: _months,
      compounding: _compounding,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Shared inputs
          _buildSharedInputs(),
          const SizedBox(height: AdminDesignSystem.spacing16),
          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFutureValueTab(),
                _buildPrincipalNeededTab(),
                _buildReturnsOnlyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AdminDesignSystem.cardBackground,
      elevation: 0,
      title: DelayedDisplay(
        delay: const Duration(milliseconds: 100),
        child: Text(
          'Savings Calculator',
          style: AdminDesignSystem.headingLarge.copyWith(
            color: AdminDesignSystem.primaryNavy,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: DelayedDisplay(
          delay: const Duration(milliseconds: 200),
          child: Container(
            color: AdminDesignSystem.cardBackground,
            child: TabBar(
              controller: _tabController,
              labelColor: AdminDesignSystem.accentTeal,
              unselectedLabelColor: AdminDesignSystem.textSecondary,
              indicatorColor: AdminDesignSystem.accentTeal,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Future Value'),
                Tab(text: 'Principal Needed'),
                Tab(text: 'Returns Only'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSharedInputs() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 300),
      child: Container(
        color: AdminDesignSystem.cardBackground,
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AdminDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing12),

              // Annual Rate
              _buildSliderInput(
                label: 'Annual Interest Rate',
                value: _annualRate,
                min: 0,
                max: 50,
                onChanged: (v) {
                  _annualRate = v;
                  _calculateFutureValue();
                  _calculatePrincipalNeeded();
                  _calculateReturnsOnly();
                },
                suffix: '%',
              ),
              const SizedBox(height: AdminDesignSystem.spacing12),

              // Duration
              _buildSliderInput(
                label: 'Duration',
                value: _months.toDouble(),
                min: 1,
                max: 360,
                onChanged: (v) {
                  _months = v.toInt();
                  _calculateFutureValue();
                  _calculatePrincipalNeeded();
                  _calculateReturnsOnly();
                },
                suffix: ' months',
              ),
              const SizedBox(height: AdminDesignSystem.spacing12),

              // Compounding
              _buildCompoundingSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderInput({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AdminDesignSystem.bodySmall),
            Text(
              '${value.toStringAsFixed(1)}$suffix',
              style: AdminDesignSystem.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AdminDesignSystem.accentTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminDesignSystem.spacing8),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AdminDesignSystem.accentTeal,
          inactiveColor: AdminDesignSystem.divider,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCompoundingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compounding', style: AdminDesignSystem.bodySmall),
        const SizedBox(height: AdminDesignSystem.spacing8),
        Wrap(
          spacing: AdminDesignSystem.spacing8,
          children: CompoundingFrequency.values.map((freq) {
            final isSelected = _compounding == freq;
            return ChoiceChip(
              label: Text(freq.name.capitalize()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _compounding = freq;
                  _calculateFutureValue();
                  _calculatePrincipalNeeded();
                  _calculateReturnsOnly();
                }
              },
              selectedColor: AdminDesignSystem.accentTeal,
              labelStyle: AdminDesignSystem.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : AdminDesignSystem.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==================== TAB CONTENTS ====================

  Widget _buildFutureValueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Calculate Final Value',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Inputs
          DelayedDisplay(
            delay: const Duration(milliseconds: 500),
            child: _buildNumberInput(
              label: 'Initial Investment',
              value: _principal,
              onChanged: (v) {
                _principal = v;
                _calculateFutureValue();
              },
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          DelayedDisplay(
            delay: const Duration(milliseconds: 600),
            child: _buildNumberInput(
              label: 'Monthly Contribution',
              value: _monthlyContribution,
              onChanged: (v) {
                _monthlyContribution = v;
                _calculateFutureValue();
                _calculatePrincipalNeeded();
                _calculateReturnsOnly();
              },
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Results
          if (_fvResult != null) ...[
            DelayedDisplay(
              delay: const Duration(milliseconds: 700),
              child: _buildResultsCard(_fvResult!),
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            DelayedDisplay(
              delay: const Duration(milliseconds: 900),
              child: _buildChart(_fvResult!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrincipalNeededTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Calculate Required Investment',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Inputs
          DelayedDisplay(
            delay: const Duration(milliseconds: 500),
            child: _buildNumberInput(
              label: 'Target Amount',
              value: _targetAmount,
              onChanged: (v) {
                _targetAmount = v;
                _calculatePrincipalNeeded();
              },
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          DelayedDisplay(
            delay: const Duration(milliseconds: 600),
            child: _buildNumberInput(
              label: 'Monthly Contribution',
              value: _monthlyContribution,
              onChanged: (v) {
                _monthlyContribution = v;
                _calculatePrincipalNeeded();
              },
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Results
          if (_pnResult != null) ...[
            DelayedDisplay(
              delay: const Duration(milliseconds: 700),
              child: Container(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.accentTeal.withAlpha(12),
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Initial Investment Needed',
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing8),
                    AnimatedNumber(
                      value: _pnResult!.principal,
                      formatter: _currencyFormatter,
                      style: AdminDesignSystem.headingMedium.copyWith(
                        color: AdminDesignSystem.accentTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            DelayedDisplay(
              delay: const Duration(milliseconds: 800),
              child: _buildResultsCard(_pnResult!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReturnsOnlyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Calculate Returns from Contributions',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          DelayedDisplay(
            delay: const Duration(milliseconds: 500),
            child: _buildNumberInput(
              label: 'Monthly Contribution',
              value: _monthlyContribution,
              onChanged: (v) {
                _monthlyContribution = v;
                _calculateReturnsOnly();
              },
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          if (_roResult != null) ...[
            DelayedDisplay(
              delay: const Duration(milliseconds: 700),
              child: _buildResultsCard(_roResult!),
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            DelayedDisplay(
              delay: const Duration(milliseconds: 900),
              child: _buildChart(_roResult!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsCard(CalculationResult result) {
    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        border: Border.all(color: AdminDesignSystem.divider),
      ),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedResultRow(
            'Total Invested',
            result.principal + (result.monthlyAmount * result.months),
            AdminDesignSystem.textSecondary,
            delay: 0,
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          _buildAnimatedResultRow(
            'Interest Earned',
            result.totalInterest,
            AdminDesignSystem.accentTeal,
            delay: 100,
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          Container(height: 1, color: AdminDesignSystem.divider),
          const SizedBox(height: AdminDesignSystem.spacing12),
          _buildAnimatedResultRow(
            'Total Value',
            result.futureValue,
            AdminDesignSystem.statusActive,
            isBold: true,
            delay: 200,
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          DelayedDisplay(
            delay: const Duration(milliseconds: 800),
            child: Text(
              'Effective Return: ${(result.totalInterest / (result.principal + (result.monthlyAmount * result.months)) * 100).toStringAsFixed(1)}%',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedResultRow(
    String label,
    double value,
    Color color, {
    bool isBold = false,
    int delay = 0,
  }) {
    return DelayedDisplay(
      delay: Duration(milliseconds: 700 + delay),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          AnimatedNumber(
            value: value,
            formatter: _currencyFormatter,
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: color,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final controller = TextEditingController(
      text: _currencyFormatter.format(value),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AdminDesignSystem.bodySmall),
        const SizedBox(height: AdminDesignSystem.spacing8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            // Remove formatting characters
            final cleanValue = v.replaceAll('₦', '').replaceAll(',', '').trim();
            final num = double.tryParse(cleanValue) ?? value;
            onChanged(num);

            // Re-format on the fly
            if (cleanValue.isNotEmpty) {
              controller.value = controller.value.copyWith(
                text: _currencyFormatter.format(num),
                selection: TextSelection.fromPosition(
                  TextPosition(offset: _currencyFormatter.format(num).length),
                ),
              );
            }
          },
          decoration: InputDecoration(
            hintText: _currencyFormatter.format(0),
            filled: true,
            fillColor: AdminDesignSystem.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing12,
              vertical: AdminDesignSystem.spacing12,
            ),
          ),
          style: AdminDesignSystem.bodyMedium.copyWith(
            color: AdminDesignSystem.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(CalculationResult result) {
    if (result.timeline.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = result.timeline
        .asMap()
        .entries
        .map((e) => FlSpot(e.value.month.toDouble(), e.value.balance))
        .toList();

    final maxY = result.timeline.isNotEmpty
        ? result.timeline.map((e) => e.balance).reduce((a, b) => a > b ? a : b)
        : 100000;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        border: Border.all(color: AdminDesignSystem.divider),
      ),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AdminDesignSystem.divider, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatChartAmount(value),
                    style: AdminDesignSystem.labelSmall,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}m',
                    style: AdminDesignSystem.labelSmall,
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AdminDesignSystem.accentTeal,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  String _formatChartAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(0)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

/// Animated number widget with count-up effect
class AnimatedNumber extends StatefulWidget {
  final double value;
  final NumberFormat formatter;
  final TextStyle? style;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: oldWidget.value, end: widget.value)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          widget.formatter.format(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}

extension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}
