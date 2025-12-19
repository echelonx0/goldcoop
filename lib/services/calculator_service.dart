// lib/services/calculator_service.dart

import 'dart:math';

import 'package:intl/intl.dart';

/// Calculation modes for the calculator
enum CalculationMode {
  futureValue, // Principal → Future Value
  principalNeeded, // Target → Required Principal
  returnAmount, // Calculate returns only
  timelineMap, // Show growth over time
}

/// Compounding frequency
enum CompoundingFrequency { daily, monthly, quarterly, semiannual, annual }

/// Result model for calculator outputs
class CalculationResult {
  final double principal;
  final double interestRate;
  final int months;
  final double futureValue;
  final double totalInterest;
  final double monthlyAmount;
  final CompoundingFrequency compounding;
  final List<TimelineEntry> timeline;

  CalculationResult({
    required this.principal,
    required this.interestRate,
    required this.months,
    required this.futureValue,
    required this.totalInterest,
    required this.monthlyAmount,
    required this.compounding,
    required this.timeline,
  });

  /// Formatted outputs
  String get futureValueFormatted => _formatCurrency(futureValue);
  String get totalInterestFormatted => _formatCurrency(totalInterest);
  String get monthlyAmountFormatted => _formatCurrency(monthlyAmount);
  String get annualizedReturnFormatted {
    final annual = (interestRate * 12).toStringAsFixed(2);
    return '$annual%';
  }

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }
}

/// Timeline entry for growth visualization
class TimelineEntry {
  final int month;
  final double balance;
  final double interest;
  final double contributions;

  TimelineEntry({
    required this.month,
    required this.balance,
    required this.interest,
    required this.contributions,
  });
}

/// Main calculator service
class SavingsInvestmentCalculator {
  /// Calculate future value with compound interest
  ///
  /// Formula: FV = P(1 + r/n)^(nt) + PMT * [((1 + r/n)^(nt) - 1) / (r/n)]
  /// Where:
  /// - P = Principal
  /// - r = Annual interest rate (as decimal)
  /// - n = Compounding frequency per year
  /// - t = Time in years
  /// - PMT = Monthly payment
  static CalculationResult calculateFutureValue({
    required double principal,
    required double monthlyContribution,
    required double annualInterestRate,
    required int months,
    CompoundingFrequency compounding = CompoundingFrequency.annual,
  }) {
    final years = months / 12;
    final monthlyRate = annualInterestRate / 100 / 12;

    // Compound interest on principal
    final compoundingPerYear = _getCompoundingPerYear(compounding);
    final ratePerPeriod = (annualInterestRate / 100) / compoundingPerYear;
    final periods = compoundingPerYear * years;

    final principalFV = principal * pow(1 + ratePerPeriod, periods);

    // Future value of annuity (monthly contributions)
    final contributionsFV =
        monthlyContribution *
        ((pow(1 + monthlyRate, months) - 1) / monthlyRate);

    final totalFV = principalFV + contributionsFV;
    final totalInvested = principal + (monthlyContribution * months);
    final totalInterest = totalFV - totalInvested;

    // Generate timeline
    final timeline = _generateTimeline(
      principal: principal,
      monthlyContribution: monthlyContribution,
      monthlyRate: monthlyRate,
      totalMonths: months,
    );

    return CalculationResult(
      principal: principal,
      interestRate: annualInterestRate,
      months: months,
      futureValue: totalFV,
      totalInterest: totalInterest,
      monthlyAmount: monthlyContribution,
      compounding: compounding,
      timeline: timeline,
    );
  }

  /// Calculate required principal to reach target amount
  ///
  /// Solves: Target = P(1 + r/n)^(nt) + PMT * [((1 + r/n)^(nt) - 1) / (r/n)]
  static CalculationResult calculatePrincipalNeeded({
    required double targetAmount,
    required double monthlyContribution,
    required double annualInterestRate,
    required int months,
    CompoundingFrequency compounding = CompoundingFrequency.annual,
  }) {
    final years = months / 12;
    final monthlyRate = annualInterestRate / 100 / 12;

    // FV of monthly contributions
    final contributionsFV =
        monthlyContribution *
        ((pow(1 + monthlyRate, months) - 1) / monthlyRate);

    // Remaining amount that principal must generate
    final remainingFV = targetAmount - contributionsFV;

    // Solve for P: P = FV / (1 + r)^t
    final compoundingPerYear = _getCompoundingPerYear(compounding);
    final ratePerPeriod = (annualInterestRate / 100) / compoundingPerYear;
    final periods = compoundingPerYear * years;

    final principal = remainingFV / pow(1 + ratePerPeriod, periods);

    final totalInvested =
        principal.clamp(0, double.infinity) + (monthlyContribution * months);
    final totalInterest = targetAmount - totalInvested;

    final timeline = _generateTimeline(
      principal: principal.clamp(0, double.infinity),
      monthlyContribution: monthlyContribution,
      monthlyRate: monthlyRate,
      totalMonths: months,
    );

    return CalculationResult(
      principal: principal.clamp(0, double.infinity),
      interestRate: annualInterestRate,
      months: months,
      futureValue: targetAmount,
      totalInterest: totalInterest,
      monthlyAmount: monthlyContribution,
      compounding: compounding,
      timeline: timeline,
    );
  }

