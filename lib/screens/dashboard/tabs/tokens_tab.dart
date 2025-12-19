// lib/screens/dashboard/tabs/tokens_tab.dart

import 'package:flutter/material.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';

class TokensTab extends StatefulWidget {
  final String uid;
  final VoidCallback? onConvert;

  const TokensTab({super.key, required this.uid, this.onConvert});

  @override
  State<TokensTab> createState() => _TokensTabState();
}

class _TokensTabState extends State<TokensTab>
    with SingleTickerProviderStateMixin {
  late final FirestoreService _firestoreService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
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

        final tokenCount = snapshot.data?.financialProfile.tokenBalance ?? 0;

        if (tokenCount == 0) {
          return _buildEmptyState();
        }

        return _buildTokensCard(tokenCount);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: AdminDesignSystem.cardDecoration,
      child: Center(
        child: CircularProgressIndicator(color: AdminDesignSystem.accentTeal),
      ),
    );
  }

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

  Widget _buildTokensCard(int tokenCount) {
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
                  onPressed: widget.onConvert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AdminDesignSystem.accentTeal,
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
                          color: AdminDesignSystem.accentTeal,
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

  Widget _buildEmptyState() {
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
                padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.accentTeal.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.stars_outlined,
                  size: 56,
                  color: AdminDesignSystem.accentTeal,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing20),
              Text(
                'No tokens yet',
                style: AdminDesignSystem.headingMedium.copyWith(
                  color: AdminDesignSystem.primaryNavy,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing8),
              Text(
                'Earn tokens by completing savings milestones\nand reaching your financial goals',
                style: AdminDesignSystem.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),

              // How to earn section
              Container(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.background,
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to earn tokens',
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AdminDesignSystem.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing12),
                    _buildEarnOption(
                      icon: Icons.flag,
                      title: 'Complete savings goals',
                      subtitle: 'Earn 50 tokens per goal',
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing8),
                    _buildEarnOption(
                      icon: Icons.trending_up,
                      title: 'Make investments',
                      subtitle: 'Earn 10 tokens per investment',
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing8),
                    _buildEarnOption(
                      icon: Icons.calendar_today,
                      title: 'Daily savings streak',
                      subtitle: 'Earn 5 tokens per week',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AdminDesignSystem.spacing24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to goals or savings
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminDesignSystem.accentTeal,
                    foregroundColor: Colors.white,
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
                  child: Text(
                    'Start Earning',
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarnOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
          decoration: BoxDecoration(
            color: AdminDesignSystem.accentTeal.withAlpha(38),
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
          ),
          child: Icon(icon, size: 18, color: AdminDesignSystem.accentTeal),
        ),
        const SizedBox(width: AdminDesignSystem.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AdminDesignSystem.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AdminDesignSystem.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: AdminDesignSystem.labelSmall.copyWith(
                  color: AdminDesignSystem.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
