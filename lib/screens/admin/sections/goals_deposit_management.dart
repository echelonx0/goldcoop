// // lib/screens/admin/admin_deposits_screen.dart

// import 'package:flutter/material.dart';
// import 'package:delayed_display/delayed_display.dart';
// import 'package:intl/intl.dart';

// import '../../../core/theme/app_colors.dart';
// import '../../../models/payment_proof_model.dart';
// import '../../../services/deposit_service.dart';
// import '../../../services/firestore_service.dart';
// import '../widgets/proof_detail_modal.dart';
// import '../widgets/proof_form.dart';

// class AdminDepositsScreen extends StatefulWidget {
//   final String adminUserId;

//   const AdminDepositsScreen({super.key, required this.adminUserId});

//   @override
//   State<AdminDepositsScreen> createState() => _AdminDepositsScreenState();
// }

// class _AdminDepositsScreenState extends State<AdminDepositsScreen>
//     with SingleTickerProviderStateMixin {
//   late final DepositService _depositService;
//   late final FirestoreService _firestoreService;
//   late TabController _tabController;

//   final _currencyFormatter = NumberFormat('#,##0', 'en_US');
//   PaymentProofStatus _filterStatus = PaymentProofStatus.pending;

//   @override
//   void initState() {
//     super.initState();
//     _depositService = DepositService();
//     _firestoreService = FirestoreService();
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(_onTabChanged);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _onTabChanged() {
//     setState(() {
//       switch (_tabController.index) {
//         case 0:
//           _filterStatus = PaymentProofStatus.pending;
//           break;
//         case 1:
//           _filterStatus = PaymentProofStatus.approved;
//           break;
//         case 2:
//           _filterStatus = PaymentProofStatus.rejected;
//           break;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundNeutral,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildTabBar(),
//           _buildStats(),
//           Expanded(child: _buildContent()),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: Text(
//         'Deposit Management',
//         style: AppTextTheme.bodySmall.copyWith(color: AppColors.deepNavy),
//       ),
//       elevation: 0,
//       backgroundColor: AppColors.backgroundWhite,
//       automaticallyImplyLeading: false,

//       actions: [
//         IconButton(
//           icon: const Icon(Icons.refresh),
//           onPressed: () => setState(() {}),
//           color: AppColors.primaryOrange,
//           tooltip: 'Refresh',
//         ),
//       ],
//     );
//   }

//   Widget _buildTabBar() {
//     return Container(
//       color: AppColors.backgroundWhite,
//       child: TabBar(
//         controller: _tabController,
//         labelColor: AppColors.primaryOrange,
//         unselectedLabelColor: AppColors.textSecondary,
//         indicatorColor: AppColors.primaryOrange,
//         indicatorWeight: 3,
//         labelStyle: AppTextTheme.bodyRegular.copyWith(
//           fontWeight: FontWeight.w600,
//         ),
//         tabs: const [
//           Tab(text: 'Pending'),
//           Tab(text: 'Approved'),
//           Tab(text: 'Rejected'),
//         ],
//       ),
//     );
//   }

//   Widget _buildStats() {
//     return FutureBuilder<int>(
//       future: _depositService.getPendingProofsCount(),
//       builder: (context, snapshot) {
//         final pendingCount = snapshot.data ?? 0;

//         return DelayedDisplay(
//           delay: const Duration(milliseconds: 100),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(AppSpacing.md),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.primaryOrange,
//                   AppColors.primaryOrange.withAlpha(230),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.pending_actions, color: Colors.white, size: 24),
//                 const SizedBox(width: AppSpacing.sm),
//                 Text(
//                   '$pendingCount Pending Verification',
//                   style: AppTextTheme.bodyLarge.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildContent() {
//     return TabBarView(
//       controller: _tabController,
//       children: [
//         _buildProofsList(PaymentProofStatus.pending),
//         _buildProofsList(PaymentProofStatus.approved),
//         _buildProofsList(PaymentProofStatus.rejected),
//       ],
//     );
//   }

//   Widget _buildProofsList(PaymentProofStatus status) {
//     return StreamBuilder<List<PaymentProofModel>>(
//       stream: status == PaymentProofStatus.pending
//           ? _depositService.getPendingPaymentProofsStream(limit: 100)
//           : _getProofsByStatus(status),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(color: AppColors.primaryOrange),
//           );
//         }

//         if (snapshot.hasError) {
//           return _buildErrorState(snapshot.error.toString());
//         }

//         final proofs = snapshot.data ?? [];

//         if (proofs.isEmpty) {
//           return _buildEmptyState(status);
//         }

//         return RefreshIndicator(
//           onRefresh: () async => setState(() {}),
//           color: AppColors.primaryOrange,
//           child: ListView.builder(
//             padding: const EdgeInsets.all(AppSpacing.md),
//             itemCount: proofs.length,
//             itemBuilder: (context, index) {
//               final proof = proofs[index];
//               return DelayedDisplay(
//                 delay: Duration(milliseconds: 50 + (index * 50)),
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: AppSpacing.md),
//                   child: ProofCard(
//                     proof: proof,
//                     currencyFormatter: _currencyFormatter,
//                     onTap: () => _showProofDetails(proof),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Stream<List<PaymentProofModel>> _getProofsByStatus(
//     PaymentProofStatus status,
//   ) {
//     // For approved/rejected, we need a custom stream
//     // This is a workaround - ideally add to DepositService
//     return Stream.value([]);
//   }

