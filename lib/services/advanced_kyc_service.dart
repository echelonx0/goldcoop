// lib/services/advanced_kyc_service.dart
// Service layer for Advanced KYC operations

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/advanced_kyc_model.dart';

class AdvancedKYCService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'advanced_kyc';

  /// Get Advanced KYC data for a user
  Future<AdvancedKYCModel?> getAdvancedKYC(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return AdvancedKYCModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch Advanced KYC: $e');
    }
  }

  /// Stream Advanced KYC data for real-time updates
  Stream<AdvancedKYCModel?> streamAdvancedKYC(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return AdvancedKYCModel.fromFirestore(doc);
    });
  }

  /// Create or update Advanced KYC data
  Future<void> saveAdvancedKYC(AdvancedKYCModel kyc) async {
    try {
      final completionPercentage = _calculateCompletion(kyc);
      final status = _determineStatus(completionPercentage);
      
      final updatedKyc = kyc.copyWith(
        completionPercentage: completionPercentage,
        status: status,
        completedAt: status == AdvancedKYCStatus.completed 
            ? DateTime.now() 
            : kyc.completedAt,
      );
      
      await _firestore
          .collection(_collection)
          .doc(kyc.userId)
          .set(updatedKyc.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save Advanced KYC: $e');
    }
  }

  /// Update only Personal Details
  Future<void> updatePersonalDetails(
    String userId,
    PersonalDetails details,
  ) async {
    try {
      final existing = await getAdvancedKYC(userId);
      final kyc = (existing ?? AdvancedKYCModel.empty(userId)).copyWith(
        personalDetails: details,
      );
      await saveAdvancedKYC(kyc);
    } catch (e) {
      throw Exception('Failed to update Personal Details: $e');
    }
  }

  /// Update only Next of Kin
  Future<void> updateNextOfKin(String userId, NextOfKin nextOfKin) async {
    try {
      final existing = await getAdvancedKYC(userId);
      final kyc = (existing ?? AdvancedKYCModel.empty(userId)).copyWith(
        nextOfKin: nextOfKin,
      );
      await saveAdvancedKYC(kyc);
    } catch (e) {
      throw Exception('Failed to update Next of Kin: $e');
    }
  }

  /// Update only Savings Profile
  Future<void> updateSavingsProfile(
    String userId,
    SavingsProfile profile,
  ) async {
    try {
      final existing = await getAdvancedKYC(userId);
      final kyc = (existing ?? AdvancedKYCModel.empty(userId)).copyWith(
        savingsProfile: profile,
      );
      await saveAdvancedKYC(kyc);
    } catch (e) {
      throw Exception('Failed to update Savings Profile: $e');
    }
  }

  /// Calculate overall completion percentage
  int _calculateCompletion(AdvancedKYCModel kyc) {
    // Weight each section equally (33% each)
    final personalScore = kyc.personalDetails.completionScore * 0.33 / 85;
    final kinScore = kyc.nextOfKin.completionScore * 0.33 / 100;
    final savingsScore = kyc.savingsProfile.completionScore * 0.34 / 100;
    
    return ((personalScore + kinScore + savingsScore) * 100).round().clamp(0, 100);
  }

  /// Determine status based on completion
  AdvancedKYCStatus _determineStatus(int percentage) {
    if (percentage >= 100) return AdvancedKYCStatus.completed;
    if (percentage > 0) return AdvancedKYCStatus.inProgress;
    return AdvancedKYCStatus.notStarted;
  }

  /// Check if user has completed Advanced KYC
  Future<bool> isAdvancedKYCComplete(String userId) async {
    final kyc = await getAdvancedKYC(userId);
    return kyc?.isComplete ?? false;
  }

  /// Get completion percentage
  Future<int> getCompletionPercentage(String userId) async {
    final kyc = await getAdvancedKYC(userId);
    return kyc?.completionPercentage ?? 0;
  }

  /// Delete Advanced KYC data (for account deletion)
  Future<void> deleteAdvancedKYC(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete Advanced KYC: $e');
    }
  }
}
