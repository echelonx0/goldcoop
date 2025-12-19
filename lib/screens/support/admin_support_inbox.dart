// lib/screens/admin/support/admin_support_inbox.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/support_models.dart';
import '../../../services/admin_support_service.dart';
import '../admin/admin_chat_screen.dart';

class AdminSupportInbox extends StatefulWidget {
  final String adminId;
  final String adminName;
  final String adminAvatar;

  const AdminSupportInbox({
    super.key,
    required this.adminId,
    required this.adminName,
    required this.adminAvatar,
  });

  @override
  State<AdminSupportInbox> createState() => _AdminSupportInboxState();
}

class _AdminSupportInboxState extends State<AdminSupportInbox> {
  late final AdminSupportService _adminSupportService;
  String _filterStatus = 'all'; // all, open, assigned, inProgress, waiting

  @override
  void initState() {
    super.initState();
    _adminSupportService = AdminSupportService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(child: _buildConversationsList()),
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
            'Support Inbox',
            style: AdminDesignSystem.headingMedium.copyWith(
              color: AdminDesignSystem.primaryNavy,
            ),
          ),
          Text(
            'Manage support conversations',
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
        Padding(
          padding: const EdgeInsets.only(right: AdminDesignSystem.spacing12),
          child: Center(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _adminSupportService.getSupportStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {};
                final openCount = stats['openTickets'] ?? 0;

                return GestureDetector(
                  onTap: () {
                    // Refresh
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminDesignSystem.spacing12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AdminDesignSystem.statusError.withAlpha(25),
                      borderRadius: BorderRadius.circular(
                        AdminDesignSystem.radius8,
                      ),
                      border: Border.all(
                        color: AdminDesignSystem.statusError.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AdminDesignSystem.statusError,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AdminDesignSystem.spacing8),
                        Text(
                          '$openCount Open',
                          style: AdminDesignSystem.labelSmall.copyWith(
                            color: AdminDesignSystem.statusError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['all', 'open', 'assigned', 'inProgress', 'waiting'];
    final labels = ['All', 'Open', 'Assigned', 'In Progress', 'Waiting'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing12,
        vertical: AdminDesignSystem.spacing12,
      ),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _filterStatus == filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: AdminDesignSystem.spacing8),
            child: FilterChip(
              label: Text(labels[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _filterStatus = filters[index]);
                }
              },
              selectedColor: AdminDesignSystem.accentTeal,
              labelStyle: AdminDesignSystem.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : AdminDesignSystem.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              backgroundColor: AdminDesignSystem.background,
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : AdminDesignSystem.divider,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConversationsList() {
    final stream = _filterStatus == 'all'
        ? _adminSupportService.getActiveConversationsStream()
        : _adminSupportService.getActiveConversationsStream();

    return StreamBuilder<List<SupportConversation>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        var conversations = snapshot.data ?? [];

        // Filter by status
        if (_filterStatus != 'all') {
          conversations = conversations
              .where((c) => c.status == _filterStatus)
              .toList();
        }

        if (conversations.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
          itemCount: conversations.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AdminDesignSystem.spacing12),
          itemBuilder: (context, index) {
            return DelayedDisplay(
              delay: Duration(milliseconds: 100 * (index + 1)),
              child: _ConversationListItem(
                conversation: conversations[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminChatScreen(
                        conversationId: conversations[index].conversationId,
                        adminId: widget.adminId,
                        adminName: widget.adminName,
                        adminAvatar: widget.adminAvatar,
                        relatedTicket: null, // Will fetch in AdminChatScreen
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AdminDesignSystem.textTertiary,
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),
          Text(
            'No conversations',
            style: AdminDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AdminDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Text(
            'All support conversations appear here',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CONVERSATION LIST ITEM ====================

class _ConversationListItem extends StatelessWidget {
  final SupportConversation conversation;
  final VoidCallback? onTap;

  const _ConversationListItem({required this.conversation, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(conversation.status.toString());
    final isUnread =
        conversation.status == 'open' || conversation.status == 'waiting';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnread
              ? AdminDesignSystem.accentTeal.withAlpha(12)
              : AdminDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(
            color: isUnread
                ? AdminDesignSystem.accentTeal.withAlpha(50)
                : AdminDesignSystem.divider,
          ),
        ),
        padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.title,
                              style: AdminDesignSystem.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AdminDesignSystem.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(
                                left: AdminDesignSystem.spacing8,
                              ),
                              decoration: BoxDecoration(
                                color: AdminDesignSystem.accentTeal,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${conversation.conversationId.substring(0, 8)}',
                        style: AdminDesignSystem.labelSmall.copyWith(
                          color: AdminDesignSystem.textTertiary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AdminDesignSystem.spacing8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    conversation.status.toString().capitalize(),
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),

            // Meta info: User + Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'User: ${conversation.userId.substring(0, 8)}',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: AdminDesignSystem.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatTime(conversation.updatedAt),
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: AdminDesignSystem.textTertiary,
                  ),
                ),
              ],
            ),

            // Assignment info (if assigned)
            if (conversation.assignedToAdminName != null) ...[
              const SizedBox(height: AdminDesignSystem.spacing8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminDesignSystem.spacing8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.accentTeal.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '👤 ${conversation.assignedToAdminName}',
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: AdminDesignSystem.accentTeal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AdminDesignSystem.statusPending;
      case 'assigned':
        return AdminDesignSystem.accentTeal;
      case 'inProgress':
        return const Color(0xFFF39C12);
      case 'waiting':
        return const Color(0xFFF39C12);
      case 'closed':
        return AdminDesignSystem.textSecondary;
      default:
        return AdminDesignSystem.textSecondary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
