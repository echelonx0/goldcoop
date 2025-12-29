// // lib/screens/dashboard/modals/general_savings_clock_modal.dart

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../core/theme/admin_design_system.dart';
// import '../../../models/user_model.dart';

// class GeneralSavingsClockModal extends StatelessWidget {
//   final UserModel user;
//   final VoidCallback onEditTarget;
//   final VoidCallback onClose;

//   const GeneralSavingsClockModal({
//     super.key,
//     required this.user,
//     required this.onEditTarget,
//     required this.onClose,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final fp = user.financialProfile;
//     final hasTarget = (fp.savingsTarget) > 0;
//     final targetAmount = fp.savingsTarget;
//     final currentBalance = fp.accountBalance;
//     final targetDate = fp.savingsTargetDate;

//     final currencyFormatter = NumberFormat.currency(
//       symbol: '₦',
//       decimalDigits: 0,
//     );

//     if (!hasTarget || targetDate == null) {
//       return _buildEmptyState(context);
//     }

//     final progress = (currentBalance / targetAmount).clamp(0.0, 1.0);
//     final remainingAmount = (targetAmount - currentBalance).clamp(
//       0.0,
//       double.infinity,
//     );
//     final daysRemaining = targetDate.difference(DateTime.now()).inDays;
//     final isCompleted = currentBalance >= targetAmount;
//     final isOverdue = DateTime.now().isAfter(targetDate) && !isCompleted;

//     return Container(
//       decoration: BoxDecoration(
//         color: AdminDesignSystem.cardBackground,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(AdminDesignSystem.radius16),
//           topRight: Radius.circular(AdminDesignSystem.radius16),
//         ),
//       ),
//       child: CustomScrollView(
//         slivers: [
//           // Header
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: AdminDesignSystem.cardBackground,
//             elevation: 0,
//             leading: const SizedBox.shrink(),
//             title: Text(
//               'Savings Goal',
//               style: AdminDesignSystem.headingMedium.copyWith(
//                 color: AdminDesignSystem.primaryNavy,
//               ),
//             ),
//             actions: [
//               IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
//             ],
//           ),

//           // Content
//           SliverPadding(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([
//                 // Target amount card
//                 TweenAnimationBuilder<double>(
//                   tween: Tween(begin: 0, end: 1),
//                   duration: const Duration(milliseconds: 500),
//                   builder: (context, value, child) {
//                     return Opacity(opacity: value, child: child);
//                   },
//                   child: Container(
//                     decoration: AdminDesignSystem.cardDecoration,
//                     padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Target Amount',
//                                     style: AdminDesignSystem.labelMedium,
//                                   ),
//                                   const SizedBox(
//                                     height: AdminDesignSystem.spacing8,
//                                   ),
//                                   TweenAnimationBuilder<double>(
//                                     tween: Tween(begin: 0, end: targetAmount),
//                                     duration: const Duration(
//                                       milliseconds: 1200,
//                                     ),
//                                     curve: Curves.easeOutCubic,
//                                     builder: (context, value, child) {
//                                       return Text(
//                                         currencyFormatter.format(value),
//                                         style: AdminDesignSystem.displayLarge
//                                             .copyWith(
//                                               color:
//                                                   AdminDesignSystem.primaryNavy,
//                                               fontSize: 28,
//                                             ),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: onEditTarget,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: AdminDesignSystem.accentTeal.withAlpha(
//                                     38,
//                                   ),
//                                   borderRadius: BorderRadius.circular(
//                                     AdminDesignSystem.radius12,
//                                   ),
//                                 ),
//                                 padding: const EdgeInsets.all(
//                                   AdminDesignSystem.spacing12,
//                                 ),
//                                 child: Icon(
//                                   Icons.edit_outlined,
//                                   size: 20,
//                                   color: AdminDesignSystem.accentTeal,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: AdminDesignSystem.spacing20),
//                         _buildProgressSection(progress, isCompleted, isOverdue),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing16),

//                 // Stats section
//                 _buildStatsGrid(
//                   currentBalance,
//                   targetAmount,
//                   remainingAmount,
//                   daysRemaining,
//                   isCompleted,
//                   currencyFormatter,
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing16),

