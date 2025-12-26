// lib/screens/dashboard/modals/learning_center_modal.dart

import 'package:flutter/material.dart';
import '../../../core/theme/admin_design_system.dart';

class LearningCenterModal extends StatefulWidget {
  final String userId;
  final Future<bool> Function(LearningInterestModel) onSubmitInterest;

  const LearningCenterModal({
    super.key,
    required this.userId,
    required this.onSubmitInterest,
  });

  @override
  State<LearningCenterModal> createState() => _LearningCenterModalState();
}

class _LearningCenterModalState extends State<LearningCenterModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final Set<String> _selectedTopics = {};
  final TextEditingController _customTopicController = TextEditingController();
  final FocusNode _customTopicFocus = FocusNode();

  bool _isSubmitting = false;
  bool _showCustomInput = false;
  bool _submitted = false;

  static const List<_TopicOption> _predefinedTopics = [
    _TopicOption(
      id: 'budgeting',
      title: 'Budgeting Basics',
      icon: Icons.account_balance_wallet_outlined,
      description: 'Track income & expenses',
    ),
    _TopicOption(
      id: 'saving_strategies',
      title: 'Saving Strategies',
      icon: Icons.savings_outlined,
      description: 'Build your savings faster',
    ),
    _TopicOption(
      id: 'investing_101',
      title: 'Investing 101',
      icon: Icons.trending_up,
      description: 'Start your investment journey',
    ),
    _TopicOption(
      id: 'gold_investment',
      title: 'Gold Investment',
      icon: Icons.star_outline,
      description: 'Why and how to invest in gold',
    ),
    _TopicOption(
      id: 'debt_management',
      title: 'Debt Management',
      icon: Icons.credit_card_outlined,
      description: 'Pay off debt strategically',
    ),
    _TopicOption(
      id: 'emergency_fund',
      title: 'Emergency Funds',
      icon: Icons.health_and_safety_outlined,
      description: 'Prepare for the unexpected',
    ),
    _TopicOption(
      id: 'retirement_planning',
      title: 'Retirement Planning',
      icon: Icons.beach_access_outlined,
      description: 'Secure your future',
    ),
    _TopicOption(
      id: 'tax_basics',
      title: 'Tax Basics',
      icon: Icons.receipt_long_outlined,
      description: 'Understand your taxes',
    ),
  ];

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

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _customTopicController.dispose();
    _customTopicFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AdminDesignSystem.radius24),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Expanded(
            child: _submitted ? _buildSuccessState() : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AdminDesignSystem.spacing12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AdminDesignSystem.textTertiary.withAlpha(77),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMainContent() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(),
                const SizedBox(height: AdminDesignSystem.spacing24),
                _buildComingSoonBanner(),
                const SizedBox(height: AdminDesignSystem.spacing24),
                _buildTopicsSection(),
                const SizedBox(height: AdminDesignSystem.spacing16),
                _buildTopicsGrid(),
                const SizedBox(height: AdminDesignSystem.spacing16),
                _buildCustomTopicSection(),
                const SizedBox(height: AdminDesignSystem.spacing24),
                _buildSubmitButton(),
                const SizedBox(height: AdminDesignSystem.spacing32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3498DB),
                const Color(0xFF3498DB).withAlpha(179),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          ),
          child: const Icon(
            Icons.school_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: AdminDesignSystem.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning Center',
                style: AdminDesignSystem.headingLarge.copyWith(
                  color: AdminDesignSystem.primaryNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Financial education, your way',
                style: AdminDesignSystem.bodySmall.copyWith(
                  color: AdminDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: AdminDesignSystem.textSecondary),
        ),
      ],
    );
  }

  Widget _buildComingSoonBanner() {
    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminDesignSystem.primaryNavy,
            AdminDesignSystem.primaryNavy.withAlpha(230),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Coming Soon',
                      style: AdminDesignSystem.headingMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminDesignSystem.spacing8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AdminDesignSystem.accentTeal,
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius8,
                        ),
                      ),
                      child: Text(
                        '2025',
                        style: AdminDesignSystem.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  'We\'re building something special. Help us tailor it to your needs.',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: Colors.white.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to learn?',
          style: AdminDesignSystem.headingMedium.copyWith(
            color: AdminDesignSystem.primaryNavy,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          'Select all topics that interest you',
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AdminDesignSystem.spacing12,
        crossAxisSpacing: AdminDesignSystem.spacing12,
        childAspectRatio: 1.4,
      ),
      itemCount: _predefinedTopics.length,
      itemBuilder: (context, index) {
        final topic = _predefinedTopics[index];
        final isSelected = _selectedTopics.contains(topic.id);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _TopicCard(
            topic: topic,
            isSelected: isSelected,
            onTap: () => _toggleTopic(topic.id),
          ),
        );
      },
    );
  }

  Widget _buildCustomTopicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _showCustomInput = !_showCustomInput;
                if (_showCustomInput) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _customTopicFocus.requestFocus();
                  });
                }
              });
            },
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            child: Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              decoration: BoxDecoration(
                color: AdminDesignSystem.background,
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                border: Border.all(
                  color: _showCustomInput
                      ? AdminDesignSystem.accentTeal
                      : AdminDesignSystem.divider,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _showCustomInput ? Icons.edit : Icons.add_circle_outline,
                    color: _showCustomInput
                        ? AdminDesignSystem.accentTeal
                        : AdminDesignSystem.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing12),
                  Expanded(
                    child: Text(
                      _showCustomInput
                          ? 'Tell us what else you\'d like to learn'
                          : 'Something else? Let us know!',
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        color: _showCustomInput
                            ? AdminDesignSystem.accentTeal
                            : AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    _showCustomInput
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AdminDesignSystem.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Custom input field
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: _showCustomInput
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: AdminDesignSystem.spacing12,
                  ),
                  child: TextFormField(
                    controller: _customTopicController,
                    focusNode: _customTopicFocus,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText:
                          'E.g., "How to start a side business" or "Understanding cryptocurrency"',
                      hintStyle: AdminDesignSystem.bodyMedium.copyWith(
                        color: AdminDesignSystem.textTertiary,
                      ),
                      filled: true,
                      fillColor: AdminDesignSystem.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                        borderSide: BorderSide(
                          color: AdminDesignSystem.accentTeal,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(
                        AdminDesignSystem.spacing16,
                      ),
                      counterStyle: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textTertiary,
                      ),
                    ),
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      color: AdminDesignSystem.textPrimary,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final hasSelection =
        _selectedTopics.isNotEmpty ||
        _customTopicController.text.trim().isNotEmpty;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasSelection && !_isSubmitting ? _submitInterests : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminDesignSystem.accentTeal,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AdminDesignSystem.textTertiary.withAlpha(
                77,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AdminDesignSystem.spacing16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Submit My Interests',
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing12),
        Text(
          'We\'ll notify you when relevant content is ready',
          style: AdminDesignSystem.labelSmall.copyWith(
            color: AdminDesignSystem.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing24),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.statusActive.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AdminDesignSystem.statusActive,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing24),
              Text(
                'Thank You!',
                style: AdminDesignSystem.headingLarge.copyWith(
                  color: AdminDesignSystem.primaryNavy,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing8),
              Text(
                'Your interests have been saved.\nWe\'ll build content just for you.',
                style: AdminDesignSystem.bodyMedium.copyWith(
                  color: AdminDesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AdminDesignSystem.spacing32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AdminDesignSystem.spacing16,
                    ),
                    side: BorderSide(color: AdminDesignSystem.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius12,
                      ),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AdminDesignSystem.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleTopic(String topicId) {
    setState(() {
      if (_selectedTopics.contains(topicId)) {
        _selectedTopics.remove(topicId);
      } else {
        _selectedTopics.add(topicId);
      }
    });
  }

  Future<void> _submitInterests() async {
    setState(() => _isSubmitting = true);

    final interest = LearningInterestModel(
      userId: widget.userId,
      selectedTopics: _selectedTopics.toList(),
      customTopic: _customTopicController.text.trim().isNotEmpty
          ? _customTopicController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    final success = await widget.onSubmitInterest(interest);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (success) {
          _submitted = true;
        }
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save. Please try again.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AdminDesignSystem.statusError,
          ),
        );
      }
    }
  }
}

