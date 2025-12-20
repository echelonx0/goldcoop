// lib/models/financial_wallet_model.dart
// Wallet model for bank accounts, crypto, PayPal, international payments

import 'package:cloud_firestore/cloud_firestore.dart';

/// Financial wallet model for managing multiple payment methods
/// Stored in users/{uid}/wallets subcollection
class FinancialWallet {
  final String walletId;
  final String userId;

  // Wallet Details
  final WalletType type;
  final String walletName; // e.g., "GTBank Account", "Bitcoin Wallet", "PayPal"
  final bool isDefault;
  final bool isVerified;

  // Bank Account Fields (for local/intl bank transfers)
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final String? bankCode; // SWIFT code for international
  final String? routingNumber; // US routing number
  final String? iban; // International IBAN
  final String? country; // Account country

  // Crypto Fields
  final String? walletAddress;
  final String? cryptoType; // BTC, ETH, USDT, etc.
  final String? networkType; // Mainnet, Testnet, etc.

  // PayPal & Digital Wallet Fields
  final String? email; // PayPal, Google Pay, Apple Pay email
  final String? phoneNumber; // Mobile Money, etc.

  // International Payment Fields
  final String? currency;
  final String? paymentMethod; // Wise, Remitly, PayPal, etc.

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastUsedAt;
  final int transactionCount;

  FinancialWallet({
    required this.walletId,
    required this.userId,
    required this.type,
    required this.walletName,
    this.isDefault = false,
    this.isVerified = false,
    // Bank fields
    this.bankName,
    this.accountNumber,
    this.accountHolderName,
    this.bankCode,
    this.routingNumber,
    this.iban,
    this.country,
    // Crypto fields
    this.walletAddress,
    this.cryptoType,
    this.networkType,
    // Digital/PayPal fields
    this.email,
    this.phoneNumber,
    // International fields
    this.currency,
    this.paymentMethod,
    // Metadata
    required this.createdAt,
    required this.updatedAt,
    this.lastUsedAt,
    this.transactionCount = 0,
  });

  // ==================== GETTERS ====================
  String get displayName => walletName;

  String get displayDetails {
    switch (type) {
      case WalletType.bankAccount:
        return '$bankName • ••${accountNumber?.substring(max(0, accountNumber!.length - 4))}';
      case WalletType.cryptoWallet:
        return '$cryptoType • ${walletAddress?.substring(0, 8)}...';
      case WalletType.paypal:
        return 'PayPal • $email';
      case WalletType.mobileMoney:
        return '$walletName • $phoneNumber';
      case WalletType.internationalPayment:
        return '$paymentMethod • $currency';
    }
  }

  bool get canWithdraw =>
      isVerified && accountNumber != null && accountNumber!.isNotEmpty;

