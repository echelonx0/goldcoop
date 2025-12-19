// lib/models/user_model.dart
// User model with fintech-specific fields and extensibility

import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a Gold Savings user
/// Maps to Firestore 'users' collection
/// Includes migration support for existing 'clients' collection fields
class UserModel {
  final String uid;

  // Core Identity
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? profilePic;

  // KYC & Verification
  final KYCStatus kycStatus;
  final String? bvn; // Bank Verification Number (Nigeria)
  final String? nationalId;
  final String? dateOfBirth;
  final String? address;
  final String? country;
  final bool emailVerified;

  // Financial Profile
  final FinancialProfile financialProfile;

  // Account Status
  final AccountStatus accountStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  // Preferences
  final UserPreferences preferences;

  // Metadata
  final Map<String, dynamic>? metadata; // For future use

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.profilePic,
    this.kycStatus = KYCStatus.pending,
    this.bvn,
    this.nationalId,
    this.dateOfBirth,
    this.address,
    this.country,
    this.emailVerified = false,
    required this.financialProfile,
    this.accountStatus = AccountStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    required this.preferences,
    this.metadata,
  });

  // ==================== GETTERS ====================
  String get displayName => '$firstName $lastName';

  bool get isKYCVerified => kycStatus == KYCStatus.verified;
  bool get isAccountActive => accountStatus == AccountStatus.active;
  bool get canInvest => isAccountActive && isKYCVerified;
  bool get canWithdraw =>
      isAccountActive && (financialProfile.accountBalance > 0);

  // ==================== FROM FIRESTORE ====================
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data, doc.id);
  }

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    // Log raw data
    // log('[UserModel.fromJson] Starting parse for uid: $uid');
    // log('[UserModel.fromJson] Raw JSON keys: ${json.keys.toList()}');

    // Parse each field with logging
    final email = _toStringWithLog(json['email'], 'email');
    final firstName = _toStringWithLog(
      json['firstName']?.toString().isNotEmpty == true
          ? json['firstName']
          : json['displayName']?.toString().split(' ').firstOrNull,
      'firstName',
    );
    final lastName = _toStringWithLog(
      json['lastName']?.toString().isNotEmpty == true
          ? json['lastName']
          : json['displayName']?.toString().split(' ').skip(1).join(' '),
      'lastName',
    );
    final phoneNumber = _toStringWithLog(json['phoneNumber'], 'phoneNumber');
    final profilePic =
        json['profilePic']?.toString() ?? json['photoUrl']?.toString();
    // log(
    //   '[UserModel.fromJson] profilePic: $profilePic (from ${json['profilePic']} or ${json['photoUrl']})',
    // );

    final bvn = _toStringWithLog(json['bvn'], 'bvn');
    final nationalId = _toStringWithLog(json['nationalId'], 'nationalId');
    final dateOfBirth = _toStringWithLog(json['dateOfBirth'], 'dateOfBirth');
    final address = _toStringWithLog(json['address'], 'address');
    final country = _toStringWithLog(json['country'], 'country');

    final emailVerified = json['emailVerified'] ?? false;
    // log('[UserModel.fromJson] emailVerified: $emailVerified');

    final kycStatus = _parseKYCStatus(json['kycStatus']);
    // log(
    //   '[UserModel.fromJson] kycStatus: $kycStatus (from ${json['kycStatus']})',
    // );

    final accountStatus = _parseAccountStatus(json['accountStatus']);
    // log(
    //   '[UserModel.fromJson] accountStatus: $accountStatus (from ${json['accountStatus']})',
    // );

    final createdAt = _parseTimestamp(json['createdAt']);
    final updatedAt = _parseTimestamp(json['updatedAt']);
    final lastLoginAt = json['lastLoginAt'] != null
        ? _parseTimestamp(json['lastLoginAt'])
        : null;

    final financialProfile = FinancialProfile.fromJson(
      json['financialProfile'] ?? {},
      json,
    );

    final preferences = UserPreferences.fromJson(json['preferences'] ?? {});

    return UserModel(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profilePic: profilePic,
      kycStatus: kycStatus,
      bvn: bvn,
      nationalId: nationalId,
      dateOfBirth: dateOfBirth,
      address: address,
      country: country,
      emailVerified: emailVerified,
      financialProfile: financialProfile,
      accountStatus: accountStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
      preferences: preferences,
      metadata: json['metadata'],
    );
  }

  // New helper with logging
  static String _toStringWithLog(dynamic value, String fieldName) {
    final result = _toString(value);

    return result;
  }

  // Updated _toString - returns empty string for nulls
  static String _toString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();

    return '';
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'kycStatus': kycStatus.name,
      'bvn': bvn,
      'nationalId': nationalId,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'country': country,
      'emailVerified': emailVerified,
      'financialProfile': financialProfile.toJson(),
      'accountStatus': accountStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'preferences': preferences.toJson(),
      'metadata': metadata,
    };
  }

  // ==================== HELPERS ====================
  static KYCStatus _parseKYCStatus(dynamic value) {
    if (value is String) {
      return KYCStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => KYCStatus.pending,
      );
    }
    return KYCStatus.pending;
  }

  static AccountStatus _parseAccountStatus(dynamic value) {
    if (value is String) {
      return AccountStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AccountStatus.active,
      );
    }
    return AccountStatus.active;
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

  // ==================== COPY WITH ====================
  UserModel copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePic,
    KYCStatus? kycStatus,
    String? bvn,
    String? nationalId,
    String? dateOfBirth,
    String? address,
    String? country,
    bool? emailVerified,
    FinancialProfile? financialProfile,
    AccountStatus? accountStatus,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePic: profilePic ?? this.profilePic,
      kycStatus: kycStatus ?? this.kycStatus,
      bvn: bvn ?? this.bvn,
      nationalId: nationalId ?? this.nationalId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      country: country ?? this.country,
      emailVerified: emailVerified ?? this.emailVerified,
      financialProfile: financialProfile ?? this.financialProfile,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }
}

