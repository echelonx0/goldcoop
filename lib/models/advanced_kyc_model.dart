// lib/models/advanced_kyc_model.dart
// Advanced KYC data model for extended user profiling

import 'package:cloud_firestore/cloud_firestore.dart';

/// Advanced KYC status tracking
enum AdvancedKYCStatus { notStarted, inProgress, completed }

/// Gender options
enum Gender { male, female, other, preferNotToSay }

/// Relationship types for next of kin
enum Relationship { spouse, parent, sibling, child, relative, friend, other }

/// Main Advanced KYC Model
class AdvancedKYCModel {
  final String userId;
  final PersonalDetails personalDetails;
  final NextOfKin nextOfKin;
  final SavingsProfile savingsProfile;
  final AdvancedKYCStatus status;
  final int completionPercentage;
  final DateTime? completedAt;
  final DateTime updatedAt;

  AdvancedKYCModel({
    required this.userId,
    required this.personalDetails,
    required this.nextOfKin,
    required this.savingsProfile,
    this.status = AdvancedKYCStatus.notStarted,
    this.completionPercentage = 0,
    this.completedAt,
    required this.updatedAt,
  });

  bool get isComplete => status == AdvancedKYCStatus.completed;

  factory AdvancedKYCModel.empty(String userId) {
    return AdvancedKYCModel(
      userId: userId,
      personalDetails: PersonalDetails.empty(),
      nextOfKin: NextOfKin.empty(),
      savingsProfile: SavingsProfile.empty(),
      status: AdvancedKYCStatus.notStarted,
      completionPercentage: 0,
      updatedAt: DateTime.now(),
    );
  }

