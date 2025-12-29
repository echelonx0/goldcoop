// // lib/screens/dashboard/tabs/savings_tab.dart
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import '../../../core/theme/admin_design_system.dart';
// import '../../../models/goals_model.dart';
// import '../../../services/firestore_service.dart';
// import 'savings/goal-detail/goal_detail_sheet.dart';
// import 'savings/goal_creation_form.dart';
// import 'savings/add_to_goal_form.dart';
// import 'savings/set_savings_target_form.dart';
// import 'savings/goals_list_section.dart';
// import 'savings/general_savings_section.dart';

// class SavingsTab extends StatefulWidget {
//   final String uid;
//   final VoidCallback? onCreatePlan;

//   const SavingsTab({super.key, required this.uid, this.onCreatePlan});

//   @override
//   State<SavingsTab> createState() => _SavingsTabState();
// }

// class _SavingsTabState extends State<SavingsTab> with TickerProviderStateMixin {
//   late final FirestoreService _firestoreService;
//   late TabController _tabController;
//   late AnimationController _fadeController;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreService = FirestoreService();
//     _tabController = TabController(length: 2, vsync: this);
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     )..forward();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AdminDesignSystem.background,
//       // appBar: _buildAppBar(),
//       body: FadeTransition(
//         opacity: _fadeController,
//         child: TabBarView(
//           controller: _tabController,
//           children: [_buildGoalsTab(), _buildGeneralSavingsTab()],
//         ),
//       ),
//     );
//   }

//   Widget _buildGoalsTab() {
//     return CustomScrollView(
//       slivers: [
//         SliverPadding(
//           padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//           sliver: SliverList(
//             delegate: SliverChildListDelegate([
//               GoalsListSection(
//                 uid: widget.uid,
//                 onCreateGoal: _showCreateGoalSheet,
//                 onViewGoal: _showGoalDetailsSheet,
//                 onAddToGoal: _showAddToGoalSheet,
//               ),
//               const SizedBox(height: AdminDesignSystem.spacing16),
//             ]),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGeneralSavingsTab() {
//     return CustomScrollView(
//       slivers: [
//         SliverPadding(
//           padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//           sliver: SliverList(
//             delegate: SliverChildListDelegate([
//               GeneralSavingsSection(
//                 uid: widget.uid,
//                 onSetTarget: _showSetSavingsTargetSheet,
//               ),
//               const SizedBox(height: AdminDesignSystem.spacing16),
//             ]),
//           ),
//         ),
//       ],
//     );
//   }

//   // Modal sheets
//   void _showCreateGoalSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => GoalCreationForm(
//         onCreateGoal: (goal) => _handleCreateGoal(goal),
//         onCancel: () => Navigator.pop(context),
//       ),
//     );
//   }

//   void _showAddToGoalSheet(GoalModel goal) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => AddToGoalForm(
//         goal: goal,
//         onContribute: (amount) => _handleAddToGoal(goal, amount),
//         onCancel: () => Navigator.pop(context),
//       ),
//     );
//   }

//   void _showGoalDetailsSheet(GoalModel goal) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => GoalDetailSheet(
//         goal: goal,
//         onAddFunds: () {
//           Navigator.pop(context);
//           _showAddToGoalSheet(goal);
//         },
//         onClose: () => Navigator.pop(context),
//       ),
//     );
//   }

//   void _showSetSavingsTargetSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => SetSavingsTargetForm(
//         onSetTarget: (amount) => _handleSetSavingsTarget(amount),
//         onCancel: () => Navigator.pop(context),
//       ),
//     );
//   }

//   // Action handlers
//   Future<void> _handleCreateGoal(GoalModel goal) async {
//     final success = await _firestoreService.createGoal(widget.uid, goal);

//     if (mounted) {
//       Navigator.pop(context);
//       if (success != null) {
//         _showSuccessSnackbar('Goal created successfully');
//       } else {
//         _showErrorSnackbar('Failed to create goal');
//       }
//     }
//   }

//   Future<void> _handleAddToGoal(GoalModel goal, double amount) async {
//     final success = await _firestoreService.contributeToGoal(
//       uid: widget.uid,
//       goalId: goal.goalId,
//       amount: amount,
//       description: 'Contribution to ${goal.title}',
//     );

//     if (mounted) {
//       Navigator.pop(context);
//       if (success) {
//         _showSuccessSnackbar('Added to goal successfully');
//       } else {
//         _showErrorSnackbar('Failed to add to goal');
//       }
//     }
//   }

//   Future<void> _handleSetSavingsTarget(double amount) async {
//     final success = await _firestoreService.updateFinancialProfile(
//       uid: widget.uid,
//       savingsTarget: amount,
//     );

//     if (mounted) {
//       Navigator.pop(context);
//       if (success) {
//         final user = await _firestoreService.getUser(widget.uid);
//         log(
//           'After save - savingsTarget: ${user?.financialProfile.savingsTarget}',
//         );

//         _showSuccessSnackbar('Savings target set');
//       } else {
//         _showErrorSnackbar('Failed to set target');
//       }
//     }
//   }

//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: AdminDesignSystem.statusActive,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: AdminDesignSystem.statusError,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }

// lib/screens/dashboard/tabs/savings_tab.dart

import 'package:flutter/material.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/goals_model.dart';
import '../../../services/firestore_service.dart';
import 'savings/goal-detail/goal_detail_sheet.dart';
import 'savings/goal_creation_form.dart';
import 'savings/add_to_goal_form.dart';
import 'savings/goals_list_section.dart';

class SavingsTab extends StatefulWidget {
  final String uid;
  final VoidCallback? onCreatePlan;

  const SavingsTab({super.key, required this.uid, this.onCreatePlan});

  @override
  State<SavingsTab> createState() => _SavingsTabState();
}

class _SavingsTabState extends State<SavingsTab> with TickerProviderStateMixin {
  late final FirestoreService _firestoreService;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      body: FadeTransition(
        opacity: _fadeController,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  GoalsListSection(
                    uid: widget.uid,
                    onCreateGoal: _showCreateGoalSheet,
                    onViewGoal: _showGoalDetailsSheet,
                    onAddToGoal: _showAddToGoalSheet,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalCreationForm(
        onCreateGoal: (goal) => _handleCreateGoal(goal),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showAddToGoalSheet(GoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToGoalForm(
        goal: goal,
        onContribute: (amount) => _handleAddToGoal(goal, amount),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showGoalDetailsSheet(GoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalDetailSheet(
        goal: goal,
        onAddFunds: () {
          Navigator.pop(context);
          _showAddToGoalSheet(goal);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _handleCreateGoal(GoalModel goal) async {
    final success = await _firestoreService.createGoal(widget.uid, goal);

    if (mounted) {
      Navigator.pop(context);
      if (success != null) {
        _showSuccessSnackbar('Goal created successfully');
      } else {
        _showErrorSnackbar('Failed to create goal');
      }
    }
  }

  Future<void> _handleAddToGoal(GoalModel goal, double amount) async {
    final success = await _firestoreService.contributeToGoal(
      uid: widget.uid,
      goalId: goal.goalId,
      amount: amount,
      description: 'Contribution to ${goal.title}',
    );

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        _showSuccessSnackbar('Added to goal successfully');
      } else {
        _showErrorSnackbar('Failed to add to goal');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminDesignSystem.statusActive,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminDesignSystem.statusError,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
