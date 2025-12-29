// lib/services/admin_service.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investment_model.dart';
import '../models/investment_plan_model.dart';
import '../models/user_model.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== STATS ====================

  // Future<Map<String, dynamic>> getAdminStats() async {
  //   try {
  //     final usersSnapshot = await _firestore.collection('clients').get();
  //     final investmentsSnapshot = await _firestore
  //         .collection('investment_opportunities')
  //         .where('isActive', isEqualTo: true)
  //         .get();
  //     final transactionsSnapshot = await _firestore
  //         .collection('transactions')
  //         .where('status', isEqualTo: 'completed')
  //         .get();

  //     double totalInvested = 0;
  //     double totalBalance = 0;
  //     int activeInvestors = 0;

  //     for (var doc in usersSnapshot.docs) {
  //       final data = doc.data();
  //       final fpData = data['financialProfile'] as Map<String, dynamic>?;
  //       if (fpData != null) {
  //         totalInvested += (fpData['totalInvested'] ?? 0).toDouble();
  //         totalBalance += (fpData['accountBalance'] ?? 0).toDouble();
  //         if ((fpData['totalInvested'] ?? 0) > 0) activeInvestors++;
  //       }
  //     }

  //     double totalTransactionVolume = 0;
  //     for (var doc in transactionsSnapshot.docs) {
  //       totalTransactionVolume += (doc.data()['amount'] ?? 0).toDouble();
  //     }

  //     return {
  //       'totalUsers': usersSnapshot.size,
  //       'activeInvestors': activeInvestors,
  //       'totalInvestments': investmentsSnapshot.size,
  //       'totalInvested': totalInvested,
  //       'totalBalance': totalBalance,
  //       'totalTransactions': transactionsSnapshot.size,
  //       'transactionVolume': totalTransactionVolume,
  //     };
  //   } catch (e) {
  //     log('[AdminService] Error fetching stats: $e');
  //     return {};
  //   }
  // }
  // lib/services/admin_service.dart (ADD THIS METHOD)

  // Add to existing AdminService class:

  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final usersSnapshot = await _firestore.collection('clients').get();
      final investmentsSnapshot = await _firestore
          .collection('investment_opportunities')
          .where('isActive', isEqualTo: true)
          .get();
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where(
            'transactionStatus',
            isEqualTo: 'completed',
          ) // ← FIX: Use transactionStatus
          .get();

      double totalInvested = 0;
      double totalBalance = 0;
      double totalReturns = 0;
      int activeInvestors = 0;

      // Calculate user-level totals
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final fpData = data['financialProfile'] as Map<String, dynamic>?;
        if (fpData != null) {
          totalInvested += (fpData['totalInvested'] ?? 0).toDouble();
          totalBalance += (fpData['accountBalance'] ?? 0).toDouble();
          totalReturns += (fpData['totalReturns'] ?? 0).toDouble();
          if ((fpData['totalInvested'] ?? 0) > 0) activeInvestors++;
        }
      }

      // Calculate transaction volume
      double totalTransactionVolume = 0;
      for (var doc in transactionsSnapshot.docs) {
        totalTransactionVolume += (doc.data()['amount'] ?? 0).toDouble();
      }

      // ✅ PLATFORM BALANCE = accountBalance + invested + returns
      final platformBalance = totalBalance + totalInvested + totalReturns;

      return {
        'totalUsers': usersSnapshot.size,
        'activeInvestors': activeInvestors,
        'totalInvestments': investmentsSnapshot.size,
        'totalInvested': totalInvested,
        'accountBalance': totalBalance, // ← Breakdown #1
        'totalReturns': totalReturns, // ← Breakdown #2
        'platformBalance': platformBalance, // ← Total
        'totalTransactions': transactionsSnapshot.size,
        'transactionVolume': totalTransactionVolume,
      };
    } catch (e) {
      log('[AdminService] Error fetching stats: $e');
      return {};
    }
  }
  // ==================== INVESTMENT PLANS ====================

  /// Create a new investment plan
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

  /// Update an existing investment plan
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

  /// Delete an investment plan (soft delete by setting isActive to false)
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

  /// Get all plans (active and inactive)
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

  /// Stream all plans in real-time
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

  /// Get a specific plan by ID
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
