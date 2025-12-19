// lib/models/investment_model.dart
// Investment opportunities model for display and purchase

import 'package:cloud_firestore/cloud_firestore.dart';

/// Investment model representing an investment opportunity
/// Maps to Firestore 'investment_opportunities' collection
class InvestmentModel {
  final String investmentId;

  // Basic Info
  final String name;
  final String description;
  final String
  category; // e.g., "Real Estate", "Stocks", "Agriculture", "Treasury"
  final String? logoUrl;
  final String? backgroundImageUrl;

  // Financial Details
  final double minimumInvestment;
  final double maximumInvestment;
  final double currentTargetAmount;
  final double amountRaised;
  final double expectedReturn; // Annual return %
  final String currency;

  // Duration
  final int durationMonths;
  final DateTime startDate;
  final DateTime maturityDate;

  // Status
  final InvestmentStatus status;
  final int investorCount;
  final double riskLevel; // 1.0-5.0

  // Details
  final String? issuer;
  final String? sector;
  final List<String> features; // Key features/benefits
  final String? documentsUrl; // PDF or link to docs
  final String? prospectusUrl; // Legal prospectus

  // Admin
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFeatured;
  final bool isActive;

  // Metadata
  final Map<String, dynamic>? metadata; // Custom fields

  InvestmentModel({
    required this.investmentId,
    required this.name,
    required this.description,
    required this.category,
    this.logoUrl,
    this.backgroundImageUrl,
    required this.minimumInvestment,
    required this.maximumInvestment,
    required this.currentTargetAmount,
    this.amountRaised = 0.0,
    required this.expectedReturn,
    this.currency = 'NGN',
    required this.durationMonths,
    required this.startDate,
    required this.maturityDate,
    this.status = InvestmentStatus.active,
    this.investorCount = 0,
    this.riskLevel = 3.0,
    this.issuer,
    this.sector,
    this.features = const [],
    this.documentsUrl,
    this.prospectusUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isFeatured = false,
    this.isActive = true,
    this.metadata,
  });

  // ==================== GETTERS ====================
  double get progressPercentage => (amountRaised / currentTargetAmount) * 100;
  double get availableAmount => currentTargetAmount - amountRaised;
  bool get isFunded => amountRaised >= currentTargetAmount;
  bool get canInvest =>
      isActive &&
      status == InvestmentStatus.active &&
      !isFunded &&
      availableAmount > 0;

  String get riskLabel {
    if (riskLevel <= 1.5) return 'Very Low';
    if (riskLevel <= 2.5) return 'Low';
    if (riskLevel <= 3.5) return 'Medium';
    if (riskLevel <= 4.5) return 'High';
    return 'Very High';
  }

