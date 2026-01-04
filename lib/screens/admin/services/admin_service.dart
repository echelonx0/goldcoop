// lib/services/admin_service.dart
// FIXED: Reads from existing transactions collection with proper field detection

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/investment_model.dart';
import '../../../models/investment_plan_model.dart';
import '../../../models/user_model.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all admin dashboard stats
  /// Reads from existing transactions collection
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      // Parallel fetch for performance
      final results = await Future.wait([
        _firestore.collection('clients').get(),
        _firestore
            .collection('investment_opportunities')
            .where('isActive', isEqualTo: true)
            .get(),
        _firestore.collection('transactions').get(),
      ]);

      final usersSnapshot = results[0] as QuerySnapshot;
      final investmentsSnapshot = results[1] as QuerySnapshot;
      final transactionsSnapshot = results[2] as QuerySnapshot;

      // Calculate user metrics
      double totalCashBalance = 0;
      int activeUsers = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final fpData = data['financialProfile'] as Map<String, dynamic>?;
        if (fpData != null) {
          final balance = (fpData['accountBalance'] ?? 0).toDouble();
          totalCashBalance += balance;
          if (balance > 0) activeUsers++;
        }
      }

      // Calculate cash flow from transactions
      double totalDeposits = 0;
      double totalWithdrawals = 0;
      int completedTransactionCount = 0;

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Check if transaction is completed (handle both field names)
        final status = _getStatus(data);
        if (status != 'completed') continue;

        // Get transaction type (handle both field names)
        final type = _getType(data);
        if (type == null) continue;

        // Get amount (handle multiple field names)
        final amount = _getAmount(data);

        if (type == 'deposit') {
          totalDeposits += amount;
          completedTransactionCount++;
        } else if (type == 'withdrawal') {
          totalWithdrawals += amount;
          completedTransactionCount++;
        }
      }

      // Debug logging
      log('📊 Stats Debug:');
      log('   Total transactions docs: ${transactionsSnapshot.docs.length}');
      log('   Completed deposit/withdrawal count: $completedTransactionCount');
      log('   Total Deposits: $totalDeposits');
      log('   Total Withdrawals: $totalWithdrawals');
      log('   User Cash Balance Sum: $totalCashBalance');

      return {
        'totalUsers': usersSnapshot.size,
        'activeUsers': activeUsers,
        'totalInvestments': investmentsSnapshot.size,
        'cashBalance': totalCashBalance,
        'totalDeposits': totalDeposits,
        'totalWithdrawals': totalWithdrawals,
        'totalTransactions': completedTransactionCount,
        'netCashFlow': totalDeposits - totalWithdrawals,
      };
    } catch (e) {
      log('[AdminService] Error fetching stats: $e');
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'totalInvestments': 0,
        'cashBalance': 0.0,
        'totalDeposits': 0.0,
        'totalWithdrawals': 0.0,
        'totalTransactions': 0,
        'netCashFlow': 0.0,
      };
    }
  }

  // ==================== FIELD EXTRACTION HELPERS ====================

  /// Get status from transaction data (handles multiple field names)
  String? _getStatus(Map<String, dynamic> data) {
    // Try all possible status field names
    final possibleFields = ['transactionStatus', 'status'];

    for (final field in possibleFields) {
      if (data.containsKey(field) && data[field] != null) {
        return (data[field] as String).toLowerCase();
      }
    }
    return null;
  }

  /// Get type from transaction data (handles multiple field names)
  String? _getType(Map<String, dynamic> data) {
    // Try all possible type field names
    final possibleFields = ['transactionType', 'type'];

    for (final field in possibleFields) {
      if (data.containsKey(field) && data[field] != null) {
        return (data[field] as String).toLowerCase();
      }
    }
    return null;
  }

  /// Get amount from transaction data (handles multiple field names)
  double _getAmount(Map<String, dynamic> data) {
    // Try all possible amount field names in priority order
    final possibleFields = ['transactionAmount', 'amount', 'netAmount'];

    for (final field in possibleFields) {
      if (data.containsKey(field) && data[field] != null) {
        return (data[field]).toDouble();
      }
    }
    return 0.0;
  }

  /// Debug method - prints actual field structure of transactions
  Future<void> debugTransactionStructure() async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .limit(5)
          .get();

      log('🔍 Transaction Structure Debug:');
      for (var doc in snapshot.docs) {
        final data = doc.data();
        log('--- Doc ID: ${doc.id} ---');
        log('   Keys: ${data.keys.toList()}');
        log('   transactionStatus: ${data['transactionStatus']}');
        log('   status: ${data['status']}');
        log('   transactionType: ${data['transactionType']}');
        log('   type: ${data['type']}');
        log('   transactionAmount: ${data['transactionAmount']}');
        log('   amount: ${data['amount']}');
      }
    } catch (e) {
      log('Debug error: $e');
    }
  }

  // ==================== INVESTMENT PLANS ====================

  Future<DocumentReference> createPlan(InvestmentPlanModel plan) async {
    try {
      final docRef = await _firestore
          .collection('investment_plans')
          .add(plan.toJson());
      log('[AdminService] Plan created: ${plan.planName}');
      return docRef;
    } catch (e) {
      log('[AdminService] Error creating plan: $e');
      rethrow;
    }
  }

  Future<void> updatePlan(String planId, InvestmentPlanModel plan) async {
    try {
      await _firestore
          .collection('investment_plans')
          .doc(planId)
          .update(plan.toJson());
      log('[AdminService] Plan updated: $planId');
    } catch (e) {
      log('[AdminService] Error updating plan: $e');
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _firestore.collection('investment_plans').doc(planId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log('[AdminService] Plan deleted: $planId');
    } catch (e) {
      log('[AdminService] Error deleting plan: $e');
      rethrow;
    }
  }

  Future<List<InvestmentPlanModel>> getAllPlans() async {
    try {
      final snapshot = await _firestore
          .collection('investment_plans')
          .orderBy('isFeatured', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InvestmentPlanModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[AdminService] Error fetching plans: $e');
      return [];
    }
  }

  Stream<List<InvestmentPlanModel>> getAllPlansStream() {
    return _firestore
        .collection('investment_plans')
        .orderBy('isFeatured', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InvestmentPlanModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<InvestmentPlanModel?> getPlan(String planId) async {
    try {
      final doc = await _firestore
          .collection('investment_plans')
          .doc(planId)
          .get();

      if (!doc.exists) {
        log('[AdminService] Plan not found: $planId');
        return null;
      }

      return InvestmentPlanModel.fromFirestore(doc);
    } catch (e) {
      log('[AdminService] Error fetching plan: $e');
      return null;
    }
  }

  // ==================== INVESTMENTS (Legacy) ====================

  Future<String?> createInvestment(InvestmentModel investment) async {
    try {
      final docRef = await _firestore
          .collection('investment_opportunities')
          .add(investment.toJson());
      return docRef.id;
    } catch (e) {
      log('[AdminService] Error creating investment: $e');
      return null;
    }
  }

  Future<bool> updateInvestment(
    String investmentId,
    InvestmentModel investment,
  ) async {
    try {
      await _firestore
          .collection('investment_opportunities')
          .doc(investmentId)
          .update(investment.toJson());
      return true;
    } catch (e) {
      log('[AdminService] Error updating investment: $e');
      return false;
    }
  }

  Future<bool> deleteInvestment(String investmentId) async {
    try {
      await _firestore
          .collection('investment_opportunities')
          .doc(investmentId)
          .delete();
      return true;
    } catch (e) {
      log('[AdminService] Error deleting investment: $e');
      return false;
    }
  }

  Stream<List<InvestmentModel>> getAllInvestmentsStream() {
    return _firestore
        .collection('investment_opportunities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InvestmentModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== USERS ====================

  Future<List<UserModel>> getAllUsers({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('clients')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      log('[AdminService] Error fetching users: $e');
      return [];
    }
  }

  Stream<List<UserModel>> getAllUsersStream({int limit = 100}) {
    return _firestore
        .collection('clients')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  Future<bool> updateUserFinancials({
    required String uid,
    double? accountBalance,
    double? totalInvested,
    double? totalReturns,
    int? tokenBalance,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (accountBalance != null) {
        updates['financialProfile.accountBalance'] = accountBalance;
      }
      if (totalInvested != null) {
        updates['financialProfile.totalInvested'] = totalInvested;
      }
      if (totalReturns != null) {
        updates['financialProfile.totalReturns'] = totalReturns;
      }
      if (tokenBalance != null) {
        updates['financialProfile.tokenBalance'] = tokenBalance;
      }

      await _firestore.collection('clients').doc(uid).update(updates);
      return true;
    } catch (e) {
      log('[AdminService] Error updating user financials: $e');
      return false;
    }
  }

  Future<bool> updateUserStatus({
    required String uid,
    required AccountStatus status,
  }) async {
    try {
      await _firestore.collection('clients').doc(uid).update({
        'accountStatus': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('[AdminService] Error updating user status: $e');
      return false;
    }
  }

  Future<bool> updateUserKYC({
    required String uid,
    required KYCStatus status,
  }) async {
    try {
      await _firestore.collection('clients').doc(uid).update({
        'kycStatus': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('[AdminService] Error updating KYC: $e');
      return false;
    }
  }

  // ==================== SEARCH ====================

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('clients')
          .where('email', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('email', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      log('[AdminService] Error searching users: $e');
      return [];
    }
  }
}
