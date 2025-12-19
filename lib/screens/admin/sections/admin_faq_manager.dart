import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';

import '../../../core/theme/admin_design_system.dart';
import '../../../models/support_models.dart';
import '../../../services/support_service.dart';

class AdminFAQManager extends StatefulWidget {
  const AdminFAQManager({super.key});

  @override
  State<AdminFAQManager> createState() => _AdminFAQManagerState();
}

class _AdminFAQManagerState extends State<AdminFAQManager> {
  late final SupportService _supportService;
  String _selectedCategory = 'general';
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _supportService = SupportService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      appBar: _buildAppBar(),
      body: _showForm
          ? _AdminFAQForm(
              category: _selectedCategory,
              supportService: _supportService,
              onSuccess: () {
                setState(() => _showForm = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('FAQ created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              onCancel: () => setState(() => _showForm = false),
            )
          : _FAQListView(
              supportService: _supportService,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() => _selectedCategory = category);
              },
              onAddNew: () => setState(() => _showForm = true),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AdminDesignSystem.cardBackground,
      elevation: 0,
      title: Text(
        _showForm ? 'Create FAQ' : 'FAQ Management',
        style: AdminDesignSystem.headingMedium.copyWith(
          color: AdminDesignSystem.primaryNavy,
        ),
      ),
      leading: _showForm
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _showForm = false),
            )
          : null,
    );
  }
}

// ==================== FAQ FORM WIDGET ====================