  // ==================== FROM FIRESTORE ====================
  factory FinancialWallet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialWallet.fromJson(data, doc.id);
  }

  factory FinancialWallet.fromJson(Map<String, dynamic> json, String walletId) {
    return FinancialWallet(
      walletId: walletId,
      userId: json['userId'] ?? '',
      type: _parseWalletType(json['type']),
      walletName: json['walletName'] ?? '',
      isDefault: json['isDefault'] ?? false,
      isVerified: json['isVerified'] ?? false,
      // Bank
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      accountHolderName: json['accountHolderName'],
      bankCode: json['bankCode'],
      routingNumber: json['routingNumber'],
      iban: json['iban'],
      country: json['country'],
      // Crypto
      walletAddress: json['walletAddress'],
      cryptoType: json['cryptoType'],
      networkType: json['networkType'],
      // Digital
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      // International
      currency: json['currency'],
      paymentMethod: json['paymentMethod'],
      // Metadata
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      lastUsedAt: json['lastUsedAt'],
      transactionCount: json['transactionCount'] ?? 0,
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type.name,
      'walletName': walletName,
      'isDefault': isDefault,
      'isVerified': isVerified,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'bankCode': bankCode,
      'routingNumber': routingNumber,
      'iban': iban,
      'country': country,
      'walletAddress': walletAddress,
      'cryptoType': cryptoType,
      'networkType': networkType,
      'email': email,
      'phoneNumber': phoneNumber,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastUsedAt': lastUsedAt,
      'transactionCount': transactionCount,
    };
  }

  // ==================== COPY WITH ====================
  FinancialWallet copyWith({
    WalletType? type,
    String? walletName,
    bool? isDefault,
    bool? isVerified,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    String? bankCode,
    String? routingNumber,
    String? iban,
    String? country,
    String? walletAddress,
    String? cryptoType,
    String? networkType,
    String? email,
    String? phoneNumber,
    String? currency,
    String? paymentMethod,
    String? lastUsedAt,
    int? transactionCount,
  }) {
    return FinancialWallet(
      walletId: walletId,
      userId: userId,
      type: type ?? this.type,
      walletName: walletName ?? this.walletName,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankCode: bankCode ?? this.bankCode,
      routingNumber: routingNumber ?? this.routingNumber,
      iban: iban ?? this.iban,
      country: country ?? this.country,
      walletAddress: walletAddress ?? this.walletAddress,
      cryptoType: cryptoType ?? this.cryptoType,
      networkType: networkType ?? this.networkType,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  // ==================== HELPERS ====================
  static WalletType _parseWalletType(dynamic value) {
    if (value is String) {
      return WalletType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => WalletType.bankAccount,
      );
    }
    return WalletType.bankAccount;
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
enum WalletType {
  bankAccount, // Local or international bank account
  cryptoWallet, // Bitcoin, Ethereum, USDT, etc.
  paypal, // PayPal account
  mobileMoney, // MTN Mobile Money, Airtel Money, etc.
  internationalPayment, // Wise, Remitly, etc.
}

// ==================== WITHDRAWAL REQUEST MODEL ====================
class WithdrawalRequest {
  final String withdrawalId;
  final String userId;
  final String walletId;

  // Withdrawal Details
  final double amount;
  final String currency;
  final WithdrawalStatus status;
  final String description;

  // Wallet Info (snapshot at time of request)
  final String walletName;
  final String walletDetails;
  final WalletType walletType;

  // Timeline
  final DateTime requestedAt;
  final DateTime? processedAt;
  final DateTime? completedAt;

  // Additional Info
  final String? referenceNumber;
  final String? failureReason;
  final double? fee;
  final String? adminNotes;

  WithdrawalRequest({
    required this.withdrawalId,
    required this.userId,
    required this.walletId,
    required this.amount,
    this.currency = 'NGN',
    this.status = WithdrawalStatus.pending,
    required this.description,
    required this.walletName,
    required this.walletDetails,
    required this.walletType,
    required this.requestedAt,
    this.processedAt,
    this.completedAt,
    this.referenceNumber,
    this.failureReason,
    this.fee,
    this.adminNotes,
  });

  // ==================== GETTERS ====================
  bool get isPending => status == WithdrawalStatus.pending;
  bool get isApproved => status == WithdrawalStatus.approved;
  bool get isCompleted => status == WithdrawalStatus.completed;
  bool get isFailed => status == WithdrawalStatus.failed;

  // ==================== FROM FIRESTORE ====================
  factory WithdrawalRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WithdrawalRequest.fromJson(data, doc.id);
  }

  factory WithdrawalRequest.fromJson(
    Map<String, dynamic> json,
    String withdrawalId,
  ) {
    return WithdrawalRequest(
      withdrawalId: withdrawalId,
      userId: json['userId'] ?? '',
      walletId: json['walletId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'NGN',
      status: _parseWithdrawalStatus(json['status']),
      description: json['description'] ?? 'Withdrawal request',
      walletName: json['walletName'] ?? '',
      walletDetails: json['walletDetails'] ?? '',
      walletType: _parseWalletType(json['walletType']),
      requestedAt: _parseTimestamp(json['requestedAt']),
      processedAt: json['processedAt'] != null
          ? _parseTimestamp(json['processedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? _parseTimestamp(json['completedAt'])
          : null,
      referenceNumber: json['referenceNumber'],
      failureReason: json['failureReason'],
      fee: json['fee'] != null ? (json['fee']).toDouble() : null,
      adminNotes: json['adminNotes'],
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'walletId': walletId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'description': description,
      'walletName': walletName,
      'walletDetails': walletDetails,
      'walletType': walletType.name,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'processedAt': processedAt != null
          ? Timestamp.fromDate(processedAt!)
          : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'referenceNumber': referenceNumber,
      'failureReason': failureReason,
      'fee': fee,
      'adminNotes': adminNotes,
    };
  }

  // ==================== COPY WITH ====================
  WithdrawalRequest copyWith({
    WithdrawalStatus? status,
    DateTime? processedAt,
    DateTime? completedAt,
    String? referenceNumber,
    String? failureReason,
    String? adminNotes,
  }) {
    return WithdrawalRequest(
      withdrawalId: withdrawalId,
      userId: userId,
      walletId: walletId,
      amount: amount,
      currency: currency,
      status: status ?? this.status,
      description: description,
      walletName: walletName,
      walletDetails: walletDetails,
      walletType: walletType,
      requestedAt: requestedAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      failureReason: failureReason ?? this.failureReason,
      fee: fee,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  // ==================== HELPERS ====================
  static WithdrawalStatus _parseWithdrawalStatus(dynamic value) {
    if (value is String) {
      return WithdrawalStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => WithdrawalStatus.pending,
      );
    }
    return WithdrawalStatus.pending;
  }

  static WalletType _parseWalletType(dynamic value) {
    if (value is String) {
      return WalletType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => WalletType.bankAccount,
      );
    }
    return WalletType.bankAccount;
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

// ==================== WITHDRAWAL STATUS ENUM ====================
enum WithdrawalStatus {
  pending, // Awaiting admin review
  approved, // Approved by admin
  processing, // Being processed
  completed, // Successfully completed
  failed, // Failed
  cancelled, // User cancelled
}

int max(int a, int b) => a > b ? a : b;
