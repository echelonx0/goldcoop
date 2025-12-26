// lib/screens/dashboard/tabs/home_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/user_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/token_conversion_service.dart';
import '../../modals/token_conversion_modal.dart';
import 'action_card.dart';
import 'balance_card-skeleton.dart';
import 'token_balance_card.dart';
import 'fiat_balance_card.dart';

class HomeTab extends StatefulWidget {
  final String uid;
  final VoidCallback? onTapGoals;
  final VoidCallback? onInvest;
  final VoidCallback? onWithdraw;
  final VoidCallback? onHistory;
  final VoidCallback? onTopUpAirtime;
  final VoidCallback? onLearn;

  const HomeTab({
    super.key,
    required this.uid,
    this.onTapGoals,
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
  late final TokenConversionService _tokenService;
  late final PageController _pageController;
  late final Stream<UserModel?> _userStream;

  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _tokenService = TokenConversionService();
    _pageController = PageController(initialPage: _currentPage);

    // Convert to broadcast stream so multiple widgets can listen
    _userStream = _firestoreService
        .getUserStream(widget.uid)
        .asBroadcastStream();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _userStream,
      builder: (context, snapshot) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _BalanceCardsSection(
                    user: snapshot.data,
                    isLoading:
                        snapshot.connectionState == ConnectionState.waiting,
                    hasError:
                        snapshot.hasError ||
                        (snapshot.connectionState == ConnectionState.active &&
                            snapshot.data == null),
                    pageController: _pageController,
                    currentPage: _currentPage,
                    currencyFormatter: _currencyFormatter,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    onTapGoals: widget.onTapGoals,
                    onInvest: widget.onInvest,
                    onWithdraw: widget.onWithdraw,
                    onHistory: widget.onHistory,
                    onConvertTokens: _showConversionModal,
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

  void _showConversionModal(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TokenConversionModal(
        user: user,
        tokenConversionService: _tokenService,
        onSuccess: (conversionId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Conversion submitted successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AdminDesignSystem.statusActive,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

// ==================== BALANCE CARDS SECTION ====================

class _BalanceCardsSection extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;
  final bool hasError;
  final PageController pageController;
  final int currentPage;
  final NumberFormat currencyFormatter;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onTapGoals;
  final VoidCallback? onInvest;
  final VoidCallback? onWithdraw;
  final VoidCallback? onHistory;
  final void Function(UserModel user) onConvertTokens;

  const _BalanceCardsSection({
    required this.user,
    required this.isLoading,
    required this.hasError,
    required this.pageController,
    required this.currentPage,
    required this.currencyFormatter,
    required this.onPageChanged,
    this.onTapGoals,
    this.onInvest,
    this.onWithdraw,
    this.onHistory,
    required this.onConvertTokens,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          PageView(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            pageSnapping: true,
            onPageChanged: onPageChanged,
            children: [_buildFiatCard(), _buildTokenCard()],
          ),
          Positioned(
            top: AdminDesignSystem.spacing16,
            right: AdminDesignSystem.spacing16,
            child: _PageIndicator(pageCount: 2, currentPage: currentPage),
          ),
        ],
      ),
    );
  }

  Widget _buildFiatCard() {
    if (isLoading) {
      return BalanceCardSkeleton.fiat();
    }

    if (hasError || user == null) {
      return BalanceCardError.fiat();
    }

    return FiatBalanceCard(
      user: user!,
      currencyFormatter: currencyFormatter,
      onGoalsTapped: onTapGoals,
      onInvest: onInvest,
      onWithdraw: onWithdraw,
      onHistory: onHistory,
    );
  }

  Widget _buildTokenCard() {
    if (isLoading) {
      return BalanceCardSkeleton.token();
    }

    if (hasError || user == null) {
      return BalanceCardError.token();
    }

    return TokensBalanceCard(
      user: user!,
      onEarnTokens: onTapGoals,
      onConvertTokens: () => onConvertTokens(user!),
    );
  }
}

// ==================== PAGE INDICATOR ====================

class _PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const _PageIndicator({required this.pageCount, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing8,
        vertical: AdminDesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing4 / 2,
            ),
            width: isActive ? 8 : 6,
            height: isActive ? 8 : 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withAlpha(128),
              shape: BoxShape.circle,
            ),
          );
        }),
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
        AnimatedActionCard(
          icon: Icons.trending_up,
          title: 'Invest',
          subtitle: 'Grow your wealth',
          color: AdminDesignSystem.accentTeal,
          delay: 200,
          onPressed: onInvest,
        ),
        AnimatedActionCard(
          icon: Icons.arrow_circle_down_outlined,
          title: 'Withdraw',
          subtitle: 'Get your funds',
          color: const Color(0xFF9B59B6),
          delay: 300,
          onPressed: onWithdraw,
        ),
        AnimatedActionCard(
          icon: Icons.school_outlined,
          title: 'Learning Center',
          subtitle: 'Improve your financial knowledge',
          color: const Color(0xFF3498DB),
          delay: 400,
          onPressed: onLearn,
        ),
        AnimatedActionCard(
          icon: Icons.sim_card_outlined,
          title: 'Integrations',
          subtitle: 'Other Tools',
          color: const Color(0xFFF39C12),
          delay: 500,
          onPressed: onTopUpAirtime,
        ),
      ],
    );
  }
}
