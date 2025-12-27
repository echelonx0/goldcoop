// // lib/screens/dashboard/tabs/savings/goal_detail_sheet.dart

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../components/base/app_button.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../models/goals_model.dart';
// import '../../../../extensions/goal_category_extension.dart';

// class GoalDetailSheet extends StatefulWidget {
//   final GoalModel goal;
//   final VoidCallback onAddFunds;
//   final VoidCallback onClose;

//   const GoalDetailSheet({
//     super.key,
//     required this.goal,
//     required this.onAddFunds,
//     required this.onClose,
//   });

//   @override
//   State<GoalDetailSheet> createState() => _GoalDetailSheetState();
// }

// class _GoalDetailSheetState extends State<GoalDetailSheet>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   final _currencyFormatter = NumberFormat.currency(
//     symbol: '₦',
//     decimalDigits: 0,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
//       ),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.85,
//           ),
//           decoration: BoxDecoration(
//             color: AppColors.backgroundWhite,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(AppBorderRadius.large),
//               topRight: Radius.circular(AppBorderRadius.large),
//             ),
//           ),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(AppSpacing.lg),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: AppSpacing.lg),
//                 _buildTitleSection(),
//                 const SizedBox(height: AppSpacing.lg),
//                 _buildProgressSection(),
//                 const SizedBox(height: AppSpacing.lg),
//                 _buildStatsGrid(),
//                 const SizedBox(height: AppSpacing.lg),
//                 _buildCategoryInfo(),
//                 const SizedBox(height: AppSpacing.lg),
//                 _buildActionSection(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Container(
//           width: 40,
//           height: 4,
//           decoration: BoxDecoration(
//             color: AppColors.borderLight,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         GestureDetector(
//           onTap: widget.onClose,
//           child: Container(
//             padding: const EdgeInsets.all(AppSpacing.xs),
//             decoration: BoxDecoration(
//               color: AppColors.backgroundNeutral,
//               borderRadius: BorderRadius.circular(AppBorderRadius.small),
//             ),
//             child: Icon(Icons.close, color: AppColors.textSecondary, size: 20),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTitleSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: widget.goal.category.color.withAlpha(25),
//                 borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//               ),
//               padding: const EdgeInsets.all(AppSpacing.md),
//               child: Icon(
//                 _getCategoryIcon(widget.goal.category),
//                 color: widget.goal.category.color,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: AppSpacing.md),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.goal.title,
//                     style: AppTextTheme.heading2.copyWith(
//                       color: AppColors.deepNavy,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.xs),
//                   _buildStatusBadge(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         if (widget.goal.description.isNotEmpty) ...[
//           const SizedBox(height: AppSpacing.md),
//           Text(
//             widget.goal.description,
//             style: AppTextTheme.bodyRegular.copyWith(
//               color: AppColors.textSecondary,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildStatusBadge() {
//     final isCompleted = widget.goal.isCompleted;
//     final isOverdue = widget.goal.isOverdue;

//     Color badgeColor;
//     IconData badgeIcon;
//     String badgeText;

