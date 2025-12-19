// lib/screens/admin/sections/users_management.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/user_model.dart';
import '../../../services/admin_service.dart';
import '../forms/user_edit_form.dart';

class UsersManagement extends StatefulWidget {
  const UsersManagement({super.key});

  @override
  State<UsersManagement> createState() => _UsersManagementState();
}

class _UsersManagementState extends State<UsersManagement> {
  final AdminService _adminService = AdminService();
  final _currencyFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );
  final _searchController = TextEditingController();
  List<UserModel>? _searchResults;
  String _filterKYC = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(child: _buildUsersList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AdminDesignSystem.cardBackground,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Users',
                  style: AdminDesignSystem.headingLarge.copyWith(
                    color: AdminDesignSystem.primaryNavy,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  'Manage platform users',
                  style: AdminDesignSystem.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _searchResults = null),
            icon: const Icon(Icons.refresh),
            color: AdminDesignSystem.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: AdminDesignSystem.cardBackground,
      padding: const EdgeInsets.fromLTRB(
        AdminDesignSystem.spacing16,
        0,
        AdminDesignSystem.spacing16,
        AdminDesignSystem.spacing16,
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by email...',
              hintStyle: AdminDesignSystem.bodyMedium,
              prefixIcon: Icon(
                Icons.search,
                color: AdminDesignSystem.textTertiary,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = null);
                      },
                    )
                  : null,
              filled: true,
              fillColor: AdminDesignSystem.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AdminDesignSystem.spacing16,
                vertical: AdminDesignSystem.spacing12,
              ),
            ),
            onSubmitted: _handleSearch,
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          Row(
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: AdminDesignSystem.spacing8),
              _buildFilterChip('Verified'),
              const SizedBox(width: AdminDesignSystem.spacing8),
              _buildFilterChip('Pending'),
              const SizedBox(width: AdminDesignSystem.spacing8),
              _buildFilterChip('None'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterKYC == label;
    return InkWell(
      onTap: () => setState(() => _filterKYC = label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminDesignSystem.spacing12,
          vertical: AdminDesignSystem.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminDesignSystem.accentTeal
              : AdminDesignSystem.background,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
        ),
        child: Text(
          label,
          style: AdminDesignSystem.labelMedium.copyWith(
            color: isSelected ? Colors.white : AdminDesignSystem.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    final results = await _adminService.searchUsers(query);
    setState(() => _searchResults = results);
  }

  Widget _buildUsersList() {
    if (_searchResults != null) {
      return _buildUsersListView(_searchResults!);
    }

    return StreamBuilder<List<UserModel>>(
      stream: _adminService.getAllUsersStream(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        final users = snapshot.data ?? [];
        return _buildUsersListView(users);
      },
    );
  }

  Widget _buildUsersListView(List<UserModel> allUsers) {
    var users = allUsers;

    // Apply KYC filter
    if (_filterKYC != 'All') {
      users = users.where((user) {
        switch (_filterKYC) {
          case 'Verified':
            return user.kycStatus == KYCStatus.verified;
          case 'Pending':
            return user.kycStatus == KYCStatus.pending;
          case 'None':
            return user.kycStatus == KYCStatus.expired;
          default:
            return true;
        }
      }).toList();
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AdminDesignSystem.textTertiary,
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            Text('No users found', style: AdminDesignSystem.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      itemCount: users.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AdminDesignSystem.spacing12),
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    final initials = _getInitials(user.displayName);
    final avatarColor = _getColorForUser(user.uid);

    return AdminCard(
      onTap: () => _showUserEditForm(user),
      child: Row(
        children: [
          AvatarCircle(
            initials: initials,
            backgroundColor: avatarColor,
            size: 48,
          ),
          const SizedBox(width: AdminDesignSystem.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.displayName,
                        style: AdminDesignSystem.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AdminDesignSystem.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildKYCBadge(user.kycStatus),
                  ],
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  user.email,
                  style: AdminDesignSystem.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),
                Row(
                  children: [
                    Expanded(
                      child: _buildUserMetric(
                        'Balance',
                        _currencyFormatter.format(
                          user.financialProfile.accountBalance,
                        ),
                        AdminDesignSystem.statusActive,
                      ),
                    ),
                    Expanded(
                      child: _buildUserMetric(
                        'Invested',
                        _currencyFormatter.format(
                          user.financialProfile.totalInvested,
                        ),
                        AdminDesignSystem.primaryNavy,
                      ),
                    ),
                    Expanded(
                      child: _buildUserMetric(
                        'Tokens',
                        '${user.financialProfile.tokenBalance}',
                        AdminDesignSystem.accentTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AdminDesignSystem.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildUserMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AdminDesignSystem.labelSmall),
        const SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          value,
          style: AdminDesignSystem.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildKYCBadge(KYCStatus status) {
    Color color;
    String label;

    switch (status) {
      case KYCStatus.verified:
        color = AdminDesignSystem.statusActive;
        label = 'Verified';
        break;
      case KYCStatus.pending:
        color = AdminDesignSystem.statusPending;
        label = 'Pending';
        break;
      case KYCStatus.rejected:
        color = AdminDesignSystem.statusError;
        label = 'Rejected';
        break;
      default:
        color = AdminDesignSystem.statusInactive;
        label = 'None';
    }

    return StatusBadge(label: label, color: color);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Color _getColorForUser(String userId) {
    final colors = [
      AdminDesignSystem.primaryNavy,
      AdminDesignSystem.accentTeal,
      AdminDesignSystem.statusActive,
      AdminDesignSystem.statusPending,
      const Color(0xFF9B59B6),
      const Color(0xFFE74C3C),
    ];
    final hash = userId.hashCode;
    return colors[hash.abs() % colors.length];
  }

  void _showUserEditForm(UserModel user) {
    showUserEditSheet(context, user, () => setState(() {}));
  }
}