//                 // Target date section
//                 Container(
//                   decoration: AdminDesignSystem.cardDecoration,
//                   padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Target Date', style: AdminDesignSystem.labelMedium),
//                       const SizedBox(height: AdminDesignSystem.spacing12),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_today_outlined,
//                             color: AdminDesignSystem.accentTeal,
//                             size: 24,
//                           ),
//                           const SizedBox(width: AdminDesignSystem.spacing12),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 DateFormat('MMM dd, yyyy').format(targetDate),
//                                 style: AdminDesignSystem.bodyMedium.copyWith(
//                                   color: AdminDesignSystem.textPrimary,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: AdminDesignSystem.spacing4,
//                               ),
//                               Text(
//                                 _formatDaysRemaining(daysRemaining),
//                                 style: AdminDesignSystem.labelSmall.copyWith(
//                                   color: isOverdue
//                                       ? AdminDesignSystem.statusError
//                                       : AdminDesignSystem.textSecondary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing16),

//                 // Achievement banner if completed
//                 if (isCompleted) _buildAchievementBanner(),

//                 const SizedBox(height: AdminDesignSystem.spacing16),
//               ]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AdminDesignSystem.cardBackground,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(AdminDesignSystem.radius16),
//           topRight: Radius.circular(AdminDesignSystem.radius16),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           AppBar(
//             backgroundColor: AdminDesignSystem.cardBackground,
//             elevation: 0,
//             leading: const SizedBox.shrink(),
//             title: Text(
//               'Savings Goal',
//               style: AdminDesignSystem.headingMedium.copyWith(
//                 color: AdminDesignSystem.primaryNavy,
//               ),
//             ),
//             actions: [
//               IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AdminDesignSystem.accentTeal.withAlpha(38),
//                     borderRadius: BorderRadius.circular(
//                       AdminDesignSystem.radius16,
//                     ),
//                   ),
//                   padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
//                   child: Icon(
//                     Icons.savings_outlined,
//                     size: 48,
//                     color: AdminDesignSystem.accentTeal,
//                   ),
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing20),
//                 Text(
//                   'No savings target yet',
//                   style: AdminDesignSystem.headingMedium.copyWith(
//                     color: AdminDesignSystem.primaryNavy,
//                   ),
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing8),
//                 Text(
//                   'Set a savings target to track\nyour progress and stay motivated',
//                   style: AdminDesignSystem.bodySmall,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: onEditTarget,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AdminDesignSystem.accentTeal,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: AdminDesignSystem.spacing16,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           AdminDesignSystem.radius12,
//                         ),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: Text(
//                       'Set Target',
//                       style: AdminDesignSystem.bodyMedium.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressSection(
//     double progress,
//     bool isCompleted,
//     bool isOverdue,
//   ) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: progress),
//       duration: const Duration(milliseconds: 1200),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//               child: LinearProgressIndicator(
//                 value: value.clamp(0.0, 1.0),
//                 minHeight: 8,
//                 backgroundColor: AdminDesignSystem.accentTeal.withAlpha(38),
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   isCompleted
//                       ? AdminDesignSystem.statusActive
//                       : AdminDesignSystem.accentTeal,
//                 ),
//               ),
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${(value * 100).toStringAsFixed(1)}% complete',
//                   style: AdminDesignSystem.labelSmall.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 if (isCompleted)
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         size: 14,
//                         color: AdminDesignSystem.statusActive,
//                       ),
//                       const SizedBox(width: AdminDesignSystem.spacing4),
//                       Text(
//                         'Target reached',
//                         style: AdminDesignSystem.labelSmall.copyWith(
//                           color: AdminDesignSystem.statusActive,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   )
//                 else if (isOverdue)
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.warning_amber,
//                         size: 14,
//                         color: AdminDesignSystem.statusError,
//                       ),
//                       const SizedBox(width: AdminDesignSystem.spacing4),
//                       Text(
//                         'Overdue',
//                         style: AdminDesignSystem.labelSmall.copyWith(
//                           color: AdminDesignSystem.statusError,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildStatsGrid(
//     double currentBalance,
//     double targetAmount,
//     double remainingAmount,
//     int daysRemaining,
//     bool isCompleted,
//     NumberFormat formatter,
//   ) {
//     return Container(
//       decoration: AdminDesignSystem.cardDecoration,
//       padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatItem(
//                   label: 'Saved',
//                   value: formatter.format(currentBalance),
//                   icon: Icons.account_balance_wallet_outlined,
//                   color: isCompleted
//                       ? AdminDesignSystem.statusActive
//                       : AdminDesignSystem.accentTeal,
//                 ),
//               ),
//               Container(
//                 width: 1,
//                 height: 60,
//                 color: AdminDesignSystem.divider,
//                 margin: const EdgeInsets.symmetric(
//                   horizontal: AdminDesignSystem.spacing12,
//                 ),
//               ),
//               Expanded(
//                 child: _buildStatItem(
//                   label: 'Remaining',
//                   value: formatter.format(remainingAmount),
//                   icon: Icons.hourglass_empty,
//                   color: AdminDesignSystem.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required String label,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: color.withAlpha(153), size: 20),
//         const SizedBox(height: AdminDesignSystem.spacing8),
//         Text(label, style: AdminDesignSystem.labelSmall),
//         const SizedBox(height: AdminDesignSystem.spacing4),
//         Text(
//           value,
//           style: AdminDesignSystem.bodyMedium.copyWith(
//             color: color,
//             fontWeight: FontWeight.w700,
//           ),
//           textAlign: TextAlign.center,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     );
//   }

