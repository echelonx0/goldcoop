// lib/screens/support/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../core/theme/admin_design_system.dart';
import '../../models/support_models.dart';
import '../../services/support_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String userId;
  final String userName;
  final String userAvatar;
  final SupportTicket? relatedTicket;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.relatedTicket,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final SupportService _supportService;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _supportService = SupportService();
    // Mark messages as read when screen opens
    _supportService.markMessagesAsRead(widget.conversationId, widget.userId);
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
        senderId: widget.userId,
        senderName: widget.userName,
        senderAvatar: widget.userAvatar,
        senderType: MessageSender.user,
        content: messageText,
        sentAt: DateTime.now(),
      );

      await _supportService.sendMessage(message);

      // Scroll to bottom
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Related ticket info (if exists)
          if (widget.relatedTicket != null)
            DelayedDisplay(
              delay: const Duration(milliseconds: 100),
              child: _buildTicketBanner(),
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
            'Support Chat',
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
    );
  }

  Widget _buildTicketBanner() {
    final ticket = widget.relatedTicket!;
    final statusColor = _getStatusColor(ticket.status);

    return Container(
      margin: const EdgeInsets.all(AdminDesignSystem.spacing12),
      padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(12),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
        border: Border.all(color: statusColor.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AdminDesignSystem.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  style: AdminDesignSystem.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminDesignSystem.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Status: ${ticket.status.name.capitalize()}',
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
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
            final isUserMessage = message.senderType == MessageSender.user;

            return Align(
              alignment: isUserMessage
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: ChatBubble(message: message, isUserMessage: isUserMessage),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: 1,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Type your message...',
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
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
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
                  : Icon(Icons.send_outlined, color: Colors.white, size: 20),
            ),
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

// ==================== CHAT BUBBLE ====================

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUserMessage;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUserMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminDesignSystem.spacing12),
      child: Column(
        crossAxisAlignment: isUserMessage
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender name and time (support messages only)
          if (!isUserMessage)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AdminDesignSystem.spacing4,
                left: AdminDesignSystem.spacing12,
              ),
              child: Row(
                children: [
                  Text(
                    message.senderName,
                    style: AdminDesignSystem.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AdminDesignSystem.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AdminDesignSystem.spacing8),
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
              color: isUserMessage
                  ? AdminDesignSystem.accentTeal
                  : AdminDesignSystem.cardBackground,
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
              border: isUserMessage
                  ? null
                  : Border.all(color: AdminDesignSystem.divider),
            ),
            child: Text(
              message.content,
              style: AdminDesignSystem.bodySmall.copyWith(
                color: isUserMessage
                    ? Colors.white
                    : AdminDesignSystem.textPrimary,
              ),
            ),
          ),

          // Timestamp (user messages)
          if (isUserMessage)
            Padding(
              padding: const EdgeInsets.only(
                top: AdminDesignSystem.spacing4,
                right: AdminDesignSystem.spacing12,
              ),
              child: Text(
                _formatTime(message.sentAt),
                style: AdminDesignSystem.labelSmall.copyWith(
                  color: AdminDesignSystem.textTertiary,
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
