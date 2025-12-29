// // ==================== ANIMATED BALANCE CARD ====================

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../../../../core/theme/admin_design_system.dart';
// import '../../../../models/user_model.dart';
// import '../../modals/deposit_instructions_modal.dart';

// class FiatBalanceCard extends StatefulWidget {
//   final UserModel user;
//   final NumberFormat currencyFormatter;

//   final VoidCallback? onInvest;
//   final VoidCallback? onWithdraw;
//   final VoidCallback? onHistory;

//   const FiatBalanceCard({
//     super.key,
//     required this.user,
//     required this.currencyFormatter,

//     this.onInvest,
//     this.onWithdraw,
//     this.onHistory,
//   });

//   @override
//   State<FiatBalanceCard> createState() => _FiatBalanceCardState();
// }

// class _FiatBalanceCardState extends State<FiatBalanceCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
//       ),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
//           ),
//         );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final balance = widget.user.financialProfile.accountBalance;

//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 AdminDesignSystem.accentTeal,
//                 AdminDesignSystem.accentTeal.withAlpha(230),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
//             boxShadow: [
//               BoxShadow(
//                 color: AdminDesignSystem.accentTeal.withAlpha(38),
//                 blurRadius: 16,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Naira Balance',
//                           style: AdminDesignSystem.labelMedium.copyWith(
//                             color: Colors.white.withAlpha(179),
//                           ),
//                         ),
//                         const SizedBox(height: AdminDesignSystem.spacing8),
//                         TweenAnimationBuilder<double>(
//                           tween: Tween(begin: 0, end: balance),
//                           duration: const Duration(milliseconds: 1200),
//                           curve: Curves.easeOutCubic,
//                           builder: (context, value, child) {
//                             return Text(
//                               widget.currencyFormatter.format(value),
//                               style: AdminDesignSystem.displayLarge.copyWith(
//                                 color: Colors.white,
//                                 fontSize: 32,
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AdminDesignSystem.spacing24),
//               Row(
//                 children: [
//                   _AnimatedActionButton(
//                     icon: Icons.add_circle_outline,
//                     label: 'Fund Account',
//                     onPressed: () async {
//                       await showModalBottomSheet(
//                         context: context,
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         builder: (context) => DepositInstructionsModal(
//                           userId: widget.user.uid,
//                           onClose: () => Navigator.pop(context),
//                         ),
//                       );
//                     },
//                     delay: 200,
//                   ),
//                   const SizedBox(width: AdminDesignSystem.spacing8),

//                   _AnimatedActionButton(
//                     icon: Icons.receipt_long_outlined,
//                     label: 'History',
//                     onPressed: widget.onHistory,
//                     delay: 500,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ==================== ANIMATED ACTION BUTTON ====================

// class _AnimatedActionButton extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback? onPressed;
//   final int delay;

//   const _AnimatedActionButton({
//     required this.icon,
//     required this.label,
//     required this.onPressed,
//     required this.delay,
//   });

//   @override
//   State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
// }

// class _AnimatedActionButtonState extends State<_AnimatedActionButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

//     Future.delayed(Duration(milliseconds: widget.delay), () {
//       if (mounted) _controller.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Material(
//           color: Colors.transparent,
//           child: GestureDetector(
//             onTap: widget.onPressed,
//             //borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withAlpha(25),
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//               ),
//               padding: const EdgeInsets.symmetric(
//                 vertical: AdminDesignSystem.spacing12,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(widget.icon, color: Colors.white, size: 24),
//                   const SizedBox(height: AdminDesignSystem.spacing4),
//                   Text(
//                     widget.label,
//                     style: AdminDesignSystem.labelSmall.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// ==================== UPDATED FIAT BALANCE CARD ====================
// Replace your current lib/screens/dashboard/tabs/home_tab/fiat_balance_card.dart with this

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/user_model.dart';
import '../../modals/fund_account_modal.dart';
import '../../modals/deposit_instructions_modal.dart';
import '../../modals/upload_proof_modal.dart';

class FiatBalanceCard extends StatefulWidget {
  final UserModel user;
  final NumberFormat currencyFormatter;
  final VoidCallback? onWithdraw;
  final VoidCallback? onHistory;

  const FiatBalanceCard({
    super.key,
    required this.user,
    required this.currencyFormatter,
    this.onWithdraw,
    this.onHistory,
  });

  @override
  State<FiatBalanceCard> createState() => _FiatBalanceCardState();
}

class _FiatBalanceCardState extends State<FiatBalanceCard>
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

  void _showFundAccountModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FundAccountModal(
        userId: widget.user.uid,
        onViewInstructions: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DepositInstructionsModal(
              userId: widget.user.uid,
              onClose: () => Navigator.pop(context),
            ),
          );
        },
        onUploadProof: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => UploadProofModal(
              transactionId: '', // Empty for new deposit (not tied to goal)
              goalId: '', // Empty for general account funding

              goalTitle: 'Account Funding',
              onSuccess: () {
                Navigator.pop(context);
                _showSuccessSnackbar(
                  'Proof uploaded! Your deposit will be verified shortly.',
                );
              },
              onCancel: () {
                Navigator.pop(context);
              },
            ),
          );
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminDesignSystem.statusActive,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
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
                          'Naira Balance',
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
                    label: 'Fund Account',
                    onPressed: _showFundAccountModal,
                    delay: 200,
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
