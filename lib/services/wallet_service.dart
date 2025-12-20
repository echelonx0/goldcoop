// lib/services/wallet_service.dart
// Service for managing wallets and withdrawal requests

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/financial_wallet_models.dart';
import '../models/transaction_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== WALLET METHODS ====================

  /// Get all wallets for a user
  Future<List<FinancialWallet>> getUserWallets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .get();

      return snapshot.docs
          .map((doc) => FinancialWallet.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching wallets: $e');
      rethrow;
    }
  }

  /// Stream of wallets for a user (real-time updates)
  Stream<List<FinancialWallet>> getUserWalletsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FinancialWallet.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get a single wallet by ID
  Future<FinancialWallet?> getWallet(String userId, String walletId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .doc(walletId)
          .get();

      return doc.exists ? FinancialWallet.fromFirestore(doc) : null;
    } catch (e) {
      log('Error fetching wallet: $e');
      return null;
    }
  }

  /// Create a new wallet for a user
  Future<void> createWallet(FinancialWallet wallet) async {
    try {
      await _firestore
          .collection('users')
          .doc(wallet.userId)
          .collection('wallets')
          .doc(wallet.walletId)
          .set(wallet.toJson());
    } catch (e) {
      log('Error creating wallet: $e');
      rethrow;
    }
  }

  /// Update an existing wallet
  Future<void> updateWallet(FinancialWallet wallet) async {
    try {
      await _firestore
          .collection('users')
          .doc(wallet.userId)
          .collection('wallets')
          .doc(wallet.walletId)
          .update(wallet.toJson());
    } catch (e) {
      log('Error updating wallet: $e');
      rethrow;
    }
  }

  /// Delete a wallet
  Future<void> deleteWallet(String userId, String walletId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .doc(walletId)
          .delete();
    } catch (e) {
      log('Error deleting wallet: $e');
      rethrow;
    }
  }

  /// Get default wallet for a user
  Future<FinancialWallet?> getDefaultWallet(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty
          ? FinancialWallet.fromFirestore(snapshot.docs.first)
          : null;
    } catch (e) {
      log('Error fetching default wallet: $e');
      return null;
    }
  }

  /// Set a wallet as default
  Future<void> setDefaultWallet(String userId, String walletId) async {
    try {
      final batch = _firestore.batch();

      // Get all user wallets
      final wallets = await getUserWallets(userId);

      // Set all to false
      for (final wallet in wallets) {
        batch.update(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('wallets')
              .doc(wallet.walletId),
          {'isDefault': false},
        );
      }

      // Set the selected one to true
      batch.update(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('wallets')
            .doc(walletId),
        {'isDefault': true},
      );

      await batch.commit();
    } catch (e) {
      log('Error setting default wallet: $e');
      rethrow;
    }
  }

  // ==================== WITHDRAWAL REQUEST METHODS ====================

  /// Create a withdrawal request
  Future<void> createWithdrawalRequest(WithdrawalRequest withdrawal) async {
    try {
      await _firestore
          .collection('withdrawal_requests')
          .doc(withdrawal.withdrawalId)
          .set(withdrawal.toJson());
    } catch (e) {
      log('Error creating withdrawal request: $e');
      rethrow;
    }
  }

  /// Get all withdrawal requests for a user
  Future<List<WithdrawalRequest>> getUserWithdrawalRequests(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('withdrawal_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WithdrawalRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching withdrawal requests: $e');
      rethrow;
    }
  }

  /// Stream of withdrawal requests for a user (real-time updates)
  Stream<List<WithdrawalRequest>> getUserWithdrawalRequestsStream(
    String userId,
  ) {
    return _firestore
        .collection('withdrawal_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WithdrawalRequest.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get withdrawal requests by status
  Future<List<WithdrawalRequest>> getWithdrawalsByStatus(
    String userId,
    WithdrawalStatus status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('withdrawal_requests')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WithdrawalRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching withdrawals by status: $e');
      rethrow;
    }
  }

  /// Stream of withdrawal requests by status
  Stream<List<WithdrawalRequest>> getWithdrawalsByStatusStream(
    String userId,
    WithdrawalStatus status,
  ) {
    return _firestore
        .collection('withdrawal_requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status.name)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WithdrawalRequest.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get a single withdrawal request
  Future<WithdrawalRequest?> getWithdrawalRequest(String withdrawalId) async {
    try {
      final doc = await _firestore
          .collection('withdrawal_requests')
          .doc(withdrawalId)
          .get();

      return doc.exists ? WithdrawalRequest.fromFirestore(doc) : null;
    } catch (e) {
      log('Error fetching withdrawal request: $e');
      return null;
    }
  }

  /// Update withdrawal request status (admin only)
  Future<void> updateWithdrawalStatus(
    String withdrawalId,
    WithdrawalStatus status, {
    String? referenceNumber,
    String? failureReason,
    String? adminNotes,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        if (referenceNumber != null) 'referenceNumber': referenceNumber,
        if (failureReason != null) 'failureReason': failureReason,
        if (adminNotes != null) 'adminNotes': adminNotes,
        if (status == WithdrawalStatus.processing)
          'processedAt': Timestamp.now()
        else if (status == WithdrawalStatus.completed)
          'completedAt': Timestamp.now(),
      };

      await _firestore
          .collection('withdrawal_requests')
          .doc(withdrawalId)
          .update(updateData);
    } catch (e) {
      log('Error updating withdrawal status: $e');
      rethrow;
    }
  }

  /// Cancel a pending withdrawal request (user only)
  Future<void> cancelWithdrawalRequest(String withdrawalId) async {
    try {
      await _firestore
          .collection('withdrawal_requests')
          .doc(withdrawalId)
          .update({'status': WithdrawalStatus.cancelled.name});
    } catch (e) {
      log('Error cancelling withdrawal request: $e');
      rethrow;
    }
  }

  /// Get all pending withdrawals (admin)
  Future<List<WithdrawalRequest>> getAllPendingWithdrawals() async {
    try {
      final snapshot = await _firestore
          .collection('withdrawal_requests')
          .where('status', isEqualTo: WithdrawalStatus.pending.name)
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WithdrawalRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching pending withdrawals: $e');
      rethrow;
    }
  }

  /// Stream of all pending withdrawals (admin, real-time)
  Stream<List<WithdrawalRequest>> getAllPendingWithdrawalsStream() {
    return _firestore
        .collection('withdrawal_requests')
        .where('status', isEqualTo: WithdrawalStatus.pending.name)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WithdrawalRequest.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== TRANSACTION METHODS ====================

  /// Create a transaction
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.transactionId)
          .set(transaction.toJson());
    } catch (e) {
      log('Error creating transaction: $e');
      rethrow;
    }
  }

  /// Update a transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.transactionId)
          .update(transaction.toJson());
    } catch (e) {
      log('Error updating transaction: $e');
      rethrow;
    }
  }

  /// Get user transactions by type
  Future<List<TransactionModel>> getUserTransactionsByType(
    String userId,
    TransactionType type,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('transactionType', isEqualTo: type.name)
          .orderBy('transactionDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching transactions: $e');
      rethrow;
    }
  }

  /// Get user withdrawals (transactions of type withdrawal)
  Future<List<TransactionModel>> getUserWithdrawals(String userId) async {
    return getUserTransactionsByType(userId, TransactionType.withdrawal);
  }

  /// Stream of user transactions
  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Stream of user withdrawal transactions
  Stream<List<TransactionModel>> getUserWithdrawalsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('transactionType', isEqualTo: TransactionType.withdrawal.name)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== SUMMARY METHODS ====================

  /// Get withdrawal statistics for a user
  Future<Map<String, dynamic>> getWithdrawalStats(String userId) async {
    try {
      final withdrawals = await getUserWithdrawalRequests(userId);

      double totalRequested = 0;
      double totalCompleted = 0;
      int pendingCount = 0;

      for (final withdrawal in withdrawals) {
        totalRequested += withdrawal.amount;
        if (withdrawal.isCompleted) {
          totalCompleted += withdrawal.amount;
        }
        if (withdrawal.isPending) {
          pendingCount++;
        }
      }

      return {
        'totalRequested': totalRequested,
        'totalCompleted': totalCompleted,
        'pendingCount': pendingCount,
        'totalWithdrawals': withdrawals.length,
      };
    } catch (e) {
      log('Error getting withdrawal stats: $e');
      return {
        'totalRequested': 0.0,
        'totalCompleted': 0.0,
        'pendingCount': 0,
        'totalWithdrawals': 0,
      };
    }
  }

  /// Get wallet statistics for a user
  Future<Map<String, dynamic>> getWalletStats(String userId) async {
    try {
      final wallets = await getUserWallets(userId);

      return {
        'totalWallets': wallets.length,
        'verifiedWallets': wallets.where((w) => w.isVerified).length,
        'bankAccounts': wallets
            .where((w) => w.type == WalletType.bankAccount)
            .length,
        'cryptoWallets': wallets
            .where((w) => w.type == WalletType.cryptoWallet)
            .length,
        'otherWallets': wallets
            .where(
              (w) =>
                  w.type != WalletType.bankAccount &&
                  w.type != WalletType.cryptoWallet,
            )
            .length,
      };
    } catch (e) {
      log('Error getting wallet stats: $e');
      return {
        'totalWallets': 0,
        'verifiedWallets': 0,
        'bankAccounts': 0,
        'cryptoWallets': 0,
        'otherWallets': 0,
      };
    }
  }
}
