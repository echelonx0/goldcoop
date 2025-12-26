// lib/services/user_settings_service.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettingsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== NOTIFICATION SETTINGS ====================

  /// Get user's notification settings
  Future<Map<String, dynamic>?> getNotificationSettings(String userId) async {
    try {
      final doc = await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();

      if (!doc.exists) {
        // Return default settings if none exist
        return {
          'deposits': true,
          'withdrawals': true,
          'investments': true,
          'security': true,
          'kyc': true,
          'goalMilestones': true,
          'goalReminders': false,
          'promotions': false,
          'productUpdates': true,
          'newsletter': false,
        };
      }

      return doc.data();
    } catch (e) {
      log('Error fetching notification settings: $e');
      return null;
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set({
            ...settings,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error updating notification settings: $e');
      return false;
    }
  }

  /// Update single notification preference
  Future<bool> updateNotificationPreference(
    String userId,
    String key,
    bool value,
  ) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set({
            key: value,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error updating notification preference: $e');
      return false;
    }
  }

  // ==================== SECURITY SETTINGS ====================

  /// Get user's security settings
  Future<Map<String, dynamic>?> getSecuritySettings(String userId) async {
    try {
      final doc = await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .get();

      if (!doc.exists) {
        // Return default settings if none exist
        return {
          'smsAuth': false,
          'emailAuth': false,
          'biometric': false,
          'locationTracking': false,
          'phoneNumber': '',
          'activeSessions': [],
        };
      }

      return doc.data();
    } catch (e) {
      log('Error fetching security settings: $e');
      return null;
    }
  }

  /// Update security settings
  Future<bool> updateSecuritySettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .set({
            ...settings,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error updating security settings: $e');
      return false;
    }
  }

  /// Enable/disable SMS authentication
  Future<bool> toggleSMSAuth(String userId, bool enabled) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .set({
            'smsAuth': enabled,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error toggling SMS auth: $e');
      return false;
    }
  }

  /// Enable/disable email authentication
  Future<bool> toggleEmailAuth(String userId, bool enabled) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .set({
            'emailAuth': enabled,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error toggling email auth: $e');
      return false;
    }
  }

  /// Enable/disable biometric login
  Future<bool> toggleBiometric(String userId, bool enabled) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .set({
            'biometric': enabled,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error toggling biometric: $e');
      return false;
    }
  }

  /// Enable/disable location tracking
  Future<bool> toggleLocationTracking(String userId, bool enabled) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .set({
            'locationTracking': enabled,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error toggling location tracking: $e');
      return false;
    }
  }

  /// Add active session
  Future<bool> addActiveSession(
    String userId,
    Map<String, dynamic> session,
  ) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .set({
            'activeSessions': FieldValue.arrayUnion([session]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error adding active session: $e');
      return false;
    }
  }

  /// Clear all active sessions (logout all devices)
  Future<bool> clearAllSessions(String userId) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .set({
            'activeSessions': [],
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error clearing sessions: $e');
      return false;
    }
  }

  // ==================== APP PREFERENCES ====================

  /// Get user's app preferences (theme, language, etc.)
  Future<Map<String, dynamic>?> getAppPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (!doc.exists) {
        return {
          'theme': 'light',
          'language': 'en',
          'currency': 'NGN',
          'notifications': true,
        };
      }

      return doc.data();
    } catch (e) {
      log('Error fetching app preferences: $e');
      return null;
    }
  }

  /// Update app preferences
  Future<bool> updateAppPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _firestore
          .collection('clients')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set({
            ...preferences,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      log('Error updating app preferences: $e');
      return false;
    }
  }
}
