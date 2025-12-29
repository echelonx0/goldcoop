// // // lib/screens/dashboard/tabs/home_tab.dart

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../../../../core/theme/admin_design_system.dart';
// import '../../../../models/goals_model.dart';
// import '../../../../models/user_model.dart';
// import '../../../../services/firestore_service.dart';
// import '../../../../services/token_conversion_service.dart';
// import '../../modals/learning_center_modal.dart';
// import '../../modals/token_conversion_modal.dart';
// import '../../modals/savings_clock_modal.dart';
// import 'action_card.dart';
// import 'balance_card-skeleton.dart';
// import 'token_balance_card.dart';
// import 'fiat_balance_card.dart';

// class HomeTab extends StatefulWidget {
//   final String uid;
//   final VoidCallback? onTapGoals;
//   final VoidCallback? onInvest;
//   final VoidCallback? onWithdraw;
//   final VoidCallback? onHistory;
//   final Function(GoalModel)? onViewGoal;
//   final VoidCallback? onCreateGoal;

//   const HomeTab({
//     super.key,
//     required this.uid,
//     this.onTapGoals,
//     this.onInvest,
//     this.onWithdraw,
//     this.onHistory,
//     this.onViewGoal,
//     this.onCreateGoal,
//   });

//   @override
//   State<HomeTab> createState() => _HomeTabState();
// }

// class _HomeTabState extends State<HomeTab> {
//   late final FirestoreService _firestoreService;
//   late final TokenConversionService _tokenService;
//   late final PageController _pageController;
//   late final Stream<UserModel?> _userStream;
//   late final Stream<List<GoalModel>> _goalsStream;

//   final _currencyFormatter = NumberFormat.currency(
//     symbol: '₦',
//     decimalDigits: 0,
//   );

//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreService = FirestoreService();
//     _tokenService = TokenConversionService();
//     _pageController = PageController(initialPage: _currentPage);

//     _userStream = _firestoreService
//         .getUserStream(widget.uid)
//         .asBroadcastStream();

//     _goalsStream = _firestoreService
//         .getUserGoalsStream(widget.uid)
//         .asBroadcastStream();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<UserModel?>(
//       stream: _userStream,
//       builder: (context, snapshot) {
//         return CustomScrollView(
//           slivers: [
//             SliverPadding(
//               padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//               sliver: SliverList(
//                 delegate: SliverChildListDelegate([
//                   _BalanceCardsSection(
//                     user: snapshot.data,
//                     isLoading:
//                         snapshot.connectionState == ConnectionState.waiting,
//                     hasError:
//                         snapshot.hasError ||
//                         (snapshot.connectionState == ConnectionState.active &&
//                             snapshot.data == null),
//                     pageController: _pageController,
//                     currentPage: _currentPage,
//                     currencyFormatter: _currencyFormatter,
//                     onPageChanged: (index) {
//                       setState(() => _currentPage = index);
//                     },
//                     onTapGoals: widget.onTapGoals,
//                     onInvest: widget.onInvest,
//                     onWithdraw: widget.onWithdraw,
//                     onHistory: widget.onHistory,
//                     onConvertTokens: _showConversionModal,
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing24),
//                   _ActionCardsGrid(
//                     goalsStream: _goalsStream,
//                     onInvest: widget.onInvest,
//                     onWithdraw: widget.onWithdraw,
//                     onLearn: _showLearningCenterModal,
//                     onSavingsClock: _showSavingsClockModal,
//                   ),
//                 ]),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ==================== MODALS ====================

