// lib/screens/admin/support/admin_support_inbox.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/support_models.dart';
import '../../../services/admin_support_service.dart';
import '../admin/dashboard/tabs/admin_chat_screen.dart';

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
  String _filterStatus = 'all';

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
            child: StreamBuilder<int>(
              stream: _getOpenConversationCount(),
              builder: (context, snapshot) {
                final openCount = snapshot.data ?? 0;

                return GestureDetector(
                  onTap: () {
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

  /// Stream open conversation count (matches the list)
  Stream<int> _getOpenConversationCount() {
    return _adminSupportService.getActiveConversationsStream().map(
      (conversations) => conversations.length,
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
    return StreamBuilder<List<SupportConversation>>(
      stream: _adminSupportService.getActiveConversationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AdminDesignSystem.statusError,
                ),
                const SizedBox(height: AdminDesignSystem.spacing16),
                Text(
                  'Error loading conversations',
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing8),
                Text(
                  snapshot.error.toString(),
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        var conversations = snapshot.data ?? [];

        // Filter conversations by status
        if (_filterStatus != 'all') {
          conversations = conversations.where((c) {
            switch (_filterStatus) {
              case 'open':
                return c.status == ConversationStatus.open;
              case 'assigned':
                return c.assignedToAdminId != null &&
                    c.assignedToAdminId!.isNotEmpty &&
                    c.status == ConversationStatus.open;
              case 'inProgress':
                return c.status == ConversationStatus.open &&
                    c.lastMessageAt != null;
              case 'waiting':
                return c.unreadCount > 0;
              default:
                return true;
            }
          }).toList();
        }

        if (conversations.isEmpty) {
          return _buildEmptyState();
        }

        conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

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
                        relatedTicket: null,
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
            _filterStatus == 'all'
                ? 'No conversations'
                : 'No $_filterStatus conversations',
            style: AdminDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AdminDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Text(
            _filterStatus == 'all'
                ? 'All support conversations appear here'
                : 'Try changing the filter to see more conversations',
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
    final statusColor = _getStatusColor(conversation.status);
    final isUnread = conversation.unreadCount > 0;

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
                        'ID: ${_getIdDisplay(conversation.conversationId)}',
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
                    conversation.status.name.capitalize(),
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'User: ${_getIdDisplay(conversation.userId)}',
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

  String _getIdDisplay(String id) {
    if (id.isEmpty) return 'No ID';
    if (id.length >= 8) return id.substring(0, 8);
    return id;
  }

  Color _getStatusColor(ConversationStatus status) {
    switch (status) {
      case ConversationStatus.open:
        return AdminDesignSystem.statusPending;
      case ConversationStatus.closed:
        return AdminDesignSystem.textSecondary;
      case ConversationStatus.assigned:
        return AdminDesignSystem.statusInactive;
      case ConversationStatus.inProgress:
        return AdminDesignSystem.statusActive;
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