// ==================== ENUMS ====================
enum KYCStatus {
  pending, // Not started
  submitted, // Awaiting verification
  verified, // Approved
  rejected, // Failed verification
  expired, // Needs renewal
}

enum AccountStatus {
  active, // Normal operation
  suspended, // Temporary freeze
  locked, // Security issue
  closed, // Account closed
}

// ==================== FINANCIAL PROFILE ====================

class FinancialProfile {
  final double accountBalance;
  final double totalInvested;
  final double totalReturns;
  final double availableBalance;
  final int tokenBalance;
  final double monthlyIncome; // Optional, for future credit features
  final double savingsTarget; // Savings goal
  final String? bankName;
  final String? accountNumber;
  final String? accountType; // savings, checking, etc.
  final CreditProfile? creditProfile;

  FinancialProfile({
    this.accountBalance = 0.0,
    this.totalInvested = 0.0,
    this.totalReturns = 0.0,
    this.availableBalance = 0.0,
    this.tokenBalance = 0,
    this.monthlyIncome = 0.0,
    this.savingsTarget = 0.0,
    this.bankName,
    this.accountNumber,
    this.accountType,
    this.creditProfile,
  });

  factory FinancialProfile.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> rawData,
  ) {
    // Safe cast without type checking
    Map<String, dynamic> fpData;
    if (json.isNotEmpty) {
      fpData = json;
    } else {
      final rawFp = rawData['financialProfile'];
      if (rawFp is Map) {
        fpData = Map<String, dynamic>.from(rawFp);
      } else {
        fpData = {};
      }
    }

    final accountBalance = _toDoubleWithLog(
      fpData['accountBalance'] ?? rawData['accountBalance'],
      'accountBalance',
    );
    final totalInvested = _toDoubleWithLog(
      fpData['totalInvested'] ?? rawData['totalInvested'],
      'totalInvested',
    );
    final totalReturns = _toDoubleWithLog(
      fpData['totalReturns'] ?? rawData['totalReturns'],
      'totalReturns',
    );
    final availableBalance = _toDoubleWithLog(
      fpData['availableBalance'] ?? rawData['accountBalance'],
      'availableBalance',
    );
    final tokenBalance = _toIntWithLog(
      fpData['tokenBalance'] ?? rawData['tokenBalance'],
      'tokenBalance',
    );
    final monthlyIncome = _toDoubleWithLog(
      fpData['monthlyIncome'],
      'monthlyIncome',
    );
    final savingsTarget = _toDoubleWithLog(
      fpData['savingsTarget'] ?? rawData['savingsTarget'],
      'savingsTarget',
    );
    final bankName = _toStringWithLog(fpData['bankName'], 'bankName');
    final accountNumber = _toStringWithLog(
      fpData['accountNumber'] ?? rawData['accountNumber'],
      'accountNumber',
    );
    final accountType = _toStringWithLog(fpData['accountType'], 'accountType');

    final creditProfile = fpData['creditProfile'] != null
        ? CreditProfile.fromJson(
            fpData['creditProfile'] as Map<String, dynamic>,
          )
        : null;

    return FinancialProfile(
      accountBalance: accountBalance,
      totalInvested: totalInvested,
      totalReturns: totalReturns,
      availableBalance: availableBalance,
      tokenBalance: tokenBalance,
      monthlyIncome: monthlyIncome,
      savingsTarget: savingsTarget,
      bankName: bankName,
      accountNumber: accountNumber,
      accountType: accountType,
      creditProfile: creditProfile,
    );
  }

  // Add the missing helper methods
  static int _toIntWithLog(dynamic value, String fieldName) {
    final result = _toInt(value);

    return result;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }

  static String _toStringWithLog(dynamic value, String fieldName) {
    final result = _toString(value);

    return result;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();

    return '';
  }

  static double _toDoubleWithLog(dynamic value, String fieldName) {
    final result = _toDouble(value);

    return result;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;

    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'accountBalance': accountBalance,
      'totalInvested': totalInvested,
      'totalReturns': totalReturns,
      'availableBalance': availableBalance,
      'tokenBalance': tokenBalance,
      'monthlyIncome': monthlyIncome,
      'savingsTarget': savingsTarget,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'creditProfile': creditProfile?.toJson(),
    };
  }
}

