import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../../../../core/theme/admin_design_system.dart';
import '../../../../../../models/support_models.dart';
import '../../../../../../services/admin_support_service.dart';

class AdminTicketsManager extends StatefulWidget {
  final String adminId;
  final String adminName;

  const AdminTicketsManager({
    super.key,
    required this.adminId,
    required this.adminName,
  });

  @override
  State<AdminTicketsManager> createState() => _AdminTicketsManagerState();
}

class _AdminTicketsManagerState extends State<AdminTicketsManager> {
  late final AdminSupportService _adminSupportService;
  TicketStatus? _filterStatus;
  TicketPriority? _filterPriority;

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
          _buildFilterBar(),
          Expanded(child: _buildTicketsList()),
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
            'Support Tickets',
            style: AdminDesignSystem.headingMedium.copyWith(
              color: AdminDesignSystem.primaryNavy,
            ),
          ),
          Text(
            'Manage all support tickets',
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
              stream: _getOpenTicketCount(),
              builder: (context, snapshot) {
                final openCount = snapshot.data ?? 0;

                return Container(
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
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Stream<int> _getOpenTicketCount() {
    return _adminSupportService.getOpenTicketsStream().map(
      (tickets) => tickets.length,
    );
  }

  Widget _buildFilterBar() {
    final statuses = TicketStatus.values;
    final priorities = TicketPriority.values;

    return Container(
      color: AdminDesignSystem.cardBackground,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filter
          Text(
            'Filter by Status',
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: _filterStatus == null,
                  onTap: () => setState(() => _filterStatus = null),
                ),
                ...statuses.map((status) {
                  return _buildFilterChip(
                    label: status.name.capitalize(),
                    selected: _filterStatus == status,
                    onTap: () => setState(() => _filterStatus = status),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),

          // Priority filter
          Text(
            'Filter by Priority',
            style: AdminDesignSystem.labelSmall.copyWith(
              color: AdminDesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: _filterPriority == null,
                  onTap: () => setState(() => _filterPriority = null),
                ),
                ...priorities.map((priority) {
                  return _buildFilterChip(
                    label: priority.name.capitalize(),
                    selected: _filterPriority == priority,
                    onTap: () => setState(() => _filterPriority = priority),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AdminDesignSystem.spacing8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AdminDesignSystem.accentTeal,
        labelStyle: AdminDesignSystem.bodySmall.copyWith(
          color: selected ? Colors.white : AdminDesignSystem.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
        backgroundColor: AdminDesignSystem.background,
        side: BorderSide(
          color: selected ? Colors.transparent : AdminDesignSystem.divider,
        ),
      ),
    );
  }

  Widget _buildTicketsList() {
    return StreamBuilder<List<SupportTicket>>(
      stream: _adminSupportService.getOpenTicketsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        if (snapshot.hasError) {
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
                  'Error loading tickets',
                  style: AdminDesignSystem.bodyMedium.copyWith(
                    color: AdminDesignSystem.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }

        var tickets = snapshot.data ?? [];

        // ✅ FIXED: Apply filters using enum values directly
        // Don't try to match enum.name to ticket.status - use enum comparison
        if (_filterStatus != null) {
          tickets = tickets.where((t) => t.status == _filterStatus).toList();
        }
        if (_filterPriority != null) {
          tickets = tickets
              .where((t) => t.priority == _filterPriority)
              .toList();
        }

        if (tickets.isEmpty) {
          return _buildEmptyState();
        }

        // Sort by priority (high first) then by creation date
        tickets.sort((a, b) {
          final priorityCompare = b.priority.index.compareTo(a.priority.index);
          if (priorityCompare != 0) return priorityCompare;
          return b.createdAt.compareTo(a.createdAt);
        });

        return ListView.separated(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
          itemCount: tickets.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AdminDesignSystem.spacing12),
          itemBuilder: (context, index) {
            return DelayedDisplay(
              delay: Duration(milliseconds: 100 * (index + 1)),
              child: _TicketListItem(
                ticket: tickets[index],
                onTap: () {
                  // Navigate to ticket detail screen
                  _showTicketDetail(context, tickets[index]);
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
            Icons.airplane_ticket_sharp,
            size: 48,
            color: AdminDesignSystem.textTertiary,
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),
          Text(
            'No tickets found',
            style: AdminDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AdminDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: AdminDesignSystem.spacing8),
          Text(
            'Try changing the filters',
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketDetail(BuildContext context, SupportTicket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TicketDetailBottomSheet(
        ticket: ticket,
        adminId: widget.adminId,
        adminName: widget.adminName,
        adminSupportService: _adminSupportService,
        onUpdate: () => setState(() {}),
      ),
    );
  }
}

// ==================== TICKET LIST ITEM ====================

class _TicketListItem extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback? onTap;

  const _TicketListItem({required this.ticket, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ticket.status);
    final priorityColor = _getPriorityColor(ticket.priority);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AdminDesignSystem.cardDecoration,
        padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: AdminDesignSystem.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AdminDesignSystem.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    ticket.status.name.capitalize(),
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),

            // Description preview
            Text(
              ticket.description,
              style: AdminDesignSystem.labelSmall.copyWith(
                color: AdminDesignSystem.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),

            // Meta: ID, Priority, User, Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '#${ticket.ticketId.substring(0, 8)}',
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: AdminDesignSystem.textTertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AdminDesignSystem.spacing8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket.priority.name.capitalize(),
                    style: AdminDesignSystem.labelSmall.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatDate(ticket.createdAt),
                  style: AdminDesignSystem.labelSmall.copyWith(
                    color: AdminDesignSystem.textTertiary,
                  ),
                ),
              ],
            ),

            // Assigned to (if assigned)
            if (ticket.assignedToStaffName != null) ...[
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
                  '👤 ${ticket.assignedToStaffName}',
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

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return AdminDesignSystem.statusPending;
      case TicketStatus.assigned:
        return AdminDesignSystem.accentTeal;
      case TicketStatus.inProgress:
        return Colors.blue;
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

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return AdminDesignSystem.statusInactive;
      case TicketPriority.medium:
        return AdminDesignSystem.statusPending;
      case TicketPriority.high:
        return AdminDesignSystem.statusError;
      case TicketPriority.urgent:
        return Colors.red;
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d').format(dateTime);
  }
}

// ==================== TICKET DETAIL BOTTOM SHEET ====================

class _TicketDetailBottomSheet extends StatefulWidget {
  final SupportTicket ticket;
  final String adminId;
  final String adminName;
  final AdminSupportService adminSupportService;
  final VoidCallback onUpdate;

  const _TicketDetailBottomSheet({
    required this.ticket,
    required this.adminId,
    required this.adminName,
    required this.adminSupportService,
    required this.onUpdate,
  });

  @override
  State<_TicketDetailBottomSheet> createState() =>
      _TicketDetailBottomSheetState();
}

class _TicketDetailBottomSheetState extends State<_TicketDetailBottomSheet> {
  late TicketStatus _selectedStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ticket.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminDesignSystem.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ticket Details',
                  style: AdminDesignSystem.headingMedium.copyWith(
                    color: AdminDesignSystem.primaryNavy,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AdminDesignSystem.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AdminDesignSystem.spacing16),

            // Ticket info
            _buildInfoRow('ID', widget.ticket.ticketId.substring(0, 12)),
            const SizedBox(height: AdminDesignSystem.spacing12),
            _buildInfoRow('Subject', widget.ticket.subject),
            const SizedBox(height: AdminDesignSystem.spacing12),
            _buildInfoRow('Priority', widget.ticket.priority.name.capitalize()),
            const SizedBox(height: AdminDesignSystem.spacing16),

            // Status selector
            Text(
              'Change Status',
              style: AdminDesignSystem.labelMedium.copyWith(
                color: AdminDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: AdminDesignSystem.spacing8),
            _buildStatusPicker(),
            const SizedBox(height: AdminDesignSystem.spacing20),

            // Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminDesignSystem.accentTeal,
                  disabledBackgroundColor: AdminDesignSystem.textTertiary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AdminDesignSystem.spacing12,
                  ),
                ),
                child: _isUpdating
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Update Status',
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AdminDesignSystem.labelSmall.copyWith(
            color: AdminDesignSystem.textSecondary,
          ),
        ),
        Text(
          value,
          style: AdminDesignSystem.bodySmall.copyWith(
            color: AdminDesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPicker() {
    return Wrap(
      spacing: AdminDesignSystem.spacing8,
      children: TicketStatus.values.map((status) {
        final isSelected = _selectedStatus == status;
        return ChoiceChip(
          label: Text(status.name.capitalize()),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedStatus = status);
            }
          },
          selectedColor: AdminDesignSystem.accentTeal,
          labelStyle: AdminDesignSystem.bodySmall.copyWith(
            color: isSelected ? Colors.white : AdminDesignSystem.textPrimary,
          ),
          backgroundColor: AdminDesignSystem.cardBackground,
        );
      }).toList(),
    );
  }

  Future<void> _updateStatus() async {
    setState(() => _isUpdating = true);

    try {
      await widget.adminSupportService.updateTicketStatus(
        ticketId: widget.ticket.ticketId,
        newStatus: _selectedStatus,
      );

      Navigator.pop(context);
      widget.onUpdate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ticket status updated to ${_selectedStatus.name}',
              style: AdminDesignSystem.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: AdminDesignSystem.statusActive,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AdminDesignSystem.spacing16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating ticket: ${e.toString()}',
              style: AdminDesignSystem.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: AdminDesignSystem.statusError,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AdminDesignSystem.spacing16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
