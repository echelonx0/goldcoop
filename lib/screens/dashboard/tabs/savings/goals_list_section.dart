// lib/screens/dashboard/tabs/savings/goals_list_section.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/admin_design_system.dart';
import '../../../../models/goals_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../calculator/investment_calculator.dart';
import 'goal_progress_card.dart';

class GoalsListSection extends StatelessWidget {
  final String uid;
  final VoidCallback onCreateGoal;
  final Function(GoalModel) onViewGoal;
  final Function(GoalModel) onAddToGoal;

  const GoalsListSection({
    super.key,
    required this.uid,
    required this.onCreateGoal,
    required this.onViewGoal,
    required this.onAddToGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: AdminDesignSystem.spacing16),
        StreamBuilder<List<GoalModel>>(
          stream: FirestoreService().getUserGoalsStream(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
                  child: CircularProgressIndicator(
                    color: AdminDesignSystem.accentTeal,
                  ),
                ),
              );
            }

            final goals = snapshot.data ?? [];
            final activeGoals = goals
                .where((g) => g.status == GoalStatus.active)
                .toList();

            if (activeGoals.isEmpty) {
              return _buildEmptyState(onCreateGoal);
            }

            return Column(
              children: List.generate(
                activeGoals.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AdminDesignSystem.spacing12,
                  ),
                  child: GoalProgressCard(
                    goal: activeGoals[index],
                    animationIndex: index,
                    onAddFunds: () => onAddToGoal(activeGoals[index]),
                    onViewDetails: () => onViewGoal(activeGoals[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Savings Goals & Calculator',
                style: AdminDesignSystem.headingMedium.copyWith(
                  color: AdminDesignSystem.primaryNavy,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing4),
              Text(
                'Plan, save towards specific goals and track progress',
                style: AdminDesignSystem.bodySmall,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onCreateGoal,
          child: Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
            decoration: BoxDecoration(
              color: AdminDesignSystem.accentTeal,
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
        SizedBox(width: AdminDesignSystem.spacing12),
        GestureDetector(
          onTap: () {
            // Show investment calculator
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SavingsInvestmentCalculatorScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
            decoration: BoxDecoration(
              color: AdminDesignSystem.accentTeal,
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
            ),
            child: Icon(Icons.calculate_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(VoidCallback onCreateGoal) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: AdminDesignSystem.cardDecoration,
        padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AdminDesignSystem.accentTeal.withAlpha(38),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
              ),
              padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
              child: Icon(
                Icons.flag_outlined,
                size: 48,
                color: AdminDesignSystem.accentTeal,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing20),
            Text(
              'No savings goals yet',
              style: AdminDesignSystem.headingMedium.copyWith(
                color: AdminDesignSystem.primaryNavy,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            Text(
              'Create your first goal to start\nsaving with purpose',
              style: AdminDesignSystem.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AdminDesignSystem.spacing24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCreateGoal,
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
                  'Create Goal',
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
    );
  }
}
