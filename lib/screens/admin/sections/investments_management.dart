// lib/screens/admin/investment_plans_management.dart

import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../../../core/theme/admin_design_system.dart';
import '../../../models/investment_plan_model.dart';
import '../../../services/investment_plan_service.dart';
import '../../../services/admin_service.dart';
import '../forms/investment_form.dart';

class InvestmentPlansManagement extends StatefulWidget {
  const InvestmentPlansManagement({super.key});

  @override
  State<InvestmentPlansManagement> createState() =>
      _InvestmentPlansManagementState();
}

class _InvestmentPlansManagementState extends State<InvestmentPlansManagement> {
  final InvestmentPlanService _planService = InvestmentPlanService();
  final AdminService _adminService = AdminService();
  final _searchController = TextEditingController();
  String _filterStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 60),
          _buildHeader(),
          _buildFilters(),
          Expanded(child: _buildPlansList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AdminDesignSystem.cardBackground,
      padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
            color: AdminDesignSystem.accentTeal,
            iconSize: 32,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Investment Plans',
                  style: AdminDesignSystem.headingLarge.copyWith(
                    color: AdminDesignSystem.primaryNavy,
                  ),
                ),
                const SizedBox(height: AdminDesignSystem.spacing4),
                Text(
                  'Manage investment plans',
                  style: AdminDesignSystem.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showPlanForm(null),
            icon: const Icon(Icons.add_circle),
            color: AdminDesignSystem.accentTeal,
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Container(
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
                hintText: 'Search plans...',
                hintStyle: AdminDesignSystem.bodyMedium,
                prefixIcon: Icon(
                  Icons.search,
                  color: AdminDesignSystem.textTertiary,
                  size: 20,
                ),
                filled: true,
                fillColor: AdminDesignSystem.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius12,
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AdminDesignSystem.spacing16,
                  vertical: AdminDesignSystem.spacing12,
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _dismissKeyboard(),
            ),
            const SizedBox(height: AdminDesignSystem.spacing12),
            Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: AdminDesignSystem.spacing8),
                _buildFilterChip('Active'),
                const SizedBox(width: AdminDesignSystem.spacing8),
                _buildFilterChip('Featured'),
                const SizedBox(width: AdminDesignSystem.spacing8),
                _buildFilterChip('Inactive'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus == label;
    return InkWell(
      onTap: () {
        setState(() => _filterStatus = label);
        _dismissKeyboard();
      },
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

  Widget _buildPlansList() {
    return StreamBuilder<List<InvestmentPlanModel>>(
      stream: _planService.getActivePlansStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AdminDesignSystem.accentTeal,
            ),
          );
        }

        var plans = snapshot.data ?? [];

        // Apply search filter
        if (_searchController.text.isNotEmpty) {
          plans = plans
              .where(
                (plan) => plan.planName.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
              )
              .toList();
        }

        // Apply status filter
        if (_filterStatus != 'All') {
          plans = plans.where((plan) {
            switch (_filterStatus) {
              case 'Active':
                return plan.isActive && !plan.isFeatured;
              case 'Featured':
                return plan.isFeatured;
              case 'Inactive':
                return !plan.isActive;
              default:
                return true;
            }
          }).toList();
        }

        if (plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: AdminDesignSystem.textTertiary,
                ),
                const SizedBox(height: AdminDesignSystem.spacing12),
                Text('No plans found', style: AdminDesignSystem.bodyMedium),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
          itemCount: plans.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AdminDesignSystem.spacing12),
          itemBuilder: (context, index) {
            final plan = plans[index];
            return _buildPlanCard(plan);
          },
        );
      },
    );
  }

  Widget _buildPlanCard(InvestmentPlanModel plan) {
    return AdminCard(
      onTap: () => _showPlanForm(plan),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AdminDesignSystem.spacing8),
                decoration: BoxDecoration(
                  color: AdminDesignSystem.accentTeal.withAlpha(38),
                  borderRadius: BorderRadius.circular(
                    AdminDesignSystem.radius8,
                  ),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: AdminDesignSystem.accentTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: AdminDesignSystem.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.planName,
                      style: AdminDesignSystem.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AdminDesignSystem.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AdminDesignSystem.spacing4),
                    Text(
                      plan.description,
                      style: AdminDesignSystem.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildPlanStatusBadge(plan),
            ],
          ),
          const SizedBox(height: AdminDesignSystem.spacing16),

          // Investment range row
          Container(
            decoration: BoxDecoration(
              color: AdminDesignSystem.background,
              borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDesignSystem.spacing12,
              vertical: AdminDesignSystem.spacing8,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.price_change,
                  size: 16,
                  color: AdminDesignSystem.accentTeal,
                ),
                const SizedBox(width: AdminDesignSystem.spacing8),
                Text(
                  'Range: ${_formatCurrency(plan.minimumInvestment)} - ${_formatCurrency(plan.maximumInvestment)}',
                  style: AdminDesignSystem.bodySmall.copyWith(
                    color: AdminDesignSystem.accentTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AdminDesignSystem.spacing12),

          // Metrics row
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Return',
                  '${plan.expectedAnnualReturn.toStringAsFixed(1)}%',
                  AdminDesignSystem.statusActive,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Duration',
                  '${plan.durationMonths}m',
                  AdminDesignSystem.primaryNavy,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Payout',
                  plan.payoutFrequency,
                  AdminDesignSystem.accentTeal,
                ),
              ),
            ],
          ),

          const SizedBox(height: AdminDesignSystem.spacing16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showPlanForm(plan),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AdminDesignSystem.accentTeal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDelete(plan),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: AdminDesignSystem.statusError,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AdminDesignSystem.labelSmall),
        const SizedBox(height: AdminDesignSystem.spacing4),
        Text(
          value,
          style: AdminDesignSystem.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlanStatusBadge(InvestmentPlanModel plan) {
    if (plan.isFeatured) {
      return StatusBadge(
        label: 'Featured',
        color: AdminDesignSystem.statusPending,
      );
    } else if (plan.isActive) {
      return StatusBadge(
        label: 'Active',
        color: AdminDesignSystem.statusActive,
      );
    } else {
      return StatusBadge(
        label: 'Inactive',
        color: AdminDesignSystem.statusInactive,
      );
    }
  }

  void _showPlanForm(InvestmentPlanModel? plan) {
    _dismissKeyboard();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvestmentPlanForm(
        plan: plan,
        onSave: (updatedPlan) async {
          try {
            if (plan == null) {
              await _adminService.createPlan(updatedPlan);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Plan created: ${updatedPlan.planName}'),
                  backgroundColor: AdminDesignSystem.statusActive,
                ),
              );
            } else {
              await _adminService.updatePlan(plan.planId, updatedPlan);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Plan updated: ${updatedPlan.planName}'),
                  backgroundColor: AdminDesignSystem.statusActive,
                ),
              );
            }
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AdminDesignSystem.statusError,
              ),
            );
            dev.log('[InvestmentPlansManagement] Error saving plan: $e');
          }
        },
      ),
    );
  }

  void _confirmDelete(InvestmentPlanModel plan) {
    _dismissKeyboard();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius16),
        ),
        title: Text('Delete Plan', style: AdminDesignSystem.headingMedium),
        content: Text(
          'Are you sure you want to delete "${plan.planName}"? This action cannot be undone.',
          style: AdminDesignSystem.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AdminDesignSystem.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _adminService.deletePlan(plan.planId);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Plan deleted: ${plan.planName}'),
                    backgroundColor: AdminDesignSystem.statusActive,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AdminDesignSystem.statusError,
                  ),
                );
                dev.log('[InvestmentPlansManagement] Error deleting plan: $e');
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: AdminDesignSystem.statusError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = RegExp(r'(\d)(?=(\d{3})+$)');
    final intAmount = amount.toInt();
    final formatted = intAmount.toString().replaceAllMapped(
      formatter,
      (match) => '${match.group(1)},',
    );
    return '₦$formatted';
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }
}

// StatusBadge component
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AdminDesignSystem.radius8),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignSystem.spacing12,
        vertical: AdminDesignSystem.spacing8,
      ),
      child: Text(
        label,
        style: AdminDesignSystem.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// AdminCard component
class AdminCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AdminCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AdminDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(AdminDesignSystem.radius12),
          border: Border.all(color: AdminDesignSystem.divider),
        ),
        padding: const EdgeInsets.all(AdminDesignSystem.spacing16),
        child: child,
      ),
    );
  }
}