  /// Calculate returns only (no principal)
  static CalculationResult calculateReturnsOnly({
    required double monthlyContribution,
    required double annualInterestRate,
    required int months,
    CompoundingFrequency compounding = CompoundingFrequency.annual,
  }) {
    return calculateFutureValue(
      principal: 0,
      monthlyContribution: monthlyContribution,
      annualInterestRate: annualInterestRate,
      months: months,
      compounding: compounding,
    );
  }

  /// Calculate with custom lump sum contributions at intervals
  static CalculationResult calculateWithLumpSums({
    required double principal,
    required List<LumpSumContribution> lumpSums,
    required double annualInterestRate,
    required int months,
    CompoundingFrequency compounding = CompoundingFrequency.annual,
  }) {
    final years = months / 12;
    final monthlyRate = annualInterestRate / 100 / 12;
    final compoundingPerYear = _getCompoundingPerYear(compounding);
    final ratePerPeriod = (annualInterestRate / 100) / compoundingPerYear;

    double totalFV =
        principal *
        pow(1 + ratePerPeriod, compoundingPerYear * years).toDouble();

    double totalLumpSums = 0;
    for (final lump in lumpSums) {
      final monthsToMaturity = months - lump.monthToAdd;
      if (monthsToMaturity > 0) {
        final periodsToMaturity = compoundingPerYear * (monthsToMaturity / 12);
        totalFV += lump.amount * pow(1 + ratePerPeriod, periodsToMaturity);
        totalLumpSums += lump.amount;
      }
    }

    final totalInvested = principal + totalLumpSums;
    final totalInterest = totalFV - totalInvested;

    final timeline = _generateTimelineWithLumpSums(
      principal: principal,
      lumpSums: lumpSums,
      monthlyRate: monthlyRate,
      totalMonths: months,
    );

    return CalculationResult(
      principal: principal,
      interestRate: annualInterestRate,
      months: months,
      futureValue: totalFV,
      totalInterest: totalInterest,
      monthlyAmount: 0,
      compounding: compounding,
      timeline: timeline,
    );
  }

  // ==================== HELPERS ====================

  static int _getCompoundingPerYear(CompoundingFrequency frequency) {
    switch (frequency) {
      case CompoundingFrequency.daily:
        return 365;
      case CompoundingFrequency.monthly:
        return 12;
      case CompoundingFrequency.quarterly:
        return 4;
      case CompoundingFrequency.semiannual:
        return 2;
      case CompoundingFrequency.annual:
        return 1;
    }
  }

  static List<TimelineEntry> _generateTimeline({
    required double principal,
    required double monthlyContribution,
    required double monthlyRate,
    required int totalMonths,
  }) {
    final timeline = <TimelineEntry>[];
    double balance = principal;
    double totalContributions = principal;

    for (int month = 1; month <= totalMonths; month++) {
      final interestEarned = balance * monthlyRate;
      balance += interestEarned + monthlyContribution;
      totalContributions += monthlyContribution;

      if (month % _getTimelineInterval(totalMonths) == 0 || month == 1) {
        timeline.add(
          TimelineEntry(
            month: month,
            balance: balance,
            interest: interestEarned,
            contributions: totalContributions,
          ),
        );
      }
    }

    // Always include final month
    if (timeline.isEmpty || timeline.last.month != totalMonths) {
      final finalInterest = balance * monthlyRate;
      timeline.add(
        TimelineEntry(
          month: totalMonths,
          balance: balance + finalInterest,
          interest: finalInterest,
          contributions: totalContributions,
        ),
      );
    }

    return timeline;
  }

  static List<TimelineEntry> _generateTimelineWithLumpSums({
    required double principal,
    required List<LumpSumContribution> lumpSums,
    required double monthlyRate,
    required int totalMonths,
  }) {
    final timeline = <TimelineEntry>[];
    double balance = principal;

    final lumpSumMap = <int, double>{};
    for (final lump in lumpSums) {
      lumpSumMap[lump.monthToAdd] =
          (lumpSumMap[lump.monthToAdd] ?? 0) + lump.amount;
    }

    for (int month = 1; month <= totalMonths; month++) {
      final interestEarned = balance * monthlyRate;
      balance += interestEarned;

      if (lumpSumMap.containsKey(month)) {
        balance += lumpSumMap[month]!;
      }

      if (month % _getTimelineInterval(totalMonths) == 0 || month == 1) {
        timeline.add(
          TimelineEntry(
            month: month,
            balance: balance,
            interest: interestEarned,
            contributions:
                principal + lumpSumMap.values.fold(0, (a, b) => a + b),
          ),
        );
      }
    }

    return timeline;
  }

  static int _getTimelineInterval(int totalMonths) {
    if (totalMonths <= 12) return 1;
    if (totalMonths <= 60) return 3;
    if (totalMonths <= 120) return 6;
    return 12;
  }
}

/// Model for lump sum contributions
class LumpSumContribution {
  final double amount;
  final int monthToAdd; // Month number to add this contribution

  LumpSumContribution({required this.amount, required this.monthToAdd});
}
