// lib/screens/admin/dashboard/widgets/admin_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/admin_design_system.dart';

class AdminCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AdminCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: AdminDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(color: AdminDesignSystem.divider),
        ),
        child: child,
      ),
    );
  }
}