//   Widget _buildEmptyState(PaymentProofStatus status) {
//     String message;
//     IconData icon;

//     switch (status) {
//       case PaymentProofStatus.pending:
//         message = 'No pending deposits';
//         icon = Icons.inbox;
//         break;
//       case PaymentProofStatus.approved:
//         message = 'No approved deposits yet';
//         icon = Icons.check_circle_outline;
//         break;
//       case PaymentProofStatus.rejected:
//         message = 'No rejected deposits';
//         icon = Icons.cancel_outlined;
//         break;
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 200),
//             child: Icon(icon, size: 64, color: AppColors.textTertiary),
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           DelayedDisplay(
//             delay: const Duration(milliseconds: 300),
//             child: Text(
//               message,
//               style: AppTextTheme.bodyLarge.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String error) {
//     print(error);
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 64, color: AppColors.warmRed),
//           const SizedBox(height: AppSpacing.lg),
//           Text(
//             'Failed to load deposits',
//             style: AppTextTheme.bodyLarge.copyWith(color: AppColors.warmRed),
//           ),
//           const SizedBox(height: AppSpacing.sm),
//           Text(
//             error,
//             style: AppTextTheme.bodySmall.copyWith(
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   void _showProofDetails(PaymentProofModel proof) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => ProofDetailModal(
//         proof: proof,
//         adminUserId: widget.adminUserId,
//         onApprove: () => _handleApprove(proof),
//         onReject: () => _handleReject(proof),
//         onClose: () => Navigator.pop(context),
//       ),
//     );
//   }

//   Future<void> _handleApprove(PaymentProofModel proof) async {
//     // Close detail modal
//     Navigator.pop(context);

//     // Show loading
//     _showLoadingDialog('Approving deposit...');

//     try {
//       final success = await _depositService.approvePaymentProof(
//         proofId: proof.proofId,
//         adminUserId: widget.adminUserId,
//       );

//       // Close loading
//       if (mounted) Navigator.pop(context);

//       if (success) {
//         _showSuccessSnackbar('Deposit approved successfully');
//         setState(() {}); // Refresh list
//       } else {
//         _showErrorSnackbar('Failed to approve deposit');
//       }
//     } catch (e) {
//       if (mounted) Navigator.pop(context);
//       _showErrorSnackbar('Error: ${e.toString()}');
//     }
//   }

//   Future<void> _handleReject(PaymentProofModel proof) async {
//     // Show rejection reason dialog
//     final reason = await _showRejectReasonDialog();
//     if (reason == null || reason.isEmpty) return;

//     // Close detail modal
//     Navigator.pop(context);

//     // Show loading
//     _showLoadingDialog('Rejecting deposit...');

//     try {
//       final success = await _depositService.rejectPaymentProof(
//         proofId: proof.proofId,
//         adminUserId: widget.adminUserId,
//         reason: reason,
//       );

//       // Close loading
//       if (mounted) Navigator.pop(context);

//       if (success) {
//         _showSuccessSnackbar('Deposit rejected');
//         setState(() {}); // Refresh list
//       } else {
//         _showErrorSnackbar('Failed to reject deposit');
//       }
//     } catch (e) {
//       if (mounted) Navigator.pop(context);
//       _showErrorSnackbar('Error: ${e.toString()}');
//     }
//   }

//   Future<String?> _showRejectReasonDialog() async {
//     final controller = TextEditingController();

//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Rejection Reason',
//           style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
//         ),
//         content: TextField(
//           controller: controller,
//           maxLines: 3,
//           decoration: InputDecoration(
//             hintText: 'Enter reason for rejection...',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, controller.text),
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.warmRed),
//             child: Text('Reject'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLoadingDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         child: Padding(
//           padding: const EdgeInsets.all(AppSpacing.lg),
//           child: Row(
//             children: [
//               CircularProgressIndicator(color: AppColors.primaryOrange),
//               const SizedBox(width: AppSpacing.lg),
//               Expanded(child: Text(message, style: AppTextTheme.bodyRegular)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: AppSpacing.sm),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: AppColors.tealSuccess,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: AppSpacing.sm),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: AppColors.warmRed,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }
