// lib/screens/admin/widgets/learning_center_submissions_widget.dart
// Admin view for all Learning Center submissions

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../services/firestore_service.dart';
import '../../dashboard/modals/learning_interest_modal.dart';

class LearningCenterSubmissionsWidget extends StatefulWidget {
  const LearningCenterSubmissionsWidget({super.key});

  @override
  State<LearningCenterSubmissionsWidget> createState() =>
      _LearningCenterSubmissionsWidgetState();
}

class _LearningCenterSubmissionsWidgetState
    extends State<LearningCenterSubmissionsWidget> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<LearningInterestModel> _allSubmissions = [];
  List<LearningInterestModel> _filteredSubmissions = [];
  Map<String, int> _topicCounts = {};
  List<String> _customTopics = [];

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
    _searchController.addListener(_filterSubmissions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    setState(() => _isLoading = true);

    try {
      final submissions = await _firestoreService.getAllLearningInterests(
        limit: 500,
      );
      final topicCounts = await _firestoreService.getLearningTopicCounts();
      final customTopics = await _firestoreService.getCustomTopicSuggestions();

      setState(() {
        _allSubmissions = submissions;
        _filteredSubmissions = submissions;
        _topicCounts = topicCounts;
        _customTopics = customTopics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading submissions: $e'),
            backgroundColor: AdminDesignSystem.statusError,
          ),
        );
      }
    }
  }

  void _filterSubmissions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredSubmissions = _allSubmissions
          .where(
            (submission) =>
                submission.userId.toLowerCase().contains(query) ||
                (submission.customTopic != null &&
                    submission.customTopic!.toLowerCase().contains(query)),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: AdminDesignSystem.spacing20),
        _buildAnalytics(),
        const SizedBox(height: AdminDesignSystem.spacing20),
        _buildSearchBar(),
        const SizedBox(height: AdminDesignSystem.spacing16),
        Expanded(
          child: _isLoading ? _buildLoadingState() : _buildSubmissionsList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Center Submissions',
            style: AdminDesignSystem.headingMedium.copyWith(
              color: AdminDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing4),
          Text(
            'Manage user learning interests and feedback',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 180),
      child: Container(
        decoration: AdminDesignSystem.cardDecoration,
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Submissions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Submissions',
                      style: AdminDesignSystem.labelMedium.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing4),
                    Text(
                      _allSubmissions.length.toString(),
                      style: AdminDesignSystem.displayLarge.copyWith(
                        color: AdminDesignSystem.accentTeal,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Topics',
                      style: AdminDesignSystem.labelMedium.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing4),
                    Text(
                      _customTopics.length.toString(),
                      style: AdminDesignSystem.displayLarge.copyWith(
                        color: AdminDesignSystem.statusActive,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            // Top Topics
            Text(
              'Top Requested Topics',
              style: AdminDesignSystem.bodyMedium.copyWith(
                color: AdminDesignSystem.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            _buildTopTopics(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTopics() {
    final topicList = _topicCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top5 = topicList.take(5).toList();

    if (top5.isEmpty) {
      return Text(
        'No topic data yet',
        style: AdminDesignSystem.bodySmall.copyWith(
          color: AdminDesignSystem.textTertiary,
        ),
      );
    }

    return Wrap(
      spacing: AdminDesignSystem.spacing8,
      runSpacing: AdminDesignSystem.spacing8,
      children: top5.map((entry) {
        final maxCount = top5.first.value.toDouble();
        final percentage = (entry.value / maxCount) * 100;

        return _buildTopicBadge(entry.key, entry.value, percentage.toInt());
      }).toList(),
    );
  }

  Widget _buildTopicBadge(String topic, int count, int percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing12,
        vertical: AdminDesignSystem.spacing8,
      ),
      decoration: BoxDecoration(
        color: AdminDesignSystem.accentTeal.withAlpha(26),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        border: Border.all(color: AdminDesignSystem.accentTeal.withAlpha(51)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            topic.replaceAll('_', ' ').toUpperCase(),
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.accentTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count users',
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 260),
      child: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by user ID or custom topic...',
          hintStyle: AdminDesignSystem.bodyMedium.copyWith(
            color: AdminDesignSystem.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: AdminDesignSystem.textTertiary,
          ),
          filled: true,
          fillColor: AdminDesignSystem.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            borderSide: BorderSide(
              color: AdminDesignSystem.accentTeal,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AdminDesignSystem.spacing16,
            vertical: AdminDesignSystem.spacing12,
          ),
        ),
        style: AdminDesignSystem.bodyMedium.copyWith(
          color: AdminDesignSystem.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: AdminDesignSystem.accentTeal),
    );
  }

  Widget _buildSubmissionsList() {
    if (_filteredSubmissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AdminDesignSystem.textTertiary,
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),
            Text(
              _allSubmissions.isEmpty
                  ? 'No submissions yet'
                  : 'No results found',
              style: AdminDesignSystem.bodyMedium.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AdminDesignSystem.spacing16),
      itemCount: _filteredSubmissions.length,
      itemBuilder: (context, index) {
        final submission = _filteredSubmissions[index];

        return DelayedDisplay(
          delay: Duration(milliseconds: 340 + (index * 50)),
          child: _buildSubmissionCard(submission),
        );
      },
    );
  }

  Widget _buildSubmissionCard(LearningInterestModel submission) {
    return Container(
      margin: const EdgeInsets.only(bottom: AdminDesignSystem.spacing12),
      decoration: AdminDesignSystem.cardDecoration,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User ID + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ID',
                      style: AdminDesignSystem.labelSmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      submission.userId,
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        color: AdminDesignSystem.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Submitted',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(submission.createdAt),
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          // Selected Topics
          if (submission.selectedTopics.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Topics',
                  style: AdminDesignSystem.labelMedium.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing8),
                Wrap(
                  spacing: AdminDesignSystem.spacing8,
                  runSpacing: AdminDesignSystem.spacing8,
                  children: submission.selectedTopics
                      .where((topic) => topic != 'custom')
                      .map((topic) => _buildTopicChip(topic))
                      .toList(),
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),
              ],
            ),

          // Custom Topic
          if (submission.hasCustomTopic)
            Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
              decoration: BoxDecoration(
                color: AdminDesignSystem.statusActive.withAlpha(13),
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
                border: Border.all(
                  color: AdminDesignSystem.statusActive.withAlpha(51),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: AdminDesignSystem.statusActive,
                      ),
                      const SizedBox(width: AdminDesignSystem.spacing8),
                      Text(
                        'Custom Topic',
                        style: AdminDesignSystem.labelSmall.copyWith(
                          color: AdminDesignSystem.statusActive,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing8),
                  Text(
                    submission.customTopic!,
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String topic) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing12,
        vertical: AdminDesignSystem.spacing8,
      ),
      decoration: BoxDecoration(
        color: AdminDesignSystem.accentTeal.withAlpha(26),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
        border: Border.all(color: AdminDesignSystem.accentTeal.withAlpha(51)),
      ),
      child: Text(
        topic.replaceAll('_', ' '),
        style: AdminDesignSystem.labelSmall.copyWith(
          color: AdminDesignSystem.accentTeal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
