// lib/coordinators/support_coordinator.dart
// Centralized support system coordinator - handles all support UI flows

import 'package:flutter/material.dart';

import '../../models/support_models.dart';
import '../../models/user_model.dart';
import '../../screens/dashboard/widgets/dashboard_support_menu.dart';
import '../../screens/dashboard/widgets/tickets_modal.dart';
import '../../screens/support/chat_screen_complete.dart';
import '../../screens/support/faq_widget.dart';
import '../../screens/support/support_ticket_form.dart';
import '../../services/support_service.dart';
import '../theme/app_colors.dart';

class SupportCoordinator {
  final BuildContext context;
  final SupportService supportService;
  final String userId;
  final UserModel? user;

  SupportCoordinator({
    required this.context,
    required this.supportService,
    required this.userId,
    required this.user,
  });

  // ==================== MAIN ENTRY POINT ====================

  /// Shows the main support menu with all options
  void showSupportMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DashboardSupportMenu(
        onFAQ: () {
          Navigator.pop(context);
          showFAQ();
        },
        onCreateTicket: () {
          Navigator.pop(context);
          showCreateTicket();
        },
        onViewTickets: () {
          Navigator.pop(context);
          showMyTickets();
        },
      ),
    );
  }

  // ==================== FAQ ====================

  /// Shows the FAQ modal
  void showFAQ() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.large),
            topRight: Radius.circular(AppBorderRadius.large),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.9,
        child: FAQWidget(
          onContactSupport: () {
            Navigator.pop(context);
            showCreateTicket();
          },
        ),
      ),
    );
  }

  // ==================== CREATE TICKET ====================

  /// Shows the create ticket form with user data pre-filled
  void showCreateTicket() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.large),
            topRight: Radius.circular(AppBorderRadius.large),
          ),
        ),
        child: SupportTicketForm(
          userId: userId,
          userName: user?.displayName ?? user?.firstName ?? 'User',
          userEmail: user?.email ?? '',
          userModel: user,
          onSubmitSuccess: () {
            Navigator.pop(context);
            _showSuccessSnackbar(
              'Support ticket created! We\'ll respond soon.',
            );
          },
        ),
      ),
    );
  }

  // ==================== VIEW TICKETS ====================

  /// Shows the user's support tickets
  void showMyTickets() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DashboardMyTickets(
        uid: userId,
        supportService: supportService,
        onTicketTap: (ticket) {
          Navigator.pop(context);
          openTicketChat(ticket);
        },
      ),
    );
  }

  // ==================== CHAT ====================

  /// Opens chat for a specific ticket by finding the linked conversation
  Future<void> openTicketChat(SupportTicket ticket) async {
    try {
      // Find conversation linked to this ticket via relatedTicketId
      final conversation = await supportService.getConversationByTicketId(
        ticket.ticketId,
      );

      if (conversation != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversation.conversationId,
              userId: userId,
              userName: user?.displayName ?? user?.firstName ?? 'User',
              userAvatar: user?.profilePic ?? '',
              relatedTicket: ticket,
            ),
          ),
        );
      } else if (context.mounted) {
        // No conversation exists yet
        _showErrorSnackbar('No chat available for this ticket yet.');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar('Failed to open chat: $e');
      }
    }
  }

  /// Opens chat directly with a conversation ID
  void openChatWithConversationId(
    String conversationId, {
    SupportTicket? ticket,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conversationId,
          userId: userId,
          userName: user?.displayName ?? user?.firstName ?? 'User',
          userAvatar: user?.profilePic ?? '',
          relatedTicket: ticket,
        ),
      ),
    );
  }

  /// Opens chat from a notification
  void openChatFromNotification(SupportNotification notification) {
    if (notification.relatedConversationId != null) {
      openChatWithConversationId(notification.relatedConversationId!);
    } else if (notification.relatedTicketId != null) {
      showMyTickets();
    }
  }

  // ==================== HELPERS ====================

  void _showSuccessSnackbar(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.tealSuccess,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warmRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
        ),
      ),
    );
  }
}