//   Widget _buildAchievementBanner() {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: const Duration(milliseconds: 600),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, (1 - value) * 20),
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               AdminDesignSystem.statusActive,
//               AdminDesignSystem.statusActive.withAlpha(230),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//           boxShadow: [
//             BoxShadow(
//               color: AdminDesignSystem.statusActive.withAlpha(38),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
//         child: Row(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withAlpha(51),
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//               ),
//               padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
//               child: Icon(Icons.emoji_events, color: Colors.white, size: 32),
//             ),
//             const SizedBox(width: AdminDesignSystem.spacing16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Goal Achieved! 🎉',
//                     style: AdminDesignSystem.bodyLarge.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: AdminDesignSystem.spacing4),
//                   Text(
//                     'You\'ve reached your savings target',
//                     style: AdminDesignSystem.bodySmall.copyWith(
//                       color: Colors.white.withAlpha(204),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDaysRemaining(int days) {
//     if (days < 0) {
//       return '${(-days).abs()} days overdue';
//     } else if (days == 0) {
//       return 'Due today';
//     } else if (days == 1) {
//       return '1 day remaining';
//     } else if (days <= 7) {
//       return '$days days left';
//     } else if (days <= 30) {
//       final weeks = (days / 7).floor();
//       return '$weeks ${weeks == 1 ? 'week' : 'weeks'} remaining';
//     } else {
//       final months = (days / 30).floor();
//       return '$months ${months == 1 ? 'month' : 'months'} left';
//     }
//   }
// }

// lib/screens/dashboard/modals/general_savings_clock_modal.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/user_model.dart';
import 'upload_proof_modal.dart';

