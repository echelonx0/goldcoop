// // lib/screens/dashboard/dashboard_screen.dart
// // Main dashboard with centralized support system

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/coordinators/support_coordinator.dart';
// import '../../core/theme/admin_design_system.dart';
// import '../../core/theme/app_colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../services/firestore_service.dart';
// import '../../services/support_service.dart';
// import '../../services/wallet_service.dart';
// import '../../models/user_model.dart';
// import '../transactions/transactions_screen.dart';
// import 'modals/withdrawal_modal.dart';
// import 'tabs/home/home_tab.dart';
// import 'tabs/savings/general_savings_section.dart';
// import 'tabs/savings/set_savings_target_form.dart';
// import 'tabs/savings_tab.dart';
// import 'tabs/tokens_tab.dart';
// import 'tabs/account/account_tab.dart';
// import 'widgets/appbar.dart';
// import 'widgets/bottom_nav.dart';
// import 'widgets/settings_menu.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedTab = 0;
//   late final FirestoreService _firestoreService;
//   late final SupportService _supportService;
//   late final WalletService _walletService;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreService = FirestoreService();
//     _supportService = SupportService();
//     _walletService = WalletService();
//   }

//   void _onTabChanged(int index) {
//     setState(() => _selectedTab = index);
//   }

//   /// Creates a SupportCoordinator with current context and user data
//   SupportCoordinator _getSupportCoordinator(String uid, UserModel? user) {
//     return SupportCoordinator(
//       context: context,
//       supportService: _supportService,
//       userId: uid,
//       user: user,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       child: Consumer<AuthProvider>(
//         builder: (context, authProvider, _) {
//           return StreamBuilder<UserModel?>(
//             stream: _firestoreService.getUserStream(
//               authProvider.currentUser!.uid,
//             ),
//             builder: (context, snapshot) {
//               final user = snapshot.data;
//               final uid = authProvider.currentUser!.uid;
//               final supportCoordinator = _getSupportCoordinator(uid, user);

