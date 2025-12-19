// lib/providers/auth_provider.dart
// Authentication state management using ChangeNotifier

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  // State variables
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailVerified = false;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmailVerified => _isEmailVerified;

  // Constructor - initialize auth state listener
  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((user) async {
      _currentUser = user;
      if (user != null) {
        await _loadUserData(user.uid);
        _isEmailVerified = user.emailVerified;
      } else {
        _userData = null;
        _isEmailVerified = false;
      }
      notifyListeners();
    });
  }

  // ==================== LOAD USER DATA ====================
  Future<void> _loadUserData(String uid) async {
    try {
      _userData = await _authService.getUserData(uid);
    } catch (e) {
      _userData = null;
    }
  }

  // ==================== SIGN UP ====================
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );

    if (result.isSuccess) {
      _currentUser = result.user;
      await _loadUserData(result.user!.uid);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  // ==================== SIGN IN ====================
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signIn(email: email, password: password);

    if (result.isSuccess) {
      _currentUser = result.user;
      _isEmailVerified = result.user?.emailVerified ?? false;
      await _loadUserData(result.user!.uid);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  // ==================== SIGN OUT ====================
  Future<bool> signOut() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.signOut();

    _isLoading = false;
    _currentUser = null;
    _userData = null;
    _isEmailVerified = false;
    _errorMessage = null;
    notifyListeners();

    return result.isSuccess;
  }

  // ==================== PASSWORD RESET ====================
  Future<bool> sendPasswordResetEmail({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.sendPasswordResetEmail(email: email);

    _isLoading = false;
    if (result.isSuccess) {
      _errorMessage = null;
    } else {
      _errorMessage = result.errorMessage;
    }
    notifyListeners();

    return result.isSuccess;
  }

  // ==================== SEND EMAIL VERIFICATION ====================
  Future<bool> sendEmailVerification() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.sendEmailVerification();

    _isLoading = false;
    if (!result.isSuccess) {
      _errorMessage = result.errorMessage;
    }
    notifyListeners();

    return result.isSuccess;
  }

  // ==================== CHECK EMAIL VERIFICATION ====================
  Future<void> checkEmailVerification() async {
    final isVerified = await _authService.isEmailVerified();
    _isEmailVerified = isVerified;
    notifyListeners();
  }

  // ==================== UPDATE PROFILE ====================
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      photoUrl: photoUrl,
    );

    if (result.isSuccess) {
      _currentUser = result.user;
      await _loadUserData(result.user!.uid);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  // ==================== UPDATE PASSWORD ====================
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _isLoading = false;
    if (result.isSuccess) {
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  // ==================== DELETE ACCOUNT ====================
  Future<bool> deleteAccount({required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.deleteAccount(password: password);

    _isLoading = false;
    if (result.isSuccess) {
      _currentUser = null;
      _userData = null;
      _isEmailVerified = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  // ==================== CLEAR ERROR ====================
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
