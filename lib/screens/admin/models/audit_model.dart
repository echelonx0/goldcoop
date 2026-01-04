// lib/models/audit_log_model.dart
// SOC2-compliant immutable audit log for all admin actions

// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable audit log entry - NEVER deleted or modified
/// Stored in 'audit_logs' collection
///
/// SOC2 Compliance:
/// - Immutable: No updates or deletes allowed
/// - Complete: Captures who, what, when, where, why
/// - Tamper-evident: Includes hash of previous entry (optional)
/// - Timestamped: Server timestamp, not client
class AuditLogModel {
  final String id;
  final String actorId; // Who performed the action (admin UID)
  final String actorEmail; // Actor's email for readability
  final AuditAction action; // What action was performed
  final String targetType; // Type of target (user, cash_flow, etc.)
  final String targetId; // ID of the affected entity
  final String? targetUserId; // If action affects a user, their ID
  final Map<String, dynamic> beforeState; // State before action
  final Map<String, dynamic> afterState; // State after action
  final String? reason; // Why the action was performed
  final String ipAddress; // Where: IP address of actor
  final String userAgent; // Device/browser info
  final DateTime timestamp; // When (server timestamp)
  final Map<String, dynamic> metadata;

  AuditLogModel({
    required this.id,
    required this.actorId,
    required this.actorEmail,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.targetUserId,
    required this.beforeState,
    required this.afterState,
    this.reason,
    required this.ipAddress,
    required this.userAgent,
    required this.timestamp,
    this.metadata = const {},
  });

  // ==================== COMPUTED PROPERTIES ====================

  /// Human-readable description of the action
  String get actionDescription {
    switch (action) {
      case AuditAction.deposit_approved:
        return 'Approved deposit of ₦${afterState['amount']}';
      case AuditAction.deposit_rejected:
        return 'Rejected deposit of ₦${beforeState['amount']}';
      case AuditAction.deposit_reversed:
        return 'Reversed deposit of ₦${beforeState['amount']}';
      case AuditAction.withdrawal_approved:
        return 'Approved withdrawal of ₦${afterState['amount']}';
      case AuditAction.withdrawal_rejected:
        return 'Rejected withdrawal of ₦${beforeState['amount']}';
      case AuditAction.withdrawal_reversed:
        return 'Reversed withdrawal of ₦${beforeState['amount']}';
      case AuditAction.user_balance_adjusted:
        return 'Adjusted user balance from ₦${beforeState['balance']} to ₦${afterState['balance']}';
      case AuditAction.user_status_changed:
        return 'Changed user status from ${beforeState['status']} to ${afterState['status']}';
      case AuditAction.user_kyc_updated:
        return 'Updated KYC status to ${afterState['kycStatus']}';
      case AuditAction.admin_login:
        return 'Admin logged in';
      case AuditAction.admin_logout:
        return 'Admin logged out';
      case AuditAction.settings_changed:
        return 'Changed system settings';
      case AuditAction.bulk_action:
        return 'Performed bulk action on ${metadata['count']} items';
    }
  }

  /// Whether this action can be reversed
  bool get isReversible {
    return [
      AuditAction.deposit_approved,
      AuditAction.withdrawal_approved,
      AuditAction.user_balance_adjusted,
    ].contains(action);
  }

  // ==================== FIRESTORE SERIALIZATION ====================

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLogModel.fromJson(data, doc.id);
  }

  factory AuditLogModel.fromJson(Map<String, dynamic> json, String id) {
    return AuditLogModel(
      id: id,
      actorId: json['actorId'] ?? '',
      actorEmail: json['actorEmail'] ?? '',
      action: AuditAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => AuditAction.settings_changed,
      ),
      targetType: json['targetType'] ?? '',
      targetId: json['targetId'] ?? '',
      targetUserId: json['targetUserId'],
      beforeState: Map<String, dynamic>.from(json['beforeState'] ?? {}),
      afterState: Map<String, dynamic>.from(json['afterState'] ?? {}),
      reason: json['reason'],
      ipAddress: json['ipAddress'] ?? 'unknown',
      userAgent: json['userAgent'] ?? 'unknown',
      timestamp: _parseDateTime(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actorId': actorId,
      'actorEmail': actorEmail,
      'action': action.name,
      'targetType': targetType,
      'targetId': targetId,
      'targetUserId': targetUserId,
      'beforeState': beforeState,
      'afterState': afterState,
      'reason': reason,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'timestamp': FieldValue.serverTimestamp(), // Always use server timestamp
      'metadata': metadata,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

// ==================== AUDIT ACTIONS ====================

enum AuditAction {
  // Cash flow actions
  deposit_approved,
  deposit_rejected,
  deposit_reversed,
  withdrawal_approved,
  withdrawal_rejected,
  withdrawal_reversed,

  // User management
  user_balance_adjusted,
  user_status_changed,
  user_kyc_updated,

  // Admin actions
  admin_login,
  admin_logout,

  // System
  settings_changed,
  bulk_action,
}

// ==================== AUDIT LOG FILTER ====================

class AuditLogFilter {
  final String? actorId;
  final String? targetUserId;
  final AuditAction? action;
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;

  AuditLogFilter({
    this.actorId,
    this.targetUserId,
    this.action,
    this.startDate,
    this.endDate,
    this.limit = 50,
  });
}
