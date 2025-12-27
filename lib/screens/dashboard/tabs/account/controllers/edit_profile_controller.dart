// lib/screens/dashboard/tabs/account/controllers/edit_profile_controller.dart
// Controller for Edit Profile screen - handles validation and state

import 'package:flutter/material.dart';
import '../../../../../models/user_model.dart';
import '../../../../../services/firestore_service.dart';

class EditProfileController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Form controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController dateOfBirthController;

  // State
  String? _selectedCountry;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasChanges = false;

  // Original values for change detection
  late UserModel _originalUser;

  // Getters
  String? get selectedCountry => _selectedCountry;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasChanges => _hasChanges;

  // Supported countries
  static const List<String> supportedCountries = [
    'Nigeria',
    'Ghana',
    'Kenya',
    'South Africa',
    'United Kingdom',
    'United States',
  ];

  void initialize(UserModel user) {
    _originalUser = user;

    firstNameController = TextEditingController(text: user.firstName);
    lastNameController = TextEditingController(text: user.lastName);
    phoneController = TextEditingController(text: user.phoneNumber);
    addressController = TextEditingController(text: user.address ?? '');
    dateOfBirthController = TextEditingController(text: user.dateOfBirth ?? '');
    _selectedCountry = user.country;

    // Listen for changes
    firstNameController.addListener(_checkForChanges);
    lastNameController.addListener(_checkForChanges);
    phoneController.addListener(_checkForChanges);
    addressController.addListener(_checkForChanges);
    dateOfBirthController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final changed = firstNameController.text != _originalUser.firstName ||
        lastNameController.text != _originalUser.lastName ||
        phoneController.text != _originalUser.phoneNumber ||
        addressController.text != (_originalUser.address ?? '') ||
        dateOfBirthController.text != (_originalUser.dateOfBirth ?? '') ||
        _selectedCountry != _originalUser.country;

    if (changed != _hasChanges) {
      _hasChanges = changed;
      notifyListeners();
    }
  }

  void setCountry(String? country) {
    _selectedCountry = country;
    _checkForChanges();
    notifyListeners();
  }

  // ==================== VALIDATION ====================

  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'First name contains invalid characters';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Last name contains invalid characters';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Basic phone validation - allows +, digits, spaces, dashes
    if (!RegExp(r'^[\+]?[\d\s\-]{10,15}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? validateAddress(String? value) {
    // Address is optional, but if provided should be reasonable
    if (value != null && value.isNotEmpty && value.length < 5) {
      return 'Please enter a complete address';
    }
    return null;
  }

  String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) return null; // Optional

    // Expected format: DD/MM/YYYY or YYYY-MM-DD
    final dateRegex = RegExp(r'^(\d{2}/\d{2}/\d{4}|\d{4}-\d{2}-\d{2})$');
    if (!dateRegex.hasMatch(value)) {
      return 'Use format: DD/MM/YYYY';
    }

    try {
      DateTime parsed;
      if (value.contains('/')) {
        final parts = value.split('/');
        parsed = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        parsed = DateTime.parse(value);
      }

      final now = DateTime.now();
      final age = now.year - parsed.year;

      if (parsed.isAfter(now)) {
        return 'Date cannot be in the future';
      }
      if (age < 18) {
        return 'You must be at least 18 years old';
      }
      if (age > 120) {
        return 'Please enter a valid date';
      }
    } catch (e) {
      return 'Invalid date format';
    }

    return null;
  }

  bool validateAll() {
    final firstNameError = validateFirstName(firstNameController.text);
    final lastNameError = validateLastName(lastNameController.text);
    final phoneError = validatePhone(phoneController.text);
    final addressError = validateAddress(addressController.text);
    final dobError = validateDateOfBirth(dateOfBirthController.text);

    if (firstNameError != null) {
      _errorMessage = firstNameError;
      notifyListeners();
      return false;
    }
    if (lastNameError != null) {
      _errorMessage = lastNameError;
      notifyListeners();
      return false;
    }
    if (phoneError != null) {
      _errorMessage = phoneError;
      notifyListeners();
      return false;
    }
    if (addressError != null) {
      _errorMessage = addressError;
      notifyListeners();
      return false;
    }
    if (dobError != null) {
      _errorMessage = dobError;
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    return true;
  }

  // ==================== SAVE ====================

  Future<bool> saveProfile(String uid) async {
    if (!validateAll()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _firestoreService.updateUserProfile(
        uid: uid,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        address: addressController.text.trim().isNotEmpty
            ? addressController.text.trim()
            : null,
        country: _selectedCountry,
        dateOfBirth: dateOfBirthController.text.trim().isNotEmpty
            ? dateOfBirthController.text.trim()
            : null,
      );

      // Also update phone if changed
      if (phoneController.text.trim() != _originalUser.phoneNumber) {
        await _firestoreService.updateUserPhone(
          uid: uid,
          phoneNumber: phoneController.text.trim(),
        );
      }

      if (success) {
        _hasChanges = false;
      } else {
        _errorMessage = 'Failed to save changes. Please try again.';
      }

      return success;
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }
}
