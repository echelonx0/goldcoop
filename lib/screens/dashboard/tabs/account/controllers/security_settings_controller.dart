// lib/screens/dashboard/tabs/account/controllers/security_settings_controller.dart

import 'package:flutter/foundation.dart';
import '../services/user_settings_service.dart';

class SecuritySettings {
  bool smsAuth;
  bool emailAuth;
  bool biometric;
  bool locationTracking;
  String phoneNumber;
  List<Map<String, dynamic>> activeSessions;

  SecuritySettings({
    this.smsAuth = false,
    this.emailAuth = false,
    this.biometric = false,
    this.locationTracking = false,
    this.phoneNumber = '',
    this.activeSessions = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'smsAuth': smsAuth,
      'emailAuth': emailAuth,
      'biometric': biometric,
      'locationTracking': locationTracking,
      'phoneNumber': phoneNumber,
      'activeSessions': activeSessions,
    };
  }

  factory SecuritySettings.fromMap(Map<String, dynamic> map) {
    return SecuritySettings(
      smsAuth: map['smsAuth'] ?? false,
      emailAuth: map['emailAuth'] ?? false,
      biometric: map['biometric'] ?? false,
      locationTracking: map['locationTracking'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      activeSessions: List<Map<String, dynamic>>.from(
        map['activeSessions'] ?? [],
      ),
    );
  }
}

class SecuritySettingsController extends ChangeNotifier {
  final String userId;
  final UserSettingsService _settingsService = UserSettingsService();

  SecuritySettings _settings = SecuritySettings();
  bool _isLoading = false;

  SecuritySettings get settings => _settings;
  bool get isLoading => _isLoading;

  SecuritySettingsController(this.userId);

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _settingsService.getSecuritySettings(userId);
      if (data != null) {
        _settings = SecuritySettings.fromMap(data);
      }
    } catch (e) {
      debugPrint('Error loading security settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSMSAuth(bool value) async {
    _settings.smsAuth = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleEmailAuth(bool value) async {
    _settings.emailAuth = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleBiometric(bool value) async {
    _settings.biometric = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleLocationTracking(bool value) async {
    _settings.locationTracking = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> logoutAllSessions() async {
    _settings.activeSessions = [];
    notifyListeners();
    await _settingsService.clearAllSessions(userId);
  }

  Future<void> _saveSettings() async {
    try {
      await _settingsService.updateSecuritySettings(userId, _settings.toMap());
    } catch (e) {
      debugPrint('Error saving security settings: $e');
    }
  }
}
