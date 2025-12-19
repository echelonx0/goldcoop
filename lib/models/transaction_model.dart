// lib/models/transaction_model.dart
// Transaction model for all financial movements

import 'package:cloud_firestore/cloud_firestore.dart';

/// Transaction model representing a financial transaction
/// Maps to Firestore 'transactions' collection
class TransactionModel {
  final String transactionId;
  final String userId;

  // Transaction Details
  final TransactionType transactionType;
  final TransactionStatus status;
  final double amount;
  final String currency;
  final String description;

  // Investment-specific
  final String? investmentId;
  final String? investmentName;

  // Timestamp
  final DateTime transactionDate;
  final DateTime createdAt;

  // Additional Info
  final String? referenceNumber;
  final String? failureReason;
  final double? fees;
  final double? netAmount; // Amount after fees
  final String? relatedTransactionId; // For reversals, refunds

  // Metadata
  final Map<String, dynamic>? metadata;

  TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.transactionType,
    required this.status,
    required this.amount,
    this.currency = 'NGN',
    required this.description,
    this.investmentId,
    this.investmentName,
    required this.transactionDate,
    required this.createdAt,
    this.referenceNumber,
    this.failureReason,
    this.fees,
    this.netAmount,
    this.relatedTransactionId,
    this.metadata,
  });

  // ==================== GETTERS ====================
  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isIncome =>
      transactionType == TransactionType.investment_return ||
      transactionType == TransactionType.referral_bonus ||
      transactionType == TransactionType.interest_earned;

  double get displayAmount => netAmount ?? amount;
  TransactionType get type => transactionType;
  // ==================== FROM FIRESTORE ====================
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel.fromJson(data, doc.id);
  }

  factory TransactionModel.fromJson(
    Map<String, dynamic> json,
    String transactionId,
  ) {
    return TransactionModel(
      transactionId: transactionId,
      userId: json['userId'] ?? '',
      transactionType: _parseTransactionType(json['transactionType']),
      status: _parseTransactionStatus(
        json['transactionStatus'] ?? json['status'],
      ),
      amount: (json['transactionAmount'] ?? json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'NGN',
      description:
          json['description'] ??
          _getDefaultDescription(json['transactionType']),
      investmentId: json['investmentId'],
      investmentName: json['investmentName'],
      transactionDate: _parseTimestamp(json['transactionDate'] ?? json['date']),
      createdAt: _parseTimestamp(json['createdAt']),
      referenceNumber: json['referenceNumber'],
      failureReason: json['failureReason'],
      fees: json['fees'] != null ? (json['fees']).toDouble() : null,
      netAmount: json['netAmount'] != null
          ? (json['netAmount']).toDouble()
          : null,
      relatedTransactionId: json['relatedTransactionId'],
      metadata: json['metadata'],
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'transactionType': transactionType.name,
      'transactionStatus': status.name,
      'transactionAmount': amount,
      'currency': currency,
      'description': description,
      'investmentId': investmentId,
      'investmentName': investmentName,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'referenceNumber': referenceNumber,
      'failureReason': failureReason,
      'fees': fees,
      'netAmount': netAmount,
      'relatedTransactionId': relatedTransactionId,
      'metadata': metadata,
    };
  }

  // ==================== COPY WITH ====================
  TransactionModel copyWith({
    TransactionStatus? status,
    String? failureReason,
    String? referenceNumber,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      transactionId: transactionId,
      userId: userId,
      transactionType: transactionType,
      status: status ?? this.status,
      amount: amount,
      currency: currency,
      description: description,
      investmentId: investmentId,
      investmentName: investmentName,
      transactionDate: transactionDate,
      createdAt: createdAt,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      failureReason: failureReason ?? this.failureReason,
      fees: fees,
      netAmount: netAmount,
      relatedTransactionId: relatedTransactionId,
      metadata: metadata ?? this.metadata,
    );
  }

  // ==================== HELPERS ====================
  static TransactionType _parseTransactionType(dynamic value) {
    if (value is String) {
      return TransactionType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TransactionType.deposit,
      );
    }
    return TransactionType.deposit;
  }

  static TransactionStatus _parseTransactionStatus(dynamic value) {
    if (value is String) {
      return TransactionStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TransactionStatus.pending,
      );
    }
    return TransactionStatus.pending;
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

  static String _getDefaultDescription(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'deposit':
          return 'Account deposit';
        case 'withdrawal':
          return 'Account withdrawal';
        case 'investment':
          return 'Investment purchase';
        case 'investment_return':
          return 'Investment return';
        case 'interest_earned':
          return 'Interest earned';
        case 'referral_bonus':
          return 'Referral bonus';
        default:
          return 'Transaction';
      }
    }
    return 'Transaction';
  }
}

// ==================== ENUMS ====================
enum TransactionType {
  deposit, // Money in (from external source)
  withdrawal, // Money out (to external account)
  investment, // Money invested in opportunity
  investment_return, // Return from investment
  interest_earned, // Interest accrued
  referral_bonus, // Bonus from referral
  token_conversion, // Converting tokens to value
  token_purchase, // Buying tokens
  transfer_to_user, // Transfer to another user
  transfer_from_user, // Transfer from another user
  fee, // Service fee
  adjustment, // Admin adjustment
}

enum TransactionStatus {
  pending, // Awaiting processing
  processing, // Being processed
  completed, // Successfully completed
  failed, // Failed
  reversed, // Reversed/refunded
  cancelled, // Cancelled
}

// ==================== TRANSACTION QUERY BUILDER ====================
class TransactionFilter {
  final String? userId;
  final TransactionType? type;
  final TransactionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? investmentId;

  TransactionFilter({
    this.userId,
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.investmentId,
  });
}
