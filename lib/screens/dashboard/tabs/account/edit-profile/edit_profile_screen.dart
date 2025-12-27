// lib/screens/dashboard/tabs/account/edit-profile/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../components/base/app_card.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../models/user_model.dart';
import '../../../../../providers/auth_provider.dart';
import '../../../../../services/firestore_service.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/profile_avatar_picker.dart';
import '../widgets/profile_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const EditProfileScreen({super.key, required this.authProvider});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late EditProfileController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _initialized = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeController(UserModel user) {
    if (!_initialized) {
      _controller.initialize(user);
      _initialized = true;
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: FirestoreService().getUserStream(
        widget.authProvider.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_initialized) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(null),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(null),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.warmRed),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Unable to load profile',
                    style: AppTextTheme.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        _initializeController(user);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(user),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => _buildBody(user),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel? user) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.deepNavy),
        onPressed: () => _handleBackPress(),
      ),
      title: Text(
        'Edit Profile',
        style: AppTextTheme.heading3.copyWith(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      actions: [
        if (user != null)
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              // Use GestureDetector + Container instead of TextButton
              return GestureDetector(
                onTap: _controller.hasChanges ? () => _saveProfile() : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: _controller.hasChanges
                          ? AppColors.primaryOrange
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBody(UserModel user) {
    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.smPlus),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Error message
                if (_controller.errorMessage != null) ...[
                  _buildErrorBanner(),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Avatar section
                StandardCard(
                  child: ProfileAvatarPicker(
                    currentImageUrl: user.profilePic,
                    initials: _getInitials(user),
                    isLoading: _isUploadingImage,
                    onPickImage: () => _showImagePicker(user),
                    onRemoveImage: user.profilePic != null
                        ? () => _removeProfileImage(user)
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Personal Info section
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: AppSpacing.md),
                StandardCard(
                  child: Column(
                    children: [
                      ProfileTextField(
                        label: 'First Name',
                        controller: _controller.firstNameController,
                        prefixIcon: Icons.person_outline,
                        hintText: 'Enter your first name',
                        validator: _controller.validateFirstName,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ProfileTextField(
                        label: 'Last Name',
                        controller: _controller.lastNameController,
                        prefixIcon: Icons.person_outline,
                        hintText: 'Enter your last name',
                        validator: _controller.validateLastName,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ProfileTextField(
                        label: 'Date of Birth',
                        controller: _controller.dateOfBirthController,
                        prefixIcon: Icons.cake_outlined,
                        hintText: 'DD/MM/YYYY',
                        validator: _controller.validateDateOfBirth,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d/\-]')),
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Contact Info section
                _buildSectionHeader('Contact Information'),
                const SizedBox(height: AppSpacing.md),
                StandardCard(
                  child: Column(
                    children: [
                      // Email is read-only
                      ProfileInfoRow(
                        label: 'Email Address',
                        value: user.email,
                        icon: Icons.email_outlined,
                        helperText: 'Contact support to change your email',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ProfileTextField(
                        label: 'Phone Number',
                        controller: _controller.phoneController,
                        prefixIcon: Icons.phone_outlined,
                        hintText: '+234 800 000 0000',
                        validator: _controller.validatePhone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d\s\+\-]'),
                          ),
                          LengthLimitingTextInputFormatter(15),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Location section
                _buildSectionHeader('Location'),
                const SizedBox(height: AppSpacing.md),
                StandardCard(
                  child: Column(
                    children: [
                      ProfileDropdownField(
                        label: 'Country',
                        value: _controller.selectedCountry,
                        items: EditProfileController.supportedCountries,
                        hintText: 'Select your country',
                        prefixIcon: Icons.public,
                        onChanged: (value) => _controller.setCountry(value),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ProfileTextField(
                        label: 'Address',
                        controller: _controller.addressController,
                        prefixIcon: Icons.location_on_outlined,
                        hintText: 'Enter your address',
                        validator: _controller.validateAddress,
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Save button (mobile-friendly)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _controller.hasChanges && !_controller.isLoading
                        ? () => _saveProfile()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.divider,
                      disabledForegroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: _controller.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextTheme.heading3.copyWith(
        color: AppColors.deepNavy,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmRed.withAlpha(25),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.warmRed.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.warmRed, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _controller.errorMessage!,
              style: TextStyle(color: AppColors.warmRed, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () => _controller.clearError(),
            child: Icon(Icons.close, color: AppColors.warmRed, size: 18),
          ),
        ],
      ),
    );
  }

  String _getInitials(UserModel user) {
    final first = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0] : '';
    return '$first$last';
  }

  // ==================== ACTIONS ====================

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = widget.authProvider.currentUser!.uid;
    final success = await _controller.saveProfile(uid);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text('Profile updated successfully'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _handleBackPress() {
    if (_controller.hasChanges) {
      _showDiscardDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Discard Changes?',
          style: AppTextTheme.heading3.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: AppTextTheme.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Keep Editing',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('Discard', style: TextStyle(color: AppColors.warmRed)),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(UserModel user) {
    ImageSourceBottomSheet.show(
      context,
      hasExistingImage: user.profilePic != null,
      onCameraSelected: () => _pickImage(ImageSource.camera),
      onGallerySelected: () => _pickImage(ImageSource.gallery),
      onRemoveSelected: user.profilePic != null
          ? () => _removeProfileImage(user)
          : null,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isUploadingImage = true);

    // TODO: Implement actual image picking with image_picker package
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isUploadingImage = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image picker requires image_picker package'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeProfileImage(UserModel user) async {
    setState(() => _isUploadingImage = true);

    try {
      final uid = widget.authProvider.currentUser!.uid;
      await FirestoreService().updateUserProfile(
        uid: uid,
        firstName: user.firstName,
        lastName: user.lastName,
        profilePic: '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo removed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove photo'),
            backgroundColor: AppColors.warmRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }
}

// Placeholder enum for image source
enum ImageSource { camera, gallery }
