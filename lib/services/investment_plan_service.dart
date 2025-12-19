// lib/services/investment_plan_service.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investment_plan_model.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/callback_and_request_models.dart';

class InvestmentPlanService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== INVESTMENT PLANS ====================

  /// Get all active plans
  Future<List<InvestmentPlanModel>> getActivePlans() async {
    try {
      final snapshot = await _firestore
          .collection('investment_plans')
          .where('isActive', isEqualTo: true)
          .orderBy('isFeatured', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InvestmentPlanModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[InvestmentPlanService] Error fetching plans: $e');
      return [];
    }
  }

  /// Stream active plans (real-time)
  Stream<List<InvestmentPlanModel>> getActivePlansStream() {
    return _firestore
        .collection('investment_plans')
        .where('isActive', isEqualTo: true)
        .orderBy('isFeatured', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InvestmentPlanModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((error) {
          log('[InvestmentPlanService] Stream error: $error');
          return <InvestmentPlanModel>[];
        });
  }

  /// Get featured plans only
  Future<List<InvestmentPlanModel>> getFeaturedPlans({int limit = 3}) async {
    try {
      final snapshot = await _firestore
          .collection('investment_plans')
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => InvestmentPlanModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[InvestmentPlanService] Error fetching featured plans: $e');
      return [];
    }
  }

  /// Get plan by ID
  Future<InvestmentPlanModel?> getPlan(String planId) async {
    try {
      final doc = await _firestore
          .collection('investment_plans')
          .doc(planId)
          .get();

      if (!doc.exists) return null;
      return InvestmentPlanModel.fromFirestore(doc);
    } catch (e) {
      log('[InvestmentPlanService] Error fetching plan: $e');
      return null;
    }
  }

  // ==================== USER INVESTMENTS ====================

  /// Get user's active investments
  Future<List<UserPlanInvestmentModel>> getUserInvestments(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('user_plan_investments')
          .where('userId', isEqualTo: userId)
          .orderBy('investmentDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserPlanInvestmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[InvestmentPlanService] Error fetching user investments: $e');
      return [];
    }
  }

  /// Stream user's investments (real-time)
  Stream<List<UserPlanInvestmentModel>> getUserInvestmentsStream(
    String userId,
  ) {
    return _firestore
        .collection('user_plan_investments')
        .where('userId', isEqualTo: userId)
        .orderBy('investmentDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserPlanInvestmentModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((error) {
          log('[InvestmentPlanService] User investments stream error: $error');
          return <UserPlanInvestmentModel>[];
        });
  }

  /// Create user investment (basic, without balance update)
  Future<String?> createUserInvestment(
    UserPlanInvestmentModel investment,
  ) async {
    try {
      final docRef = await _firestore
          .collection('user_plan_investments')
          .add(investment.toJson());
      return docRef.id;
    } catch (e) {
      log('[InvestmentPlanService] Error creating user investment: $e');
      return null;
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
      log('[InvestmentPlanService] Error creating callback request: $e');
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
      log('[InvestmentPlanService] Error fetching callback requests: $e');
      return [];
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
      log('[InvestmentPlanService] Error creating investment request: $e');
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
      log('[InvestmentPlanService] Error fetching investment requests: $e');
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
      log('[InvestmentPlanService] Error updating investment request: $e');
      return false;
    }
  }

  // ==================== ATOMIC INVESTMENT OPERATIONS ====================

  /// Invest in plan + update balance + record transaction (atomic)
  /// Returns the investment ID if successful, null if failed
  Future<String?> investWithBalance({
    required String userId,
    required String planId,
    required String planName,
    required double amount,
    required UserModel user,
  }) async {
    try {
      // Validate minimum investment
      final plan = await getPlan(planId);
      if (plan == null) {
        log('[InvestmentPlanService] Plan not found: $planId');
        return null;
      }

      if (amount < plan.minimumInvestment) {
        log(
          '[InvestmentPlanService] Amount below minimum: $amount < ${plan.minimumInvestment}',
        );
        return null;
      }

      if (user.financialProfile.accountBalance < amount) {
        log('[InvestmentPlanService] Insufficient balance');
        return null;
      }

      String? investmentId;

      await _firestore.runTransaction((transaction) async {
        // Create user investment
        final userInvestmentRef = _firestore
            .collection('user_plan_investments')
            .doc();

        final maturityDate = DateTime.now().add(
          Duration(days: plan.durationMonths * 30),
        );

        final userInvestment = UserPlanInvestmentModel(
          investmentId: userInvestmentRef.id,
          userId: userId,
          planId: planId,
          planName: planName,
          amountInvested: amount,
          investmentDate: DateTime.now(),
          maturityDate: maturityDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        transaction.set(userInvestmentRef, userInvestment.toJson());
        investmentId = userInvestmentRef.id;

        // Update user balance
        final userRef = _firestore.collection('clients').doc(userId);
        transaction.update(userRef, {
          'financialProfile.accountBalance':
              user.financialProfile.accountBalance - amount,
          'financialProfile.totalInvested':
              (user.financialProfile.totalInvested) + amount,
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
          description: 'Investment in $planName',
          investmentId: planId,
          investmentName: planName,
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          netAmount: amount,
        );

        transaction.set(transactionRef, transactionRecord.toJson());
      });

      return investmentId;
    } catch (e) {
      log('[InvestmentPlanService] Error in investment transaction: $e');
      return null;
    }
  }

  /// Investment request workflow (creates request, not immediate debit)
  Future<String?> requestInvestment({
    required String userId,
    required String planId,
    required String planName,
    required double amount,
    UserModel? user,
  }) async {
    try {
      final plan = await getPlan(planId);
      if (plan == null) return null;

      if (amount < plan.minimumInvestment) return null;

      final availableBalance = user?.financialProfile.accountBalance ?? 0;
      final balanceUsed = amount <= availableBalance
          ? amount
          : availableBalance;
      final additionalNeeded = amount > availableBalance
          ? amount - availableBalance
          : 0.0;

      final request = InvestmentRequestModel(
        requestId: '', // Will be set by Firestore
        userId: userId,
        investmentId: planId,
        investmentName: planName,
        requestedAmount: amount,
        requestType: additionalNeeded > 0
            ? InvestmentRequestType.partial_balance
            : InvestmentRequestType.balance_only,
        status: InvestmentRequestStatus.pending,
        availableBalance: availableBalance,
        balanceUsed: balanceUsed,
        additionalFundingNeeded: additionalNeeded,
        paymentMethod: 'balance',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('investment_requests')
          .add(request.toJson());
      return docRef.id;
    } catch (e) {
      log('[InvestmentPlanService] Error creating investment request: $e');
      return null;
    }
  }

  /// Process approved investment request (creates investment + updates balance)
  Future<bool> processApprovedRequest({
    required String requestId,
    required String userId,
    required String planId,
    required String planName,
    required double amount,
    required UserModel user,
  }) async {
    try {
      final investmentId = await investWithBalance(
        userId: userId,
        planId: planId,
        planName: planName,
        amount: amount,
        user: user,
      );

      if (investmentId == null) {
        // Reject if investment failed
        await updateInvestmentRequest(
          requestId: requestId,
          status: InvestmentRequestStatus.rejected,
          rejectedAt: DateTime.now(),
          rejectionReason: 'Investment processing failed',
        );
        return false;
      }

      // Update request to approved
      await updateInvestmentRequest(
        requestId: requestId,
        status: InvestmentRequestStatus.approved,
        approvedAt: DateTime.now(),
        transactionId: investmentId,
      );

      return true;
    } catch (e) {
      log('[InvestmentPlanService] Error processing approved request: $e');
      return false;
    }
  }

  /// Get user's total invested across all plans
  Future<double> getUserTotalInvested(String userId) async {
    try {
      final investments = await getUserInvestments(userId);
      return investments.fold<double>(
        0.0,
        (sum, inv) => sum + inv.amountInvested,
      );
    } catch (e) {
      log('[InvestmentPlanService] Error calculating total invested: $e');
      return 0.0;
    }
  }

  /// Get user's total expected returns
  Future<double> getUserTotalExpectedReturns(String userId) async {
    try {
      final investments = await getUserInvestments(userId);
      double totalReturns = 0.0;

      for (final inv in investments) {
        final plan = await getPlan(inv.planId);
        if (plan != null) {
          final totalMonths = plan.durationMonths;
          totalReturns += plan.calculateExpectedReturn(
            inv.amountInvested,
            totalMonths,
          );
        }
      }

      return totalReturns;
    } catch (e) {
      log('[InvestmentPlanService] Error calculating expected returns: $e');
      return 0.0;
    }
  }
}
