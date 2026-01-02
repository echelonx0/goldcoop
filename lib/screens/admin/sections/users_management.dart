// // lib/screens/admin/sections/users_management.dart

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../core/theme/admin_design_system.dart';
// import '../../../models/user_model.dart';
// import '../../../services/admin_service.dart';
// import '../../../services/firestore_service.dart';
// import '../forms/user_edit_form.dart';
// import 'user_management/transactions_list.dart';

// class UsersManagement extends StatefulWidget {
//   const UsersManagement({super.key});

//   @override
//   State<UsersManagement> createState() => _UsersManagementState();
// }

// class _UsersManagementState extends State<UsersManagement> {
//   final AdminService _adminService = AdminService();
//   final FirestoreService _firestoreService = FirestoreService();
//   final _currencyFormatter = NumberFormat.currency(
//     symbol: '₦',
//     decimalDigits: 0,
//   );
//   final _searchController = TextEditingController();
//   List<UserModel>? _searchResults;
//   String _filterKYC = 'All';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildHeader(),
//         _buildFilters(),
//         Expanded(child: _buildUsersList()),
//       ],
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       color: AdminDesignSystem.cardBackground,
//       padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Users',
//                   style: AdminDesignSystem.headingLarge.copyWith(
//                     color: AdminDesignSystem.primaryNavy,
//                   ),
//                 ),
//                 const SizedBox(height: AdminDesignSystem.spacing4),
//                 Text(
//                   'Manage platform users',
//                   style: AdminDesignSystem.bodyMedium,
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             onPressed: () => setState(() => _searchResults = null),
//             icon: const Icon(Icons.refresh),
//             color: AdminDesignSystem.accentTeal,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilters() {
//     return Container(
//       color: AdminDesignSystem.cardBackground,
//       padding: const EdgeInsets.fromLTRB(
//         AdminDesignSystem.spacing16,
//         0,
//         AdminDesignSystem.spacing16,
//         AdminDesignSystem.spacing16,
//       ),
//       child: Column(
//         children: [
//           TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Search by email...',
//               hintStyle: AdminDesignSystem.bodyMedium,
//               prefixIcon: Icon(
//                 Icons.search,
//                 color: AdminDesignSystem.textTertiary,
//                 size: 20,
//               ),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear, size: 20),
//                       onPressed: () {
//                         _searchController.clear();
//                         setState(() => _searchResults = null);
//                       },
//                     )
//                   : null,
//               filled: true,
//               fillColor: AdminDesignSystem.background,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: AdminDesignSystem.spacing16,
//                 vertical: AdminDesignSystem.spacing12,
//               ),
//             ),
//             onSubmitted: _handleSearch,
//           ),
//           const SizedBox(height: AdminDesignSystem.spacing12),
//           Row(
//             children: [
//               _buildFilterChip('All'),
//               const SizedBox(width: AdminDesignSystem.spacing8),
//               _buildFilterChip('Verified'),
//               const SizedBox(width: AdminDesignSystem.spacing8),
//               _buildFilterChip('Pending'),
//               const SizedBox(width: AdminDesignSystem.spacing8),
//               _buildFilterChip('None'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label) {
//     final isSelected = _filterKYC == label;
//     return InkWell(
//       onTap: () => setState(() => _filterKYC = label),
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AdminDesignSystem.spacing12,
//           vertical: AdminDesignSystem.spacing8,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AdminDesignSystem.accentTeal
//               : AdminDesignSystem.background,
//           borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//         ),
//         child: Text(
//           label,
//           style: AdminDesignSystem.labelMedium.copyWith(
//             color: isSelected ? Colors.white : AdminDesignSystem.textSecondary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleSearch(String query) async {
//     if (query.isEmpty) {
//       setState(() => _searchResults = null);
//       return;
//     }
//     final results = await _adminService.searchUsers(query);
//     setState(() => _searchResults = results);
//   }

//   Widget _buildUsersList() {
//     if (_searchResults != null) {
//       return _buildUsersListView(_searchResults!);
//     }