//     if (isCompleted) {
//       badgeColor = AppColors.tealSuccess;
//       badgeIcon = Icons.check_circle;
//       badgeText = 'Completed';
//     } else if (isOverdue) {
//       badgeColor = AppColors.warmRed;
//       badgeIcon = Icons.warning_amber_rounded;
//       badgeText = 'Overdue';
//     } else {
//       badgeColor = AppColors.primaryOrange;
//       badgeIcon = Icons.schedule;
//       badgeText = '${widget.goal.daysRemaining} days left';
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppSpacing.sm,
//         vertical: AppSpacing.xs,
//       ),
//       decoration: BoxDecoration(
//         color: badgeColor.withAlpha(25),
//         borderRadius: BorderRadius.circular(AppBorderRadius.small),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(badgeIcon, size: 14, color: badgeColor),
//           const SizedBox(width: AppSpacing.xs),
//           Text(
//             badgeText,
//             style: AppTextTheme.bodySmall.copyWith(
//               color: badgeColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressSection() {
//     final progressPercent = widget.goal.progressPercentage;
//     final isCompleted = widget.goal.isCompleted;

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             isCompleted
//                 ? AppColors.tealSuccess.withAlpha(25)
//                 : AppColors.primaryOrange.withAlpha(25),
//             isCompleted
//                 ? AppColors.tealSuccess.withAlpha(12)
//                 : AppColors.primaryOrange.withAlpha(12),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//         border: Border.all(
//           color: isCompleted
//               ? AppColors.tealSuccess.withAlpha(50)
//               : AppColors.primaryOrange.withAlpha(50),
//         ),
//       ),
//       padding: const EdgeInsets.all(AppSpacing.md),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Progress',
//                 style: AppTextTheme.bodySmall.copyWith(
//                   color: AppColors.textSecondary,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               TweenAnimationBuilder<double>(
//                 tween: Tween(begin: 0, end: progressPercent),
//                 duration: const Duration(milliseconds: 1000),
//                 curve: Curves.easeOutCubic,
//                 builder: (context, value, child) {
//                   return Text(
//                     '${value.toStringAsFixed(0)}%',
//                     style: AppTextTheme.heading3.copyWith(
//                       color: isCompleted
//                           ? AppColors.tealSuccess
//                           : AppColors.primaryOrange,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: AppSpacing.md),
//           TweenAnimationBuilder<double>(
//             tween: Tween(begin: 0, end: progressPercent / 100),
//             duration: const Duration(milliseconds: 1200),
//             curve: Curves.easeOutCubic,
//             builder: (context, value, child) {
//               return ClipRRect(
//                 borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//                 child: LinearProgressIndicator(
//                   value: value.clamp(0.0, 1.0),
//                   minHeight: 12,
//                   backgroundColor: Colors.white.withAlpha(180),
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     isCompleted
//                         ? AppColors.tealSuccess
//                         : AppColors.primaryOrange,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsGrid() {
//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       mainAxisSpacing: AppSpacing.md,
//       crossAxisSpacing: AppSpacing.md,
//       childAspectRatio: 1.5,
//       children: [
//         _AnimatedStatCard(
//           label: 'Saved',
//           value: _currencyFormatter.format(widget.goal.currentAmount),
//           color: AppColors.tealSuccess,
//           icon: Icons.savings_outlined,
//           delay: 100,
//           targetValue: widget.goal.currentAmount,
//         ),
//         _AnimatedStatCard(
//           label: 'Target',
//           value: _currencyFormatter.format(widget.goal.targetAmount),
//           color: AppColors.primaryOrange,
//           icon: Icons.flag_outlined,
//           delay: 200,
//           targetValue: widget.goal.targetAmount,
//         ),
//         _AnimatedStatCard(
//           label: 'Remaining',
//           value: _currencyFormatter.format(widget.goal.remainingAmount),
//           color: AppColors.deepNavy,
//           icon: Icons.trending_up,
//           delay: 300,
//           targetValue: widget.goal.remainingAmount,
//         ),
//         _AnimatedStatCard(
//           label: 'Days Left',
//           value: '${widget.goal.daysRemaining}',
//           color: AppColors.textSecondary,
//           icon: Icons.calendar_today,
//           delay: 400,
//           targetValue: widget.goal.daysRemaining.toDouble(),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryInfo() {
//     return Container(
//       decoration: BoxDecoration(
//         color: widget.goal.category.color.withAlpha(12),
//         borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//         border: Border.all(color: widget.goal.category.color.withAlpha(25)),
//       ),
//       padding: const EdgeInsets.all(AppSpacing.md),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: widget.goal.category.color.withAlpha(25),
//               borderRadius: BorderRadius.circular(AppBorderRadius.small),
//             ),
//             padding: const EdgeInsets.all(AppSpacing.sm),
//             child: Icon(
//               _getCategoryIcon(widget.goal.category),
//               color: widget.goal.category.color,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: AppSpacing.md),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Category',
//                   style: AppTextTheme.bodySmall.copyWith(
//                     color: AppColors.textSecondary,
//                     fontSize: 11,
//                   ),
//                 ),
//                 const SizedBox(height: AppSpacing.xs),
//                 Text(
//                   widget.goal.category.label,
//                   style: AppTextTheme.bodyRegular.copyWith(
//                     color: widget.goal.category.color,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppSpacing.sm,
//               vertical: AppSpacing.xs,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(AppBorderRadius.small),
//             ),
//             child: Text(
//               widget.goal.category.emoji,
//               style: const TextStyle(fontSize: 20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionSection() {
//     if (widget.goal.isCompleted) {
//       return TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0.0, end: 1.0),
//         duration: const Duration(milliseconds: 600),
//         curve: Curves.easeOutBack,
//         builder: (context, value, child) {
//           return Transform.scale(
//             scale: value,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.tealSuccess.withAlpha(25),
//                     AppColors.tealSuccess.withAlpha(12),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//                 border: Border.all(color: AppColors.tealSuccess.withAlpha(50)),
//               ),
//               padding: const EdgeInsets.all(AppSpacing.md),
//               child: Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.tealSuccess.withAlpha(25),
//                       borderRadius: BorderRadius.circular(
//                         AppBorderRadius.medium,
//                       ),
//                     ),
//                     padding: const EdgeInsets.all(AppSpacing.sm),
//                     child: Icon(
//                       Icons.check_circle,
//                       color: AppColors.tealSuccess,
//                       size: 28,
//                     ),
//                   ),
//                   const SizedBox(width: AppSpacing.md),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Goal Completed! 🎉',
//                           style: AppTextTheme.bodyRegular.copyWith(
//                             color: AppColors.tealSuccess,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: AppSpacing.xs),
//                         Text(
//                           'You\'ve reached your target!',
//                           style: AppTextTheme.bodySmall.copyWith(
//                             color: AppColors.tealSuccess,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     }

