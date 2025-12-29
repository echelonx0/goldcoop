// lib/screens/dashboard/widgets/dashboard_bottom_nav.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChanged,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      selectedItemColor: AppColors.primaryOrange,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home, size: 24),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.savings_outlined, size: 24),
          activeIcon: Icon(Icons.savings, size: 24),
          label: 'Savings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.stars_outlined, size: 24),
          activeIcon: Icon(Icons.stars, size: 24),
          label: 'Set Goals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'Account',
        ),
      ],
    );
  }
}
