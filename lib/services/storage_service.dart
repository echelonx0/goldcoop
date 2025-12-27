// lib/services/storage_service.dart

import 'dart:io';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== PAYMENT PROOF UPLOADS ====================

  /// Upload payment proof to Firebase Storage
  /// Returns download URL on success, null on failure
  Future<String?> uploadPaymentProof({
    required String userId,
    required String proofId,
    required File file,
  }) async {
    try {
      final extension = path.extension(file.path);
      final fileName = '$proofId$extension';
      final ref = _storage.ref().child('payment_proofs/$userId/$fileName');

      // Upload with metadata
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(extension),
          customMetadata: {
            'userId': userId,
            'proofId': proofId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      log('✅ Payment proof uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('❌ Error uploading payment proof: $e');
      return null;
    }
  }

  /// Delete payment proof from Storage
  Future<bool> deletePaymentProof(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      log('✅ Payment proof deleted: $fileUrl');
      return true;
    } catch (e) {
      log('❌ Error deleting payment proof: $e');
      return false;
    }
  }

  /// Get file size before upload (validation)
  Future<int> getFileSize(File file) async {
    try {
      final bytes = await file.length();
      return bytes;
    } catch (e) {
      log('❌ Error getting file size: $e');
      return 0;
    }
  }

  /// Validate file size (5MB limit)
  bool isFileSizeValid(int bytes) {
    const maxSizeBytes = 5 * 1024 * 1024; // 5MB
    return bytes > 0 && bytes <= maxSizeBytes;
  }

  // ==================== HELPERS ====================

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  /// Get file extension from File object
  String getFileExtension(File file) {
    return path.extension(file.path).toLowerCase();
  }

  /// Validate allowed extensions
  bool isFileTypeAllowed(File file) {
    final extension = getFileExtension(file);
    const allowedExtensions = ['.pdf', '.jpg', '.jpeg', '.png'];
    return allowedExtensions.contains(extension);
  }
}
