// lib/screens/dashboard/widgets/dashboard_my_tickets.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/support_models.dart';
import '../../../services/support_service.dart';
import '../../support/chat_screen_complete.dart';

class DashboardMyTickets extends StatelessWidget {
  final String uid;
  final SupportService supportService;
  final Function(SupportTicket)? onTicketTap;

  const DashboardMyTickets({
    super.key,
    required this.uid,
    required this.supportService,
    this.onTicketTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.large),
          topRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'My Support Tickets',
              style: AppTextTheme.heading3.copyWith(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SupportTicket>>(
              stream: supportService.getUserTicketsStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  );
                }

                final tickets = snapshot.data ?? [];

                if (tickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No tickets yet',
                          style: AppTextTheme.bodyRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return TicketTile(
                      ticket: ticket,
                      supportService: supportService,
                      userId: uid,
                      onTap: () {
                        onTicketTap?.call(ticket);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TicketTile extends StatelessWidget {
  final SupportTicket ticket;
  final SupportService supportService;
  final String userId;
  final VoidCallback? onTap;

  const TicketTile({
    super.key,
    required this.ticket,
    required this.supportService,
    required this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ticket.status);

    return GestureDetector(
      onTap: () async {
        try {
          final conversations = await supportService.getUserConversations(
            userId,
          );

          // Find conversation for this ticket
          SupportConversation? conversation;
          try {
            conversation = conversations.firstWhere(
              (c) => c.relatedTicketId == ticket.ticketId,
            );
          } catch (e) {
            conversation = null;
          }

          if (!context.mounted) return;

          // If no conversation found, show error
          if (conversation == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No chat found for this ticket. Please create it in support menu.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: conversation!.conversationId,
                userId: userId,
                userName: 'User',
                userAvatar: '',
                relatedTicket: ticket,
              ),
            ),
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        }

        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutral,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(color: AppColors.borderLight),
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
                        'Ticket #${ticket.ticketId.substring(0, 8)}',
                        style: AppTextTheme.bodyRegular.copyWith(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.subject,
                        style: AppTextTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket.status.name.capitalize(),
                    style: AppTextTheme.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Category: ${ticket.category.name.capitalize()}',
              style: AppTextTheme.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return AppColors.primaryOrange;
      case TicketStatus.assigned:
        return Colors.blue;
      case TicketStatus.inProgress:
        return Colors.orange;
      case TicketStatus.waiting:
        return Colors.amber;
      case TicketStatus.resolved:
        return Colors.green;
      case TicketStatus.closed:
        return AppColors.textSecondary;
      case TicketStatus.reopened:
        return AppColors.warmRed;
    }
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
