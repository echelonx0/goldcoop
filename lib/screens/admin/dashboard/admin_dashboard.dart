// lib/screens/admin/dashboard/admin_dashboard.dart

import 'package:flutter/material.dart';

import '../../../core/theme/admin_design_system.dart';
import '../../../services/admin_service.dart';
import '../../../services/admin_support_service.dart';

import '../sections/deposits_management.dart';
// import '../sections/investments_management.dart';
import '../sections/users_management.dart';
import 'tabs/support_tab.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'tabs/overview_tab.dart';

class AdminDashboard extends StatefulWidget {
  final String adminId;
  final String adminName;
  final String adminAvatar;

  const AdminDashboard({
    super.key,
    required this.adminId,
    required this.adminName,
    required this.adminAvatar,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  final AdminSupportService _adminSupportService = AdminSupportService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDesignSystem.background,
      appBar: AdminAppBar(
        adminId: widget.adminId,
        adminName: widget.adminName,
        adminAvatar: widget.adminAvatar,
        adminSupportService: _adminSupportService,
      ),
      body: _buildContent(),
      bottomNavigationBar: AdminBottomNav(
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return OverviewTab(adminService: _adminService);
      case 1:
        return SupportTab(
          adminId: widget.adminId,
          adminName: widget.adminName,
          adminAvatar: widget.adminAvatar,
          adminSupportService: _adminSupportService,
        );
      case 2:
        return const UsersManagement();
      case 3:
        return AdminDepositsScreen(adminUserId: widget.adminId);

      default:
        return OverviewTab(adminService: _adminService);
    }
  }
}
