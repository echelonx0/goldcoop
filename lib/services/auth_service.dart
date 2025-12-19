// lib/services/firebase_auth_service.dart
// Firebase authentication service wrapper

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // ==================== SIGN UP ====================
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Failed to create user');
      }

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'displayName': '$firstName $lastName',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isEmailVerified': false,
        'profileComplete': false,
      });

      // Send email verification
      await user.sendEmailVerification();

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  // ==================== SIGN IN ====================
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Failed to sign in');
      }

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  // ==================== PASSWORD RESET ====================
  Future<AuthResult> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  // ==================== SIGN OUT ====================
  Future<AuthResult> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return AuthResult.success(null, message: 'Signed out successfully');
    } catch (e) {
      return AuthResult.failure('Failed to sign out: $e');
    }
  }

  // ==================== VERIFY EMAIL ====================
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      await user.sendEmailVerification();
      return AuthResult.success(
        null,
        message: 'Verification email sent',
      );
    } catch (e) {
      return AuthResult.failure('Failed to send verification email: $e');
    }
  }

  // ==================== CHECK EMAIL VERIFICATION ====================
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      await user.reload();
      return user.emailVerified;
    } catch (e) {
      return false;
    }
  }

  // ==================== UPDATE USER PROFILE ====================
  Future<AuthResult> updateUserProfile({
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      // Update Firebase Auth display name
      await user.updateDisplayName('$firstName $lastName');

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'displayName': '$firstName $lastName',
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('Failed to update profile: $e');
    }
  }

  // ==================== GET USER DATA ====================
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // Stream for user data
  Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      return doc.data();
    });
  }

  // ==================== UPDATE PASSWORD ====================
  Future<AuthResult> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return AuthResult.success(user, message: 'Password updated successfully');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to update password: $e');
    }
  }

  // ==================== DELETE ACCOUNT ====================
  Future<AuthResult> deleteAccount({
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user from Firebase Auth
      await user.delete();

      return AuthResult.success(null, message: 'Account deleted');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to delete account: $e');
    }
  }

  // ==================== ERROR HANDLING ====================
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return 'An authentication error occurred: $code';
    }
  }
}

// ==================== RESULT CLASS ====================
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? message;
  final String? errorMessage;

  AuthResult({
    required this.isSuccess,
    this.user,
    this.message,
    this.errorMessage,
  });

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult(
      isSuccess: true,
      user: user,
      message: message ?? 'Success',
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
