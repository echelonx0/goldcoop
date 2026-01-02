// lib/screens/admin/dashboard/widgets/admin_bottom_nav.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/admin_design_system.dart';

class AdminBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const AdminBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminDesignSystem.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Overview',
                index: 0,
                selectedIndex: selectedIndex,
                onTap: onIndexChanged,
              ),
              _NavItem(
                icon: Icons.trending_up_outlined,
                activeIcon: Icons.trending_up,
                label: 'Manage',
                index: 1,
                selectedIndex: selectedIndex,
                onTap: onIndexChanged,
              ),
              _NavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Users',
                index: 2,
                selectedIndex: selectedIndex,
                onTap: onIndexChanged,
              ),
              _NavItem(
                icon: Icons.account_balance_outlined, // ✅ NEW
                activeIcon: Icons.account_balance, // ✅ NEW
                label: 'Deposits', // ✅ NEW
                index: 3, // ✅ NEW
                selectedIndex: selectedIndex,
                onTap: onIndexChanged,
              ),
              // _NavItem(
              //   icon: Icons.support_agent_outlined,
              //   activeIcon: Icons.support_agent,
              //   label: 'Support',
              //   index: 4, // ✅ CHANGED from 3 to 4
              //   selectedIndex: selectedIndex,
              //   onTap: onIndexChanged,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... rest of _NavItem code stays the same

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminDesignSystem.spacing16,
          vertical: AdminDesignSystem.spacing8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AdminDesignSystem.accentTeal
                  : AdminDesignSystem.textTertiary,
              size: 24,
            ),
            const SizedBox(height: AdminDesignSystem.spacing4),
            Text(
              label,
              style: AdminDesignSystem.labelSmall.copyWith(
                color: isSelected
                    ? AdminDesignSystem.accentTeal
                    : AdminDesignSystem.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
