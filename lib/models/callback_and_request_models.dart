// lib/models/callback_and_request_models.dart
// Models for callback requests and investment requests

import 'package:cloud_firestore/cloud_firestore.dart';

// ==================== CALLBACK REQUEST ====================
/// Callback request model - for support/consultation requests
/// Maps to Firestore 'callback_requests' collection
class CallbackRequestModel {
  final String callbackId;
  final String userId;
  final String userEmail;
  final String userPhone;
  final String userName;
  
  // Request Details
  final String subject; // e.g., "General Inquiry", "Support", "Partnership", "Investment Help"
  final String message;
  final CallbackRequestType requestType;
  final CallbackRequestStatus status;
  
  // Callback Preferences
  final DateTime preferredCallbackDate;
  final String preferredCallbackTime; // e.g., "09:00-12:00", "14:00-17:00"
  final List<String> preferredContactMethods; // ["phone", "whatsapp", "email"]
  final String? bestTimeToReach;
  
  // Management
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? respondedAt;
  final String? assignedToStaffId;
  final String? notes; // Internal notes
  
  // Metadata
  final Map<String, dynamic>? metadata;

  CallbackRequestModel({
    required this.callbackId,
    required this.userId,
    required this.userEmail,
    required this.userPhone,
    required this.userName,
    required this.subject,
    required this.message,
    required this.requestType,
    this.status = CallbackRequestStatus.pending,
    required this.preferredCallbackDate,
    this.preferredCallbackTime = "09:00-17:00",
    this.preferredContactMethods = const ["phone"],
    this.bestTimeToReach,
    required this.createdAt,
    required this.updatedAt,
    this.respondedAt,
    this.assignedToStaffId,
    this.notes,
    this.metadata,
  });

  // ==================== GETTERS ====================
  bool get isPending => status == CallbackRequestStatus.pending;
  bool get isResponded => respondedAt != null;
  int get hoursWaiting => DateTime.now().difference(createdAt).inHours;
  bool get isUrgent => hoursWaiting > 24;