//     return StreamBuilder<List<UserModel>>(
//       stream: _adminService.getAllUsersStream(limit: 100),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(
//               color: AdminDesignSystem.accentTeal,
//             ),
//           );
//         }

//         final users = snapshot.data ?? [];
//         return _buildUsersListView(users);
//       },
//     );
//   }

//   Widget _buildUsersListView(List<UserModel> allUsers) {
//     var users = allUsers;

//     // Apply KYC filter
//     if (_filterKYC != 'All') {
//       users = users.where((user) {
//         switch (_filterKYC) {
//           case 'Verified':
//             return user.kycStatus == KYCStatus.verified;
//           case 'Pending':
//             return user.kycStatus == KYCStatus.pending;
//           case 'None':
//             return user.kycStatus == KYCStatus.expired;
//           default:
//             return true;
//         }
//       }).toList();
//     }

//     if (users.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.people_outline,
//               size: 64,
//               color: AdminDesignSystem.textTertiary,
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing12),
//             Text('No users found', style: AdminDesignSystem.bodyMedium),
//           ],
//         ),
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
//       itemCount: users.length,
//       separatorBuilder: (_, _) =>
//           const SizedBox(height: AdminDesignSystem.spacing12),
//       itemBuilder: (context, index) {
//         final user = users[index];
//         return _buildUserCard(user);
//       },
//     );
//   }

