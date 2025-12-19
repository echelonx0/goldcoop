import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/support_models.dart';
import '../../../services/support_service.dart';

class FAQWidget extends StatefulWidget {
  final String? initialCategory;
  final bool showHeader;
  final VoidCallback? onContactSupport;

  const FAQWidget({
    super.key,
    this.initialCategory,
    this.showHeader = true,
    this.onContactSupport,
  });

  @override
  State<FAQWidget> createState() => _FAQWidgetState();
}

class _FAQWidgetState extends State<FAQWidget> {
  late final SupportService _supportService;
  final _searchController = TextEditingController();
  String? _selectedCategory;
  List<FAQItem> _searchResults = [];
  bool _isSearching = false;

  final categories = ['general', 'billing', 'account', 'investments', 'goals'];
  final categoryIcons = {
    'general': Icons.help_outline,
    'billing': Icons.payment,
    'account': Icons.person,
    'investments': Icons.trending_up,
    'goals': Icons.flag_outlined,
  };

  @override
  void initState() {
    super.initState();
    _supportService = SupportService();
    _selectedCategory = widget.initialCategory;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _supportService.searchFAQ(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader) ...[
            DelayedDisplay(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: AdminDesignSystem.headingLarge.copyWith(
                        color: AdminDesignSystem.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing8),
                    Text(
                      'Find answers to common questions',
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Search bar
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminDesignSystem.spacing16,
                vertical: AdminDesignSystem.spacing12,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search FAQ...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AdminDesignSystem.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius12,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AdminDesignSystem.spacing12,
                    vertical: AdminDesignSystem.spacing12,
                  ),
                ),
                style: AdminDesignSystem.bodyMedium.copyWith(
                  color: AdminDesignSystem.textPrimary,
                ),
              ),
            ),
          ),

          // Category filter
          if (!_isSearching)
            DelayedDisplay(
              delay: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminDesignSystem.spacing16,
                  vertical: AdminDesignSystem.spacing12,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(null, 'All'),
                      ...categories.map(
                        (category) =>
                            _buildCategoryChip(category, category.capitalize()),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // FAQ items or search results
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing16,
              vertical: AdminDesignSystem.spacing12,
            ),
            child: _searchResults.isNotEmpty
                ? _buildSearchResults()
                : _buildFAQList(),
          ),

          // Contact support button
          if (widget.onContactSupport != null)
            Padding(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onContactSupport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminDesignSystem.accentTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AdminDesignSystem.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius12,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Still need help? Create a support ticket',
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: AdminDesignSystem.spacing8),
      child: DelayedDisplay(
        delay: Duration(
          milliseconds: 350 + (categories.indexOf(category.toString()) * 50),
        ),
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedCategory = selected ? category : null);
          },
          selectedColor: AdminDesignSystem.accentTeal,
          labelStyle: AdminDesignSystem.bodySmall.copyWith(
            color: isSelected ? Colors.white : AdminDesignSystem.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          side: BorderSide(
            color: isSelected
                ? AdminDesignSystem.accentTeal
                : AdminDesignSystem.divider,
          ),
        ),
      ),
    );
  }

  Widget _buildFAQList() {
    return StreamBuilder<List<FAQItem>>(
      stream: _supportService.getFAQItemsStream(category: _selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing32),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 48,
                    color: AdminDesignSystem.textTertiary,
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing16),
                  Text(
                    'No FAQs found',
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AdminDesignSystem.spacing12),
          itemBuilder: (context, index) {
            return DelayedDisplay(
              delay: Duration(milliseconds: 400 + (index * 50)),
              child: _FAQItemCard(
                item: items[index],
                onHelpful: (isHelpful) =>
                    _handleHelpful(items[index].id, isHelpful),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DelayedDisplay(
          delay: const Duration(milliseconds: 200),
          child: Text(
            'Search Results (${_searchResults.length})',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AdminDesignSystem.spacing12),
          itemBuilder: (context, index) {
            return DelayedDisplay(
              delay: Duration(milliseconds: 300 + (index * 50)),
              child: _FAQItemCard(
                item: _searchResults[index],
                onHelpful: (isHelpful) =>
                    _handleHelpful(_searchResults[index].id, isHelpful),
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleHelpful(String faqId, bool isHelpful) {
    _supportService.markFAQHelpful(faqId, isHelpful);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHelpful
              ? 'Thanks for the feedback!'
              : 'Your feedback helps us improve',
          style: AdminDesignSystem.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AdminDesignSystem.accentTeal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ==================== FAQ ITEM CARD ====================

class _FAQItemCard extends StatefulWidget {
  final FAQItem item;
  final Function(bool) onHelpful;

  const _FAQItemCard({required this.item, required this.onHelpful});

  @override
  State<_FAQItemCard> createState() => _FAQItemCardState();
}

class _FAQItemCardState extends State<_FAQItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.item.category);

    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        border: Border.all(color: AdminDesignSystem.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              child: Padding(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon
                    Container(
                      padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius8,
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(widget.item.category),
                        size: 20,
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),

                    // Question
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.question,
                            style: AdminDesignSystem.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AdminDesignSystem.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.item.tags.isNotEmpty) ...[
                            const SizedBox(height: AdminDesignSystem.spacing4),
                            Wrap(
                              spacing: 4,
                              children: widget.item.tags.take(2).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withAlpha(38),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag,
                                    style: AdminDesignSystem.labelSmall
                                        .copyWith(
                                          color: categoryColor,
                                          fontSize: 10,
                                        ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Expand icon
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded content
          ClipRect(
            child: SizeTransition(
              sizeFactor: _heightAnimation,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AdminDesignSystem.divider),
                  ),
                ),
                padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Answer
                    Text(
                      widget.item.answer,
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing16),

                    // Helpful buttons
                    _buildHelpfulButtons(categoryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpfulButtons(Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
      decoration: BoxDecoration(
        color: AdminDesignSystem.background,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
      ),
      child: Row(
        children: [
          Text(
            'Was this helpful?',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 32,
            child: Row(
              children: [
                _buildHelpButton(
                  icon: Icons.thumb_up_outlined,
                  isActive: true,
                  onTap: () => widget.onHelpful(true),
                  color: AdminDesignSystem.statusActive,
                ),
                const SizedBox(width: AdminDesignSystem.spacing8),
                _buildHelpButton(
                  icon: Icons.thumb_down_outlined,
                  isActive: false,
                  onTap: () => widget.onHelpful(false),
                  color: AdminDesignSystem.statusError,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminDesignSystem.spacing8,
            vertical: AdminDesignSystem.spacing4,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'billing':
        return const Color(0xFF3498DB);
      case 'account':
        return const Color(0xFF9B59B6);
      case 'investments':
        return AdminDesignSystem.accentTeal;
      case 'goals':
        return const Color(0xFFF39C12);
      default:
        return AdminDesignSystem.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'billing':
        return Icons.payment;
      case 'account':
        return Icons.person;
      case 'investments':
        return Icons.trending_up;
      case 'goals':
        return Icons.flag_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
