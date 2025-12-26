// lib/screens/dashboard/tabs/account/controllers/change_password_controller.dart

import 'package:flutter/material.dart';

class ChangePasswordController {
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  late FocusNode currentPasswordFocusNode;
  late FocusNode newPasswordFocusNode;
  late FocusNode confirmPasswordFocusNode;

  ChangePasswordController() {
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    currentPasswordFocusNode = FocusNode();
    newPasswordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
  }

  String? validate() {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      return 'Please enter your current password';
    }

    if (newPassword.isEmpty) {
      return 'Please enter a new password';
    }

    if (newPassword.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!newPassword.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!newPassword.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (newPassword == currentPassword) {
      return 'New password must be different from current password';
    }

    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    currentPasswordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
  }
}