  // ==================== FROM FIRESTORE ====================
  factory InvestmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvestmentModel.fromJson(data, doc.id);
  }

  factory InvestmentModel.fromJson(
    Map<String, dynamic> json,
    String investmentId,
  ) {
    return InvestmentModel(
      investmentId: investmentId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      logoUrl: json['logoUrl'],
      backgroundImageUrl: json['backgroundImageUrl'],
      minimumInvestment: (json['minimumInvestment'] ?? 0).toDouble(),
      maximumInvestment: (json['maximumInvestment'] ?? double.infinity)
          .toDouble(),
      currentTargetAmount:
          (json['currentTargetAmount'] ?? json['targetAmount'] ?? 0).toDouble(),
      amountRaised: (json['amountRaised'] ?? json['raised'] ?? 0).toDouble(),
      expectedReturn: (json['expectedReturn'] ?? json['annualReturn'] ?? 0)
          .toDouble(),
      currency: json['currency'] ?? 'NGN',
      durationMonths: json['durationMonths'] ?? json['duration'] ?? 12,
      startDate: _parseTimestamp(json['startDate']),
      maturityDate: _parseTimestamp(json['maturityDate']),
      status: _parseInvestmentStatus(json['status']),
      investorCount: json['investorCount'] ?? 0,
      riskLevel: (json['riskLevel'] ?? 3.0).toDouble(),
      issuer: json['issuer'],
      sector: json['sector'],
      features: List<String>.from(json['features'] ?? []),
      documentsUrl: json['documentsUrl'],
      prospectusUrl: json['prospectusUrl'],
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      isFeatured: json['isFeatured'] ?? false,
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'logoUrl': logoUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'minimumInvestment': minimumInvestment,
      'maximumInvestment': maximumInvestment,
      'currentTargetAmount': currentTargetAmount,
      'amountRaised': amountRaised,
      'expectedReturn': expectedReturn,
      'currency': currency,
      'durationMonths': durationMonths,
      'startDate': Timestamp.fromDate(startDate),
      'maturityDate': Timestamp.fromDate(maturityDate),
      'status': status.name,
      'investorCount': investorCount,
      'riskLevel': riskLevel,
      'issuer': issuer,
      'sector': sector,
      'features': features,
      'documentsUrl': documentsUrl,
      'prospectusUrl': prospectusUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isFeatured': isFeatured,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  // ==================== COPY WITH ====================
  InvestmentModel copyWith({
    double? amountRaised,
    int? investorCount,
    InvestmentStatus? status,
    bool? isActive,
    bool? isFeatured,
    Map<String, dynamic>? metadata,
  }) {
    return InvestmentModel(
      investmentId: investmentId,
      name: name,
      description: description,
      category: category,
      logoUrl: logoUrl,
      backgroundImageUrl: backgroundImageUrl,
      minimumInvestment: minimumInvestment,
      maximumInvestment: maximumInvestment,
      currentTargetAmount: currentTargetAmount,
      amountRaised: amountRaised ?? this.amountRaised,
      expectedReturn: expectedReturn,
      currency: currency,
      durationMonths: durationMonths,
      startDate: startDate,
      maturityDate: maturityDate,
      status: status ?? this.status,
      investorCount: investorCount ?? this.investorCount,
      riskLevel: riskLevel,
      issuer: issuer,
      sector: sector,
      features: features,
      documentsUrl: documentsUrl,
      prospectusUrl: prospectusUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  // ==================== HELPERS ====================
  static InvestmentStatus _parseInvestmentStatus(dynamic value) {
    if (value is String) {
      return InvestmentStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => InvestmentStatus.active,
      );
    }
    return InvestmentStatus.active;
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

// ==================== ENUMS ====================
enum InvestmentStatus {
  draft, // Not yet live
  active, // Currently accepting investments
  closed, // No longer accepting (full or deadline)
  matured, // Investment has matured
  paused, // Temporarily paused
  cancelled, // Cancelled
}

// ==================== INVESTMENT FILTER ====================
class InvestmentFilter {
  final List<String>? categories;
  final InvestmentStatus? status;
  final double? minReturn;
  final double? maxReturn;
  final double? maxRiskLevel;
  final double? minInvestment;
  final double? maxInvestment;
  final bool? onlyFeatured;
  final bool? onlyActive;

  InvestmentFilter({
    this.categories,
    this.status,
    this.minReturn,
    this.maxReturn,
    this.maxRiskLevel,
    this.minInvestment,
    this.maxInvestment,
    this.onlyFeatured = false,
    this.onlyActive = true,
  });

  InvestmentFilter copyWith({
    List<String>? categories,
    InvestmentStatus? status,
    double? minReturn,
    double? maxReturn,
    double? maxRiskLevel,
    double? minInvestment,
    double? maxInvestment,
    bool? onlyFeatured,
    bool? onlyActive,
  }) {
    return InvestmentFilter(
      categories: categories ?? this.categories,
      status: status ?? this.status,
      minReturn: minReturn ?? this.minReturn,
      maxReturn: maxReturn ?? this.maxReturn,
      maxRiskLevel: maxRiskLevel ?? this.maxRiskLevel,
      minInvestment: minInvestment ?? this.minInvestment,
      maxInvestment: maxInvestment ?? this.maxInvestment,
      onlyFeatured: onlyFeatured ?? this.onlyFeatured,
      onlyActive: onlyActive ?? this.onlyActive,
    );
  }
}

// ==================== INVESTMENT USER (Pivot Table) ====================
/// User's investment in a specific opportunity
/// Maps to Firestore 'investments_users' or 'user_investments' collection
class UserInvestmentModel {
  final String investmentUserId;
  final String userId;
  final String investmentId;
  final String investmentName;

  // Investment Details
  final double amountInvested;
  final int numberOfUnits;
  final double pricePerUnit;

  // Status
  final InvestmentUserStatus status;
  final DateTime investmentDate;
  final DateTime? maturityDate;

  // Returns
  final double expectedReturnAmount;
  final double actualReturnAmount;
  final double interestEarned;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  UserInvestmentModel({
    required this.investmentUserId,
    required this.userId,
    required this.investmentId,
    required this.investmentName,
    required this.amountInvested,
    this.numberOfUnits = 0,
    this.pricePerUnit = 0,
    this.status = InvestmentUserStatus.active,
    required this.investmentDate,
    this.maturityDate,
    this.expectedReturnAmount = 0,
    this.actualReturnAmount = 0,
    this.interestEarned = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // ==================== GETTERS ====================
  double get totalValue => amountInvested + interestEarned;
  double get unrealizedGain => expectedReturnAmount - amountInvested;
  double get returnPercentage =>
      ((totalValue - amountInvested) / amountInvested) * 100;

  factory UserInvestmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserInvestmentModel.fromJson(data, doc.id);
  }

  factory UserInvestmentModel.fromJson(
    Map<String, dynamic> json,
    String investmentUserId,
  ) {
    return UserInvestmentModel(
      investmentUserId: investmentUserId,
      userId: json['userId'] ?? '',
      investmentId: json['investmentId'] ?? '',
      investmentName: json['investmentName'] ?? '',
      amountInvested: (json['amountInvested'] ?? 0).toDouble(),
      numberOfUnits: json['numberOfUnits'] ?? 0,
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      status: _parseInvestmentUserStatus(json['status']),
      investmentDate: _parseTimestamp(json['investmentDate']),
      maturityDate: json['maturityDate'] != null
          ? _parseTimestamp(json['maturityDate'])
          : null,
      expectedReturnAmount: (json['expectedReturnAmount'] ?? 0).toDouble(),
      actualReturnAmount: (json['actualReturnAmount'] ?? 0).toDouble(),
      interestEarned: (json['interestEarned'] ?? 0).toDouble(),
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'investmentId': investmentId,
      'investmentName': investmentName,
      'amountInvested': amountInvested,
      'numberOfUnits': numberOfUnits,
      'pricePerUnit': pricePerUnit,
      'status': status.name,
      'investmentDate': Timestamp.fromDate(investmentDate),
      'maturityDate': maturityDate != null
          ? Timestamp.fromDate(maturityDate!)
          : null,
      'expectedReturnAmount': expectedReturnAmount,
      'actualReturnAmount': actualReturnAmount,
      'interestEarned': interestEarned,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static InvestmentUserStatus _parseInvestmentUserStatus(dynamic value) {
    if (value is String) {
      return InvestmentUserStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => InvestmentUserStatus.active,
      );
    }
    return InvestmentUserStatus.active;
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

enum InvestmentUserStatus {
  active, // Currently invested
  matured, // Investment matured
  withdrawn, // User withdrew
  liquidated, // Forced liquidation
}
