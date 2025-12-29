// lib/services/deposit_service.dart

import 'dart:io';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/payment_proof_model.dart';
import '../../../models/transaction_model.dart';
import '../../../services/storage_service.dart';

/// Dedicated service for handling all deposit-related operations
/// Simplified for general account savings (no goal-specific logic)
class UserSavingsDepositsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final StorageService _storageService = StorageService();

  // ==================== PENDING TRANSACTION CREATION ====================

  /// Create a pending deposit transaction (before proof upload)
  /// Now simplified - deposits go directly to general account balance
  Future<String?> createPendingDeposit({
    required String userId,
    required double amount,
    required String description,
  }) async {
    try {
      final transactionRef = _firestore.collection('transactions').doc();

      final transaction = TransactionModel(
        transactionId: transactionRef.id,
        userId: userId,
        amount: amount,
        currency: 'NGN',
        description: description,
        status: TransactionStatus.pending,
        fees: 0,
        netAmount: amount,
        referenceNumber: _generateReference(userId),
        createdAt: DateTime.now(),
        transactionType: TransactionType.deposit,
        transactionDate: DateTime.now(),
        metadata: {
          'requiresProof': true,
          'depositType': 'general_savings', // ← Clarify it's general savings
        },
      );

      await transactionRef.set(transaction.toJson());
      log('✅ Pending deposit created: ${transactionRef.id}');
      return transactionRef.id;
    } catch (e) {
      log('❌ Error creating pending deposit: $e');
      return null;
    }
  }

  /// Generate payment reference from user ID (last 7 digits)
  String _generateReference(String userId) {
    final last7 = userId.substring(userId.length - 7).toUpperCase();
    return 'DEP-$last7';
  }

  /// Get user's payment reference
  String getUserPaymentReference(String userId) {
    return _generateReference(userId);
  }

  // ==================== PAYMENT PROOF UPLOAD ====================

  /// Complete proof upload workflow (upload file + create Firestore record)
  /// Simplified - no goal reference needed
  Future<UploadProofResult> uploadPaymentProof({
    required String userId,
    required String transactionId,
    required File file,
    required double amount, // ← Required to track deposit amount
  }) async {
    try {
      // 1. Validate file
      if (!_storageService.isFileTypeAllowed(file)) {
        return UploadProofResult.failure(
          'Invalid file type. Only PDF, JPG, and PNG are allowed.',
        );
      }

      final fileSize = await _storageService.getFileSize(file);
      if (!_storageService.isFileSizeValid(fileSize)) {
        return UploadProofResult.failure(
          'File too large. Maximum size is 5MB.',
        );
      }

      // 2. Generate proof ID
      final proofId = DateTime.now().millisecondsSinceEpoch.toString();

      // 3. Upload to Storage
      final fileUrl = await _storageService.uploadPaymentProof(
        userId: userId,
        proofId: proofId,
        file: file,
      );

      if (fileUrl == null) {
        return UploadProofResult.failure('Failed to upload file to storage.');
      }

      // 4. Determine file type
      final extension = _storageService.getFileExtension(file);
      final fileType = extension == '.pdf'
          ? ProofFileType.pdf
          : ProofFileType.image;

      // 5. Create Firestore record (simplified - no goalId)
      final proofRef = _firestore.collection('payment_proofs').doc(proofId);

      final proof = PaymentProofModel(
        proofId: proofId,
        userId: userId,
        goalId: null, // ← Always null for general savings
        transactionId: transactionId,
        fileUrl: fileUrl,
        fileType: fileType,
        fileName: file.path.split('/').last,
        uploadedAt: DateTime.now(),
        metadata: {'amount': amount, 'depositType': 'general_savings'},
      );

      await proofRef.set(proof.toJson());

      // 6. Update transaction status to processing
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': TransactionStatus.processing.name,
        'metadata.proofId': proofId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      log('✅ Payment proof uploaded successfully: $proofId');
      return UploadProofResult.success(proofId);
    } catch (e) {
      log('❌ Error in uploadPaymentProof: $e');
      return UploadProofResult.failure('Upload failed: ${e.toString()}');
    }
  }

  // ==================== PAYMENT PROOF QUERIES ====================

  /// Get payment proof by transaction ID
  Future<PaymentProofModel?> getPaymentProofByTransaction(
    String transactionId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('payment_proofs')
          .where('transactionId', isEqualTo: transactionId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return PaymentProofModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      log('❌ Error fetching payment proof: $e');
      return null;
    }
  }

  /// Get all payment proofs for a user
  Future<List<PaymentProofModel>> getUserPaymentProofs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('payment_proofs')
          .where('userId', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentProofModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('❌ Error fetching user payment proofs: $e');
      return [];
    }
  }

  /// Stream user's payment proofs (real-time)
  Stream<List<PaymentProofModel>> getUserPaymentProofsStream(String userId) {
    return _firestore
        .collection('payment_proofs')
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentProofModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get payment proof by ID
  Future<PaymentProofModel?> getPaymentProofById(String proofId) async {
    try {
      final doc = await _firestore
          .collection('payment_proofs')
          .doc(proofId)
          .get();

      if (!doc.exists) return null;
      return PaymentProofModel.fromJson(doc.data()!);
    } catch (e) {
      log('❌ Error fetching payment proof by ID: $e');
      return null;
    }
  }

  // ==================== ADMIN: VERIFICATION ====================

  /// Get all pending payment proofs (admin view)
  /// Now filters by depositType = 'general_savings'
  Future<List<PaymentProofModel>> getPendingPaymentProofs({
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('payment_proofs')
          .where('verificationStatus', isEqualTo: 'pending')
          .where('metadata.depositType', isEqualTo: 'general_savings')
          .orderBy('uploadedAt', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PaymentProofModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('❌ Error fetching pending proofs: $e');
      return [];
    }
  }

  /// Stream pending payment proofs (admin real-time view)
  /// Now filters by depositType = 'general_savings'
  Stream<List<PaymentProofModel>> getPendingPaymentProofsStream({
    int limit = 50,
  }) {
    return _firestore
        .collection('payment_proofs')
        .where('verificationStatus', isEqualTo: 'pending')
        .where('metadata.depositType', isEqualTo: 'general_savings')
        .orderBy('uploadedAt', descending: false)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentProofModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get approved payment proofs (admin view)
  Future<List<PaymentProofModel>> getApprovedPaymentProofs({
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('payment_proofs')
          .where('verificationStatus', isEqualTo: 'approved')
          .where('metadata.depositType', isEqualTo: 'general_savings')
          .orderBy('verifiedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PaymentProofModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('❌ Error fetching approved proofs: $e');
      return [];
    }
  }

  /// Stream approved payment proofs (admin real-time view)
  Stream<List<PaymentProofModel>> getApprovedPaymentProofsStream({
    int limit = 50,
  }) {
    return _firestore
        .collection('payment_proofs')
        .where('verificationStatus', isEqualTo: 'approved')
        .where('metadata.depositType', isEqualTo: 'general_savings')
        .orderBy('verifiedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentProofModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get rejected payment proofs (admin view)
  Future<List<PaymentProofModel>> getRejectedPaymentProofs({
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('payment_proofs')
          .where('verificationStatus', isEqualTo: 'rejected')
          .where('metadata.depositType', isEqualTo: 'general_savings')
          .orderBy('verifiedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PaymentProofModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('❌ Error fetching rejected proofs: $e');
      return [];
    }
  }

  /// Stream rejected payment proofs (admin real-time view)
  Stream<List<PaymentProofModel>> getRejectedPaymentProofsStream({
    int limit = 50,
  }) {
    return _firestore
        .collection('payment_proofs')
        .where('verificationStatus', isEqualTo: 'rejected')
        .where('metadata.depositType', isEqualTo: 'general_savings')
        .orderBy('verifiedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentProofModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Approve payment proof (admin action)
  /// Simplified: Just updates proof status and user account balance
  Future<bool> approvePaymentProof({
    required String proofId,
    required String adminUserId,
  }) async {
    try {
      // Get the proof to extract amount
      final proof = await getPaymentProofById(proofId);
      if (proof == null) return false;

      final amount = proof.metadata['amount'] as double? ?? 0.0;

      await _firestore.runTransaction((transaction) async {
        // 1. Update proof status
        final proofRef = _firestore.collection('payment_proofs').doc(proofId);
        transaction.update(proofRef, {
          'verificationStatus': PaymentProofStatus.approved.name,
          'verifiedBy': adminUserId,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        // 2. Update transaction status to completed
        final txnRef = _firestore
            .collection('transactions')
            .doc(proof.transactionId);
        transaction.update(txnRef, {
          'status': TransactionStatus.completed.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Update user's general account balance (simplified - no goal logic)
        final userRef = _firestore.collection('clients').doc(proof.userId);
        transaction.update(userRef, {
          'financialProfile.accountBalance': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      log('✅ Payment proof approved: $proofId (₦$amount added to account)');
      return true;
    } catch (e) {
      log('❌ Error approving payment proof: $e');
      return false;
    }
  }

  /// Reject payment proof (admin action)
  /// Simplified: Just updates proof and transaction status
  Future<bool> rejectPaymentProof({
    required String proofId,
    required String adminUserId,
    required String reason,
  }) async {
    try {
      final proof = await getPaymentProofById(proofId);
      if (proof == null) return false;

      await _firestore.runTransaction((transaction) async {
        // 1. Update proof status
        final proofRef = _firestore.collection('payment_proofs').doc(proofId);
        transaction.update(proofRef, {
          'verificationStatus': PaymentProofStatus.rejected.name,
          'verifiedBy': adminUserId,
          'verifiedAt': FieldValue.serverTimestamp(),
          'rejectionReason': reason,
        });

        // 2. Update transaction status to failed
        final txnRef = _firestore
            .collection('transactions')
            .doc(proof.transactionId);
        transaction.update(txnRef, {
          'status': TransactionStatus.failed.name,
          'failureReason': 'Proof rejected: $reason',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      log('✅ Payment proof rejected: $proofId - Reason: $reason');
      return true;
    } catch (e) {
      log('❌ Error rejecting payment proof: $e');
      return false;
    }
  }

  // ==================== STATS & ANALYTICS ====================

  /// Get pending proofs count (for admin dashboard)
  Future<int> getPendingProofsCount() async {
    try {
      final snapshot = await _firestore
          .collection('payment_proofs')
          .where('verificationStatus', isEqualTo: 'pending')
          .where('metadata.depositType', isEqualTo: 'general_savings')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      log('❌ Error getting pending proofs count: $e');
      return 0;
    }
  }

  /// Get user's pending proofs count
  Future<int> getUserPendingProofsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('payment_proofs')
          .where('userId', isEqualTo: userId)
          .where('verificationStatus', isEqualTo: 'pending')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      log('❌ Error getting user pending proofs count: $e');
      return 0;
    }
  }

  /// Get total approved deposits amount (for analytics)
  Future<double> getTotalApprovedDepositsAmount() async {
    try {
      final snapshot = await _firestore
          .collection('payment_proofs')
          .where('verificationStatus', isEqualTo: 'approved')
          .where('metadata.depositType', isEqualTo: 'general_savings')
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        final amount = doc.data()['metadata']['amount'] as double? ?? 0.0;
        total += amount;
      }

      return total;
    } catch (e) {
      log('❌ Error calculating total approved deposits: $e');
      return 0;
    }
  }
}

// ==================== RESULT CLASSES ====================

class UploadProofResult {
  final bool success;
  final String? proofId;
  final String? errorMessage;

  UploadProofResult._({required this.success, this.proofId, this.errorMessage});

  factory UploadProofResult.success(String proofId) {
    return UploadProofResult._(success: true, proofId: proofId);
  }

  factory UploadProofResult.failure(String errorMessage) {
    return UploadProofResult._(success: false, errorMessage: errorMessage);
  }
}