  // ==================== FROM FIRESTORE ====================
  factory CallbackRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CallbackRequestModel.fromJson(data, doc.id);
  }

  factory CallbackRequestModel.fromJson(Map<String, dynamic> json, String callbackId) {
    return CallbackRequestModel(
      callbackId: callbackId,
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhone: json['userPhone'] ?? '',
      userName: json['userName'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      requestType: _parseCallbackType(json['requestType']),
      status: _parseCallbackStatus(json['status']),
      preferredCallbackDate: _parseTimestamp(json['preferredCallbackDate']),
      preferredCallbackTime: json['preferredCallbackTime'] ?? '09:00-17:00',
      preferredContactMethods: List<String>.from(json['preferredContactMethods'] ?? ['phone']),
      bestTimeToReach: json['bestTimeToReach'],
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      respondedAt: json['respondedAt'] != null ? _parseTimestamp(json['respondedAt']) : null,
      assignedToStaffId: json['assignedToStaffId'],
      notes: json['notes'],
      metadata: json['metadata'],
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userName': userName,
      'subject': subject,
      'message': message,
      'requestType': requestType.name,
      'status': status.name,
      'preferredCallbackDate': Timestamp.fromDate(preferredCallbackDate),
      'preferredCallbackTime': preferredCallbackTime,
      'preferredContactMethods': preferredContactMethods,
      'bestTimeToReach': bestTimeToReach,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'assignedToStaffId': assignedToStaffId,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // ==================== COPY WITH ====================
  CallbackRequestModel copyWith({
    CallbackRequestStatus? status,
    DateTime? respondedAt,
    String? assignedToStaffId,
    String? notes,
  }) {
    return CallbackRequestModel(
      callbackId: callbackId,
      userId: userId,
      userEmail: userEmail,
      userPhone: userPhone,
      userName: userName,
      subject: subject,
      message: message,
      requestType: requestType,
      status: status ?? this.status,
      preferredCallbackDate: preferredCallbackDate,
      preferredCallbackTime: preferredCallbackTime,
      preferredContactMethods: preferredContactMethods,
      bestTimeToReach: bestTimeToReach,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      respondedAt: respondedAt ?? this.respondedAt,
      assignedToStaffId: assignedToStaffId ?? this.assignedToStaffId,
      notes: notes ?? this.notes,
      metadata: metadata,
    );
  }

  static CallbackRequestType _parseCallbackType(dynamic value) {
    if (value is String) {
      return CallbackRequestType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => CallbackRequestType.general_inquiry,
      );
    }
    return CallbackRequestType.general_inquiry;
  }

  static CallbackRequestStatus _parseCallbackStatus(dynamic value) {
    if (value is String) {
      return CallbackRequestStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => CallbackRequestStatus.pending,
      );
    }
    return CallbackRequestStatus.pending;
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

enum CallbackRequestType {
  general_inquiry,       // General questions
  support,              // Technical support
  investment_help,      // Help with investment
  partnership,          // Partnership inquiry
  complaint,            // Complaint/feedback
  account_help,         // Account-related help
  kyc_help,            // KYC assistance
  other,               // Other
}

enum CallbackRequestStatus {
  pending,             // Awaiting response
  assigned,            // Assigned to staff
  in_progress,         // Being handled
  completed,           // Done
  no_callback_needed,  // Resolved without callback
  cancelled,           // User cancelled
}

// ==================== INVESTMENT REQUEST (Buy with Balance) ====================
/// Investment request model - when user wants to invest using account balance
/// Maps to Firestore 'investment_requests' collection
class InvestmentRequestModel {
  final String requestId;
  final String userId;
  final String investmentId;
  final String investmentName;
  
  // Request Details
  final double requestedAmount;
  final InvestmentRequestType requestType; // balance_only, balance_with_callback, etc.
  final InvestmentRequestStatus status;
  
  // Balance Usage
  final double availableBalance;
  final double balanceUsed;
  final double additionalFundingNeeded; // If amount > balance
  final String paymentMethod; // "balance", "bank_transfer", "card"
  
  // Additional Info
  final String? notes; // Why they want to invest, questions, etc.
  final bool? agreeToTerms;
  final bool? agreeToKYC;
  
  // For callback if needed
  final bool requestCallback;
  final String? preferredCallbackTime;
  
  // Management
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String? transactionId; // Link to transaction if approved
  
  // Metadata
  final Map<String, dynamic>? metadata;

  InvestmentRequestModel({
    required this.requestId,
    required this.userId,
    required this.investmentId,
    required this.investmentName,
    required this.requestedAmount,
    required this.requestType,
    this.status = InvestmentRequestStatus.pending,
    required this.availableBalance,
    this.balanceUsed = 0,
    this.additionalFundingNeeded = 0,
    this.paymentMethod = 'balance',
    this.notes,
    this.agreeToTerms = true,
    this.agreeToKYC = false,
    this.requestCallback = false,
    this.preferredCallbackTime,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.transactionId,
    this.metadata,
  });

  // ==================== GETTERS ====================
  bool get canUseBalance => availableBalance >= requestedAmount;
  bool get needsAdditionalFunding => requestedAmount > availableBalance;
  bool get isApproved => status == InvestmentRequestStatus.approved;
  bool get isRejected => status == InvestmentRequestStatus.rejected;
  bool get isPending => status == InvestmentRequestStatus.pending;
  
  double get actualAmountToBeInvested => canUseBalance ? requestedAmount : availableBalance;

  // ==================== FROM FIRESTORE ====================
  factory InvestmentRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvestmentRequestModel.fromJson(data, doc.id);
  }

  factory InvestmentRequestModel.fromJson(Map<String, dynamic> json, String requestId) {
    final requestedAmount = (json['requestedAmount'] ?? 0).toDouble();
    final availableBalance = (json['availableBalance'] ?? 0).toDouble();
    final balanceUsed = requestedAmount <= availableBalance ? requestedAmount : availableBalance;
    final additionalNeeded = requestedAmount > availableBalance ? requestedAmount - availableBalance : 0.0;

    return InvestmentRequestModel(
      requestId: requestId,
      userId: json['userId'] ?? '',
      investmentId: json['investmentId'] ?? '',
      investmentName: json['investmentName'] ?? '',
      requestedAmount: requestedAmount,
      requestType: _parseInvestmentRequestType(json['requestType']),
      status: _parseInvestmentRequestStatus(json['status']),
      availableBalance: availableBalance,
      balanceUsed: json['balanceUsed'] != null ? (json['balanceUsed']).toDouble() : balanceUsed,
      additionalFundingNeeded: json['additionalFundingNeeded'] != null 
          ? (json['additionalFundingNeeded']).toDouble() 
          : additionalNeeded,
      paymentMethod: json['paymentMethod'] ?? 'balance',
      notes: json['notes'],
      agreeToTerms: json['agreeToTerms'] ?? true,
      agreeToKYC: json['agreeToKYC'] ?? false,
      requestCallback: json['requestCallback'] ?? false,
      preferredCallbackTime: json['preferredCallbackTime'],
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      approvedAt: json['approvedAt'] != null ? _parseTimestamp(json['approvedAt']) : null,
      rejectedAt: json['rejectedAt'] != null ? _parseTimestamp(json['rejectedAt']) : null,
      rejectionReason: json['rejectionReason'],
      transactionId: json['transactionId'],
      metadata: json['metadata'],
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'investmentId': investmentId,
      'investmentName': investmentName,
      'requestedAmount': requestedAmount,
      'requestType': requestType.name,
      'status': status.name,
      'availableBalance': availableBalance,
      'balanceUsed': balanceUsed,
      'additionalFundingNeeded': additionalFundingNeeded,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'agreeToTerms': agreeToTerms,
      'agreeToKYC': agreeToKYC,
      'requestCallback': requestCallback,
      'preferredCallbackTime': preferredCallbackTime,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'rejectionReason': rejectionReason,
      'transactionId': transactionId,
      'metadata': metadata,
    };
  }

  // ==================== COPY WITH ====================
  InvestmentRequestModel copyWith({
    InvestmentRequestStatus? status,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? rejectionReason,
    String? transactionId,
  }) {
    return InvestmentRequestModel(
      requestId: requestId,
      userId: userId,
      investmentId: investmentId,
      investmentName: investmentName,
      requestedAmount: requestedAmount,
      requestType: requestType,
      status: status ?? this.status,
      availableBalance: availableBalance,
      balanceUsed: balanceUsed,
      additionalFundingNeeded: additionalFundingNeeded,
      paymentMethod: paymentMethod,
      notes: notes,
      agreeToTerms: agreeToTerms,
      agreeToKYC: agreeToKYC,
      requestCallback: requestCallback,
      preferredCallbackTime: preferredCallbackTime,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata,
    );
  }

  static InvestmentRequestType _parseInvestmentRequestType(dynamic value) {
    if (value is String) {
      return InvestmentRequestType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => InvestmentRequestType.balance_only,
      );
    }
    return InvestmentRequestType.balance_only;
  }

  static InvestmentRequestStatus _parseInvestmentRequestStatus(dynamic value) {
    if (value is String) {
      return InvestmentRequestStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => InvestmentRequestStatus.pending,
      );
    }
    return InvestmentRequestStatus.pending;
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

enum InvestmentRequestType {
  balance_only,                 // Only using account balance
  balance_with_callback,        // Balance + wants callback for more info
  partial_balance,              // Using part of balance, add funds later
  full_amount_with_callback,    // Needs callback to fund rest
}

enum InvestmentRequestStatus {
  pending,           // Awaiting review
  under_review,      // Being reviewed
  approved,          // Approved
  rejected,          // Rejected
  needs_kyc,         // Needs KYC completion
  needs_documentation, // Needs additional docs
  completed,         // Investment completed
  cancelled,         // User cancelled
}
