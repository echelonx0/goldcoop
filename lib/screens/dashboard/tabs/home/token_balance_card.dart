// lib/screens/dashboard/tabs/tokens_balance_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/user_model.dart';
import '../../../../services/firestore_service.dart';

class TokensBalanceCard extends StatefulWidget {
  final UserModel user;

  final VoidCallback? onEarnTokens;
  final VoidCallback? onConvertTokens;

  const TokensBalanceCard({
    super.key,
    required this.user,

    this.onEarnTokens,
    this.onConvertTokens,
  });

  @override
  State<TokensBalanceCard> createState() => _TokensBalanceCardState();
}

class _TokensBalanceCardState extends State<TokensBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late final FirestoreService _firestoreService;

  late int _displayTokenCount;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();

    // Initialize token count (ensure minimum 50)
    _displayTokenCount = widget.user.financialProfile.tokenBalance ?? 0;

    // If tokens are 0 or not set, initialize with 50 tokens
    if (_displayTokenCount == 0) {
      _initializeTokens();
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  /// Initialize user with 50 tokens on first app download
  Future<void> _initializeTokens() async {
    try {
      final success = await _firestoreService.updateFinancialProfile(
        uid: widget.user.uid,
        tokenBalance: 50,
      );

      if (success && mounted) {
        setState(() {
          _displayTokenCount = 50;
        });
      }
    } catch (e) {
      print('Error initializing tokens: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokenCount = _displayTokenCount;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
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
                color: AdminDesignSystem.accentTeal.withAlpha(38),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
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
                          'Token Balance',
                          style: AdminDesignSystem.labelMedium.copyWith(
                            color: Colors.white.withAlpha(179),
                          ),
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing8),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: tokenCount),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: AdminDesignSystem.displayLarge.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),
              Row(
                children: [
                  _AnimatedActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Transfer Tokens',
                    onPressed: () {},
                    delay: 200,
                  ),
                  if (tokenCount > 0) ...[
                    const SizedBox(width: AdminDesignSystem.spacing8),
                    _AnimatedActionButton(
                      icon: Icons.swap_horiz,
                      label: 'Convert',
                      onPressed: widget.onConvertTokens,
                      delay: 300,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ANIMATED ACTION BUTTON ====================

class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final int delay;

  const _AnimatedActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.delay,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

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
    return Expanded(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AdminDesignSystem.spacing12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 24),
                  const SizedBox(height: AdminDesignSystem.spacing4),
                  Text(
                    widget.label,
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
