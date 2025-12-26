// lib/screens/dashboard/tabs/account/controllers/notification_settings_controller.dart

import 'package:flutter/foundation.dart';
import '../services/user_settings_service.dart';

class NotificationSettings {
  bool deposits;
  bool withdrawals;
  bool investments;
  bool security;
  bool kyc;
  bool goalMilestones;
  bool goalReminders;
  bool promotions;
  bool productUpdates;
  bool newsletter;

  NotificationSettings({
    this.deposits = true,
    this.withdrawals = true,
    this.investments = true,
    this.security = true,
    this.kyc = true,
    this.goalMilestones = true,
    this.goalReminders = false,
    this.promotions = false,
    this.productUpdates = true,
    this.newsletter = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'deposits': deposits,
      'withdrawals': withdrawals,
      'investments': investments,
      'security': security,
      'kyc': kyc,
      'goalMilestones': goalMilestones,
      'goalReminders': goalReminders,
      'promotions': promotions,
      'productUpdates': productUpdates,
      'newsletter': newsletter,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      deposits: map['deposits'] ?? true,
      withdrawals: map['withdrawals'] ?? true,
      investments: map['investments'] ?? true,
      security: map['security'] ?? true,
      kyc: map['kyc'] ?? true,
      goalMilestones: map['goalMilestones'] ?? true,
      goalReminders: map['goalReminders'] ?? false,
      promotions: map['promotions'] ?? false,
      productUpdates: map['productUpdates'] ?? true,
      newsletter: map['newsletter'] ?? false,
    );
  }
}

class NotificationSettingsController extends ChangeNotifier {
  final String userId;
  final UserSettingsService _settingsService = UserSettingsService();

  NotificationSettings _settings = NotificationSettings();
  bool _isLoading = false;

  NotificationSettings get settings => _settings;
  bool get isLoading => _isLoading;

  NotificationSettingsController(this.userId);

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _settingsService.getNotificationSettings(userId);
      if (data != null) {
        _settings = NotificationSettings.fromMap(data);
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSetting(String key, bool value) async {
    switch (key) {
      case 'deposits':
        _settings.deposits = value;
        break;
      case 'withdrawals':
        _settings.withdrawals = value;
        break;
      case 'investments':
        _settings.investments = value;
        break;
      case 'security':
        _settings.security = value;
        break;
      case 'kyc':
        _settings.kyc = value;
        break;
      case 'goalMilestones':
        _settings.goalMilestones = value;
        break;
      case 'goalReminders':
        _settings.goalReminders = value;
        break;
      case 'promotions':
        _settings.promotions = value;
        break;
      case 'productUpdates':
        _settings.productUpdates = value;
        break;
      case 'newsletter':
        _settings.newsletter = value;
        break;
    }

    notifyListeners();

    try {
      await _settingsService.updateNotificationSettings(
        userId,
        _settings.toMap(),
      );
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
    }
  }
}
