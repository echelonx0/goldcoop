// ==================== ERROR STATE ====================

import 'package:flutter/material.dart';

import '../../../core/theme/admin_design_system.dart';

class ErrorState extends StatelessWidget {
  final String message;

  const ErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminDesignSystem.spacing24),
      decoration: AdminDesignSystem.softCardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AdminDesignSystem.statusError,
          ),
          const SizedBox(height: AdminDesignSystem.spacing12),
          Text(
            message,
            style: AdminDesignSystem.bodyMedium.copyWith(
              color: AdminDesignSystem.statusError,
            ),
          ),
        ],
      ),
    );
  }
}
