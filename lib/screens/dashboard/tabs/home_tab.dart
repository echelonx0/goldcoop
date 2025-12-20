// lib/screens/dashboard/tabs/home_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';

class HomeTab extends StatefulWidget {
  final String uid;
  final VoidCallback? onTopUp;
  final VoidCallback? onInvest;
  final VoidCallback? onWithdraw;
  final VoidCallback? onHistory;
  final VoidCallback? onTopUpAirtime;
  final VoidCallback? onLearn;

  const HomeTab({
    super.key,
    required this.uid,
    this.onTopUp,
    this.onInvest,
    this.onWithdraw,
    this.onHistory,
    this.onTopUpAirtime,
    this.onLearn,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final FirestoreService _firestoreService;
  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _firestoreService.getUserStream(widget.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        final user = userSnapshot.data;
        if (user == null) {
          return Center(
            child: Text(
              'Unable to load user data',
              style: AdminDesignSystem.bodyMedium.copyWith(
                color: AdminDesignSystem.statusError,
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _AnimatedBalanceCard(
                    user: user,
                    currencyFormatter: _currencyFormatter,
                    onTopUp: widget.onTopUp,
                    onInvest: widget.onInvest,
                    onWithdraw: widget.onWithdraw,
                    onHistory: widget.onHistory,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing24),
                  _ActionCardsGrid(
                    onInvest: widget.onInvest,
                    onWithdraw: widget.onWithdraw,
                    onTopUpAirtime: widget.onTopUpAirtime,
                    onLearn: widget.onLearn,
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ==================== ANIMATED BALANCE CARD ====================

class _AnimatedBalanceCard extends StatefulWidget {
  final UserModel user;
  final NumberFormat currencyFormatter;
  final VoidCallback? onTopUp;
  final VoidCallback? onInvest;
  final VoidCallback? onWithdraw;
  final VoidCallback? onHistory;

  const _AnimatedBalanceCard({
    required this.user,
    required this.currencyFormatter,
    this.onTopUp,
    this.onInvest,
    this.onWithdraw,
    this.onHistory,
  });

  @override
  State<_AnimatedBalanceCard> createState() => _AnimatedBalanceCardState();
}

class _AnimatedBalanceCardState extends State<_AnimatedBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.user.financialProfile.accountBalance;

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
                          'Total Balance',
                          style: AdminDesignSystem.labelMedium.copyWith(
                            color: Colors.white.withAlpha(179),
                          ),
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing8),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: balance),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              widget.currencyFormatter.format(value),
                              style: AdminDesignSystem.displayLarge.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing4),
                        Text(
                          'Welcome back, ${widget.user.firstName}',
                          style: AdminDesignSystem.bodySmall.copyWith(
                            color: Colors.white.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius12,
                      ),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),
              Row(
                children: [
                  _AnimatedActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Top up',
                    onPressed: widget.onTopUp,
                    delay: 200,
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing8),
                  _AnimatedActionButton(
                    icon: Icons.trending_up,
                    label: 'Invest',
                    onPressed: widget.onInvest,
                    delay: 300,
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing8),
                  _AnimatedActionButton(
                    icon: Icons.arrow_circle_down_outlined,
                    label: 'Withdraw',
                    onPressed: widget.onWithdraw,
                    delay: 400,
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing8),
                  _AnimatedActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'History',
                    onPressed: widget.onHistory,
                    delay: 500,
                  ),
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

// ==================== ACTION CARDS GRID ====================

class _ActionCardsGrid extends StatelessWidget {
  final VoidCallback? onInvest;
  final VoidCallback? onWithdraw;
  final VoidCallback? onTopUpAirtime;
  final VoidCallback? onLearn;

  const _ActionCardsGrid({
    this.onInvest,
    this.onWithdraw,
    this.onTopUpAirtime,
    this.onLearn,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AdminDesignSystem.spacing12,
      crossAxisSpacing: AdminDesignSystem.spacing12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95,
      children: [
        _AnimatedActionCard(
          icon: Icons.trending_up,
          title: 'Invest',
          subtitle: 'Grow your wealth',
          color: AdminDesignSystem.accentTeal,
          delay: 200,
          onPressed: onInvest,
        ),
        _AnimatedActionCard(
          icon: Icons.arrow_circle_down_outlined,
          title: 'Withdraw',
          subtitle: 'Get your funds',
          color: const Color(0xFF9B59B6),
          delay: 300,
          onPressed: onWithdraw,
        ),
        _AnimatedActionCard(
          icon: Icons.phone_android,
          title: 'Buy Airtime',
          subtitle: 'Top up instantly',
          color: const Color(0xFF3498DB),
          delay: 400,
          onPressed: onTopUpAirtime,
        ),
        _AnimatedActionCard(
          icon: Icons.school_outlined,
          title: 'Learn',
          subtitle: 'Financial tips',
          color: const Color(0xFFF39C12),
          delay: 500,
          onPressed: onLearn,
        ),
      ],
    );
  }
}

// ==================== ANIMATED ACTION CARD ====================

class _AnimatedActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int delay;
  final VoidCallback? onPressed;

  const _AnimatedActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.delay,
    this.onPressed,
  });

  @override
  State<_AnimatedActionCard> createState() => _AnimatedActionCardState();
}

class _AnimatedActionCardState extends State<_AnimatedActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            child: Container(
              decoration: AdminDesignSystem.cardDecoration,
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(38),
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius12,
                      ),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 32),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  Text(
                    widget.title,
                    style: AdminDesignSystem.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AdminDesignSystem.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing4),
                  Text(
                    widget.subtitle,
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textTertiary,
                    ),
                    textAlign: TextAlign.center,
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