//   void _showConversionModal(UserModel user) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => TokenConversionModal(
//         user: user,
//         tokenConversionService: _tokenService,
//         onSuccess: (conversionId) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Conversion submitted successfully!'),
//               behavior: SnackBarBehavior.floating,
//               backgroundColor: AdminDesignSystem.statusActive,
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showSavingsClockModal(List<GoalModel> goals) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => SavingsClockModal(
//         goals: goals.where((g) => g.status == GoalStatus.active).toList(),
//         onCreateGoal: widget.onCreateGoal,
//         onViewGoal: widget.onViewGoal,
//       ),
//     );
//   }

//   void _showLearningCenterModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => LearningCenterModal(
//         userId: widget.uid,
//         onSubmitInterest: (interest) async {
//           final result = await _firestoreService.saveLearningInterest(interest);
//           return result != null;
//         },
//       ),
//     );
//   }
// }

// // ==================== BALANCE CARDS SECTION ====================

// class _BalanceCardsSection extends StatelessWidget {
//   final UserModel? user;
//   final bool isLoading;
//   final bool hasError;
//   final PageController pageController;
//   final int currentPage;
//   final NumberFormat currencyFormatter;
//   final ValueChanged<int> onPageChanged;
//   final VoidCallback? onTapGoals;
//   final VoidCallback? onInvest;
//   final VoidCallback? onWithdraw;
//   final VoidCallback? onHistory;
//   final void Function(UserModel user) onConvertTokens;

//   const _BalanceCardsSection({
//     required this.user,
//     required this.isLoading,
//     required this.hasError,
//     required this.pageController,
//     required this.currentPage,
//     required this.currencyFormatter,
//     required this.onPageChanged,
//     this.onTapGoals,
//     this.onInvest,
//     this.onWithdraw,
//     this.onHistory,
//     required this.onConvertTokens,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 220,
//       child: Stack(
//         children: [
//           PageView(
//             controller: pageController,
//             physics: const BouncingScrollPhysics(),
//             pageSnapping: true,
//             onPageChanged: onPageChanged,
//             children: [_buildFiatCard(), _buildTokenCard()],
//           ),
//           Positioned(
//             top: AdminDesignSystem.spacing16,
//             right: AdminDesignSystem.spacing16,
//             child: _PageIndicator(pageCount: 2, currentPage: currentPage),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFiatCard() {
//     if (isLoading) return BalanceCardSkeleton.fiat();
//     if (hasError || user == null) return BalanceCardError.fiat();

//     return FiatBalanceCard(
//       user: user!,
//       currencyFormatter: currencyFormatter,

//       onWithdraw: onWithdraw,
//       onHistory: onHistory,
//     );
//   }

//   Widget _buildTokenCard() {
//     if (isLoading) return BalanceCardSkeleton.token();
//     if (hasError || user == null) return BalanceCardError.token();

//     return TokensBalanceCard(
//       user: user!,
//       onEarnTokens: onTapGoals,
//       onConvertTokens: () => onConvertTokens(user!),
//     );
//   }
// }

// // ==================== PAGE INDICATOR ====================

// class _PageIndicator extends StatelessWidget {
//   final int pageCount;
//   final int currentPage;

//   const _PageIndicator({required this.pageCount, required this.currentPage});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AdminDesignSystem.spacing8,
//         vertical: AdminDesignSystem.spacing4,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white.withAlpha(38),
//         borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(pageCount, (index) {
//           final isActive = index == currentPage;
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             curve: Curves.easeOutCubic,
//             margin: const EdgeInsets.symmetric(
//               horizontal: AdminDesignSystem.spacing4 / 2,
//             ),
//             width: isActive ? 8 : 6,
//             height: isActive ? 8 : 6,
//             decoration: BoxDecoration(
//               color: isActive ? Colors.white : Colors.white.withAlpha(128),
//               shape: BoxShape.circle,
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// // ==================== ACTION CARDS GRID ====================

// class _ActionCardsGrid extends StatelessWidget {
//   final Stream<List<GoalModel>> goalsStream;
//   final VoidCallback? onInvest;
//   final VoidCallback? onWithdraw;
//   final VoidCallback? onLearn;
//   final void Function(List<GoalModel>) onSavingsClock;

//   const _ActionCardsGrid({
//     required this.goalsStream,
//     this.onInvest,
//     this.onWithdraw,
//     this.onLearn,
//     required this.onSavingsClock,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<GoalModel>>(
//       stream: goalsStream,
//       builder: (context, snapshot) {
//         final goals = snapshot.data ?? [];
//         final activeGoals = goals
//             .where((g) => g.status == GoalStatus.active)
//             .toList();

//         return GridView.count(
//           crossAxisCount: 2,
//           mainAxisSpacing: AdminDesignSystem.spacing12,
//           crossAxisSpacing: AdminDesignSystem.spacing12,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           childAspectRatio: 0.95,
//           children: [
//             AnimatedActionCard(
//               icon: Icons.trending_up,
//               title: 'Invest',
//               subtitle: 'Grow your wealth',
//               color: AdminDesignSystem.accentTeal,
//               delay: 200,
//               onPressed: onInvest,
//             ),
//             AnimatedActionCard(
//               icon: Icons.arrow_circle_down_outlined,
//               title: 'Withdraw',
//               subtitle: 'Get your funds',
//               color: const Color(0xFF9B59B6),
//               delay: 300,
//               onPressed: onWithdraw,
//             ),
//             AnimatedActionCard(
//               icon: Icons.school_outlined,
//               title: 'Learning Center',
//               subtitle: 'Financial education',
//               color: const Color(0xFF3498DB),
//               delay: 400,
//               onPressed: onLearn,
//             ),
//             _SavingsClockCard(
//               activeGoalsCount: activeGoals.length,
//               delay: 500,
//               onPressed: () => onSavingsClock(goals),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// // ==================== SAVINGS CLOCK CARD ====================

// class _SavingsClockCard extends StatefulWidget {
//   final int activeGoalsCount;
//   final int delay;
//   final VoidCallback? onPressed;

//   const _SavingsClockCard({
//     required this.activeGoalsCount,
//     required this.delay,
//     this.onPressed,
//   });

//   @override
//   State<_SavingsClockCard> createState() => _SavingsClockCardState();
// }

// class _SavingsClockCardState extends State<_SavingsClockCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _pulseController;

//   static const Color _clockColor = Color(0xFFE67E22);

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: Duration(milliseconds: 300 + widget.delay),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, (1 - value) * 20),
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: widget.onPressed,
//           borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//           child: Container(
//             decoration: AdminDesignSystem.cardDecoration,
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AnimatedBuilder(
//                   animation: _pulseController,
//                   builder: (context, child) {
//                     return Container(
//                       padding: const EdgeInsets.all(
//                         AdminDesignSystem.spacing12,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _clockColor.withAlpha(
//                           (26 + (_pulseController.value * 12)).toInt(),
//                         ),
//                         borderRadius: BorderRadius.circular(
//                           AdminDesignSystem.radius12,
//                         ),
//                       ),
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Icon(
//                             Icons.watch_later_outlined,
//                             color: _clockColor,
//                             size: 32,
//                           ),
//                           if (widget.activeGoalsCount > 0)
//                             Positioned(
//                               right: -2,
//                               top: -2,
//                               child: Container(
//                                 width: 12,
//                                 height: 12,
//                                 decoration: BoxDecoration(
//                                   color: AdminDesignSystem.statusActive,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing12),
//                 Text(
//                   'Savings Clock',
//                   style: AdminDesignSystem.bodyLarge.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: AdminDesignSystem.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing4),
//                 Text(
//                   widget.activeGoalsCount > 0
//                       ? '${widget.activeGoalsCount} active goal${widget.activeGoalsCount > 1 ? 's' : ''}'
//                       : 'Track your progress',
//                   style: AdminDesignSystem.bodySmall.copyWith(
//                     color: AdminDesignSystem.textSecondary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/dashboard/tabs/home_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/goals_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/token_conversion_service.dart';
import '../../modals/learning_center_modal.dart';
import '../../modals/token_conversion_modal.dart';
import '../../modals/savings_clock_modal.dart';
import '../../modals/general_savings_clock_modal.dart';
import 'action_card.dart';
import 'balance_card-skeleton.dart';
import 'token_balance_card.dart';
import 'fiat_balance_card.dart';
import 'widgets/general_savings_clock_card.dart';

class HomeTab extends StatefulWidget {
  final String uid;
  final VoidCallback? onTapGoals;
  final VoidCallback? onInvest;
  final VoidCallback? onWithdraw;
  final VoidCallback? onHistory;
  final Function(GoalModel)? onViewGoal;
  final VoidCallback? onCreateGoal;

  const HomeTab({
    super.key,
    required this.uid,
    this.onTapGoals,
    this.onInvest,
    this.onWithdraw,
    this.onHistory,
    this.onViewGoal,
    this.onCreateGoal,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final FirestoreService _firestoreService;
  late final TokenConversionService _tokenService;
  late final PageController _pageController;
  late final Stream<UserModel?> _userStream;
  late final Stream<List<GoalModel>> _goalsStream;

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

    _userStream = _firestoreService
        .getUserStream(widget.uid)
        .asBroadcastStream();

    _goalsStream = _firestoreService
        .getUserGoalsStream(widget.uid)
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
                      setState(() => _currentPage = index);
                    },
                    onTapGoals: widget.onTapGoals,
                    onInvest: widget.onInvest,
                    onWithdraw: widget.onWithdraw,
                    onHistory: widget.onHistory,
                    onConvertTokens: _showConversionModal,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing24),
                  _ActionCardsGrid(
                    user: snapshot.data,
                    goalsStream: _goalsStream,
                    onInvest: widget.onInvest,
                    onWithdraw: widget.onWithdraw,
                    onLearn: _showLearningCenterModal,
                    onSavingsClock: _showSavingsClockModal,
                    onGeneralSavingsTap: _showGeneralSavingsClockModal,
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== MODALS ====================

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

  void _showSavingsClockModal(List<GoalModel> goals) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SavingsClockModal(
        goals: goals.where((g) => g.status == GoalStatus.active).toList(),
        onCreateGoal: widget.onCreateGoal,
        onViewGoal: widget.onViewGoal,
      ),
    );
  }

  void _showGeneralSavingsClockModal(UserModel? user) {
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GeneralSavingsClockModal(
        user: user,
        onEditTarget: () {
          Navigator.pop(context);
          // This will be called when user taps "Set Target" button
          // The dashboard will handle opening the SetSavingsTargetForm
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showLearningCenterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LearningCenterModal(
        userId: widget.uid,
        onSubmitInterest: (interest) async {
          final result = await _firestoreService.saveLearningInterest(interest);
          return result != null;
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
    if (isLoading) return BalanceCardSkeleton.fiat();
    if (hasError || user == null) return BalanceCardError.fiat();

    return FiatBalanceCard(
      user: user!,
      currencyFormatter: currencyFormatter,
      onWithdraw: onWithdraw,
      onHistory: onHistory,
    );
  }

  Widget _buildTokenCard() {
    if (isLoading) return BalanceCardSkeleton.token();
    if (hasError || user == null) return BalanceCardError.token();

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
  final UserModel? user;
  final Stream<List<GoalModel>> goalsStream;
  final VoidCallback? onInvest;
  final VoidCallback? onWithdraw;
  final VoidCallback? onLearn;
  final void Function(List<GoalModel>) onSavingsClock;
  final void Function(UserModel?) onGeneralSavingsTap;

  const _ActionCardsGrid({
    required this.user,
    required this.goalsStream,
    this.onInvest,
    this.onWithdraw,
    this.onLearn,
    required this.onSavingsClock,
    required this.onGeneralSavingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GoalModel>>(
      stream: goalsStream,
      builder: (context, snapshot) {
        final goals = snapshot.data ?? [];
        // final activeGoals = goals
        //     .where((g) => g.status == GoalStatus.active)
        //     .toList();

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
              subtitle: 'Financial education',
              color: const Color(0xFF3498DB),
              delay: 400,
              onPressed: onLearn,
            ),
            GeneralSavingsClockCard(
              user: user,
              delay: 500,
              onPressed: () => onGeneralSavingsTap(user),
            ),
          ],
        );
      },
    );
  }
}
