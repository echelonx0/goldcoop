// lib/screens/dashboard/modals/upload_proof_modal.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../components/base/app_button.dart';
import '../../../services/deposit_service.dart';

class UploadProofModal extends StatefulWidget {
  final String transactionId;
  final String? goalId;
  final double amount;
  final String? goalTitle;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const UploadProofModal({
    super.key,
    required this.transactionId,
    this.goalId,
    required this.amount,
    this.goalTitle,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<UploadProofModal> createState() => _UploadProofModalState();
}

class _UploadProofModalState extends State<UploadProofModal> {
  late final DepositService _depositService;
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  String? _errorMessage;

  // Get current user ID
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _depositService = DepositService();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        setState(() {
          _selectedFile = file;
          _fileName = result.files.single.name;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick file. Please try again.';
      });
    }
  }

  Future<void> _uploadProof() async {
    if (_selectedFile == null) {
      setState(() => _errorMessage = 'Please select a file first');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Upload proof using DepositService (auto-detects user from Firebase Auth)
      final result = await _depositService.uploadPaymentProof(
        userId: _userId,
        transactionId: widget.transactionId,
        file: _selectedFile!,
        goalId: widget.goalId,
        metadata: {
          'amount': widget.amount,
          if (widget.goalTitle != null) 'goalTitle': widget.goalTitle,
        },
      );

      if (result.success) {
        widget.onSuccess();
      } else {
        throw Exception(result.errorMessage ?? 'Upload failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.large),
          topRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title
          DelayedDisplay(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Upload Proof of Payment',
              style: AppTextTheme.heading3.copyWith(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          DelayedDisplay(
            delay: const Duration(milliseconds: 150),
            child: Text(
              'Upload your bank deposit slip or transfer receipt',
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Amount display
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.goalTitle ?? 'General Savings',
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '₦${widget.amount.toStringAsFixed(0)}',
                    style: AppTextTheme.heading2.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // File picker
          DelayedDisplay(
            delay: const Duration(milliseconds: 250),
            child: GestureDetector(
              onTap: _isUploading ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: _selectedFile != null
                      ? AppColors.tealSuccess.withAlpha(25)
                      : AppColors.backgroundNeutral,
                  border: Border.all(
                    color: _selectedFile != null
                        ? AppColors.tealSuccess
                        : AppColors.borderLight,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.check_circle
                          : Icons.upload_file,
                      size: 48,
                      color: _selectedFile != null
                          ? AppColors.tealSuccess
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _selectedFile != null ? _fileName! : 'Tap to select file',
                      style: AppTextTheme.bodyRegular.copyWith(
                        color: _selectedFile != null
                            ? AppColors.tealSuccess
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'PDF, JPG, or PNG (Max 5MB)',
                      style: AppTextTheme.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warmRed.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.warmRed,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.warmRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: _isUploading ? null : widget.onCancel,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: _isUploading ? 'Uploading...' : 'Upload',
                    onPressed: _isUploading ? null : _uploadProof,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
