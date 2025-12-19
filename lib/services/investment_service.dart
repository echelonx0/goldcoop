// lib/services/investment_service.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investment_model.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/callback_and_request_models.dart';

class InvestmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== INVESTMENT OPPORTUNITIES ====================

  /// Get all active investments
  Future<List<InvestmentModel>> getActiveInvestments({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('investment_opportunities')
          .where('isActive', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => InvestmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[InvestmentService] Error fetching investments: $e');
      return [];
    }
  }

  /// Stream active investments
  Stream<List<InvestmentModel>> getActiveInvestmentsStream({int limit = 50}) {
    return _firestore
        .collection('investment_opportunities')
        .where('isActive', isEqualTo: true)
        .where('status', isEqualTo: 'active')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InvestmentModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get featured investments
  Future<List<InvestmentModel>> getFeaturedInvestments({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('investment_opportunities')
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => InvestmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[InvestmentService] Error fetching featured investments: $e');
      return [];
    }
  }

  /// Get investment by ID
  Future<InvestmentModel?> getInvestment(String investmentId) async {
    try {
      final doc = await _firestore
          .collection('investment_opportunities')
          .doc(investmentId)
          .get();

      if (!doc.exists) return null;
      return InvestmentModel.fromFirestore(doc);
    } catch (e) {
      log('[InvestmentService] Error fetching investment: $e');
      return null;
    }
  }

  /// Filter investments
  Future<List<InvestmentModel>> filterInvestments(
    InvestmentFilter filter,
  ) async {
    try {
      Query query = _firestore.collection('investment_opportunities');

      if (filter.categories != null && filter.categories!.isNotEmpty) {
        query = query.where('category', whereIn: filter.categories);
      }
      if (filter.status != null) {
        query = query.where('status', isEqualTo: filter.status!.name);
      }
      if (filter.minReturn != null) {
        query = query.where(
          'expectedReturn',
          isGreaterThanOrEqualTo: filter.minReturn,
        );
      }
      if (filter.maxReturn != null) {
        query = query.where(
          'expectedReturn',
          isLessThanOrEqualTo: filter.maxReturn,
        );
      }
      if (filter.maxRiskLevel != null) {
        query = query.where(
          'riskLevel',
          isLessThanOrEqualTo: filter.maxRiskLevel,
        );
      }
      if (filter.onlyFeatured ?? false) {
        query = query.where('isFeatured', isEqualTo: true);
      }
      if (filter.onlyActive ?? true) {
        query = query.where('isActive', isEqualTo: true);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InvestmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[InvestmentService] Error filtering investments: $e');
      return [];
    }
  }

  // ==================== USER INVESTMENTS ====================

  /// Get user's investments
  Future<List<UserInvestmentModel>> getUserInvestments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_investments')
          .where('userId', isEqualTo: userId)
          .orderBy('investmentDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserInvestmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[InvestmentService] Error fetching user investments: $e');
      return [];
    }
  }

  /// Stream user's investments
  Stream<List<UserInvestmentModel>> getUserInvestmentsStream(String userId) {
    return _firestore
        .collection('user_investments')
        .where('userId', isEqualTo: userId)
        .orderBy('investmentDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserInvestmentModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Create user investment
  Future<String?> createUserInvestment(UserInvestmentModel investment) async {
    try {
      final docRef = await _firestore
          .collection('user_investments')
          .add(investment.toJson());
      return docRef.id;
    } catch (e) {
      log('[InvestmentService] Error creating user investment: $e');
      return null;
    }
  }

  // ==================== INVESTMENT REQUESTS ====================

  /// Create investment request
  Future<String?> createInvestmentRequest(
    InvestmentRequestModel request,
  ) async {
    try {
      final docRef = await _firestore
          .collection('investment_requests')
          .add(request.toJson());
      return docRef.id;
    } catch (e) {
      log('[InvestmentService] Error creating investment request: $e');
      return null;
    }
  }

  /// Get user's investment requests
  Future<List<InvestmentRequestModel>> getUserInvestmentRequests(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('investment_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InvestmentRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[InvestmentService] Error fetching investment requests: $e');
      return [];
    }
  }

  /// Update investment request
  Future<bool> updateInvestmentRequest({
    required String requestId,
    required InvestmentRequestStatus status,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? rejectionReason,
    String? transactionId,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (approvedAt != null) {
        updates['approvedAt'] = Timestamp.fromDate(approvedAt);
      }
      if (rejectedAt != null) {
        updates['rejectedAt'] = Timestamp.fromDate(rejectedAt);
      }
      if (rejectionReason != null) updates['rejectionReason'] = rejectionReason;
      if (transactionId != null) updates['transactionId'] = transactionId;

      await _firestore
          .collection('investment_requests')
          .doc(requestId)
          .update(updates);
      return true;
    } catch (e) {
      log('[InvestmentService] Error updating investment request: $e');
      return false;
    }
  }

  // ==================== CALLBACK REQUESTS ====================

  /// Create callback request
  Future<String?> createCallbackRequest(CallbackRequestModel request) async {
    try {
      final docRef = await _firestore
          .collection('callback_requests')
          .add(request.toJson());
      return docRef.id;
    } catch (e) {
      log('[InvestmentService] Error creating callback request: $e');
      return null;
    }
  }

  /// Get user's callback requests
  Future<List<CallbackRequestModel>> getUserCallbackRequests(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('callback_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CallbackRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[InvestmentService] Error fetching callback requests: $e');
      return [];
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Create investment + update balance + record transaction (atomic)
  Future<bool> investWithBalance({
    required String userId,
    required String investmentId,
    required String investmentName,
    required double amount,
    required UserModel user,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Create user investment
        final userInvestmentRef = _firestore
            .collection('user_investments')
            .doc();
        final userInvestment = UserInvestmentModel(
          investmentUserId: userInvestmentRef.id,
          userId: userId,
          investmentId: investmentId,
          investmentName: investmentName,
          amountInvested: amount,
          investmentDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        transaction.set(userInvestmentRef, userInvestment.toJson());

        // Update user balance
        final userRef = _firestore.collection('clients').doc(userId);
        transaction.update(userRef, {
          'financialProfile.accountBalance':
              user.financialProfile.accountBalance - amount,
          'financialProfile.totalInvested':
              user.financialProfile.totalInvested + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create transaction record
        final transactionRef = _firestore.collection('transactions').doc();
        final transactionRecord = TransactionModel(
          transactionId: transactionRef.id,
          userId: userId,
          transactionType: TransactionType.investment,
          status: TransactionStatus.completed,
          amount: amount,
          description: 'Investment in $investmentName',
          investmentId: investmentId,
          investmentName: investmentName,
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          netAmount: amount,
        );
        transaction.set(transactionRef, transactionRecord.toJson());
      });

      return true;
    } catch (e) {
      log('[InvestmentService] Error in investment transaction: $e');
      return false;
    }
  }
}