class GeneralSavingsClockModal extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditTarget;
  final VoidCallback onClose;

  const GeneralSavingsClockModal({
    super.key,
    required this.user,
    required this.onEditTarget,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final fp = user.financialProfile;
    final hasTarget = (fp.savingsTarget ?? 0) > 0;
    final targetAmount = fp.savingsTarget ?? 0;
    final currentBalance = fp.accountBalance ?? 0;
    final targetDate = fp.savingsTargetDate;

    final currencyFormatter = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: 0,
    );

    if (!hasTarget || targetDate == null) {
      return _buildEmptyState(context);
    }

    final progress = (currentBalance / targetAmount).clamp(0.0, 1.0);
    final remainingAmount = (targetAmount - currentBalance).clamp(
      0.0,
      double.infinity,
    );
    final daysRemaining = targetDate.difference(DateTime.now()).inDays;
    final isCompleted = currentBalance >= targetAmount;
    final isOverdue = DateTime.now().isAfter(targetDate) && !isCompleted;

    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AdminDesignSystem.radius16),
          topRight: Radius.circular(AdminDesignSystem.radius16),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            pinned: true,
            backgroundColor: AdminDesignSystem.cardBackground,
            elevation: 0,
            leading: const SizedBox.shrink(),
            title: Text(
              'Savings Goal',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
            actions: [
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Clock display card
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
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
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius16,
                      ),
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
                      children: [
                        // Clock icon with pulse
                        _ClockDisplay(
                          daysRemaining: daysRemaining,
                          isCompleted: isCompleted,
                          isOverdue: isOverdue,
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing16),
                        // Target amount
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: targetAmount),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Column(
                              children: [
                                Text(
                                  'Target Savings',
                                  style: AdminDesignSystem.labelMedium.copyWith(
                                    color: Colors.white.withAlpha(179),
                                  ),
                                ),
                                const SizedBox(
                                  height: AdminDesignSystem.spacing8,
                                ),
                                Text(
                                  currencyFormatter.format(value),
                                  style: AdminDesignSystem.displayLarge
                                      .copyWith(
                                        color: Colors.white,
                                        fontSize: 32,
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AdminDesignSystem.spacing16),
                        // Edit button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onEditTarget,
                                borderRadius: BorderRadius.circular(
                                  AdminDesignSystem.radius12,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(25),
                                    borderRadius: BorderRadius.circular(
                                      AdminDesignSystem.radius12,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AdminDesignSystem.spacing16,
                                    vertical: AdminDesignSystem.spacing12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: AdminDesignSystem.spacing8,
                                      ),
                                      Text(
                                        'Edit Target',
                                        style: AdminDesignSystem.labelSmall
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Progress section
                _buildProgressSection(progress, isCompleted, isOverdue),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Stats section
                _buildStatsGrid(
                  currentBalance,
                  targetAmount,
                  remainingAmount,
                  daysRemaining,
                  isCompleted,
                  currencyFormatter,
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Target date section
                Container(
                  decoration: AdminDesignSystem.cardDecoration,
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target Date', style: AdminDesignSystem.labelMedium),
                      const SizedBox(height: AdminDesignSystem.spacing12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: AdminDesignSystem.accentTeal,
                            size: 24,
                          ),
                          const SizedBox(width: AdminDesignSystem.spacing12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(targetDate),
                                style: AdminDesignSystem.bodyMedium.copyWith(
                                  color: AdminDesignSystem.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: AdminDesignSystem.spacing4,
                              ),
                              Text(
                                _formatDaysRemaining(daysRemaining),
                                style: AdminDesignSystem.labelSmall.copyWith(
                                  color: isOverdue
                                      ? AdminDesignSystem.statusError
                                      : AdminDesignSystem.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Upload proof button
                _buildUploadProofButton(context),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Achievement banner if completed
                if (isCompleted) _buildAchievementBanner(),

                const SizedBox(height: AdminDesignSystem.spacing16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AdminDesignSystem.radius16),
          topRight: Radius.circular(AdminDesignSystem.radius16),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: AdminDesignSystem.cardBackground,
            elevation: 0,
            leading: const SizedBox.shrink(),
            title: Text(
              'Savings Goal',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
            actions: [
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (value * 0.2),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AdminDesignSystem.accentTeal.withAlpha(38),
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius16,
                        ),
                      ),
                      padding: const EdgeInsets.all(
                        AdminDesignSystem.spacing20,
                      ),
                      child: Icon(
                        Icons.savings_outlined,
                        size: 48,
                        color: AdminDesignSystem.accentTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing20),
                  Text(
                    'No savings target yet',
                    style: AdminDesignSystem.headingMedium.copyWith(
                      color: AdminDesignSystem.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing8),
                  Text(
                    'Set a savings target to track\nyour progress and stay motivated',
                    style: AdminDesignSystem.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onEditTarget,
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
                        'Set Target',
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
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    double progress,
    bool isCompleted,
    bool isOverdue,
  ) {
    return Container(
      decoration: AdminDesignSystem.cardDecoration,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
                child: LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AdminDesignSystem.accentTeal.withAlpha(38),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted
                        ? AdminDesignSystem.statusActive
                        : AdminDesignSystem.accentTeal,
                  ),
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(value * 100).toStringAsFixed(1)}% complete',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isCompleted)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AdminDesignSystem.statusActive,
                        ),
                        const SizedBox(width: AdminDesignSystem.spacing4),
                        Text(
                          'Target reached',
                          style: AdminDesignSystem.labelSmall.copyWith(
                            color: AdminDesignSystem.statusActive,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else if (isOverdue)
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 14,
                          color: AdminDesignSystem.statusError,
                        ),
                        const SizedBox(width: AdminDesignSystem.spacing4),
                        Text(
                          'Overdue',
                          style: AdminDesignSystem.labelSmall.copyWith(
                            color: AdminDesignSystem.statusError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(
    double currentBalance,
    double targetAmount,
    double remainingAmount,
    int daysRemaining,
    bool isCompleted,
    NumberFormat formatter,
  ) {
    return Container(
      decoration: AdminDesignSystem.cardDecoration,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'Saved',
              value: formatter.format(currentBalance),
              icon: Icons.account_balance_wallet_outlined,
              color: isCompleted
                  ? AdminDesignSystem.statusActive
                  : AdminDesignSystem.accentTeal,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: AdminDesignSystem.divider,
            margin: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing12,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              label: 'Remaining',
              value: formatter.format(remainingAmount),
              icon: Icons.hourglass_empty,
              color: AdminDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color.withAlpha(153), size: 20),
        const SizedBox(height: AdminDesignSystem.spacing8),
        Text(label, style: AdminDesignSystem.labelSmall),
        const SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          value,
          style: AdminDesignSystem.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildUploadProofButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => UploadProofModal(
              transactionId: '',
              goalId: '',

              goalTitle: 'General Account Funding',
              onSuccess: () {
                Navigator.pop(context); // Close upload modal
                Navigator.pop(context); // Close savings clock modal
              },
              onCancel: () {
                Navigator.pop(context);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AdminDesignSystem.accentTeal),
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          ),
          padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file_outlined,
                color: AdminDesignSystem.accentTeal,
                size: 20,
              ),
              const SizedBox(width: AdminDesignSystem.spacing8),
              Text(
                'Upload Proof of Payment',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  color: AdminDesignSystem.accentTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementBanner() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AdminDesignSystem.statusActive,
              AdminDesignSystem.statusActive.withAlpha(230),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          boxShadow: [
            BoxShadow(
              color: AdminDesignSystem.statusActive.withAlpha(38),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
              child: Icon(Icons.emoji_events, color: Colors.white, size: 32),
            ),
            const SizedBox(width: AdminDesignSystem.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal Achieved! 🎉',
                    style: AdminDesignSystem.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing4),
                  Text(
                    'You\'ve reached your savings target',
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDaysRemaining(int days) {
    if (days < 0) {
      return '${(-days).abs()} days overdue';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return '1 day remaining';
    } else if (days <= 7) {
      return '$days days left';
    } else if (days <= 30) {
      final weeks = (days / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} remaining';
    } else {
      final months = (days / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} left';
    }
  }
}

// ==================== CLOCK DISPLAY COMPONENT ====================

class _ClockDisplay extends StatefulWidget {
  final int daysRemaining;
  final bool isCompleted;
  final bool isOverdue;

  const _ClockDisplay({
    required this.daysRemaining,
    required this.isCompleted,
    required this.isOverdue,
  });

  @override
  State<_ClockDisplay> createState() => _ClockDisplayState();
}

class _ClockDisplayState extends State<_ClockDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(
              (25 + (_pulseController.value * 15)).toInt(),
            ),
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Clock icon
              Icon(Icons.watch_later_outlined, color: Colors.white, size: 48),
              // Badge for status
              if (widget.daysRemaining > 0 && !widget.isCompleted)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminDesignSystem.spacing8,
                      vertical: AdminDesignSystem.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AdminDesignSystem.statusActive,
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AdminDesignSystem.statusActive.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${widget.daysRemaining}d',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (widget.isCompleted)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AdminDesignSystem.statusActive,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AdminDesignSystem.statusActive.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                )
              else if (widget.isOverdue)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AdminDesignSystem.statusError,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AdminDesignSystem.statusError.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.warning, size: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
