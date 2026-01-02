// lib/screens/admin/support/admin_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../../core/theme/admin_design_system.dart';
import '../../../../../models/support_models.dart';
import '../../../../../services/support_service.dart';

class AdminChatScreen extends StatefulWidget {
  final String conversationId;
  final String adminId;
  final String adminName;
  final String adminAvatar;
  final SupportTicket? relatedTicket;

  const AdminChatScreen({
    super.key,
    required this.conversationId,
    required this.adminId,
    required this.adminName,
    required this.adminAvatar,
    this.relatedTicket,
  });

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  late final SupportService _supportService;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _showResolutionOptions = false;
  String? _selectedResolution;

  @override
  void initState() {
    super.initState();
    _supportService = SupportService();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final messageText = _messageController.text;
    _messageController.clear();

    setState(() => _isLoading = true);

    try {
      final message = ChatMessage(
        messageId: '',
        conversationId: widget.conversationId,
        senderId: widget.adminId,
        senderName: widget.adminName,
        senderAvatar: widget.adminAvatar,
        senderType: MessageSender.support,
        content: messageText,
        sentAt: DateTime.now(),
      );

      await _supportService.sendMessage(message);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: AdminDesignSystem.statusError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resolveTicket() async {
    if (widget.relatedTicket == null) return;

    try {
      await _supportService.resolveTicket(
        widget.relatedTicket!.ticketId,
        _selectedResolution ?? 'Issue resolved by support team.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket marked as resolved'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _showResolutionOptions = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AdminDesignSystem.statusError,
          ),
        );
      }
    }
  }