//               return Scaffold(
//                 backgroundColor: AppColors.backgroundNeutral,
//                 appBar: DashboardAppBar(
//                   user: user,
//                   uid: uid,
//                   supportService: _supportService,
//                   onNotificationTap: (notification, userId, userModel) {
//                     supportCoordinator.openChatFromNotification(notification);
//                   },
//                   onSettingsTap: () =>
//                       _showSettingsMenu(uid, user, supportCoordinator),
//                 ),
//                 body: _buildBody(uid, user, supportCoordinator),
//                 bottomNavigationBar: DashboardBottomNav(
//                   currentIndex: _selectedTab,
//                   onTabChanged: _onTabChanged,
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBody(
//     String uid,
//     UserModel? user,
//     SupportCoordinator supportCoordinator,
//   ) {
//     switch (_selectedTab) {
//       case 0:
//         return HomeTab(
//           uid: uid,

//           onInvest: () {
//             Navigator.pushNamed(context, '/invest');
//           },
//           onWithdraw: () => _showWithdrawalModal(user),
//           onHistory: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => TransactionsScreen(uid: uid),
//               ),
//             );
//           },
//         );
//       case 1:
//         return SavingsTab(uid: uid);
//       case 2:
//         // return TokensTab(uid: uid);
//         return GeneralSavingsSection(
//           uid: uid,
//           onSetTarget: _showSetSavingsTargetSheet,
//         );
//       case 3:
//         return AccountTab(
//           authProvider: context.read<AuthProvider>(),
//           supportCoordinator: supportCoordinator,
//           onEditProfile: () {},
//           onSignOut: () => _handleSignOut(),
//         );
//       default:
//         return HomeTab(uid: uid);
//     }
//   }

//   // ==================== WITHDRAWAL ====================

//   void _showSetSavingsTargetSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => SetSavingsTargetForm(
//         onSetTarget: (amount) => _handleSetSavingsTarget(amount),
//         onCancel: () => Navigator.pop(context),
//       ),
//     );
//   }

//   Future<void> _handleSetSavingsTarget(double amount) async {
//     final uid = context.read<AuthProvider>().currentUser!.uid;
//     final success = await _firestoreService.updateFinancialProfile(
//       uid: uid,
//       savingsTarget: amount,
//     );

//     if (mounted) {
//       Navigator.pop(context);
//       if (success) {
//         final user = await _firestoreService.getUser(uid);
//         log(
//           'After save - savingsTarget: ${user?.financialProfile.savingsTarget}',
//         );

//         _showSuccessSnackbar('Savings target set');
//       } else {
//         _showErrorSnackbar('Failed to set target');
//       }
//     }
//   }

//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: AdminDesignSystem.statusActive,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: AdminDesignSystem.statusError,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showWithdrawalModal(UserModel? user) {
//     if (user == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Unable to load user data')));
//       return;
//     }

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => WithdrawalModal(
//         user: user,
//         onSuccess: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Withdrawal submitted successfully'),
//               duration: Duration(seconds: 2),
//             ),
//           );
//           setState(() {});
//         },
//       ),
//     );
//   }

//   // ==================== SETTINGS MENU ====================

//   void _showSettingsMenu(
//     String uid,
//     UserModel? user,
//     SupportCoordinator supportCoordinator,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DashboardSettingsMenu(
//         uid: uid,
//         user: user,
//         onHelpAndSupport: () {
//           Navigator.pop(context);
//           supportCoordinator.showSupportMenu();
//         },
//         onTerms: () {
//           Navigator.pop(context);
//           // TODO: Show terms
//         },
//         onPrivacy: () {
//           Navigator.pop(context);
//           // TODO: Show privacy policy
//         },
//         onSignOut: () {
//           Navigator.pop(context);
//           _handleSignOut();
//         },
//       ),
//     );
//   }

//   // ==================== SIGN OUT ====================

//   void _handleSignOut() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Sign Out',
//           style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
//         ),
//         content: Text(
//           'Are you sure you want to sign out?',
//           style: AppTextTheme.bodyRegular.copyWith(
//             color: AppColors.textSecondary,
//             fontSize: 14,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: AppTextTheme.bodyRegular.copyWith(
//                 color: AppColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               context.read<AuthProvider>().signOut().then((_) {
//                 Navigator.of(context).pushReplacementNamed('/login');
//               });
//             },
//             child: Text(
//               'Sign Out',
//               style: AppTextTheme.bodyRegular.copyWith(
//                 color: AppColors.warmRed,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/dashboard/dashboard_screen.dart
// Main dashboard with centralized support system

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/coordinators/support_coordinator.dart';
import '../../core/theme/admin_design_system.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/support_service.dart';
import '../../services/wallet_service.dart';
import '../../models/user_model.dart';
import '../transactions/transactions_screen.dart';
import 'modals/withdrawal_modal.dart';
import 'tabs/home/home_tab.dart';
import 'tabs/savings/general_savings_section.dart';
import 'tabs/savings/set_savings_target_form.dart';
import 'tabs/savings_tab.dart';

import 'tabs/account/account_tab.dart';
import 'widgets/appbar.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/settings_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;
  late final FirestoreService _firestoreService;
  late final SupportService _supportService;
  late final WalletService _walletService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _supportService = SupportService();
    _walletService = WalletService();
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTab = index);
  }

  /// Creates a SupportCoordinator with current context and user data
  SupportCoordinator _getSupportCoordinator(String uid, UserModel? user) {
    return SupportCoordinator(
      context: context,
      supportService: _supportService,
      userId: uid,
      user: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return StreamBuilder<UserModel?>(
            stream: _firestoreService.getUserStream(
              authProvider.currentUser!.uid,
            ),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final uid = authProvider.currentUser!.uid;
              final supportCoordinator = _getSupportCoordinator(uid, user);

              return Scaffold(
                backgroundColor: AppColors.backgroundNeutral,
                appBar: DashboardAppBar(
                  user: user,
                  uid: uid,
                  supportService: _supportService,
                  onNotificationTap: (notification, userId, userModel) {
                    supportCoordinator.openChatFromNotification(notification);
                  },
                  onSettingsTap: () =>
                      _showSettingsMenu(uid, user, supportCoordinator),
                ),
                body: _buildBody(uid, user, supportCoordinator),
                bottomNavigationBar: DashboardBottomNav(
                  currentIndex: _selectedTab,
                  onTabChanged: _onTabChanged,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    String uid,
    UserModel? user,
    SupportCoordinator supportCoordinator,
  ) {
    switch (_selectedTab) {
      case 0:
        return HomeTab(
          uid: uid,
          onInvest: () {
            Navigator.pushNamed(context, '/invest');
          },
          onWithdraw: () => _showWithdrawalModal(user),
          onHistory: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionsScreen(uid: uid),
              ),
            );
          },
        );
      case 1:
        return SavingsTab(uid: uid);
      case 2:
        // return TokensTab(uid: uid);
        return GeneralSavingsSection(
          uid: uid,
          onSetTarget: _showSetSavingsTargetSheet,
        );
      case 3:
        return AccountTab(
          authProvider: context.read<AuthProvider>(),
          supportCoordinator: supportCoordinator,
          onEditProfile: () {},
          onSignOut: () => _handleSignOut(),
        );
      default:
        return HomeTab(uid: uid);
    }
  }

  // ==================== SAVINGS TARGET ====================

  void _showSetSavingsTargetSheet({
    double? currentTarget,
    DateTime? currentTargetDate,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetSavingsTargetForm(
        onSetTarget: (amount, targetDate) =>
            _handleSetSavingsTarget(amount, targetDate),
        onCancel: () => Navigator.pop(context),
        currentTarget: currentTarget,
        currentTargetDate: currentTargetDate,
      ),
    );
  }

  Future<void> _handleSetSavingsTarget(
    double amount,
    DateTime targetDate,
  ) async {
    final uid = context.read<AuthProvider>().currentUser!.uid;
    final success = await _firestoreService.updateSavingsTarget(
      uid: uid,
      amount: amount,
      targetDate: targetDate,
    );

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        final user = await _firestoreService.getUser(uid);
        log(
          'After save - savingsTarget: ${user?.financialProfile.savingsTarget}, '
          'targetDate: ${user?.financialProfile.savingsTargetDate}',
        );

        _showSuccessSnackbar('Savings target updated');
      } else {
        _showErrorSnackbar('Failed to update target');
      }
    }
  }

  // ==================== WITHDRAWAL ====================

  void _showWithdrawalModal(UserModel? user) {
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load user data')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WithdrawalModal(
        user: user,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Withdrawal submitted successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {});
        },
      ),
    );
  }

  // ==================== SNACKBARS ====================

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminDesignSystem.statusActive,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminDesignSystem.statusError,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==================== SETTINGS MENU ====================

  void _showSettingsMenu(
    String uid,
    UserModel? user,
    SupportCoordinator supportCoordinator,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DashboardSettingsMenu(
        uid: uid,
        user: user,
        onHelpAndSupport: () {
          Navigator.pop(context);
          supportCoordinator.showSupportMenu();
        },
        onTerms: () {
          Navigator.pop(context);
          // TODO: Show terms
        },
        onPrivacy: () {
          Navigator.pop(context);
          // TODO: Show privacy policy
        },
        onSignOut: () {
          Navigator.pop(context);
          _handleSignOut();
        },
      ),
    );
  }

  // ==================== SIGN OUT ====================

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: AppTextTheme.heading3.copyWith(color: AppColors.deepNavy),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextTheme.bodyRegular.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut().then((_) {
                Navigator.of(context).pushReplacementNamed('/login');
              });
            },
            child: Text(
              'Sign Out',
              style: AppTextTheme.bodyRegular.copyWith(
                color: AppColors.warmRed,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
