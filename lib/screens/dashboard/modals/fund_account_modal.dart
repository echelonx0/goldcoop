// lib/screens/dashboard/modals/fund_account_modal.dart

import 'package:flutter/material.dart';
import '../../../core/theme/admin_design_system.dart';

class FundAccountModal extends StatelessWidget {
  final String userId;
  final VoidCallback onViewInstructions;
  final VoidCallback onUploadProof;
  final VoidCallback onClose;

  const FundAccountModal({
    super.key,
    required this.userId,
    required this.onViewInstructions,
    required this.onUploadProof,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AdminDesignSystem.radius16),
          topRight: Radius.circular(AdminDesignSystem.radius16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AdminDesignSystem.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),
                Text(
                  'Fund Your Account',
                  style: AdminDesignSystem.headingMedium.copyWith(
                    color: AdminDesignSystem.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  'Choose how you\'d like to proceed',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Options
          Padding(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            child: Column(
              children: [
                // Option 1: View Deposit Instructions
                _FundOption(
                  icon: Icons.info_outline,
                  title: 'View Deposit Instructions',
                  subtitle: 'Get bank details and payment info',
                  onTap: () {
                    Navigator.pop(context);
                    onViewInstructions();
                  },
                  delay: 100,
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),

                // Option 2: Upload Proof of Payment
                _FundOption(
                  icon: Icons.upload_file_outlined,
                  title: 'Upload Proof of Payment',
                  subtitle: 'Already sent funds? Upload receipt',
                  onTap: () {
                    Navigator.pop(context);
                    onUploadProof();
                  },
                  delay: 200,
                ),
              ],
            ),
          ),

          const SizedBox(height: AdminDesignSystem.spacing8),

          // Close button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing16,
              vertical: AdminDesignSystem.spacing8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onClose,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AdminDesignSystem.spacing16,
                  ),
                  side: BorderSide(color: AdminDesignSystem.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius12,
                    ),
                  ),
                ),
                child: Text(
                  'Close',
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),
        ],
      ),
    );
  }
}

// ==================== FUND OPTION TILE ====================

class _FundOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int delay;

  const _FundOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_FundOption> createState() => _FundOptionState();
}

class _FundOptionState extends State<_FundOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AdminDesignSystem.divider),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    decoration: BoxDecoration(
                      color: AdminDesignSystem.accentTeal.withAlpha(38),
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius12,
                      ),
                    ),
                    padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                    child: Icon(
                      widget.icon,
                      color: AdminDesignSystem.accentTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing16),

                  // Title & subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AdminDesignSystem.bodyLarge.copyWith(
                            color: AdminDesignSystem.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing4),
                        Text(
                          widget.subtitle,
                          style: AdminDesignSystem.bodySmall.copyWith(
                            color: AdminDesignSystem.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  Icon(
                    Icons.chevron_right,
                    color: AdminDesignSystem.textTertiary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
