// lib/screens/dashboard/tabs/home_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/user_model.dart';
import '../../../../services/firestore_service.dart';
import 'action_card.dart';
import 'user_balance_card.dart';

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
                  AnimatedBalanceCard(
                    user: user,
                    currencyFormatter: _currencyFormatter,
                    onGoalsTapped: widget.onTapGoals,
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
          onPressed: () {},
        ),
      ],
    );
  }
}
