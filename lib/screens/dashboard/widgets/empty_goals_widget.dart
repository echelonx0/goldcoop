import 'package:flutter/material.dart';
import '../../../core/theme/admin_design_system.dart';

class EmptyGoalsState extends StatefulWidget {
  final VoidCallback? onCreateGoal;

  const EmptyGoalsState({super.key, this.onCreateGoal});

  @override
  State<EmptyGoalsState> createState() => _EmptyGoalsStateState();
}

class _EmptyGoalsStateState extends State<EmptyGoalsState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            child: Column(
              children: [
                // Main empty state card
                Container(
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
                  decoration: BoxDecoration(
                    color: AdminDesignSystem.cardBackground,
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius16,
                    ),
                    border: Border.all(color: AdminDesignSystem.divider),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                          AdminDesignSystem.spacing16,
                        ),
                        decoration: BoxDecoration(
                          color: AdminDesignSystem.accentTeal.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flag_outlined,
                          size: 48,
                          color: AdminDesignSystem.accentTeal,
                        ),
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing20),
                      Text(
                        'Start Saving for Your Goals',
                        style: AdminDesignSystem.headingMedium.copyWith(
                          color: AdminDesignSystem.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing12),
                      Text(
                        'Create goals and track your progress towards achieving your dreams',
                        style: AdminDesignSystem.bodySmall.copyWith(
                          color: AdminDesignSystem.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onCreateGoal,
                          icon: const Icon(Icons.add_outlined),
                          label: const Text('Create Your First Goal'),
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing24),

                // How It Works section
                Text(
                  'How It Works',
                  style: AdminDesignSystem.headingMedium.copyWith(
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Step 1
                _buildStepCard(
                  number: '1',
                  icon: Icons.tag_rounded,
                  title: 'Set a Goal',
                  description:
                      'Define what you\'re saving for and the target amount',
                  color: AdminDesignSystem.accentTeal,
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),

                // Step 2
                _buildStepCard(
                  number: '2',
                  icon: Icons.savings_outlined,
                  title: 'Add Funds',
                  description: 'Contribute from your account balance regularly',
                  color: AdminDesignSystem.statusActive,
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),

                // Step 3
                _buildStepCard(
                  number: '3',
                  icon: Icons.trending_up_outlined,
                  title: 'Track Progress',
                  description: 'Watch your savings grow towards your goal',
                  color: AdminDesignSystem.statusPending,
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),

                // Pro tip section
                Container(
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                  decoration: BoxDecoration(
                    color: AdminDesignSystem.accentTeal.withAlpha(12),
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius12,
                    ),
                    border: Border.all(
                      color: AdminDesignSystem.accentTeal.withAlpha(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outlined,
                            size: 20,
                            color: AdminDesignSystem.accentTeal,
                          ),
                          const SizedBox(width: AdminDesignSystem.spacing12),
                          Text(
                            'Pro Tip',
                            style: AdminDesignSystem.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AdminDesignSystem.accentTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing12),
                      Text(
                        'Set multiple goals for different purposes. Whether it\'s a vacation, car, home, or emergency fund - having clear targets helps you stay motivated and disciplined.',
                        style: AdminDesignSystem.bodySmall.copyWith(
                          color: AdminDesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing24),

                // Goal ideas section
                Container(
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                  decoration: BoxDecoration(
                    color: AdminDesignSystem.background,
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius12,
                    ),
                    border: Border.all(color: AdminDesignSystem.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Popular Goal Ideas',
                        style: AdminDesignSystem.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AdminDesignSystem.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildGoalTag('🏠 Home'),
                          _buildGoalTag('🚗 Car'),
                          _buildGoalTag('✈️ Vacation'),
                          _buildGoalTag('📚 Education'),
                          _buildGoalTag('💍 Wedding'),
                          _buildGoalTag('🏥 Emergency'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String number,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        border: Border.all(color: AdminDesignSystem.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
            ),
            child: Center(
              child: Text(
                number,
                style: AdminDesignSystem.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing12,
        vertical: AdminDesignSystem.spacing8,
      ),
      decoration: BoxDecoration(
        color: AdminDesignSystem.accentTeal.withAlpha(12),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
        border: Border.all(color: AdminDesignSystem.accentTeal.withAlpha(25)),
      ),
      child: Text(
        label,
        style: AdminDesignSystem.bodySmall.copyWith(
          color: AdminDesignSystem.accentTeal,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