  factory AdvancedKYCModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdvancedKYCModel.fromJson(data, doc.id);
  }

  factory AdvancedKYCModel.fromJson(Map<String, dynamic> json, String userId) {
    return AdvancedKYCModel(
      userId: userId,
      personalDetails: PersonalDetails.fromJson(json['personalDetails'] ?? {}),
      nextOfKin: NextOfKin.fromJson(json['nextOfKin'] ?? {}),
      savingsProfile: SavingsProfile.fromJson(json['savingsProfile'] ?? {}),
      status: _parseStatus(json['status']),
      completionPercentage: json['completionPercentage'] ?? 0,
      completedAt: _parseTimestamp(json['completedAt']),
      updatedAt: _parseTimestamp(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'personalDetails': personalDetails.toJson(),
      'nextOfKin': nextOfKin.toJson(),
      'savingsProfile': savingsProfile.toJson(),
      'status': status.name,
      'completionPercentage': completionPercentage,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AdvancedKYCModel copyWith({
    PersonalDetails? personalDetails,
    NextOfKin? nextOfKin,
    SavingsProfile? savingsProfile,
    AdvancedKYCStatus? status,
    int? completionPercentage,
    DateTime? completedAt,
  }) {
    return AdvancedKYCModel(
      userId: userId,
      personalDetails: personalDetails ?? this.personalDetails,
      nextOfKin: nextOfKin ?? this.nextOfKin,
      savingsProfile: savingsProfile ?? this.savingsProfile,
      status: status ?? this.status,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: DateTime.now(),
    );
  }

  static AdvancedKYCStatus _parseStatus(dynamic value) {
    if (value is String) {
      return AdvancedKYCStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AdvancedKYCStatus.notStarted,
      );
    }
    return AdvancedKYCStatus.notStarted;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

/// Personal Details Section
class PersonalDetails {
  final Gender? gender;
  final String occupation;
  final String dateOfBirth;
  final String homeTown;
  final String lga; // Local Government Area
  final String state;
  final String whatsappNumber;

  PersonalDetails({
    this.gender,
    this.occupation = '',
    this.dateOfBirth = '',
    this.homeTown = '',
    this.lga = '',
    this.state = '',
    this.whatsappNumber = '',
  });

  bool get isComplete =>
      gender != null &&
      occupation.isNotEmpty &&
      dateOfBirth.isNotEmpty &&
      homeTown.isNotEmpty &&
      state.isNotEmpty;

  int get completionScore {
    int score = 0;
    if (gender != null) score += 15;
    if (occupation.isNotEmpty) score += 15;
    if (dateOfBirth.isNotEmpty) score += 15;
    if (homeTown.isNotEmpty) score += 10;
    if (lga.isNotEmpty) score += 10;
    if (state.isNotEmpty) score += 10;
    if (whatsappNumber.isNotEmpty) score += 10;
    return score; // Max 85, normalized to ~33% of total
  }

  factory PersonalDetails.empty() => PersonalDetails();

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      gender: _parseGender(json['gender']),
      occupation: json['occupation'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      homeTown: json['homeTown'] ?? '',
      lga: json['lga'] ?? '',
      state: json['state'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender?.name,
      'occupation': occupation,
      'dateOfBirth': dateOfBirth,
      'homeTown': homeTown,
      'lga': lga,
      'state': state,
      'whatsappNumber': whatsappNumber,
    };
  }

  PersonalDetails copyWith({
    Gender? gender,
    String? occupation,
    String? dateOfBirth,
    String? homeTown,
    String? lga,
    String? state,
    String? whatsappNumber,
  }) {
    return PersonalDetails(
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      homeTown: homeTown ?? this.homeTown,
      lga: lga ?? this.lga,
      state: state ?? this.state,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }

  static Gender? _parseGender(dynamic value) {
    if (value is String) {
      return Gender.values.firstWhere(
        (e) => e.name == value,
        orElse: () => Gender.preferNotToSay,
      );
    }
    return null;
  }
}

/// Next of Kin Section
class NextOfKin {
  final String fullName;
  final Relationship? relationship;
  final String phoneNumber;
  final String address;
  final String email;

  NextOfKin({
    this.fullName = '',
    this.relationship,
    this.phoneNumber = '',
    this.address = '',
    this.email = '',
  });

  bool get isComplete =>
      fullName.isNotEmpty && relationship != null && phoneNumber.isNotEmpty;

  int get completionScore {
    int score = 0;
    if (fullName.isNotEmpty) score += 25;
    if (relationship != null) score += 20;
    if (phoneNumber.isNotEmpty) score += 25;
    if (address.isNotEmpty) score += 15;
    if (email.isNotEmpty) score += 15;
    return score; // Max 100, normalized to ~33% of total
  }

  factory NextOfKin.empty() => NextOfKin();

  factory NextOfKin.fromJson(Map<String, dynamic> json) {
    return NextOfKin(
      fullName: json['fullName'] ?? '',
      relationship: _parseRelationship(json['relationship']),
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'relationship': relationship?.name,
      'phoneNumber': phoneNumber,
      'address': address,
      'email': email,
    };
  }

  NextOfKin copyWith({
    String? fullName,
    Relationship? relationship,
    String? phoneNumber,
    String? address,
    String? email,
  }) {
    return NextOfKin(
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      email: email ?? this.email,
    );
  }

  static Relationship? _parseRelationship(dynamic value) {
    if (value is String) {
      return Relationship.values.firstWhere(
        (e) => e.name == value,
        orElse: () => Relationship.other,
      );
    }
    return null;
  }
}

/// Savings Profile Section
class SavingsProfile {
  final String savingsPurpose;
  final double targetAmount;
  final String targetDuration; // e.g., "6 months", "1 year"
  final String referralName;
  final String referralPhone;
  final List<String> interestAreas; // Investment categories

  SavingsProfile({
    this.savingsPurpose = '',
    this.targetAmount = 0.0,
    this.targetDuration = '',
    this.referralName = '',
    this.referralPhone = '',
    this.interestAreas = const [],
  });

  bool get isComplete => savingsPurpose.isNotEmpty && targetAmount > 0;

  int get completionScore {
    int score = 0;
    if (savingsPurpose.isNotEmpty) score += 30;
    if (targetAmount > 0) score += 25;
    if (targetDuration.isNotEmpty) score += 15;
    if (referralName.isNotEmpty) score += 10;
    if (referralPhone.isNotEmpty) score += 10;
    if (interestAreas.isNotEmpty) score += 10;
    return score; // Max 100, normalized to ~33% of total
  }

  factory SavingsProfile.empty() => SavingsProfile();

  factory SavingsProfile.fromJson(Map<String, dynamic> json) {
    return SavingsProfile(
      savingsPurpose: json['savingsPurpose'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      targetDuration: json['targetDuration'] ?? '',
      referralName: json['referralName'] ?? '',
      referralPhone: json['referralPhone'] ?? '',
      interestAreas: _parseStringList(json['interestAreas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'savingsPurpose': savingsPurpose,
      'targetAmount': targetAmount,
      'targetDuration': targetDuration,
      'referralName': referralName,
      'referralPhone': referralPhone,
      'interestAreas': interestAreas,
    };
  }

  SavingsProfile copyWith({
    String? savingsPurpose,
    double? targetAmount,
    String? targetDuration,
    String? referralName,
    String? referralPhone,
    List<String>? interestAreas,
  }) {
    return SavingsProfile(
      savingsPurpose: savingsPurpose ?? this.savingsPurpose,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDuration: targetDuration ?? this.targetDuration,
      referralName: referralName ?? this.referralName,
      referralPhone: referralPhone ?? this.referralPhone,
      interestAreas: interestAreas ?? this.interestAreas,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}

/// Nigerian States for dropdown
class NigerianStates {
  static const List<String> states = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'FCT',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];
}

/// Savings Purpose Options
class SavingsPurposeOptions {
  static const List<String> purposes = [
    'Emergency Fund',
    'Business Capital',
    'Education',
    'Home Purchase',
    'Vehicle Purchase',
    'Wedding',
    'Travel',
    'Retirement',
    'Investment',
    'General Savings',
    'Other',
  ];
}

/// Interest Areas for personalization
class InterestAreaOptions {
  static const List<String> areas = [
    'Gold Investment',
    'Fixed Deposits',
    'Real Estate',
    'Agriculture',
    'Stocks & Bonds',
    'Cryptocurrency',
    'Mutual Funds',
    'Insurance',
  ];
}

/// Product Interests for personalized offerings
class ProductInterestOptions {
  static const List<ProductInterest> products = [
    ProductInterest(
      id: 'gold_savings',
      name: 'Gold Savings',
      description: 'Save in gold to protect against inflation',
      icon: 'savings',
    ),
    ProductInterest(
      id: 'gold_investment',
      name: 'Gold Investment',
      description: 'Invest in gold for potential returns',
      icon: 'trending_up',
    ),
    ProductInterest(
      id: 'credit',
      name: 'Credit/Loans',
      description: 'Access to personal or business loans',
      icon: 'account_balance',
    ),
    ProductInterest(
      id: 'insurance',
      name: 'Insurance',
      description: 'Life, health, or asset protection',
      icon: 'security',
    ),
    ProductInterest(
      id: 'cooperative',
      name: 'Cooperative Benefits',
      description: 'Group savings and mutual support',
      icon: 'groups',
    ),
    ProductInterest(
      id: 'education',
      name: 'Financial Education',
      description: 'Learn about money management',
      icon: 'school',
    ),
  ];
}

class ProductInterest {
  final String id;
  final String name;
  final String description;
  final String icon;

  const ProductInterest({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// Employment Status Options
class EmploymentStatusOptions {
  static const List<String> statuses = [
    'Employed (Full-time)',
    'Employed (Part-time)',
    'Self-Employed',
    'Business Owner',
    'Trader/Merchant',
    'Farmer',
    'Student',
    'Retired',
    'Unemployed',
  ];
}

/// Monthly Income Ranges
class IncomeRangeOptions {
  static const List<String> ranges = [
    'Below ₦50,000',
    '₦50,000 - ₦100,000',
    '₦100,000 - ₦250,000',
    '₦250,000 - ₦500,000',
    '₦500,000 - ₦1,000,000',
    'Above ₦1,000,000',
    'Prefer not to say',
  ];
}
