// lib/screens/dashboard/tabs/tokens_tab.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/user_model.dart';
import '../../../models/token_conversion_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/token_conversion_service.dart';
import '../modals/token_conversion_modal.dart';
import 'tokens/empty_state.dart';

class TokensTab extends StatefulWidget {
  final String uid;

  const TokensTab({super.key, required this.uid});

  @override
  State<TokensTab> createState() => _TokensTabState();
}

class _TokensTabState extends State<TokensTab>
    with SingleTickerProviderStateMixin {
  late final FirestoreService _firestoreService;
  late final TokenConversionService _tokenService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _tokenService = TokenConversionService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              const SizedBox(height: AdminDesignSystem.spacing24),
              _buildContent(),
            ]),
          ),
        ),
      ],
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Tokens',
            style: AdminDesignSystem.headingLarge.copyWith(
              color: AdminDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing4),
          Text(
            'Convert tokens to airtime or rewards',
            style: AdminDesignSystem.bodySmall,
          ),
        ],
      ),
    );
  }

  // ==================== CONTENT ====================
  Widget _buildContent() {
    return StreamBuilder<UserModel?>(
      stream: _firestoreService.getUserStream(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final user = snapshot.data;
        final tokenCount = user?.financialProfile.tokenBalance ?? 0;

        if (tokenCount == 0) {
          return TokensEmptyState(
            onStartEarning: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to goals coming soon')),
              );
            },
          );
        }

        return Column(
          children: [
            _buildTokensCard(tokenCount, user),
            const SizedBox(height: AdminDesignSystem.spacing32),
            _buildConversionHistory(),
          ],
        );
      },
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: AdminDesignSystem.cardDecoration,
      child: Center(
        child: CircularProgressIndicator(color: AdminDesignSystem.accentTeal),
      ),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
          decoration: AdminDesignSystem.cardDecoration,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.statusError.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AdminDesignSystem.statusError,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing16),
              Text(
                'Failed to load tokens',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  color: AdminDesignSystem.statusError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TOKENS CARD ====================
  Widget _buildTokensCard(int tokenCount, UserModel? user) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AdminDesignSystem.accentTeal,
                AdminDesignSystem.accentTeal.withAlpha(230),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
            boxShadow: [
              BoxShadow(
                color: AdminDesignSystem.accentTeal.withAlpha(51),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AdminDesignSystem.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Tokens',
                          style: AdminDesignSystem.labelMedium.copyWith(
                            color: Colors.white.withAlpha(179),
                          ),
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing12),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: tokenCount),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: AdminDesignSystem.displayLarge.copyWith(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing8),
                        Text(
                          '1 token = ₦10 value',
                          style: AdminDesignSystem.bodySmall.copyWith(
                            color: Colors.white.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius16,
                      ),
                    ),
                    child: Icon(Icons.stars, size: 40, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // Info cards
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Token Value',
                      value: '₦${(tokenCount * 10).toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.phone_android,
                      label: 'Airtime',
                      value: '₦${(tokenCount * 10).toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AdminDesignSystem.spacing20),

              // Convert button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: tokenCount > 0
                      ? () => _showConversionModal(user)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AdminDesignSystem.accentTeal,
                    disabledBackgroundColor: Colors.white.withAlpha(128),
                    padding: const EdgeInsets.symmetric(
                      vertical: AdminDesignSystem.spacing16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius12,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz, size: 20),
                      const SizedBox(width: AdminDesignSystem.spacing8),
                      Text(
                        'Convert to Airtime',
                        style: AdminDesignSystem.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokenCount > 0
                              ? AdminDesignSystem.accentTeal
                              : AdminDesignSystem.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== CONVERSION HISTORY ====================
  Widget _buildConversionHistory() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Conversions',
            style: AdminDesignSystem.headingMedium.copyWith(
              color: AdminDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),
          StreamBuilder<List<TokenConversionModel>>(
            stream: _tokenService.getUserConversionsStream(widget.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    height: 100,
                    child: CircularProgressIndicator(
                      color: AdminDesignSystem.accentTeal,
                    ),
                  ),
                );
              }

              final conversions = snapshot.data ?? [];

              if (conversions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AdminDesignSystem.spacing20,
                  ),
                  child: Center(
                    child: Text(
                      'No conversions yet',
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: conversions.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AdminDesignSystem.spacing12),
                itemBuilder: (context, index) {
                  final conversion = conversions[index];
                  return DelayedDisplay(
                    delay: Duration(milliseconds: 450 + (index * 100)),
                    child: _ConversionTile(
                      conversion: conversion,
                      onRetry: () => _retryConversion(conversion),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== INFO CARD ====================
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withAlpha(179), size: 20),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Text(
            label,
            style: AdminDesignSystem.labelSmall.copyWith(
              color: Colors.white.withAlpha(179),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing4),
          Text(
            value,
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MODAL ====================
  void _showConversionModal(UserModel? user) {
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load user data')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TokenConversionModal(
        user: user,
        tokenConversionService: _tokenService,
        onSuccess: (conversionId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversion submitted successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  // ==================== RETRY ====================
  void _retryConversion(TokenConversionModel conversion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retry Conversion'),
        content: Text(
          'Retry converting ${conversion.tokenCount} tokens to airtime?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _tokenService.retryConversion(
                conversion.conversionId,
              );
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Retry submitted' : 'Failed to retry',
                  ),
                ),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ==================== CONVERSION TILE ====================
class _ConversionTile extends StatelessWidget {
  final TokenConversionModel conversion;
  final VoidCallback onRetry;

  const _ConversionTile({required this.conversion, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(conversion.status);
    final statusIcon = _getStatusIcon(conversion.status);

    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(12),
        border: Border.all(color: statusColor.withAlpha(51)),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${conversion.tokenCount} tokens → ₦${conversion.nairaValue.toStringAsFixed(0)} airtime',
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AdminDesignSystem.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing4),
                    Text(
                      conversion.displayPhoneNumber,
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminDesignSystem.spacing8,
                  vertical: AdminDesignSystem.spacing4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      conversion.status.name.capitalize(),
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${conversion.networkName} • ${_formatDate(conversion.requestedAt)}',
                style: AdminDesignSystem.bodySmall.copyWith(
                  color: AdminDesignSystem.textTertiary,
                ),
              ),
              if (conversion.canRetry)
                GestureDetector(
                  onTap: onRetry,
                  child: Text(
                    'Retry',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: AdminDesignSystem.accentTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ConversionStatus status) {
    switch (status) {
      case ConversionStatus.pending:
        return Colors.orange;
      case ConversionStatus.approved:
        return Colors.blue;
      case ConversionStatus.processing:
        return Colors.amber;
      case ConversionStatus.completed:
        return Colors.green;
      case ConversionStatus.failed:
        return AdminDesignSystem.statusError;
      case ConversionStatus.cancelled:
        return AdminDesignSystem.textSecondary;
    }
  }

  IconData _getStatusIcon(ConversionStatus status) {
    switch (status) {
      case ConversionStatus.pending:
        return Icons.schedule;
      case ConversionStatus.approved:
        return Icons.check_circle_outline;
      case ConversionStatus.processing:
        return Icons.hourglass_bottom;
      case ConversionStatus.completed:
        return Icons.check_circle;
      case ConversionStatus.failed:
        return Icons.error_outline;
      case ConversionStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, h:mm a').format(date);
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