// ==================== TOPIC CARD ====================

class _TopicCard extends StatelessWidget {
  final _TopicOption topic;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
          decoration: BoxDecoration(
            color: isSelected
                ? AdminDesignSystem.accentTeal.withAlpha(26)
                : AdminDesignSystem.cardBackground,
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            border: Border.all(
              color: isSelected
                  ? AdminDesignSystem.accentTeal
                  : AdminDesignSystem.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    topic.icon,
                    size: 20,
                    color: isSelected
                        ? AdminDesignSystem.accentTeal
                        : AdminDesignSystem.textSecondary,
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AdminDesignSystem.accentTeal
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AdminDesignSystem.accentTeal
                            : AdminDesignSystem.textTertiary,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                topic.title,
                style: AdminDesignSystem.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AdminDesignSystem.primaryNavy
                      : AdminDesignSystem.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                topic.description,
                style: AdminDesignSystem.labelSmall.copyWith(
                  color: AdminDesignSystem.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== DATA CLASSES ====================

class _TopicOption {
  final String id;
  final String title;
  final IconData icon;
  final String description;

  const _TopicOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}

class LearningInterestModel {
  final String? interestId;
  final String userId;
  final List<String> selectedTopics;
  final String? customTopic;
  final DateTime createdAt;

  LearningInterestModel({
    this.interestId,
    required this.userId,
    required this.selectedTopics,
    this.customTopic,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'interestId': interestId,
      'userId': userId,
      'selectedTopics': selectedTopics,
      'customTopic': customTopic,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LearningInterestModel.fromJson(Map<String, dynamic> json) {
    return LearningInterestModel(
      interestId: json['interestId'],
      userId: json['userId'] ?? '',
      selectedTopics: List<String>.from(json['selectedTopics'] ?? []),
      customTopic: json['customTopic'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