// ==================== CREDIT PROFILE ====================
class CreditProfile {
  final double creditScore;
  final double creditLimit;
  final double usedCredit;
  final DateTime? lastUpdated;

  CreditProfile({
    this.creditScore = 0.0,
    this.creditLimit = 0.0,
    this.usedCredit = 0.0,
    this.lastUpdated,
  });

  double get availableCredit => creditLimit - usedCredit;

  factory CreditProfile.fromJson(Map<String, dynamic> json) {
    return CreditProfile(
      creditScore: (json['creditScore'] ?? 0).toDouble(),
      creditLimit: (json['creditLimit'] ?? 0).toDouble(),
      usedCredit: (json['usedCredit'] ?? 0).toDouble(),
      lastUpdated: json['lastUpdated'] != null
          ? (json['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creditScore': creditScore,
      'creditLimit': creditLimit,
      'usedCredit': usedCredit,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }
}

// ==================== USER PREFERENCES ====================

class UserPreferences {
  final bool receiveNotifications;
  final bool receiveMarketingEmails;
  final String preferredLanguage;
  final String timezone;
  final bool twoFactorEnabled;
  final List<String> investmentCategories; // Categories user is interested in

  UserPreferences({
    this.receiveNotifications = true,
    this.receiveMarketingEmails = false,
    this.preferredLanguage = 'en',
    this.timezone = 'UTC',
    this.twoFactorEnabled = false,
    this.investmentCategories = const [],
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      receiveNotifications: json['receiveNotifications'] ?? true,
      receiveMarketingEmails: json['receiveMarketingEmails'] ?? false,
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      timezone: json['timezone'] ?? 'UTC',
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      investmentCategories: _safeStringList(json['investmentCategories']),
    );
  }

  static List<String> _safeStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'receiveNotifications': receiveNotifications,
      'receiveMarketingEmails': receiveMarketingEmails,
      'preferredLanguage': preferredLanguage,
      'timezone': timezone,
      'twoFactorEnabled': twoFactorEnabled,
      'investmentCategories': investmentCategories,
    };
  }
}
