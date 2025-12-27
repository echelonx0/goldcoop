// lib/screens/dashboard/tabs/account/widgets/profile_avatar_picker.dart
// Avatar picker widget with camera/gallery options

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileAvatarPicker extends StatelessWidget {
  final String? currentImageUrl;
  final String initials;
  final bool isLoading;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  const ProfileAvatarPicker({
    super.key,
    this.currentImageUrl,
    required this.initials,
    this.isLoading = false,
    required this.onPickImage,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryOrange.withAlpha(25),
                  border: Border.all(
                    color: AppColors.primaryOrange.withAlpha(51),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepNavy.withAlpha(13),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildAvatarContent(),
                ),
              ),

              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: isLoading ? null : onPickImage,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isLoading ? Icons.hourglass_empty : Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tap to change photo',
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (currentImageUrl != null && onRemoveImage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: isLoading ? null : onRemoveImage,
              child: Text(
                'Remove photo',
                style: TextStyle(
                  color: AppColors.warmRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryOrange,
        ),
      );
    }

    if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      return Image.network(
        currentImageUrl!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryOrange,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsAvatar();
        },
      );
    }

    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: AppColors.primaryOrange,
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Bottom sheet for image source selection
class ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;
  final VoidCallback? onRemoveSelected;
  final bool hasExistingImage;

  const ImageSourceBottomSheet({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
    this.onRemoveSelected,
    this.hasExistingImage = false,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
    VoidCallback? onRemoveSelected,
    bool hasExistingImage = false,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        onCameraSelected: () {
          Navigator.pop(context);
          onCameraSelected();
        },
        onGallerySelected: () {
          Navigator.pop(context);
          onGallerySelected();
        },
        onRemoveSelected: onRemoveSelected != null
            ? () {
                Navigator.pop(context);
                onRemoveSelected();
              }
            : null,
        hasExistingImage: hasExistingImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Change Profile Photo',
              style: AppTextTheme.heading3.copyWith(
                color: AppColors.deepNavy,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Options
            _buildOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              onTap: onCameraSelected,
            ),
            _buildOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: onGallerySelected,
            ),
            if (hasExistingImage && onRemoveSelected != null)
              _buildOption(
                icon: Icons.delete_outline,
                label: 'Remove Photo',
                onTap: onRemoveSelected!,
                isDestructive: true,
              ),

            const SizedBox(height: AppSpacing.md),

            // Cancel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.warmRed : AppColors.deepNavy;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isDestructive
                          ? AppColors.warmRed
                          : AppColors.primaryOrange)
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTextTheme.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withAlpha(128),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
