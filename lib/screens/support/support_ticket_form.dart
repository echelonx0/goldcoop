import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/support_models.dart';
import '../../../services/support_service.dart';

class SupportTicketForm extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final VoidCallback? onSubmitSuccess;

  const SupportTicketForm({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.onSubmitSuccess,
  });

  @override
  State<SupportTicketForm> createState() => _SupportTicketFormState();
}

class _SupportTicketFormState extends State<SupportTicketForm> {
  late final SupportService _supportService;
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  TicketCategory _selectedCategory = TicketCategory.other;
  TicketPriority _selectedPriority = TicketPriority.medium;
  List<String> _attachmentUrls = [];
  bool _isLoading = false;
  String? _createdTicketId;

  @override
  void initState() {
    super.initState();
    _supportService = SupportService();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ticket = SupportTicket(
        ticketId: '',
        userId: widget.userId,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        status: TicketStatus.open,
        priority: _selectedPriority,
        attachmentUrls: _attachmentUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final ticketId = await _supportService.createTicket(ticket);

      if (!mounted) return;

      if (ticketId != null) {
        // Create conversation linked to ticket
        final conversation = SupportConversation(
          conversationId: '',
          userId: widget.userId,
          relatedTicketId: ticketId,
          title: 'Support Ticket - $ticketId',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: ConversationStatus.open,
        );

        await _supportService.createConversation(conversation);

        setState(() {
          _isLoading = false;
          _createdTicketId = ticketId;
        });

        // Show success state for 2 seconds, then close
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          widget.onSubmitSuccess?.call();
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackbar('Failed to create ticket. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Error: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminDesignSystem.statusError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show success state
    if (_createdTicketId != null) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AdminDesignSystem.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AdminDesignSystem.radius16),
            topRight: Radius.circular(AdminDesignSystem.radius16),
          ),
        ),
        child: Center(
          child: DelayedDisplay(
            delay: const Duration(milliseconds: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AdminDesignSystem.statusActive.withAlpha(25),
                    borderRadius: BorderRadius.circular(64),
                  ),
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
                  child: Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AdminDesignSystem.statusActive,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing24),
                Text(
                  'Ticket Created Successfully',
                  style: AdminDesignSystem.headingLarge.copyWith(
                    color: AdminDesignSystem.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),
                Text(
                  'Ticket ID: $_createdTicketId',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AdminDesignSystem.spacing24),
                Text(
                  'Our support team will review your ticket shortly.\nYou can track its status in the chat window.',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show form
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AdminDesignSystem.radius16),
          topRight: Radius.circular(AdminDesignSystem.radius16),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: AdminDesignSystem.spacing12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AdminDesignSystem.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Support Ticket',
                            style: AdminDesignSystem.headingLarge.copyWith(
                              color: AdminDesignSystem.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: AdminDesignSystem.spacing8),
                          Text(
                            'Describe your issue and we\'ll help you resolve it',
                            style: AdminDesignSystem.bodySmall.copyWith(
                              color: AdminDesignSystem.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing24),

                    // Category selector
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 200),
                      child: _buildCategorySelector(),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing20),

                    // Priority selector
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 300),
                      child: _buildPrioritySelector(),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing20),

                    // Subject field
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 400),
                      child: _buildTextField(
                        label: 'Subject',
                        hint: 'Brief description of your issue',
                        controller: _subjectController,
                        maxLines: 1,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Subject is required';
                          if (value!.length < 5) {
                            return 'Subject must be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing16),

                    // Description field
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 500),
                      child: _buildTextField(
                        label: 'Description',
                        hint: 'Provide detailed information about your issue',
                        controller: _descriptionController,
                        maxLines: 6,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Description is required';
                          if (value!.length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing20),

                    // Attachments placeholder
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 600),
                      child: _buildAttachmentSection(),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing24),

                    // Info message
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 700),
                      child: Container(
                        padding: const EdgeInsets.all(
                          AdminDesignSystem.spacing12,
                        ),
                        decoration: BoxDecoration(
                          color: AdminDesignSystem.accentTeal.withAlpha(12),
                          borderRadius: BorderRadius.circular(
                            AdminDesignSystem.radius8,
                          ),
                          border: Border.all(
                            color: AdminDesignSystem.accentTeal.withAlpha(25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AdminDesignSystem.accentTeal,
                            ),
                            const SizedBox(width: AdminDesignSystem.spacing8),
                            Expanded(
                              child: Text(
                                'Average response time: 2-4 hours',
                                style: AdminDesignSystem.bodySmall.copyWith(
                                  color: AdminDesignSystem.accentTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Submit button - sticky footer
          Padding(
            padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
            child: DelayedDisplay(
              delay: const Duration(milliseconds: 800),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTicket,
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
                          'Submit Ticket',
                          style: AdminDesignSystem.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
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
        const SizedBox(height: AdminDesignSystem.spacing12),
        Wrap(
          spacing: AdminDesignSystem.spacing8,
          runSpacing: AdminDesignSystem.spacing8,
          children: TicketCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return ChoiceChip(
              label: Text(category.name.capitalize()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                }
              },
              selectedColor: AdminDesignSystem.accentTeal,
              labelStyle: AdminDesignSystem.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : AdminDesignSystem.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: AdminDesignSystem.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AdminDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing12),
        Wrap(
          spacing: AdminDesignSystem.spacing8,
          runSpacing: AdminDesignSystem.spacing8,
          children: TicketPriority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            final priorityColor = _getPriorityColor(priority);

            return ChoiceChip(
              label: Text(priority.name.capitalize()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedPriority = priority);
                }
              },
              selectedColor: priorityColor,
              labelStyle: AdminDesignSystem.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : AdminDesignSystem.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required int maxLines,
    required String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          enabled: !_isLoading,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AdminDesignSystem.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(AdminDesignSystem.spacing12),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              borderSide: BorderSide(
                color: AdminDesignSystem.statusError,
                width: 1,
              ),
            ),
          ),
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments (Optional)',
          style: AdminDesignSystem.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AdminDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: AdminDesignSystem.spacing12),
        Container(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
          decoration: BoxDecoration(
            color: AdminDesignSystem.background,
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
            border: Border.all(color: AdminDesignSystem.divider),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: AdminDesignSystem.textTertiary,
              ),
              const SizedBox(height: AdminDesignSystem.spacing8),
              Text(
                'Upload screenshots or files',
                style: AdminDesignSystem.bodySmall.copyWith(
                  color: AdminDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: AdminDesignSystem.spacing8),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File upload coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                child: Text(
                  'Choose File',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.accentTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return const Color(0xFF95A5A6);
      case TicketPriority.medium:
        return const Color(0xFFF39C12);
      case TicketPriority.high:
        return const Color(0xFFE67E22);
      case TicketPriority.urgent:
        return AdminDesignSystem.statusError;
    }
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