//   Widget _buildUserCard(UserModel user) {
//     return AdminCard(
//       child: Padding(
//         padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Top row: Avatar + Info + Action buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               user.displayName,
//                               style: AdminDesignSystem.bodyLarge.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 color: AdminDesignSystem.textPrimary,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: AdminDesignSystem.spacing4),
//                       Text(
//                         user.email,
//                         style: AdminDesignSystem.bodySmall,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: AdminDesignSystem.spacing12),
//                 // Action buttons
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildActionButton(
//                       icon: Icons.edit,
//                       tooltip: 'Edit user',
//                       onTap: () => _showUserEditForm(user),
//                       color: AdminDesignSystem.accentTeal,
//                     ),
//                     const SizedBox(width: AdminDesignSystem.spacing8),
//                     _buildActionButton(
//                       icon: Icons.history,
//                       tooltip: 'View transactions',
//                       onTap: () => _showUserTransactions(user),
//                       color: AdminDesignSystem.primaryNavy,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing12),
//             // Metrics row
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildUserMetric(
//                     'Balance',
//                     _currencyFormatter.format(
//                       user.financialProfile.accountBalance,
//                     ),
//                     AdminDesignSystem.statusActive,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildUserMetric(
//                     'Invested',
//                     _currencyFormatter.format(
//                       user.financialProfile.totalInvested,
//                     ),
//                     AdminDesignSystem.primaryNavy,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildUserMetric(
//                     'Tokens',
//                     '${user.financialProfile.tokenBalance}',
//                     AdminDesignSystem.accentTeal,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: AdminDesignSystem.spacing12),
//             Row(
//               children: [
//                 Text(
//                   'KYC Status: ',
//                   style: AdminDesignSystem.bodySmall.copyWith(
//                     color: AdminDesignSystem.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(width: AdminDesignSystem.spacing12),
//                 _buildKYCBadge(user.kycStatus),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String tooltip,
//     required VoidCallback onTap,
//     required Color color,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//         child: Container(
//           padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
//           decoration: BoxDecoration(
//             color: color.withAlpha(25),
//             borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
//           ),
//           child: Icon(icon, size: 18, color: color),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMetric(String label, String value, Color color) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: AdminDesignSystem.labelSmall),
//         const SizedBox(height: AdminDesignSystem.spacing4),
//         Text(
//           value,
//           style: AdminDesignSystem.bodySmall.copyWith(
//             fontWeight: FontWeight.w600,
//             color: color,
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     );
//   }

//   Widget _buildKYCBadge(KYCStatus status) {
//     Color color;
//     String label;

//     switch (status) {
//       case KYCStatus.verified:
//         color = AdminDesignSystem.statusActive;
//         label = 'Verified';
//         break;
//       case KYCStatus.pending:
//         color = AdminDesignSystem.statusPending;
//         label = 'Pending';
//         break;
//       case KYCStatus.rejected:
//         color = AdminDesignSystem.statusError;
//         label = 'Rejected';
//         break;
//       default:
//         color = AdminDesignSystem.statusInactive;
//         label = 'None';
//     }

//     return StatusBadge(label: label, color: color);
//   }

//   void _showUserEditForm(UserModel user) {
//     showUserEditSheet(context, user, () => setState(() {}));
//   }

//   void _showUserTransactions(UserModel user) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.85,
//       ),
//       builder: (context) => AdminUserTransactionsSheet(
//         userId: user.uid,
//         userName: user.displayName,
//         firestoreService: _firestoreService,
//       ),
//     );
//   }
// }
// lib/screens/admin/sections/users_management.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/admin_design_system.dart';
import '../../../models/user_model.dart';
import '../../../services/admin_service.dart';
import '../../../services/firestore_service.dart';
import '../forms/user_edit_form.dart';
import 'user_management/transactions_list.dart';

class UsersManagement extends StatefulWidget {
  const UsersManagement({super.key});

  @override
  State<UsersManagement> createState() => _UsersManagementState();
}

class _UsersManagementState extends State<UsersManagement> {
  final AdminService _adminService = AdminService();
  final FirestoreService _firestoreService = FirestoreService();
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
    return AdminCard(
      child: Padding(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar + Info + Action buttons
            Row(
              children: [
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
                        ],
                      ),
                      const SizedBox(height: AdminDesignSystem.spacing4),
                      Text(
                        user.email,
                        style: AdminDesignSystem.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AdminDesignSystem.spacing12),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      tooltip: 'Edit user',
                      onTap: () => _showUserEditForm(user),
                      color: AdminDesignSystem.accentTeal,
                    ),
                    const SizedBox(width: AdminDesignSystem.spacing8),
                    _buildActionButton(
                      icon: Icons.history,
                      tooltip: 'View transactions',
                      onTap: () => _showUserTransactions(user),
                      color: AdminDesignSystem.primaryNavy,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            // Metrics row
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
            const SizedBox(height: AdminDesignSystem.spacing12),
            Row(
              children: [
                Text(
                  'KYC Status: ',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(width: AdminDesignSystem.spacing12),
                _buildKYCBadge(user.kycStatus),
              ],
            ),
            // Phone number row
            if (user.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: AdminDesignSystem.spacing12),
              _buildPhoneRow(user.phoneNumber),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneRow(String phoneNumber) {
    return Row(
      children: [
        Icon(
          Icons.phone_outlined,
          size: 14,
          color: AdminDesignSystem.textTertiary,
        ),
        const SizedBox(width: AdminDesignSystem.spacing8),
        Expanded(
          child: Text(
            phoneNumber,
            style: AdminDesignSystem.bodySmall.copyWith(
              color: AdminDesignSystem.textSecondary,
            ),
          ),
        ),
        _buildPhoneAction(
          icon: Icons.copy,
          tooltip: 'Copy number',
          onTap: () => _copyToClipboard(phoneNumber),
        ),
        const SizedBox(width: AdminDesignSystem.spacing8),
        _buildPhoneAction(
          icon: Icons.call,
          tooltip: 'Call',
          onTap: () => _makeCall(phoneNumber),
        ),
      ],
    );
  }

  Widget _buildPhoneAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
        child: Container(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing4),
          child: Icon(icon, size: 16, color: AdminDesignSystem.accentTeal),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phone number copied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch phone app'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
        child: Container(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
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

  void _showUserEditForm(UserModel user) {
    showUserEditSheet(context, user, () => setState(() {}));
  }

  void _showUserTransactions(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => AdminUserTransactionsSheet(
        userId: user.uid,
        userName: user.displayName,
        firestoreService: _firestoreService,
      ),
    );
  }
}
