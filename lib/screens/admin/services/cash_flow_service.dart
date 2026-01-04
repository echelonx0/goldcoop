// lib/services/cash_flow_service.dart
// Unified service for all cash flow operations with SOC2 audit logging

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/audit_model.dart';
import '../models/cash_flow_model.dart';

/// Central service for all deposit/withdrawal operations
/// Every action is:
/// 1. Atomic (transaction-based)
/// 2. Audited (immutable log)
/// 3. Reversible (admin can undo)
class CashFlowService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _cashFlows =>
      _firestore.collection('cash_flows');
  CollectionReference<Map<String, dynamic>> get _auditLogs =>
      _firestore.collection('audit_logs');
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('clients');

  // ==================== CREATE CASH FLOW ====================

  /// Create a pending deposit request
  Future<String?> createDeposit({
    required String userId,
    required double amount,
    String? description,
    String? proofId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = _cashFlows.doc();

      final cashFlow = CashFlowModel(
        id: docRef.id,
        userId: userId,
        type: CashFlowType.deposit,
        status: CashFlowStatus.pending,
        amount: amount,
        description: description ?? 'Deposit',
        proofId: proofId,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      await docRef.set(cashFlow.toJson());
      log('✅ Deposit created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      log('❌ Error creating deposit: $e');
      return null;
    }
  }

  /// Create a pending withdrawal request
  Future<String?> createWithdrawal({
    required String userId,
    required double amount,
    String? description,
    String? bankReference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = _cashFlows.doc();

      final cashFlow = CashFlowModel(
        id: docRef.id,
        userId: userId,
        type: CashFlowType.withdrawal,
        status: CashFlowStatus.pending,
        amount: amount,
        description: description ?? 'Withdrawal',
        bankReference: bankReference,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      await docRef.set(cashFlow.toJson());
      log('✅ Withdrawal created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      log('❌ Error creating withdrawal: $e');
      return null;
    }
  }

  // ==================== ADMIN: APPROVE ====================

  /// Approve a deposit - adds funds to user balance
  Future<bool> approveDeposit({
    required String cashFlowId,
    required String adminId,
    required String adminEmail,
    String? reason,
    String ipAddress = 'unknown',
    String userAgent = 'unknown',
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // 1. Get the cash flow
        final cashFlowDoc = await transaction.get(_cashFlows.doc(cashFlowId));
        if (!cashFlowDoc.exists) throw Exception('Cash flow not found');

        final cashFlow = CashFlowModel.fromFirestore(cashFlowDoc);
        if (cashFlow.type != CashFlowType.deposit) {
          throw Exception('Not a deposit');
        }
        if (cashFlow.status != CashFlowStatus.pending) {
          throw Exception('Deposit is not pending');
        }

        // 2. Get user's current balance
        final userDoc = await transaction.get(_users.doc(cashFlow.userId));
        if (!userDoc.exists) throw Exception('User not found');

        final userData = userDoc.data()!;
        final currentBalance =
            (userData['financialProfile']?['accountBalance'] ?? 0).toDouble();
        final newBalance = currentBalance + cashFlow.amount;

        // 3. Update cash flow status
        transaction.update(_cashFlows.doc(cashFlowId), {
          'status': CashFlowStatus.completed.name,
          'processedAt': FieldValue.serverTimestamp(),
          'processedBy': adminId,
        });

        // 4. Update user balance
        transaction.update(_users.doc(cashFlow.userId), {
          'financialProfile.accountBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 5. Create audit log
        final auditRef = _auditLogs.doc();
        transaction.set(
          auditRef,
          AuditLogModel(
            id: auditRef.id,
            actorId: adminId,
            actorEmail: adminEmail,
            action: AuditAction.deposit_approved,
            targetType: 'cash_flow',
            targetId: cashFlowId,
            targetUserId: cashFlow.userId,
            beforeState: {
              'status': CashFlowStatus.pending.name,
              'userBalance': currentBalance,
            },
            afterState: {
              'status': CashFlowStatus.completed.name,
              'userBalance': newBalance,
              'amount': cashFlow.amount,
            },
            reason: reason,
            ipAddress: ipAddress,
            userAgent: userAgent,
            timestamp: DateTime.now(),
          ).toJson(),
        );

        return true;
      });
    } catch (e) {
      log('❌ Error approving deposit: $e');
      return false;
    }
  }

  /// Approve a withdrawal - deducts funds from user balance
  Future<bool> approveWithdrawal({
    required String cashFlowId,
    required String adminId,
    required String adminEmail,
    String? reason,
    String ipAddress = 'unknown',
    String userAgent = 'unknown',
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // 1. Get the cash flow
        final cashFlowDoc = await transaction.get(_cashFlows.doc(cashFlowId));
        if (!cashFlowDoc.exists) throw Exception('Cash flow not found');

        final cashFlow = CashFlowModel.fromFirestore(cashFlowDoc);
        if (cashFlow.type != CashFlowType.withdrawal) {
          throw Exception('Not a withdrawal');
        }
        if (cashFlow.status != CashFlowStatus.pending) {
          throw Exception('Withdrawal is not pending');
        }

        // 2. Get user's current balance
        final userDoc = await transaction.get(_users.doc(cashFlow.userId));
        if (!userDoc.exists) throw Exception('User not found');

        final userData = userDoc.data()!;
        final currentBalance =
            (userData['financialProfile']?['accountBalance'] ?? 0).toDouble();

        // 3. Verify sufficient funds
        if (currentBalance < cashFlow.amount) {
          throw Exception('Insufficient funds');
        }

        final newBalance = currentBalance - cashFlow.amount;

        // 4. Update cash flow status
        transaction.update(_cashFlows.doc(cashFlowId), {
          'status': CashFlowStatus.completed.name,
          'processedAt': FieldValue.serverTimestamp(),
          'processedBy': adminId,
        });

        // 5. Update user balance
        transaction.update(_users.doc(cashFlow.userId), {
          'financialProfile.accountBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 6. Create audit log
        final auditRef = _auditLogs.doc();
        transaction.set(
          auditRef,
          AuditLogModel(
            id: auditRef.id,
            actorId: adminId,
            actorEmail: adminEmail,
            action: AuditAction.withdrawal_approved,
            targetType: 'cash_flow',
            targetId: cashFlowId,
            targetUserId: cashFlow.userId,
            beforeState: {
              'status': CashFlowStatus.pending.name,
              'userBalance': currentBalance,
            },
            afterState: {
              'status': CashFlowStatus.completed.name,
              'userBalance': newBalance,
              'amount': cashFlow.amount,
            },
            reason: reason,
            ipAddress: ipAddress,
            userAgent: userAgent,
            timestamp: DateTime.now(),
          ).toJson(),
        );

        return true;
      });
    } catch (e) {
      log('❌ Error approving withdrawal: $e');
      return false;
    }
  }

  // ==================== ADMIN: REJECT ====================

  /// Reject a pending deposit or withdrawal
  Future<bool> reject({
    required String cashFlowId,
    required String adminId,
    required String adminEmail,
    required String reason,
    String ipAddress = 'unknown',
    String userAgent = 'unknown',
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final cashFlowDoc = await transaction.get(_cashFlows.doc(cashFlowId));
        if (!cashFlowDoc.exists) throw Exception('Cash flow not found');

        final cashFlow = CashFlowModel.fromFirestore(cashFlowDoc);
        if (cashFlow.status != CashFlowStatus.pending) {
          throw Exception('Cash flow is not pending');
        }

        // Update status
        transaction.update(_cashFlows.doc(cashFlowId), {
          'status': CashFlowStatus.rejected.name,
          'processedAt': FieldValue.serverTimestamp(),
          'processedBy': adminId,
          'metadata.rejectionReason': reason,
        });

        // Audit log
        final auditAction = cashFlow.isDeposit
            ? AuditAction.deposit_rejected
            : AuditAction.withdrawal_rejected;

        final auditRef = _auditLogs.doc();
        transaction.set(
          auditRef,
          AuditLogModel(
            id: auditRef.id,
            actorId: adminId,
            actorEmail: adminEmail,
            action: auditAction,
            targetType: 'cash_flow',
            targetId: cashFlowId,
            targetUserId: cashFlow.userId,
            beforeState: {
              'status': CashFlowStatus.pending.name,
              'amount': cashFlow.amount,
            },
            afterState: {'status': CashFlowStatus.rejected.name},
            reason: reason,
            ipAddress: ipAddress,
            userAgent: userAgent,
            timestamp: DateTime.now(),
          ).toJson(),
        );

        return true;
      });
    } catch (e) {
      log('❌ Error rejecting cash flow: $e');
      return false;
    }
  }

  // ==================== ADMIN: REVERSE ====================

  /// Reverse a completed deposit - removes funds from user
  Future<bool> reverseDeposit({
    required String cashFlowId,
    required String adminId,
    required String adminEmail,
    required String reason,
    String ipAddress = 'unknown',
    String userAgent = 'unknown',
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final cashFlowDoc = await transaction.get(_cashFlows.doc(cashFlowId));
        if (!cashFlowDoc.exists) throw Exception('Cash flow not found');

        final cashFlow = CashFlowModel.fromFirestore(cashFlowDoc);
        if (cashFlow.type != CashFlowType.deposit) {
          throw Exception('Not a deposit');
        }
        if (cashFlow.status != CashFlowStatus.completed) {
          throw Exception('Deposit is not completed');
        }

        // Get user balance
        final userDoc = await transaction.get(_users.doc(cashFlow.userId));
        if (!userDoc.exists) throw Exception('User not found');

        final userData = userDoc.data()!;
        final currentBalance =
            (userData['financialProfile']?['accountBalance'] ?? 0).toDouble();
        final newBalance = currentBalance - cashFlow.amount;

        // Update cash flow
        transaction.update(_cashFlows.doc(cashFlowId), {
          'status': CashFlowStatus.reversed.name,
          'reversedAt': FieldValue.serverTimestamp(),
          'reversedBy': adminId,
          'reversalReason': reason,
        });

        // Update user balance (can go negative - admin responsibility)
        transaction.update(_users.doc(cashFlow.userId), {
          'financialProfile.accountBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Audit log
        final auditRef = _auditLogs.doc();
        transaction.set(
          auditRef,
          AuditLogModel(
            id: auditRef.id,
            actorId: adminId,
            actorEmail: adminEmail,
            action: AuditAction.deposit_reversed,
            targetType: 'cash_flow',
            targetId: cashFlowId,
            targetUserId: cashFlow.userId,
            beforeState: {
              'status': CashFlowStatus.completed.name,
              'userBalance': currentBalance,
              'amount': cashFlow.amount,
            },
            afterState: {
              'status': CashFlowStatus.reversed.name,
              'userBalance': newBalance,
            },
            reason: reason,
            ipAddress: ipAddress,
            userAgent: userAgent,
            timestamp: DateTime.now(),
          ).toJson(),
        );

        return true;
      });
    } catch (e) {
      log('❌ Error reversing deposit: $e');
      return false;
    }
  }

  /// Reverse a completed withdrawal - restores funds to user
  Future<bool> reverseWithdrawal({
    required String cashFlowId,
    required String adminId,
    required String adminEmail,
    required String reason,
    String ipAddress = 'unknown',
    String userAgent = 'unknown',
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final cashFlowDoc = await transaction.get(_cashFlows.doc(cashFlowId));
        if (!cashFlowDoc.exists) throw Exception('Cash flow not found');

        final cashFlow = CashFlowModel.fromFirestore(cashFlowDoc);
        if (cashFlow.type != CashFlowType.withdrawal) {
          throw Exception('Not a withdrawal');
        }
        if (cashFlow.status != CashFlowStatus.completed) {
          throw Exception('Withdrawal is not completed');
        }

        // Get user balance
        final userDoc = await transaction.get(_users.doc(cashFlow.userId));
        if (!userDoc.exists) throw Exception('User not found');

        final userData = userDoc.data()!;
        final currentBalance =
            (userData['financialProfile']?['accountBalance'] ?? 0).toDouble();
        final newBalance = currentBalance + cashFlow.amount; // Restore funds

        // Update cash flow
        transaction.update(_cashFlows.doc(cashFlowId), {
          'status': CashFlowStatus.reversed.name,
          'reversedAt': FieldValue.serverTimestamp(),
          'reversedBy': adminId,
          'reversalReason': reason,
        });

        // Update user balance
        transaction.update(_users.doc(cashFlow.userId), {
          'financialProfile.accountBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Audit log
        final auditRef = _auditLogs.doc();
        transaction.set(
          auditRef,
          AuditLogModel(
            id: auditRef.id,
            actorId: adminId,
            actorEmail: adminEmail,
            action: AuditAction.withdrawal_reversed,
            targetType: 'cash_flow',
            targetId: cashFlowId,
            targetUserId: cashFlow.userId,
            beforeState: {
              'status': CashFlowStatus.completed.name,
              'userBalance': currentBalance,
              'amount': cashFlow.amount,
            },
            afterState: {
              'status': CashFlowStatus.reversed.name,
              'userBalance': newBalance,
            },
            reason: reason,
            ipAddress: ipAddress,
            userAgent: userAgent,
            timestamp: DateTime.now(),
          ).toJson(),
        );

        return true;
      });
    } catch (e) {
      log('❌ Error reversing withdrawal: $e');
      return false;
    }
  }

  // ==================== QUERIES ====================

  /// Get platform cash flow stats
  Future<CashFlowStats> getStats() async {
    try {
      final snapshot = await _cashFlows
          .where('status', isEqualTo: CashFlowStatus.completed.name)
          .get();

      double totalDeposits = 0;
      double totalWithdrawals = 0;
      int depositCount = 0;
      int withdrawalCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final type = data['type'] as String?;

        if (type == CashFlowType.deposit.name) {
          totalDeposits += amount;
          depositCount++;
        } else if (type == CashFlowType.withdrawal.name) {
          totalWithdrawals += amount;
          withdrawalCount++;
        }
      }

      return CashFlowStats(
        totalDeposits: totalDeposits,
        totalWithdrawals: totalWithdrawals,
        depositCount: depositCount,
        withdrawalCount: withdrawalCount,
        netCashFlow: totalDeposits - totalWithdrawals,
      );
    } catch (e) {
      log('❌ Error getting cash flow stats: $e');
      return CashFlowStats.empty();
    }
  }

  /// Get pending count for admin badge
  Future<int> getPendingCount() async {
    try {
      final snapshot = await _cashFlows
          .where('status', isEqualTo: CashFlowStatus.pending.name)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Stream all cash flows (for admin list)
  Stream<List<CashFlowModel>> streamAll({
    CashFlowType? type,
    CashFlowStatus? status,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _cashFlows.orderBy(
      'createdAt',
      descending: true,
    );

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CashFlowModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Stream pending cash flows
  Stream<List<CashFlowModel>> streamPending({int limit = 50}) {
    return _cashFlows
        .where('status', isEqualTo: CashFlowStatus.pending.name)
        .orderBy('createdAt', descending: false) // Oldest first
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CashFlowModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Stream completed cash flows (for history)
  Stream<List<CashFlowModel>> streamCompleted({
    CashFlowType? type,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _cashFlows
        .where('status', isEqualTo: CashFlowStatus.completed.name)
        .orderBy('processedAt', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    return query
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CashFlowModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get user's cash flows
  Stream<List<CashFlowModel>> streamUserCashFlows(
    String userId, {
    int limit = 20,
  }) {
    return _cashFlows
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CashFlowModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== AUDIT LOG QUERIES ====================

  /// Stream audit logs (for compliance)
  Stream<List<AuditLogModel>> streamAuditLogs({
    String? actorId,
    String? targetUserId,
    int limit = 100,
  }) {
    Query<Map<String, dynamic>> query = _auditLogs.orderBy(
      'timestamp',
      descending: true,
    );

    if (actorId != null) {
      query = query.where('actorId', isEqualTo: actorId);
    }
    if (targetUserId != null) {
      query = query.where('targetUserId', isEqualTo: targetUserId);
    }

    return query
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuditLogModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get audit logs for a specific cash flow
  Future<List<AuditLogModel>> getAuditLogsForCashFlow(String cashFlowId) async {
    try {
      final snapshot = await _auditLogs
          .where('targetId', isEqualTo: cashFlowId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AuditLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('❌ Error getting audit logs: $e');
      return [];
    }
  }
}

// ==================== STATS MODEL ====================

class CashFlowStats {
  final double totalDeposits;
  final double totalWithdrawals;
  final int depositCount;
  final int withdrawalCount;
  final double netCashFlow;

  CashFlowStats({
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.depositCount,
    required this.withdrawalCount,
    required this.netCashFlow,
  });

  factory CashFlowStats.empty() {
    return CashFlowStats(
      totalDeposits: 0,
      totalWithdrawals: 0,
      depositCount: 0,
      withdrawalCount: 0,
      netCashFlow: 0,
    );
  }

  int get totalCount => depositCount + withdrawalCount;
}
