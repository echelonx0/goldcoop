// lib/services/token_conversion_service.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/token_conversion_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class TokenConversionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== CONVERSION REQUEST METHODS ====================

  /// Create a token conversion request
  /// Returns conversionId on success, null on failure
  Future<String?> createConversionRequest({
    required String userId,
    required int tokenCount,
    required String phoneNumber,
    required PhoneNetwork network,
  }) async {
    try {
      // Validate inputs
      if (!phoneNumber.isValidNigerianPhone) {
        throw Exception('Invalid phone number');
      }
      if (tokenCount <= 0) {
        throw Exception('Token count must be greater than 0');
      }

      final conversionId = _firestore.collection('token_conversions').doc().id;
      final nairaValue = tokenCount * 10.0; // 1 token = ₦10

      final conversion = TokenConversionModel(
        conversionId: conversionId,
        userId: userId,
        tokenCount: tokenCount,
        nairaValue: nairaValue,
        phoneNumber: phoneNumber.toNigerianPhoneFormat(),
        network: network,
        status: ConversionStatus.pending,
        requestedAt: DateTime.now(),
      );

      await _firestore
          .collection('token_conversions')
          .doc(conversionId)
          .set(conversion.toJson());

      return conversionId;
    } catch (e) {
      log('Error creating conversion request: $e');
      return null;
    }
  }

  /// Get all conversions for a user
  Future<List<TokenConversionModel>> getUserConversions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('token_conversions')
          .where('userId', isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TokenConversionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching conversions: $e');
      return [];
    }
  }

  /// Stream user conversions (real-time updates)
  Stream<List<TokenConversionModel>> getUserConversionsStream(String userId) {
    return _firestore
        .collection('token_conversions')
        .where('userId', isEqualTo: userId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TokenConversionModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get pending conversions for a user
  Future<List<TokenConversionModel>> getUserPendingConversions(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('token_conversions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: ConversionStatus.pending.name)
          .get();

      return snapshot.docs
          .map((doc) => TokenConversionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching pending conversions: $e');
      return [];
    }
  }

  /// Stream pending conversions for a user
  Stream<List<TokenConversionModel>> getUserPendingConversionsStream(
    String userId,
  ) {
    return _firestore
        .collection('token_conversions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: ConversionStatus.pending.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TokenConversionModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get single conversion by ID
  Future<TokenConversionModel?> getConversion(String conversionId) async {
    try {
      final doc = await _firestore
          .collection('token_conversions')
          .doc(conversionId)
          .get();

      return doc.exists ? TokenConversionModel.fromFirestore(doc) : null;
    } catch (e) {
      log('Error fetching conversion: $e');
      return null;
    }
  }

  /// Stream single conversion (real-time)
  Stream<TokenConversionModel?> getConversionStream(String conversionId) {
    return _firestore
        .collection('token_conversions')
        .doc(conversionId)
        .snapshots()
        .map((doc) {
          return doc.exists ? TokenConversionModel.fromFirestore(doc) : null;
        });
  }

  // ==================== CONVERSION STATUS UPDATES ====================

  /// Update conversion status
  Future<bool> updateConversionStatus(
    String conversionId,
    ConversionStatus status, {
    DateTime? approvedAt,
    DateTime? completedAt,
    String? failureReason,
    String? telecomReference,
  }) async {
    try {
      final updates = <String, dynamic>{'status': status.name};

      if (approvedAt != null) {
        updates['approvedAt'] = Timestamp.fromDate(approvedAt);
      }
      if (completedAt != null) {
        updates['completedAt'] = Timestamp.fromDate(completedAt);
      }
      if (failureReason != null) {
        updates['failureReason'] = failureReason;
      }
      if (telecomReference != null) {
        updates['telecomReference'] = telecomReference;
      }

      await _firestore
          .collection('token_conversions')
          .doc(conversionId)
          .update(updates);

      return true;
    } catch (e) {
      log('Error updating conversion status: $e');
      return false;
    }
  }

  /// Approve conversion (admin)
  Future<bool> approveConversion(String conversionId) async {
    return updateConversionStatus(
      conversionId,
      ConversionStatus.approved,
      approvedAt: DateTime.now(),
    );
  }

  /// Mark conversion as processing (after telecom API call)
  Future<bool> markAsProcessing(String conversionId) async {
    return updateConversionStatus(conversionId, ConversionStatus.processing);
  }

  /// Mark conversion as completed (after confirmation from telecom)
  Future<bool> markAsCompleted(
    String conversionId, {
    String? telecomReference,
  }) async {
    return updateConversionStatus(
      conversionId,
      ConversionStatus.completed,
      completedAt: DateTime.now(),
      telecomReference: telecomReference,
    );
  }

  /// Mark conversion as failed
  Future<bool> markAsFailed(
    String conversionId, {
    required String failureReason,
  }) async {
    try {
      final conversion = await getConversion(conversionId);
      if (conversion == null) return false;

      final newRetryCount = (conversion.retryCount ?? 0) + 1;

      await _firestore
          .collection('token_conversions')
          .doc(conversionId)
          .update({
            'status': ConversionStatus.failed.name,
            'failureReason': failureReason,
            'retryCount': newRetryCount,
          });

      return true;
    } catch (e) {
      log('Error marking conversion as failed: $e');
      return false;
    }
  }

  /// Cancel conversion (user cancels pending request)
  Future<bool> cancelConversion(String conversionId) async {
    try {
      final conversion = await getConversion(conversionId);
      if (conversion == null) return false;

      // Can only cancel pending conversions
      if (!conversion.isPending) {
        throw Exception('Can only cancel pending conversions');
      }

      // Refund tokens to user
      await _firestore.collection('token_conversions').doc(conversionId).update(
        {'status': ConversionStatus.cancelled.name},
      );

      // TODO: Add tokens back to user balance
      return true;
    } catch (e) {
      log('Error cancelling conversion: $e');
      return false;
    }
  }

  // ==================== ADMIN METHODS ====================

  /// Get all pending conversions (admin dashboard)
  Future<List<TokenConversionModel>> getAllPendingConversions() async {
    try {
      final snapshot = await _firestore
          .collection('token_conversions')
          .where('status', isEqualTo: ConversionStatus.pending.name)
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TokenConversionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching all pending conversions: $e');
      return [];
    }
  }

  /// Stream all pending conversions (admin, real-time)
  Stream<List<TokenConversionModel>> getAllPendingConversionsStream() {
    return _firestore
        .collection('token_conversions')
        .where('status', isEqualTo: ConversionStatus.pending.name)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TokenConversionModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get conversions by status (admin)
  Future<List<TokenConversionModel>> getConversionsByStatus(
    ConversionStatus status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('token_conversions')
          .where('status', isEqualTo: status.name)
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TokenConversionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching conversions by status: $e');
      return [];
    }
  }

  // ==================== ANALYTICS ====================

  /// Get conversion statistics
  Future<Map<String, dynamic>> getConversionStats(String userId) async {
    try {
      final conversions = await getUserConversions(userId);

      int totalCompleted = 0;
      int totalTokens = 0;
      int totalFailures = 0;
      double totalNairaValue = 0;

      for (final conversion in conversions) {
        if (conversion.isCompleted) {
          totalCompleted++;
          totalTokens += conversion.tokenCount;
          totalNairaValue += conversion.nairaValue;
        }
        if (conversion.isFailed) {
          totalFailures++;
        }
      }

      return {
        'totalConversions': conversions.length,
        'completedConversions': totalCompleted,
        'totalTokensConverted': totalTokens,
        'totalNairaValue': totalNairaValue,
        'failedConversions': totalFailures,
        'successRate': conversions.isEmpty
            ? 0.0
            : (totalCompleted / conversions.length),
      };
    } catch (e) {
      log('Error getting conversion stats: $e');
      return {};
    }
  }

  /// Get popular networks
  Future<Map<String, int>> getPopularNetworks() async {
    try {
      final snapshot = await _firestore
          .collection('token_conversions')
          .where('status', isEqualTo: ConversionStatus.completed.name)
          .get();

      final networkCounts = <String, int>{};

      for (final doc in snapshot.docs) {
        final conversion = TokenConversionModel.fromFirestore(doc);
        final networkName = conversion.networkName;
        networkCounts[networkName] = (networkCounts[networkName] ?? 0) + 1;
      }

      return networkCounts;
    } catch (e) {
      log('Error getting popular networks: $e');
      return {};
    }
  }

  // ==================== ATOMIC OPERATIONS ====================

  /// Create conversion + deduct tokens + record transaction (atomic)
  Future<String?> convertTokensAtomically({
    required String userId,
    required int tokenCount,
    required String phoneNumber,
    required PhoneNetwork network,
    required UserModel user,
  }) async {
    try {
      String? conversionId;

      await _firestore.runTransaction((transaction) async {
        // Verify user has enough tokens
        if (user.financialProfile.tokenBalance < tokenCount) {
          throw Exception('Insufficient tokens');
        }

        // Create conversion request
        conversionId = _firestore.collection('token_conversions').doc().id;
        final nairaValue = tokenCount * 10.0;

        final conversion = TokenConversionModel(
          conversionId: conversionId!,
          userId: userId,
          tokenCount: tokenCount,
          nairaValue: nairaValue,
          phoneNumber: phoneNumber.toNigerianPhoneFormat(),
          network: network,
          status: ConversionStatus.pending,
          requestedAt: DateTime.now(),
        );

        transaction.set(
          _firestore.collection('token_conversions').doc(conversionId),
          conversion.toJson(),
        );

        // Deduct tokens from user balance
        final userRef = _firestore.collection('clients').doc(userId);
        transaction.update(userRef, {
          'financialProfile.tokenBalance':
              user.financialProfile.tokenBalance - tokenCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create transaction record
        final txnId = _firestore.collection('transactions').doc().id;
        final txn = TransactionModel(
          transactionId: txnId,
          userId: userId,
          transactionType: TransactionType.token_conversion,
          status: TransactionStatus.pending,
          amount: nairaValue,
          currency: 'NGN',
          description: 'Token conversion to ${network.name} airtime',
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          referenceNumber: conversionId!.substring(0, 8),
        );

        transaction.set(
          _firestore.collection('transactions').doc(txnId),
          txn.toJson(),
        );

        // Link conversion to transaction
        transaction.update(
          _firestore.collection('token_conversions').doc(conversionId),
          {'transactionId': txnId},
        );
      });

      return conversionId;
    } catch (e) {
      log('Error in atomic token conversion: $e');
      return null;
    }
  }

  /// Retry failed conversion
  Future<bool> retryConversion(String conversionId) async {
    try {
      final conversion = await getConversion(conversionId);
      if (conversion == null) return false;

      if (!conversion.canRetry) {
        throw Exception('Cannot retry: max retries reached');
      }

      // Reset status to pending for retry
      await updateConversionStatus(conversionId, ConversionStatus.pending);

      return true;
    } catch (e) {
      log('Error retrying conversion: $e');
      return false;
    }
  }
}
