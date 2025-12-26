// lib/screens/dashboard/tabs/account/account_tab_controller.dart
// Controller for AccountTab - handles business logic and utilities

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../models/user_model.dart';

/// Controller for AccountTab business logic and utilities
class AccountTabController {
  // ==================== STATUS COLOR MAPPING ====================

  /// Returns the appropriate color for an account status
  static Color getAccountStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return AppColors.tealSuccess;
      case AccountStatus.suspended:
      case AccountStatus.locked:
        return AppColors.warmRed;
      case AccountStatus.closed:
        return AppColors.textSecondary;
    }
  }

  /// Returns the appropriate color for a KYC status
  static Color getKYCStatusColor(KYCStatus status) {
    switch (status) {
      case KYCStatus.verified:
        return AppColors.tealSuccess;
      case KYCStatus.pending:
        return AppColors.softAmber;
      case KYCStatus.submitted:
        return AppColors.primaryOrange;
      case KYCStatus.rejected:
        return AppColors.warmRed;
      case KYCStatus.expired:
        return AppColors.textSecondary;
    }
  }

  // ==================== KYC BADGE DATA ====================

  /// Returns KYC badge display data (color, text, icon)
  static KYCBadgeData getKYCBadgeData(KYCStatus status) {
    switch (status) {
      case KYCStatus.verified:
        return KYCBadgeData(
          color: AppColors.tealSuccess,
          text: 'Verified',
          icon: Icons.verified_user,
        );
      case KYCStatus.pending:
        return KYCBadgeData(
          color: AppColors.softAmber,
          text: 'Pending Verification',
          icon: Icons.pending,
        );
      case KYCStatus.submitted:
        return KYCBadgeData(
          color: AppColors.primaryOrange,
          text: 'Under Review',
          icon: Icons.hourglass_empty,
        );
      case KYCStatus.rejected:
        return KYCBadgeData(
          color: AppColors.warmRed,
          text: 'Verification Failed',
          icon: Icons.error_outline,
        );
      case KYCStatus.expired:
        return KYCBadgeData(
          color: AppColors.textSecondary,
          text: 'Expired',
          icon: Icons.info_outline,
        );
    }
  }

  // ==================== DATE FORMATTING ====================

  /// Formats a DateTime to a readable string (e.g., "Jan 15, 2024")
  static String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a DateTime to full format (e.g., "January 15, 2024")
  static String formatDateFull(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ==================== USER INFO HELPERS ====================

  /// Returns a safe display value or fallback
  static String getDisplayValue(String? value, {String fallback = 'Not set'}) {
    if (value == null || value.isEmpty) return fallback;
    return value;
  }

  /// Returns formatted phone number or fallback
  static String getPhoneDisplay(UserModel? user) {
    return getDisplayValue(user?.phoneNumber);
  }

  /// Returns formatted country or fallback
  static String getCountryDisplay(UserModel? user) {
    return getDisplayValue(user?.country);
  }

  /// Returns formatted account status
  static String getAccountStatusDisplay(UserModel? user) {
    return user?.accountStatus.name.toUpperCase() ?? 'UNKNOWN';
  }
}

/// Data class for KYC badge display
class KYCBadgeData {
  final Color color;
  final String text;
  final IconData icon;

  const KYCBadgeData({
    required this.color,
    required this.text,
    required this.icon,
  });
}
