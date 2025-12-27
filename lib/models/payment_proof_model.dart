// lib/models/payment_proof_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentProofStatus { pending, approved, rejected }

enum ProofFileType { pdf, image }

class PaymentProofModel {
  final String proofId;
  final String userId;
  final String? goalId; // Null for general savings
  final String transactionId;
  final String fileUrl;
  final ProofFileType fileType;
  final String fileName;
  final DateTime uploadedAt;
  final PaymentProofStatus verificationStatus;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final Map<String, dynamic> metadata;

  PaymentProofModel({
    required this.proofId,
    required this.userId,
    this.goalId,
    required this.transactionId,
    required this.fileUrl,
    required this.fileType,
    required this.fileName,
    required this.uploadedAt,
    this.verificationStatus = PaymentProofStatus.pending,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
    this.metadata = const {},
  });

  // ==================== GETTERS ====================

  bool get isPending => verificationStatus == PaymentProofStatus.pending;
  bool get isApproved => verificationStatus == PaymentProofStatus.approved;
  bool get isRejected => verificationStatus == PaymentProofStatus.rejected;

  String get statusLabel {
    switch (verificationStatus) {
      case PaymentProofStatus.pending:
        return 'Pending Verification';
      case PaymentProofStatus.approved:
        return 'Verified';
      case PaymentProofStatus.rejected:
        return 'Rejected';
    }
  }

  // ==================== FROM FIRESTORE ====================

  factory PaymentProofModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentProofModel.fromJson(data);
  }

  factory PaymentProofModel.fromJson(Map<String, dynamic> json) {
    return PaymentProofModel(
      proofId: json['proofId'] ?? '',
      userId: json['userId'] ?? '',
      goalId: json['goalId'],
      transactionId: json['transactionId'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: _parseFileType(json['fileType']),
      fileName: json['fileName'] ?? '',
      uploadedAt:
          _parseTimestamp(json['uploadedAt']) ??
          DateTime.now(), // ✅ FIX: Provide fallback
      verificationStatus: _parseStatus(json['verificationStatus']),
      verifiedBy: json['verifiedBy'],
      verifiedAt: _parseTimestamp(json['verifiedAt']), // ✅ This can be null
      rejectionReason: json['rejectionReason'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // ==================== TO FIRESTORE ====================

  Map<String, dynamic> toJson() {
    return {
      'proofId': proofId,
      'userId': userId,
      'goalId': goalId,
      'transactionId': transactionId,
      'fileUrl': fileUrl,
      'fileType': fileType.name,
      'fileName': fileName,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'verificationStatus': verificationStatus.name,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'rejectionReason': rejectionReason,
      'metadata': metadata,
    };
  }

  // ==================== HELPERS ====================

  static ProofFileType _parseFileType(dynamic value) {
    if (value == null) return ProofFileType.image;
    if (value is String) {
      if (value.toLowerCase() == 'pdf') return ProofFileType.pdf;
    }
    return ProofFileType.image;
  }

  static PaymentProofStatus _parseStatus(dynamic value) {
    if (value == null) return PaymentProofStatus.pending;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'approved':
          return PaymentProofStatus.approved;
        case 'rejected':
          return PaymentProofStatus.rejected;
        default:
          return PaymentProofStatus.pending;
      }
    }
    return PaymentProofStatus.pending;
  }

  // ✅ FIX: Returns nullable DateTime
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ==================== COPY WITH ====================

  PaymentProofModel copyWith({
    String? proofId,
    String? userId,
    String? goalId,
    String? transactionId,
    String? fileUrl,
    ProofFileType? fileType,
    String? fileName,
    DateTime? uploadedAt,
    PaymentProofStatus? verificationStatus,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? rejectionReason,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentProofModel(
      proofId: proofId ?? this.proofId,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      transactionId: transactionId ?? this.transactionId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentProofModel &&
        other.proofId == proofId &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode => proofId.hashCode ^ transactionId.hashCode;
}
