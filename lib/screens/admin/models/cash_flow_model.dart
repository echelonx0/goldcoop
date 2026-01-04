// lib/models/cash_flow_model.dart
// Clean, dedicated model for deposit/withdrawal tracking

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single cash flow entry (deposit or withdrawal)
/// Stored in 'cash_flows' collection
class CashFlowModel {
  final String id;
  final String userId;
  final CashFlowType type;
  final CashFlowStatus status;
  final double amount;
  final String? description;
  final String? proofId; // Link to payment proof (for deposits)
  final String? bankReference; // External bank reference
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? processedBy; // Admin who processed
  final String? reversedAt;
  final String? reversedBy; // Admin who reversed
  final String? reversalReason;
  final Map<String, dynamic> metadata;

  CashFlowModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    this.description,
    this.proofId,
    this.bankReference,
    required this.createdAt,
    this.processedAt,
    this.processedBy,
    this.reversedAt,
    this.reversedBy,
    this.reversalReason,
    this.metadata = const {},
  });

  // ==================== COMPUTED PROPERTIES ====================

  bool get isDeposit => type == CashFlowType.deposit;
  bool get isWithdrawal => type == CashFlowType.withdrawal;
  bool get isPending => status == CashFlowStatus.pending;
  bool get isCompleted => status == CashFlowStatus.completed;
  bool get isReversed => status == CashFlowStatus.reversed;
  bool get canBeReversed => isCompleted && !isReversed;

  // ==================== FIRESTORE SERIALIZATION ====================

  factory CashFlowModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CashFlowModel.fromJson(data, doc.id);
  }

  factory CashFlowModel.fromJson(Map<String, dynamic> json, String id) {
    return CashFlowModel(
      id: id,
      userId: json['userId'] ?? '',
      type: CashFlowType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CashFlowType.deposit,
      ),
      status: CashFlowStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CashFlowStatus.pending,
      ),
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      proofId: json['proofId'],
      bankReference: json['bankReference'],
      createdAt: _parseDateTime(json['createdAt']),
      processedAt: json['processedAt'] != null
          ? _parseDateTime(json['processedAt'])
          : null,
      processedBy: json['processedBy'],
      reversedAt: json['reversedAt'],
      reversedBy: json['reversedBy'],
      reversalReason: json['reversalReason'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'description': description,
      'proofId': proofId,
      'bankReference': bankReference,
      'createdAt': Timestamp.fromDate(createdAt),
      'processedAt': processedAt != null
          ? Timestamp.fromDate(processedAt!)
          : null,
      'processedBy': processedBy,
      'reversedAt': reversedAt,
      'reversedBy': reversedBy,
      'reversalReason': reversalReason,
      'metadata': metadata,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  // ==================== COPY WITH ====================

  CashFlowModel copyWith({
    CashFlowStatus? status,
    DateTime? processedAt,
    String? processedBy,
    String? reversedAt,
    String? reversedBy,
    String? reversalReason,
  }) {
    return CashFlowModel(
      id: id,
      userId: userId,
      type: type,
      status: status ?? this.status,
      amount: amount,
      description: description,
      proofId: proofId,
      bankReference: bankReference,
      createdAt: createdAt,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
      reversedAt: reversedAt ?? this.reversedAt,
      reversedBy: reversedBy ?? this.reversedBy,
      reversalReason: reversalReason ?? this.reversalReason,
      metadata: metadata,
    );
  }
}

// ==================== ENUMS ====================

enum CashFlowType { deposit, withdrawal }

enum CashFlowStatus {
  pending, // Awaiting admin approval
  processing, // Being processed
  completed, // Successfully processed
  rejected, // Rejected by admin
  reversed, // Was completed, then reversed
  cancelled, // Cancelled by user
}
