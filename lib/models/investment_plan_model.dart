// lib/models/investment_plan_model.dart
// Simplified investment plan model for GOLD Savings & Investment Co-operative
import 'package:cloud_firestore/cloud_firestore.dart';

/// Investment plan - represents a savings/investment product
class InvestmentPlanModel {
  final String planId;
  final String planName; // e.g., "Gold Plus", "Silver Shield"
  final String description;
  final double minimumInvestment;
  final double maximumInvestment;
  final double expectedAnnualReturn; // percentage
  final String payoutFrequency; // "Monthly", "Quarterly", "Annual"
  final int durationMonths;
  // Status & Admin
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvestmentPlanModel({
    required this.planId,
    required this.planName,
    required this.description,
    required this.minimumInvestment,
    required this.maximumInvestment,
    required this.expectedAnnualReturn,
    required this.payoutFrequency,
    required this.durationMonths,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // ==================== GETTERS ====================

  /// Check if investment amount is within valid range
  bool isValidInvestmentAmount(double amount) {
    return amount >= minimumInvestment && amount <= maximumInvestment;
  }

  /// Get investment range as formatted string
  String getInvestmentRangeText() {
    return '₦${(minimumInvestment / 1000000).toStringAsFixed(1)}M - ₦${(maximumInvestment / 1000000).toStringAsFixed(1)}M';
  }

  /// Calculate expected return for a given investment amount and time period
  double calculateExpectedReturn(double amount, int months) {
    final rate = expectedAnnualReturn / 100;
    final timeInYears = months / 12;
    return amount * rate * timeInYears;
  }

  /// Get total value (principal + return) for display
  double getTotalValue(double amount, int months) {
    return amount + calculateExpectedReturn(amount, months);
  }

  /// Get payout amount per period
  double getPayoutPerPeriod(double amount) {
    final annualReturn = calculateExpectedReturn(amount, 12);
    switch (payoutFrequency.toLowerCase()) {
      case 'monthly':
        return annualReturn / 12;
      case 'quarterly':
        return annualReturn / 4;
      case 'annual':
        return annualReturn;
      default:
        return annualReturn / 12;
    }
  }

  // ==================== FIRESTORE ====================

  factory InvestmentPlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return InvestmentPlanModel.fromJson(data, doc.id);
  }

  factory InvestmentPlanModel.fromJson(
    Map<String, dynamic> json,
    String planId,
  ) {
    return InvestmentPlanModel(
      planId: planId,
      planName: json['planName'] ?? 'Plan',
      description: json['description'] ?? '',
      minimumInvestment: (json['minimumInvestment'] ?? 0).toDouble(),
      maximumInvestment: (json['maximumInvestment'] ?? 0).toDouble(),
      expectedAnnualReturn: (json['expectedAnnualReturn'] ?? 0).toDouble(),
      payoutFrequency: json['payoutFrequency'] ?? 'Monthly',
      durationMonths: json['durationMonths'] ?? 12,
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      'description': description,
      'minimumInvestment': minimumInvestment,
      'maximumInvestment': maximumInvestment,
      'expectedAnnualReturn': expectedAnnualReturn,
      'payoutFrequency': payoutFrequency,
      'durationMonths': durationMonths,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  InvestmentPlanModel copyWith({
    String? planName,
    String? description,
    double? minimumInvestment,
    double? maximumInvestment,
    double? expectedAnnualReturn,
    String? payoutFrequency,
    int? durationMonths,
    bool? isActive,
    bool? isFeatured,
  }) {
    return InvestmentPlanModel(
      planId: planId,
      planName: planName ?? this.planName,
      description: description ?? this.description,
      minimumInvestment: minimumInvestment ?? this.minimumInvestment,
      maximumInvestment: maximumInvestment ?? this.maximumInvestment,
      expectedAnnualReturn: expectedAnnualReturn ?? this.expectedAnnualReturn,
      payoutFrequency: payoutFrequency ?? this.payoutFrequency,
      durationMonths: durationMonths ?? this.durationMonths,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// ==================== USER INVESTMENT ====================

/// User's active investment in a plan
class UserPlanInvestmentModel {
  final String investmentId;
  final String userId;
  final String planId;
  final String planName;
  final double amountInvested;
  final DateTime investmentDate;
  final DateTime maturityDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPlanInvestmentModel({
    required this.investmentId,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.amountInvested,
    required this.investmentDate,
    required this.maturityDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPlanInvestmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return UserPlanInvestmentModel.fromJson(data, doc.id);
  }

  factory UserPlanInvestmentModel.fromJson(
    Map<String, dynamic> json,
    String investmentId,
  ) {
    return UserPlanInvestmentModel(
      investmentId: investmentId,
      userId: json['userId'] ?? '',
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? '',
      amountInvested: (json['amountInvested'] ?? 0).toDouble(),
      investmentDate: _parseTimestamp(json['investmentDate']),
      maturityDate: _parseTimestamp(json['maturityDate']),
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'amountInvested': amountInvested,
      'investmentDate': Timestamp.fromDate(investmentDate),
      'maturityDate': Timestamp.fromDate(maturityDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}