//     return SizedBox(
//       width: double.infinity,
//       child: PrimaryButton(label: 'Add Funds', onPressed: widget.onAddFunds),
//     );
//   }

//   IconData _getCategoryIcon(GoalCategory category) {
//     switch (category) {
//       case GoalCategory.vacation:
//         return Icons.flight_takeoff;
//       case GoalCategory.realestate:
//         return Icons.home;
//       case GoalCategory.education:
//         return Icons.school;
//       case GoalCategory.vehicle:
//         return Icons.directions_car;
//       case GoalCategory.wedding:
//         return Icons.favorite;
//       case GoalCategory.business:
//         return Icons.business_center;
//       case GoalCategory.investment:
//         return Icons.trending_up;
//       case GoalCategory.retirement:
//         return Icons.beach_access;
//       case GoalCategory.emergency:
//         return Icons.health_and_safety;
//       case GoalCategory.other:
//         return Icons.flag;
//     }
//   }
// }

// // ==================== ANIMATED STAT CARD ====================

// class _AnimatedStatCard extends StatefulWidget {
//   final String label;
//   final String value;
//   final Color color;
//   final IconData icon;
//   final int delay;
//   final double targetValue;

//   const _AnimatedStatCard({
//     required this.label,
//     required this.value,
//     required this.color,
//     required this.icon,
//     required this.delay,
//     required this.targetValue,
//   });

//   @override
//   State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
// }

// class _AnimatedStatCardState extends State<_AnimatedStatCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           decoration: BoxDecoration(
//             color: widget.color.withAlpha(12),
//             borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//             border: Border.all(color: widget.color.withAlpha(25)),
//           ),
//           padding: const EdgeInsets.all(AppSpacing.md),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     widget.label,
//                     style: AppTextTheme.bodySmall.copyWith(
//                       color: AppColors.textSecondary,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Icon(
//                     widget.icon,
//                     color: widget.color.withAlpha(180),
//                     size: 16,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               Text(
//                 widget.value,
//                 style: AppTextTheme.bodyRegular.copyWith(
//                   color: widget.color,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
