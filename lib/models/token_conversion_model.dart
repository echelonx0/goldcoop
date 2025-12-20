// lib/models/token_conversion_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for conversion status
enum ConversionStatus {
  pending, // Awaiting admin approval
  approved, // Approved, ready to send
  processing, // Sending to telecom
  completed, // Successfully sent
  failed, // Failed
  cancelled, // User cancelled
}

/// Enum for phone networks in Nigeria
enum PhoneNetwork {
  mtn,
  airtel,
  glo, // Globacom
  etisalat,
  other,
}

/// Token conversion model for tracking token → airtime conversions
/// Stored in Firestore 'token_conversions' collection
class TokenConversionModel {
  final String conversionId;
  final String userId;

  // Conversion Details
  final int tokenCount;
  final double nairaValue;
  final String phoneNumber;
  final PhoneNetwork network;

  // Status
  final ConversionStatus status;

  // Timestamps
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;

  // Additional Info
  final String? failureReason;
  final String? transactionId; // Link to transactions collection
  final String? telecomReference; // Reference from telecom API
  final int? retryCount;

  // Metadata
  final Map<String, dynamic>? metadata;

  TokenConversionModel({
    required this.conversionId,
    required this.userId,
    required this.tokenCount,
    required this.nairaValue,
    required this.phoneNumber,
    required this.network,
    this.status = ConversionStatus.pending,
    required this.requestedAt,
    this.approvedAt,
    this.completedAt,
    this.failureReason,
    this.transactionId,
    this.telecomReference,
    this.retryCount = 0,
    this.metadata,
  });

  // ==================== GETTERS ====================
  bool get isPending => status == ConversionStatus.pending;
  bool get isApproved => status == ConversionStatus.approved;
  bool get isProcessing => status == ConversionStatus.processing;
  bool get isCompleted => status == ConversionStatus.completed;
  bool get isFailed => status == ConversionStatus.failed;
  bool get isCancelled => status == ConversionStatus.cancelled;

  bool get canRetry => isFailed && (retryCount ?? 0) < 3;

  String get networkName {
    switch (network) {
      case PhoneNetwork.mtn:
        return 'MTN';
      case PhoneNetwork.airtel:
        return 'Airtel';
      case PhoneNetwork.glo:
        return 'Globacom';
      case PhoneNetwork.etisalat:
        return 'Etisalat';
      case PhoneNetwork.other:
        return 'Other';
    }
  }

  String get displayPhoneNumber {
    // Hide middle digits: 2348012345678 → 2348012***678
    if (phoneNumber.length < 7) return phoneNumber;
    final start = phoneNumber.substring(0, 7);
    final end = phoneNumber.substring(phoneNumber.length - 4);
    return '$start***$end';
  }

  Duration? get processingTime {
    if (completedAt == null) return null;
    return completedAt!.difference(requestedAt);
  }

  // ==================== FROM FIRESTORE ====================
  factory TokenConversionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TokenConversionModel.fromJson(data, doc.id);
  }

  factory TokenConversionModel.fromJson(
    Map<String, dynamic> json,
    String conversionId,
  ) {
    return TokenConversionModel(
      conversionId: conversionId,
      userId: json['userId'] ?? '',
      tokenCount: json['tokenCount'] ?? 0,
      nairaValue: (json['nairaValue'] ?? 0).toDouble(),
      phoneNumber: json['phoneNumber'] ?? '',
      network: _parseNetwork(json['network']),
      status: _parseStatus(json['status']),
      requestedAt: _parseTimestamp(json['requestedAt']),
      approvedAt: json['approvedAt'] != null
          ? _parseTimestamp(json['approvedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? _parseTimestamp(json['completedAt'])
          : null,
      failureReason: json['failureReason'],
      transactionId: json['transactionId'],
      telecomReference: json['telecomReference'],
      retryCount: json['retryCount'] ?? 0,
      metadata: json['metadata'],
    );
  }

  // ==================== TO FIRESTORE ====================
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tokenCount': tokenCount,
      'nairaValue': nairaValue,
      'phoneNumber': phoneNumber,
      'network': network.name,
      'status': status.name,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'failureReason': failureReason,
      'transactionId': transactionId,
      'telecomReference': telecomReference,
      'retryCount': retryCount,
      'metadata': metadata,
    };
  }

  // ==================== COPY WITH ====================
  TokenConversionModel copyWith({
    ConversionStatus? status,
    DateTime? approvedAt,
    DateTime? completedAt,
    String? failureReason,
    String? transactionId,
    String? telecomReference,
    int? retryCount,
  }) {
    return TokenConversionModel(
      conversionId: conversionId,
      userId: userId,
      tokenCount: tokenCount,
      nairaValue: nairaValue,
      phoneNumber: phoneNumber,
      network: network,
      status: status ?? this.status,
      requestedAt: requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      transactionId: transactionId ?? this.transactionId,
      telecomReference: telecomReference ?? this.telecomReference,
      retryCount: retryCount ?? this.retryCount,
      metadata: metadata,
    );
  }

  // ==================== HELPERS ====================
  static ConversionStatus _parseStatus(dynamic value) {
    if (value is String) {
      return ConversionStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ConversionStatus.pending,
      );
    }
    return ConversionStatus.pending;
  }

  static PhoneNetwork _parseNetwork(dynamic value) {
    if (value is String) {
      return PhoneNetwork.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PhoneNetwork.other,
      );
    }
    return PhoneNetwork.other;
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

// ==================== HELPER EXTENSIONS ====================
extension PhoneNumberValidator on String {
  /// Validate Nigerian phone number
  /// Formats: 2348012345678, 08012345678, +2348012345678
  bool get isValidNigerianPhone {
    // Remove common formatting characters
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it's valid Nigerian number
    if (cleaned.startsWith('234') && cleaned.length == 13) {
      return true; // 2348012345678
    }
    if (cleaned.startsWith('0') && cleaned.length == 11) {
      return true; // 08012345678
    }
    if (cleaned.startsWith('+234') && cleaned.length == 14) {
      return true; // +2348012345678
    }

    return false;
  }

  /// Convert to standard format: 2348012345678
  String toNigerianPhoneFormat() {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleaned.startsWith('+234')) {
      return cleaned.substring(1); // +2348012345678 → 2348012345678
    }
    if (cleaned.startsWith('0') && cleaned.length == 11) {
      return '234${cleaned.substring(1)}'; // 08012345678 → 2348012345678
    }

    return cleaned; // Already in correct format
  }

  /// Detect network from phone number
  PhoneNetwork detectNetwork() {
    final cleaned = toNigerianPhoneFormat();

    // Get first 4 digits (after country code 234)
    if (cleaned.length < 7) return PhoneNetwork.other;

    final prefix = cleaned.substring(3, 7);

    // MTN: 0703-0706, 0803-0806
    if ([
      '0703',
      '0704',
      '0705',
      '0706',
      '0803',
      '0804',
      '0805',
      '0806',
    ].contains(prefix)) {
      return PhoneNetwork.mtn;
    }

    // Airtel: 0701, 0702, 0801, 0802
    if (['0701', '0702', '0801', '0802'].contains(prefix)) {
      return PhoneNetwork.airtel;
    }

    // Globacom: 0705, 0807, 0811, 0812
    if (['0707', '0705', '0807', '0811', '0812'].contains(prefix)) {
      return PhoneNetwork.glo;
    }

    // Etisalat: 0809, 0818
    if (['0809', '0818'].contains(prefix)) {
      return PhoneNetwork.etisalat;
    }

    return PhoneNetwork.other;
  }
}
