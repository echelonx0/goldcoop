// lib/services/firestore_service_profile_extension.dart
// Extension methods for FirestoreService - Profile updates
// Add these methods to your existing FirestoreService class

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Add these methods to your existing FirestoreService class
/// Copy the methods below into firestore_service.dart

/*
  // ==================== PROFILE UPDATES ====================

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

  /// Update user's profile picture URL
  Future<bool> updateProfilePicture({
    required String uid,
    required String? imageUrl,
  }) async {
    try {
      await _firestore.collection('clients').doc(uid).update({
        'profilePic': imageUrl,
        'photoUrl': imageUrl, // Backwards compatibility
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('Error updating profile picture: $e');
      return false;
    }
  }

  /// Full profile update (all editable fields at once)
  Future<bool> updateFullProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? country,
    String? dateOfBirth,
    String? profilePic,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (firstName != null) {
        updates['firstName'] = firstName;
      }
      if (lastName != null) {
        updates['lastName'] = lastName;
      }
      if (firstName != null || lastName != null) {
        final first = firstName ?? '';
        final last = lastName ?? '';
        updates['displayName'] = '$first $last'.trim();
      }
      if (phoneNumber != null) {
        updates['phoneNumber'] = phoneNumber;
      }
      if (address != null) {
        updates['address'] = address;
      }
      if (country != null) {
        updates['country'] = country;
      }
      if (dateOfBirth != null) {
        updates['dateOfBirth'] = dateOfBirth;
      }
      if (profilePic != null) {
        updates['profilePic'] = profilePic;
        updates['photoUrl'] = profilePic;
      }

      await _firestore.collection('clients').doc(uid).update(updates);
      return true;
    } catch (e) {
      log('Error updating full profile: $e');
      return false;
    }
  }
*/

/// Standalone class if you prefer not to modify FirestoreService
class ProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update user's phone number
  static Future<bool> updateUserPhone({
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

  /// Update user's profile picture URL
  static Future<bool> updateProfilePicture({
    required String uid,
    required String? imageUrl,
  }) async {
    try {
      await _firestore.collection('clients').doc(uid).update({
        'profilePic': imageUrl,
        'photoUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('Error updating profile picture: $e');
      return false;
    }
  }

  /// Full profile update
  static Future<bool> updateFullProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? country,
    String? dateOfBirth,
    String? profilePic,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      
      if (firstName != null || lastName != null) {
        final first = firstName ?? '';
        final last = lastName ?? '';
        updates['displayName'] = '$first $last'.trim();
      }
      
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (country != null) updates['country'] = country;
      if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth;
      
      if (profilePic != null) {
        updates['profilePic'] = profilePic;
        updates['photoUrl'] = profilePic;
      }

      await _firestore.collection('clients').doc(uid).update(updates);
      return true;
    } catch (e) {
      log('Error updating full profile: $e');
      return false;
    }
  }
}