class _AdminFAQForm extends StatefulWidget {
  final String category;
  final SupportService supportService;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const _AdminFAQForm({
    required this.category,
    required this.supportService,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_AdminFAQForm> createState() => _AdminFAQFormState();
}

class _AdminFAQFormState extends State<_AdminFAQForm> {
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  late final TextEditingController _tagsController;
  late String _selectedCategory;
  int _displayOrder = 0;
  bool _isVisible = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _answerController = TextEditingController();
    _tagsController = TextEditingController();
    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submitFAQ() async {
    if (_questionController.text.isEmpty || _answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final faqItem = FAQItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory,
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        tags: _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        order: _displayOrder,
        isVisible: _isVisible,
        helpfulCount: 0,
        unhelpfulCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final success = await _saveFAQToFirestore(faqItem);

      if (!mounted) return;

      if (success) {
        setState(() => _isLoading = false);
        widget.onSuccess();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save FAQ. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<bool> _saveFAQToFirestore(FAQItem faqItem) async {
    try {
      return await widget.supportService.createFAQItem(faqItem);
    } catch (e) {
      throw Exception('Failed to save FAQ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category selector
          DelayedDisplay(
            delay: const Duration(milliseconds: 100),
            child: _buildCategorySelector(),
          ),
          const SizedBox(height: AdminDesignSystem.spacing20),

          // Question field
          DelayedDisplay(
            delay: const Duration(milliseconds: 150),
            child: _buildTextField(
              label: 'Question',
              hint: 'What is this FAQ about?',
              controller: _questionController,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Answer field
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: _buildTextField(
              label: 'Answer',
              hint: 'Provide a detailed answer...',
              controller: _answerController,
              maxLines: 8,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Tags field
          DelayedDisplay(
            delay: const Duration(milliseconds: 250),
            child: _buildTextField(
              label: 'Tags (comma-separated)',
              hint: 'e.g., billing, account, payment',
              controller: _tagsController,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Display order
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display Order',
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing8),
                Container(
                  decoration: BoxDecoration(
                    color: AdminDesignSystem.background,
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius12,
                    ),
                    border: Border.all(color: AdminDesignSystem.divider),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AdminDesignSystem.spacing12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(() {
                          if (_displayOrder > 0) _displayOrder--;
                        }),
                      ),
                      Expanded(
                        child: Text(
                          _displayOrder.toString(),
                          textAlign: TextAlign.center,
                          style: AdminDesignSystem.bodyMedium.copyWith(
                            color: AdminDesignSystem.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _displayOrder++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Visibility toggle
          DelayedDisplay(
            delay: const Duration(milliseconds: 350),
            child: Container(
              decoration: BoxDecoration(
                color: AdminDesignSystem.background,
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                border: Border.all(color: AdminDesignSystem.divider),
              ),
              padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Visible to Users',
                    style: AdminDesignSystem.bodyMedium.copyWith(
                      color: AdminDesignSystem.textPrimary,
                    ),
                  ),
                  Switch(
                    value: _isVisible,
                    onChanged: (value) => setState(() => _isVisible = value),
                    activeColor: AdminDesignSystem.accentTeal,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing24),

          // Action buttons
          DelayedDisplay(
            delay: const Duration(milliseconds: 400),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : widget.onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminDesignSystem.divider,
                      padding: const EdgeInsets.symmetric(
                        vertical: AdminDesignSystem.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        color: AdminDesignSystem.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AdminDesignSystem.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitFAQ,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminDesignSystem.accentTeal,
                      padding: const EdgeInsets.symmetric(
                        vertical: AdminDesignSystem.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Create FAQ',
                            style: AdminDesignSystem.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AdminDesignSystem.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AdminDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing8),
        Container(
          decoration: BoxDecoration(
            color: AdminDesignSystem.background,
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            border: Border.all(color: AdminDesignSystem.divider),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing12,
              vertical: AdminDesignSystem.spacing12,
            ),
            items: ['general', 'billing', 'account', 'investments', 'goals']
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(
                      category.capitalize(),
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.textPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AdminDesignSystem.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AdminDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AdminDesignSystem.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide(color: AdminDesignSystem.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide(
                color: AdminDesignSystem.accentTeal,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(AdminDesignSystem.spacing12),
          ),
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ==================== FAQ LIST VIEW ====================

class _FAQListView extends StatelessWidget {
  final SupportService supportService;
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final VoidCallback onAddNew;

  const _FAQListView({
    required this.supportService,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category filter
        DelayedDisplay(
          delay: const Duration(milliseconds: 100),
          child: Container(
            color: AdminDesignSystem.cardBackground,
            padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    ['general', 'billing', 'account', 'investments', 'goals']
                        .map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(
                              right: AdminDesignSystem.spacing8,
                            ),
                            child: FilterChip(
                              label: Text(category.capitalize()),
                              selected: selectedCategory == category,
                              onSelected: (selected) {
                                if (selected) onCategoryChanged(category);
                              },
                              selectedColor: AdminDesignSystem.accentTeal,
                              labelStyle: AdminDesignSystem.bodySmall.copyWith(
                                color: selectedCategory == category
                                    ? Colors.white
                                    : AdminDesignSystem.textPrimary,
                                fontWeight: selectedCategory == category
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),

        // FAQ list
        Expanded(
          child: StreamBuilder<List<FAQItem>>(
            stream: supportService.getFAQItemsStream(
              category: selectedCategory,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AdminDesignSystem.accentTeal,
                  ),
                );
              }

              final faqs = snapshot.data ?? [];

              if (faqs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 48,
                        color: AdminDesignSystem.textTertiary,
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing16),
                      Text(
                        'No FAQs in this category',
                        style: AdminDesignSystem.bodyMedium.copyWith(
                          color: AdminDesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                itemCount: faqs.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AdminDesignSystem.spacing12),
                itemBuilder: (context, index) {
                  return DelayedDisplay(
                    delay: Duration(milliseconds: 150 + (index * 50)),
                    child: _FAQItemCard(
                      faqItem: faqs[index],
                      supportService: supportService,
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Add button
        Padding(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
          child: DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAddNew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminDesignSystem.accentTeal,
                  padding: const EdgeInsets.symmetric(
                    vertical: AdminDesignSystem.spacing16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius12,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: AdminDesignSystem.spacing8),
                    Text(
                      'Add New FAQ',
                      style: AdminDesignSystem.bodyMedium.copyWith(
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
      ],
    );
  }
}

// ==================== FAQ ITEM CARD ====================

class _FAQItemCard extends StatefulWidget {
  final FAQItem faqItem;
  final SupportService supportService;

  const _FAQItemCard({required this.faqItem, required this.supportService});

  @override
  State<_FAQItemCard> createState() => _FAQItemCardState();
}

class _FAQItemCardState extends State<_FAQItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        border: Border.all(color: AdminDesignSystem.divider),
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              child: Padding(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.faqItem.question,
                            style: AdminDesignSystem.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AdminDesignSystem.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AdminDesignSystem.spacing4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AdminDesignSystem.accentTeal.withAlpha(
                                    25,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.faqItem.category.capitalize(),
                                  style: AdminDesignSystem.labelSmall.copyWith(
                                    color: AdminDesignSystem.accentTeal,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AdminDesignSystem.spacing8),
                              if (!widget.faqItem.isVisible)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AdminDesignSystem.statusError
                                        .withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Hidden',
                                    style: AdminDesignSystem.labelSmall
                                        .copyWith(
                                          color: AdminDesignSystem.statusError,
                                          fontSize: 10,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing12),
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
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AdminDesignSystem.divider),
                ),
              ),
              padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answer',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing8),
                  Text(
                    widget.faqItem.answer,
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Helpful: ${widget.faqItem.helpfulCount} | Unhelpful: ${widget.faqItem.unhelpfulCount}',
                          style: AdminDesignSystem.labelSmall.copyWith(
                            color: AdminDesignSystem.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AdminDesignSystem.spacing8),
                      SizedBox(
                        width: 180,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Edit coming soon'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit'),
                              ),
                            ),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete FAQ'),
                                      content: const Text(
                                        'Are you sure you want to delete this FAQ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            final success = await widget
                                                .supportService
                                                .deleteFAQItem(
                                                  widget.faqItem.id,
                                                );
                                            if (success && mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'FAQ deleted successfully',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            'Del',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Del'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
