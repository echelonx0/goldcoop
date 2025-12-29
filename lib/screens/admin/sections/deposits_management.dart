// lib/screens/admin/admin_deposits_screen.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/payment_proof_model.dart';

import '../../../services/firestore_service.dart';
import '../widgets/proof_detail_modal.dart';
import 'user_savings_deposits_service.dart';

class AdminDepositsScreen extends StatefulWidget {
  final String adminUserId;

  const AdminDepositsScreen({super.key, required this.adminUserId});

  @override
  State<AdminDepositsScreen> createState() => _AdminDepositsScreenState();
}

class _AdminDepositsScreenState extends State<AdminDepositsScreen>
    with SingleTickerProviderStateMixin {
  late final UserSavingsDepositsService _depositService;
  late final FirestoreService _firestoreService;
  late TabController _tabController;

  final _currencyFormatter = NumberFormat('#,##0', 'en_US');
  PaymentProofStatus _filterStatus = PaymentProofStatus.pending;

  @override
  void initState() {
    super.initState();
    _depositService = UserSavingsDepositsService();
    _firestoreService = FirestoreService();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _filterStatus = PaymentProofStatus.pending;
          break;
        case 1:
          _filterStatus = PaymentProofStatus.approved;
          break;
        case 2:
          _filterStatus = PaymentProofStatus.rejected;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          _buildStats(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Deposit Management',
        style: AppTextTheme.bodySmall.copyWith(color: AppColors.deepNavy),
      ),
      elevation: 0,
      backgroundColor: AppColors.backgroundWhite,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => setState(() {}),
          color: AppColors.primaryOrange,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.backgroundWhite,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryOrange,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryOrange,
        indicatorWeight: 3,
        labelStyle: AppTextTheme.bodyRegular.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Approved'),
          Tab(text: 'Rejected'),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return FutureBuilder<int>(
      future: _depositService.getPendingProofsCount(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;

        return DelayedDisplay(
          delay: const Duration(milliseconds: 100),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryOrange,
                  AppColors.primaryOrange.withAlpha(230),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pending_actions, color: Colors.white, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$pendingCount Pending Verification',
                  style: AppTextTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPendingProofsList(),
        _buildApprovedProofsList(),
        _buildRejectedProofsList(),
      ],
    );
  }

  /// Build pending proofs list
  Widget _buildPendingProofsList() {
    return StreamBuilder<List<PaymentProofModel>>(
      stream: _depositService.getPendingPaymentProofsStream(limit: 100),
      builder: (context, snapshot) {
        return _buildProofsListContent(snapshot, PaymentProofStatus.pending);
      },
    );
  }

  /// Build approved proofs list
  Widget _buildApprovedProofsList() {
    return StreamBuilder<List<PaymentProofModel>>(
      stream: _depositService.getApprovedPaymentProofsStream(limit: 100),
      builder: (context, snapshot) {
        return _buildProofsListContent(snapshot, PaymentProofStatus.approved);
      },
    );
  }

  /// Build rejected proofs list
  Widget _buildRejectedProofsList() {
    return StreamBuilder<List<PaymentProofModel>>(
      stream: _depositService.getRejectedPaymentProofsStream(limit: 100),
      builder: (context, snapshot) {
        return _buildProofsListContent(snapshot, PaymentProofStatus.rejected);
      },
    );
  }

  /// Generic proofs list builder
  Widget _buildProofsListContent(
    AsyncSnapshot<List<PaymentProofModel>> snapshot,
    PaymentProofStatus status,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (snapshot.hasError) {
      return _buildErrorState(snapshot.error.toString());
    }

    final proofs = snapshot.data ?? [];

    if (proofs.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      color: AppColors.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: proofs.length,
        itemBuilder: (context, index) {
          final proof = proofs[index];
          return DelayedDisplay(
            delay: Duration(milliseconds: 50 + (index * 50)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildProofCard(proof),
            ),
          );
        },
      ),
    );
  }

  /// Build individual proof card
  Widget _buildProofCard(PaymentProofModel proof) {
    final amount = proof.metadata['amount'] as double? ?? 0.0;
    final statusColor = _getStatusColor(proof.verificationStatus);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showProofDetails(proof),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deposit Proof',
                          style: AppTextTheme.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₦${_currencyFormatter.format(amount)}',
                          style: AppTextTheme.heading3.copyWith(
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(38),
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.small,
                      ),
                    ),
                    child: Text(
                      proof.verificationStatus.name.toUpperCase(),
                      style: AppTextTheme.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'User ID',
                      proof.userId.substring(0, 8) + '...',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildDetailItem(
                      'File Type',
                      proof.fileType.name.toUpperCase(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Uploaded date
              _buildDetailItem('Uploaded', _formatDate(proof.uploadedAt)),

              // Verified info (if applicable)
              if (proof.verificationStatus != PaymentProofStatus.pending) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildDetailItem(
                  'Verified',
                  _formatDate(proof.verifiedAt ?? DateTime.now()),
                ),
                if (proof.rejectionReason != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailItem('Reason', proof.rejectionReason ?? ''),
                ],
              ],

              const SizedBox(height: AppSpacing.md),

              // Tap to view details hint
              Text(
                'Tap to view details',
                style: AppTextTheme.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextTheme.bodySmall.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(PaymentProofStatus status) {
    switch (status) {
      case PaymentProofStatus.pending:
        return AppColors.primaryOrange;
      case PaymentProofStatus.approved:
        return AppColors.tealSuccess;
      case PaymentProofStatus.rejected:
        return AppColors.warmRed;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  Widget _buildEmptyState(PaymentProofStatus status) {
    String message;
    IconData icon;

    switch (status) {
      case PaymentProofStatus.pending:
        message = 'No pending deposits';
        icon = Icons.inbox;
        break;
      case PaymentProofStatus.approved:
        message = 'No approved deposits yet';
        icon = Icons.check_circle_outline;
        break;
      case PaymentProofStatus.rejected:
        message = 'No rejected deposits';
        icon = Icons.cancel_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DelayedDisplay(
            delay: const Duration(milliseconds: 200),
            child: Icon(icon, size: 64, color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayedDisplay(
            delay: const Duration(milliseconds: 300),
            child: Text(
              message,
              style: AppTextTheme.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    print(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.warmRed),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Failed to load deposits',
            style: AppTextTheme.bodyLarge.copyWith(color: AppColors.warmRed),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: AppTextTheme.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showProofDetails(PaymentProofModel proof) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProofDetailModal(
        proof: proof,
        adminUserId: widget.adminUserId,
        onApprove: () => _handleApprove(proof),
        onReject: () => _handleReject(proof),
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _handleApprove(PaymentProofModel proof) async {
    // Close detail modal
    Navigator.pop(context);

    // Show loading
    _showLoadingDialog('Approving deposit...');

    try {
      final success = await _depositService.approvePaymentProof(
        proofId: proof.proofId,
        adminUserId: widget.adminUserId,
      );

      // Close loading
      if (mounted) Navigator.pop(context);

      if (success) {
        _showSuccessSnackbar('Deposit approved successfully');
        setState(() {}); // Refresh list
      } else {
        _showErrorSnackbar('Failed to approve deposit');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorSnackbar('Error: ${e.toString()}');
    }
  }

  Future<void> _handleReject(PaymentProofModel proof) async {
    // Show rejection reason dialog
    final reason = await _showRejectReasonDialog();
    if (reason == null || reason.isEmpty) return;

    // Close detail modal
    Navigator.pop(context);

    // Show loading
    _showLoadingDialog('Rejecting deposit...');

    try {
      final success = await _depositService.rejectPaymentProof(
        proofId: proof.proofId,
        adminUserId: widget.adminUserId,
        reason: reason,
      );

      // Close loading
      if (mounted) Navigator.pop(context);

      if (success) {
        _showSuccessSnackbar('Deposit rejected');
        setState(() {}); // Refresh list
      } else {
        _showErrorSnackbar('Failed to reject deposit');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorSnackbar('Error: ${e.toString()}');
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rejection Reason',
          style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter reason for rejection...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warmRed),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primaryOrange),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: Text(message, style: AppTextTheme.bodyRegular)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.tealSuccess,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.warmRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
