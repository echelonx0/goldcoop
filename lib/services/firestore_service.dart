// lib/services/firestore_service.dart
// Firestore data access layer with caching and error handling

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goals_model.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/investment_model.dart';
import '../models/callback_and_request_models.dart';
import '../screens/dashboard/modals/learning_interest_modal.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== LEARNING INTERESTS ====================

  /// Save user's learning interests (for Learning Center waitlist)
  Future<String?> saveLearningInterest(LearningInterestModel interest) async {
    try {
      final docRef = _firestore.collection('learning_interests').doc();

      await docRef.set({
        'interestId': docRef.id,
        'userId': interest.userId,
        'selectedTopics': interest.selectedTopics,
        'customTopic': interest.customTopic,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      log('Error saving learning interest: $e');
      return null;
    }
  }

  /// Check if user has already submitted interests
  Future<bool> hasSubmittedLearningInterest(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('learning_interests')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      log('Error checking learning interest: $e');
      return false;
    }
  }

  /// Get user's learning interests
  Future<LearningInterestModel?> getUserLearningInterest(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('learning_interests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return LearningInterestModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      log('Error fetching learning interest: $e');
      return null;
    }
  }

  /// Update existing learning interest (if user wants to modify)
  Future<bool> updateLearningInterest({
    required String interestId,
    List<String>? selectedTopics,
    String? customTopic,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (selectedTopics != null) updates['selectedTopics'] = selectedTopics;
      if (customTopic != null) updates['customTopic'] = customTopic;

      await _firestore
          .collection('learning_interests')
          .doc(interestId)
          .update(updates);

      return true;
    } catch (e) {
      log('Error updating learning interest: $e');
      return false;
    }
  }

  // ==================== ADMIN: ANALYTICS HELPERS ====================

  /// Get all learning interests (for admin analysis)
  Future<List<LearningInterestModel>> getAllLearningInterests({
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('learning_interests')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LearningInterestModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('Error fetching all learning interests: $e');
      return [];
    }
  }

  /// Get topic popularity counts (for admin analysis)
  Future<Map<String, int>> getLearningTopicCounts() async {
    try {
      final snapshot = await _firestore.collection('learning_interests').get();

      final counts = <String, int>{};

      for (final doc in snapshot.docs) {
        final topics = List<String>.from(doc.data()['selectedTopics'] ?? []);
        for (final topic in topics) {
          counts[topic] = (counts[topic] ?? 0) + 1;
        }
      }

      return counts;
    } catch (e) {
      log('Error fetching topic counts: $e');
      return {};
    }
  }

  /// Get custom topic suggestions (for admin analysis)
  Future<List<String>> getCustomTopicSuggestions() async {
    try {
      final snapshot = await _firestore
          .collection('learning_interests')
          .where('customTopic', isNull: false)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['customTopic'] as String?)
          .whereType<String>()
          .where((topic) => topic.isNotEmpty)
          .toList();
    } catch (e) {
      log('Error fetching custom topics: $e');
      return [];
    }
  }

  // ==================== clients COLLECTION ====================

  /// Get user by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('clients').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      log('Error fetching user: $e');
      return null;
    }
  }

  /// Stream user data (real-time updates)
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('clients').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      try {
        return UserModel.fromFirestore(doc);
      } catch (e) {
        // print('[getUserStream] Parse error: $e');
        // print('[getUserStream] Data: ${doc.data()}');
        return null; // Return null instead of crashing
      }
    });
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    String? profilePic,
    String? address,
    String? country,
    String? dateOfBirth,
  }) async {
    try {
      await _firestore.collection('clients').doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'displayName': '$firstName $lastName',
        if (profilePic != null) 'profilePic': profilePic,
        if (address != null) 'address': address,
        if (country != null) 'country': country,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('Error updating user profile: $e');
      return false;
    }
  }

  /// Update KYC status
  Future<bool> updateKYCStatus({
    required String uid,
    required KYCStatus status,
    String? bvn,
    String? nationalId,
  }) async {
    try {
      await _firestore.collection('clients').doc(uid).update({
        'kycStatus': status.name,
        if (bvn != null) 'bvn': bvn,
        if (nationalId != null) 'nationalId': nationalId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('Error updating KYC status: $e');
      return false;
    }
  }

  // ==================== TRANSACTIONS COLLECTION ====================

  /// Get user's transactions
  Future<List<TransactionModel>> getUserTransactions({
    required String userId,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('transactionDate', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where(
          'transactionDate',
          isGreaterThanOrEqualTo: startDate,
        );
      }
      if (endDate != null) {
        query = query.where('transactionDate', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching transactions: $e');
      return [];
    }
  }

  /// Stream user transactions (real-time)
  Stream<List<TransactionModel>> getUserTransactionsStream({
    required String userId,
    int limit = 20,
  }) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('transactionDate', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Create transaction
  Future<String?> createTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _firestore
          .collection('transactions')
          .add(transaction.toJson());
      return docRef.id;
    } catch (e) {
      log('Error creating transaction: $e');
      return null;
    }
  }

  /// Update transaction status
  Future<bool> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status,
    String? failureReason,
    String? referenceNumber,
  }) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).update({
        'transactionStatus': status.name,
        if (failureReason != null) 'failureReason': failureReason,
        if (referenceNumber != null) 'referenceNumber': referenceNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('Error updating transaction: $e');
      return false;
    }
  }

  // ==================== INVESTMENTS COLLECTION ====================

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
      log('Error fetching investments: $e');
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
      log('Error fetching featured investments: $e');
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
      log('Error fetching investment: $e');
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
      log('Error filtering investments: $e');
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
      log('Error fetching user investments: $e');
      return [];
    }
  }

  /// Create user investment
  Future<String?> createUserInvestment(UserInvestmentModel investment) async {
    try {
      final docRef = await _firestore
          .collection('user_investments')
          .add(investment.toJson());
      return docRef.id;
    } catch (e) {
      log('Error creating user investment: $e');
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
      log('Error creating callback request: $e');
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
      log('Error fetching callback requests: $e');
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
      log('Error creating investment request: $e');
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
      log('Error fetching investment requests: $e');
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
      log('Error updating investment request: $e');
      return false;
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
      log('Error in investment transaction: $e');
      return false;
    }
  }

  // ==================== GOALS ====================

  /// Get user's active goals
  Future<List<GoalModel>> getUserGoals(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('clients')
          .doc(uid)
          .collection('goals')
          .where('status', isNotEqualTo: GoalStatus.cancelled.index)
          .orderBy('status')
          .orderBy('isPriority', descending: true)
          .orderBy('targetDate')
          .get();

      return snapshot.docs
          .map((doc) => GoalModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('Error fetching user goals: $e');
      return [];
    }
  }

  /// Stream user's active goals (real-time)
  Stream<List<GoalModel>> getUserGoalsStream(String uid) {
    return _firestore
        .collection('clients')
        .doc(uid)
        .collection('goals')
        .where('status', isNotEqualTo: GoalStatus.cancelled.index)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GoalModel.fromJson(doc.data()))
              .toList(),
        )
        .handleError((error) {
          log('Goals stream error: $error');
          return <GoalModel>[];
        });
  }

  /// Get priority goals (for home tab)
  Future<List<GoalModel>> getPriorityGoals(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('clients')
          .doc(uid)
          .collection('goals')
          .where('status', isNotEqualTo: GoalStatus.cancelled.index)
          .limit(3)
          .get();

      return snapshot.docs
          .map((doc) => GoalModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('Error fetching priority goals: $e');
      return [];
    }
  }

  /// Stream priority goals (for home tab, real-time)
  Stream<List<GoalModel>> getPriorityGoalsStream(String uid) {
    try {
      return _firestore
          .collection('clients')
          .doc(uid)
          .collection('goals')
          // .where('isPriority', isEqualTo: true)
          .where('status', isNotEqualTo: GoalStatus.cancelled.index)
          .limit(3)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => GoalModel.fromJson(doc.data()))
                .toList(),
          );
    } catch (e) {
      log('Error streaming priority goals: $e');
      return Stream.value([]);
    }
  }

  /// Create a new goal
  Future<String?> createGoal(String uid, GoalModel goal) async {
    try {
      final goalId = _firestore
          .collection('clients')
          .doc(uid)
          .collection('goals')
          .doc()
          .id;

      await _firestore
          .collection('clients')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .set(
            goal
                .copyWith(
                  goalId: goalId,
                  userId: uid, // ← Add this
                  status: GoalStatus.active, // ← Add this
                )
                .toJson(),
          );

      return goalId;
    } catch (e) {
      log('Error creating goal: $e');
      return null;
    }
  }

  /// Update goal with new amount
  Future<bool> updateGoalAmount({
    required String uid,
    required String goalId,
    required double newAmount,
  }) async {
    try {
      await _firestore
          .collection('clients')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .update({
            'currentAmount': newAmount,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      log('Error updating goal amount: $e');
      return false;
    }
  }

  /// Contribute to goal (atomically updates goal and creates transaction)
  Future<bool> contributeToGoal({
    required String uid,
    required String goalId,
    required double amount,
    required String description,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get current goal
        final goalRef = _firestore
            .collection('clients')
            .doc(uid)
            .collection('goals')
            .doc(goalId);
        final goalDoc = await transaction.get(goalRef);

        if (!goalDoc.exists) throw Exception('Goal not found');

        final goal = GoalModel.fromJson(goalDoc.data() ?? {});
        final newAmount = goal.currentAmount + amount;
        final isCompleted = newAmount >= goal.targetAmount;

        // Update goal
        transaction.update(goalRef, {
          'currentAmount': newAmount,
          'status': isCompleted
              ? GoalStatus.completed.index
              : GoalStatus.active.index,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create transaction record
        final transactionId = _firestore.collection('transactions').doc().id;
        final txn = TransactionModel(
          transactionId: transactionId,
          userId: uid,
          amount: amount,
          currency: 'NGN',
          description: description,

          status: TransactionStatus.completed,
          fees: 0,
          netAmount: amount,
          referenceNumber: 'GOAL-${goalId.substring(0, 8).toUpperCase()}',
          createdAt: DateTime.now(),
          investmentId: null,
          failureReason: null,
          relatedTransactionId: null,
          transactionType: TransactionType.adjustment,
          transactionDate: DateTime.now(),
        );

        transaction.set(
          _firestore.collection('transactions').doc(transactionId),
          txn.toJson(),
        );
      });

      return true;
    } catch (e) {
      log('Error contributing to goal: $e');
      return false;
    }
  }

  /// Update goal (title, description, date, etc.)
  Future<bool> updateGoal({
    required String uid,
    required String goalId,
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isPriority,
    GoalStatus? status,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (targetDate != null) {
        updates['targetDate'] = targetDate.toIso8601String();
      }
      if (isPriority != null) updates['isPriority'] = isPriority;
      if (status != null) updates['status'] = status.index;

      await _firestore
          .collection('clients')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .update(updates);

      return true;
    } catch (e) {
      log('Error updating goal: $e');
      return false;
    }
  }

  /// Delete goal (marks as cancelled)
  Future<bool> deleteGoal(String uid, String goalId) async {
    try {
      await _firestore
          .collection('clients')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .update({'status': GoalStatus.cancelled.index});

      return true;
    } catch (e) {
      log('Error deleting goal: $e');
      return false;
    }
  }

  /// Update user's phone number
  Future<bool> updateUserPhone({
    required String uid,
    required String phoneNumber,
  }) async {
    try {
      await _firestore.collection('clients').doc(uid).update({
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('Error updating phone number: $e');
      return false;
    }
  }

  // ==================== FINAL updateFinancialProfile METHOD ====================
  // Replace the existing updateFinancialProfile in lib/services/firestore_service.dart with this

  Future<bool> updateFinancialProfile({
    required String uid,
    double? accountBalance,
    double? totalInvested,
    double? totalReturns,
    int? tokenBalance,
    double? savingsTarget,
    DateTime? savingsTargetDate,
    String? bankName,
    String? accountNumber,
    String? accountType,
  }) async {
    try {
      final updates = <String, dynamic>{};

      // Add all provided fields to updates
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
      if (savingsTarget != null) {
        updates['financialProfile.savingsTarget'] = savingsTarget;
      }
      if (savingsTargetDate != null) {
        updates['financialProfile.savingsTargetDate'] = Timestamp.fromDate(
          savingsTargetDate,
        );
      }
      if (bankName != null) {
        updates['financialProfile.bankName'] = bankName;
      }
      if (accountNumber != null) {
        updates['financialProfile.accountNumber'] = accountNumber;
      }
      if (accountType != null) {
        updates['financialProfile.accountType'] = accountType;
      }

      // Always update the updatedAt timestamp
      updates['updatedAt'] = FieldValue.serverTimestamp();

      // If no fields to update, return early
      if (updates.isEmpty ||
          updates.length == 1 && updates.containsKey('updatedAt')) {
        return true;
      }

      // Perform the update with merge to preserve other fields
      await _firestore.collection('clients').doc(uid).update(updates);
      return true;
    } catch (e) {
      log('Error updating financial profile: $e');
      return false;
    }
  }

  // ==================== ALSO ADD THIS DEDICATED METHOD ====================
  // For specific use case of updating both savings target and target date together

  Future<bool> updateSavingsTarget({
    required String uid,
    required double amount,
    required DateTime targetDate,
  }) async {
    try {
      await _firestore.collection('clients').doc(uid).update({
        'financialProfile.savingsTarget': amount,
        'financialProfile.savingsTargetDate': Timestamp.fromDate(targetDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('Error updating savings target: $e');
      return false;
    }
  }
}