  Future<void> _updateTicketStatus(TicketStatus newStatus) async {
    if (widget.relatedTicket == null) return;

    try {
      await _supportService.updateTicketStatus(
        widget.relatedTicket!.ticketId,
        newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket status updated to ${newStatus.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AdminDesignSystem.statusError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Ticket info and actions
          if (widget.relatedTicket != null)
            DelayedDisplay(
              delay: const Duration(milliseconds: 100),
              child: _buildTicketHeader(),
            ),

          // Messages list
          Expanded(
            child: DelayedDisplay(
              delay: const Duration(milliseconds: 200),
              child: _buildMessagesList(),
            ),
          ),

          // Input area
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: _buildMessageInput(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AdminDesignSystem.cardBackground,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support Chat - Admin',
            style: AdminDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AdminDesignSystem.primaryNavy,
            ),
          ),
          if (widget.relatedTicket != null)
            Text(
              'Ticket #${widget.relatedTicket!.ticketId}',
              style: AdminDesignSystem.labelSmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
            ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AdminDesignSystem.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (widget.relatedTicket != null)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'resolve') {
                setState(() => _showResolutionOptions = true);
              } else if (value == 'reopen') {
                _updateTicketStatus(TicketStatus.reopened);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'resolve',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 12),
                    Text('Resolve Ticket'),
                  ],
                ),
              ),
              if (widget.relatedTicket!.status != TicketStatus.reopened)
                const PopupMenuItem(
                  value: 'reopen',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 12),
                      Text('Reopen Ticket'),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildTicketHeader() {
    final ticket = widget.relatedTicket!;
    final statusColor = _getStatusColor(ticket.status);

    return Container(
      margin: const EdgeInsets.all(AdminDesignSystem.spacing12),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(12),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        border: Border.all(color: statusColor.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject,
                      style: AdminDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AdminDesignSystem.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing8),
                    Text(
                      'Category: ${ticket.category.name.capitalize()} • Priority: ${ticket.priority.name.capitalize()}',
                      style: AdminDesignSystem.bodySmall.copyWith(
                        color: AdminDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminDesignSystem.spacing12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ticket.status.name.capitalize(),
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          if (ticket.assignedToStaffName != null)
            Text(
              'Assigned to: ${ticket.assignedToStaffName}',
              style: AdminDesignSystem.bodySmall.copyWith(
                color: AdminDesignSystem.accentTeal,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Text(
            'Created: ${DateFormat('MMM d, yyyy HH:mm').format(ticket.createdAt)}',
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<List<ChatMessage>>(
      stream: _supportService.getConversationMessagesStream(
        widget.conversationId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_rounded,
                  size: 48,
                  color: AdminDesignSystem.textTertiary,
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),
                Text(
                  'No messages yet',
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isAdminMessage = message.senderType == MessageSender.support;

            return Align(
              alignment: isAdminMessage
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: AdminChatBubble(
                message: message,
                isAdminMessage: isAdminMessage,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: AdminDesignSystem.cardBackground,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Resolution options (if showing)
          if (_showResolutionOptions && widget.relatedTicket != null)
            Container(
              padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
              decoration: BoxDecoration(
                color: AdminDesignSystem.background,
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resolution Notes',
                        style: AdminDesignSystem.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AdminDesignSystem.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: AdminDesignSystem.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _showResolutionOptions = false);
                        },
                      ),
                    ],
                  ),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter resolution notes...',
                      filled: true,
                      fillColor: AdminDesignSystem.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AdminDesignSystem.radius12,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(
                        AdminDesignSystem.spacing12,
                      ),
                    ),
                    style: AdminDesignSystem.bodySmall.copyWith(
                      color: AdminDesignSystem.textPrimary,
                    ),
                    onChanged: (value) {
                      setState(() => _selectedResolution = value);
                    },
                  ),
                  const SizedBox(height: AdminDesignSystem.spacing12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resolveTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminDesignSystem.statusActive,
                      ),
                      child: Text(
                        'Resolve Ticket',
                        style: AdminDesignSystem.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          // Message input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  maxLines: 1,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Type your response...',
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
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AdminDesignSystem.spacing12),
              GestureDetector(
                onTap: _isLoading || _messageController.text.isEmpty
                    ? null
                    : _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
                  decoration: BoxDecoration(
                    color: _messageController.text.isEmpty
                        ? AdminDesignSystem.divider
                        : AdminDesignSystem.accentTeal,
                    borderRadius: BorderRadius.circular(
                      AdminDesignSystem.radius12,
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return AdminDesignSystem.statusPending;
      case TicketStatus.assigned:
        return AdminDesignSystem.accentTeal;
      case TicketStatus.inProgress:
        return AdminDesignSystem.statusPending;
      case TicketStatus.waiting:
        return const Color(0xFFF39C12);
      case TicketStatus.resolved:
        return AdminDesignSystem.statusActive;
      case TicketStatus.closed:
        return AdminDesignSystem.textSecondary;
      case TicketStatus.reopened:
        return AdminDesignSystem.statusError;
    }
  }
}

// ==================== ADMIN CHAT BUBBLE ====================

class AdminChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isAdminMessage;

  const AdminChatBubble({
    super.key,
    required this.message,
    required this.isAdminMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminDesignSystem.spacing12),
      child: Column(
        crossAxisAlignment: isAdminMessage
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender info
          Padding(
            padding: isAdminMessage
                ? const EdgeInsets.only(
                    bottom: AdminDesignSystem.spacing4,
                    right: AdminDesignSystem.spacing12,
                  )
                : const EdgeInsets.only(
                    bottom: AdminDesignSystem.spacing4,
                    left: AdminDesignSystem.spacing12,
                  ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAdminMessage) ...[
                  Text(
                    message.senderName,
                    style: AdminDesignSystem.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AdminDesignSystem.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing8),
                ] else ...[
                  Text(
                    'Admin',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AdminDesignSystem.accentTeal,
                    ),
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing8),
                ],
                Text(
                  _formatTime(message.sentAt),
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: AdminDesignSystem.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing12,
              vertical: AdminDesignSystem.spacing12,
            ),
            decoration: BoxDecoration(
              color: isAdminMessage
                  ? AdminDesignSystem.accentTeal
                  : AdminDesignSystem.cardBackground,
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              border: isAdminMessage
                  ? null
                  : Border.all(color: AdminDesignSystem.divider),
            ),
            child: Text(
              message.content,
              style: AdminDesignSystem.bodySmall.copyWith(
                color: isAdminMessage
                    ? Colors.white
                    : AdminDesignSystem.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
