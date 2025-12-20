// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/theme/app_colors.dart';
// import '../../providers/auth_provider.dart';
// import '../../services/firestore_service.dart';
// import '../../services/support_service.dart';
// import '../../models/user_model.dart';
// import '../../models/support_models.dart';
// import '../support/notification_center_complete.dart';
// import '../support/chat_screen_complete.dart';
// import '../support/faq_widget.dart';
// import '../support/support_ticket_form.dart';
// import '../transactions/transactions_screen.dart';
// import 'modals/withdrawal_modal.dart';
// import 'tabs/home_tab.dart';
// import 'tabs/savings_tab.dart';
// import 'tabs/tokens_tab.dart';
// import 'tabs/account_tab.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedTab = 0;
//   late final FirestoreService _firestoreService;
//   late final SupportService _supportService;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreService = FirestoreService();
//     _supportService = SupportService();
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

//               return Scaffold(
//                 backgroundColor: AppColors.backgroundNeutral,
//                 appBar: _buildAppBar(user, uid),
//                 body: _buildBody(uid),
//                 bottomNavigationBar: _buildBottomNav(),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(UserModel? user, String uid) {
//     return AppBar(
//       backgroundColor: AppColors.backgroundWhite,
//       elevation: 0,
//       title: Text(
//         user != null ? 'Welcome, ${user.firstName}' : 'Welcome',
//         style: AppTextTheme.bodyRegular.copyWith(
//           color: AppColors.deepNavy,
//           fontWeight: FontWeight.w600,
//           fontSize: 16,
//         ),
//       ),
//       actions: [
//         NotificationBadge(
//           userId: uid,
//           supportService: _supportService,
//           onNotificationTap: (notification) {
//             _handleNotificationTap(notification, uid, user);
//           },
//         ),
//         const SizedBox(width: 8),
//         IconButton(
//           icon: const Icon(Icons.settings_outlined, size: 22),
//           color: AppColors.deepNavy,
//           onPressed: () => _showOptionsMenu(uid, user),
//         ),
//       ],
//     );
//   }

//   Widget _buildBody(String uid) {
//     return IndexedStack(
//       index: _selectedTab,
//       children: [
//         HomeTab(
//           uid: uid,
//           onTopUp: () {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(const SnackBar(content: Text('Top-up coming soon')));
//           },
//           onInvest: () {
//             Navigator.pushNamed(context, '/invest');
//           },
//           onWithdraw: () {
//           _showWithdrawalModal()
//           },
//           onHistory: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => TransactionsScreen(uid: uid),
//               ),
//             );
//           },
//           // onViewAllGoals: () => setState(() => _selectedTab = 1),
//         ),
//         SavingsTab(uid: uid),
//         TokensTab(uid: uid, onConvert: () {}),
//         AccountTab(
//           authProvider: context.read<AuthProvider>(),
//           onEditProfile: () {},
//           onChangePassword: () {},
//           onSignOut: () => _handleSignOut(),
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomNav() {
//     return BottomNavigationBar(
//       currentIndex: _selectedTab,
//       onTap: (index) => setState(() => _selectedTab = index),
//       type: BottomNavigationBarType.fixed,
//       selectedFontSize: 12,
//       unselectedFontSize: 11,
//       selectedItemColor: AppColors.primaryOrange,
//       unselectedItemColor: AppColors.textSecondary,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home_outlined, size: 24),
//           activeIcon: Icon(Icons.home, size: 24),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.savings_outlined, size: 24),
//           activeIcon: Icon(Icons.savings, size: 24),
//           label: 'Savings',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.stars_outlined, size: 24),
//           activeIcon: Icon(Icons.stars, size: 24),
//           label: 'Tokens',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person_outline, size: 24),
//           activeIcon: Icon(Icons.person, size: 24),
//           label: 'Account',
//         ),
//       ],
//     );
//   }

//   void _showOptionsMenu(String uid, UserModel? user) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundWhite,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(AppBorderRadius.large),
//             topRight: Radius.circular(AppBorderRadius.large),
//           ),
//         ),
//         padding: const EdgeInsets.all(AppSpacing.lg),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: AppColors.borderLight,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: AppSpacing.lg),
//             Text(
//               'Settings',
//               style: AppTextTheme.heading3.copyWith(
//                 color: AppColors.deepNavy,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: AppSpacing.md),
//             _buildMenuTile(
//               icon: Icons.help_outline,
//               title: 'Help & Support',
//               onTap: () {
//                 Navigator.pop(context);
//                 _showSupportMenu(uid, user);
//               },
//             ),
//             _buildMenuTile(
//               icon: Icons.description_outlined,
//               title: 'Terms & Conditions',
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             _buildMenuTile(
//               icon: Icons.privacy_tip_outlined,
//               title: 'Privacy Policy',
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             _buildMenuTile(
//               icon: Icons.logout,
//               title: 'Sign Out',
//               onTap: () {
//                 Navigator.pop(context);
//                 _handleSignOut();
//               },
//               isDestructive: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showSupportMenu(String uid, UserModel? user) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundWhite,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(AppBorderRadius.large),
//             topRight: Radius.circular(AppBorderRadius.large),
//           ),
//         ),
//         padding: const EdgeInsets.all(AppSpacing.lg),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: AppColors.borderLight,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: AppSpacing.lg),
//             Text(
//               'Help & Support',
//               style: AppTextTheme.heading3.copyWith(
//                 color: AppColors.deepNavy,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: AppSpacing.md),
//             _buildMenuTile(
//               icon: Icons.help_center_outlined,
//               title: 'View FAQ',
//               onTap: () {
//                 Navigator.pop(context);
//                 _showFAQModal(uid, user);
//               },
//             ),
//             _buildMenuTile(
//               icon: Icons.chat_bubble_outline,
//               title: 'Create Support Ticket',
//               onTap: () {
//                 Navigator.pop(context);
//                 _showCreateTicketForm(uid, user);
//               },
//             ),
//             _buildMenuTile(
//               icon: Icons.history,
//               title: 'View My Tickets',
//               onTap: () {
//                 Navigator.pop(context);
//                 _showMyTickets(uid);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showFAQModal(String uid, UserModel? user) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundWhite,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(AppBorderRadius.large),
//             topRight: Radius.circular(AppBorderRadius.large),
//           ),
//         ),
//         height: MediaQuery.of(context).size.height * 0.9,
//         child: FAQWidget(
//           onContactSupport: () {
//             Navigator.pop(context);
//             _showCreateTicketForm(uid, user);
//           },
//         ),
//       ),
//     );
//   }
// void _showWithdrawalModal(UserModel user) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) => WithdrawalModal(
//       user: user,
//       onSuccess: () {
//         // User successfully submitted withdrawal
//         // Modal auto-closes and returns to HomeTab
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Withdrawal submitted successfully'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//         // Optional: refresh user data
//         setState(() {});
//       },
//     ),
//   );
// }
//   void _showCreateTicketForm(String uid, UserModel? user) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundWhite,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(AppBorderRadius.large),
//             topRight: Radius.circular(AppBorderRadius.large),
//           ),
//         ),
//         child: SupportTicketForm(
//           userId: uid,
//           userName: user?.firstName ?? 'User',
//           userEmail: user?.email ?? '',
//           onSubmitSuccess: () {
//             Navigator.pop(context);
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text(
//                   'Support ticket created! You will hear from us soon.',
//                 ),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _showMyTickets(String uid) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundWhite,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(AppBorderRadius.large),
//             topRight: Radius.circular(AppBorderRadius.large),
//           ),
//         ),
//         height: MediaQuery.of(context).size.height * 0.8,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(AppSpacing.lg),
//               child: Text(
//                 'My Support Tickets',
//                 style: AppTextTheme.heading3.copyWith(
//                   color: AppColors.deepNavy,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: StreamBuilder<List<SupportTicket>>(
//                 stream: _supportService.getUserTicketsStream(uid),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: AppColors.primaryOrange,
//                       ),
//                     );
//                   }

//                   final tickets = snapshot.data ?? [];

//                   if (tickets.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             size: 48,
//                             color: AppColors.textTertiary,
//                           ),
//                           const SizedBox(height: AppSpacing.md),
//                           Text(
//                             'No tickets yet',
//                             style: AppTextTheme.bodyRegular.copyWith(
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   return ListView.separated(
//                     padding: const EdgeInsets.all(AppSpacing.md),
//                     itemCount: tickets.length,
//                     separatorBuilder: (_, __) =>
//                         const SizedBox(height: AppSpacing.sm),
//                     itemBuilder: (context, index) {
//                       final ticket = tickets[index];
//                       return _buildTicketTile(ticket, uid);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTicketTile(SupportTicket ticket, String uid) {
//     final statusColor = _getStatusColor(ticket.status);

//     return GestureDetector(
//       onTap: () async {
//         try {
//           final conversations = await _supportService.getUserConversations(uid);

//           // Find conversation for this ticket
//           SupportConversation? conversation;
//           try {
//             conversation = conversations.firstWhere(
//               (c) => c.relatedTicketId == ticket.ticketId,
//             );
//           } catch (e) {
//             conversation = null;
//           }

//           if (!mounted) return;

//           // If no conversation found, show error
//           if (conversation == null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text(
//                   'No chat found for this ticket. Please create it in support menu.',
//                 ),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//             return;
//           }

//           Navigator.pop(context);
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ChatScreen(
//                 conversationId: conversation!.conversationId,
//                 userId: uid,
//                 userName: 'User',
//                 userAvatar: '',
//                 relatedTicket: ticket,
//               ),
//             ),
//           );
//         } catch (e) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//             );
//           }
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.all(AppSpacing.md),
//         decoration: BoxDecoration(
//           color: AppColors.backgroundNeutral,
//           borderRadius: BorderRadius.circular(AppBorderRadius.medium),
//           border: Border.all(color: AppColors.borderLight),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Ticket #${ticket.ticketId.substring(0, 8)}',
//                         style: AppTextTheme.bodyRegular.copyWith(
//                           color: AppColors.deepNavy,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         ticket.subject,
//                         style: AppTextTheme.bodySmall.copyWith(
//                           color: AppColors.textSecondary,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppSpacing.sm,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor.withAlpha(25),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     ticket.status.name.capitalize(),
//                     style: AppTextTheme.bodySmall.copyWith(
//                       color: statusColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppSpacing.sm),
//             Text(
//               'Category: ${ticket.category.name.capitalize()}',
//               style: AppTextTheme.bodySmall.copyWith(
//                 color: AppColors.textTertiary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuTile({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     bool isDestructive = false,
//   }) {
//     return ListTile(
//       leading: Icon(
//         icon,
//         color: isDestructive ? AppColors.warmRed : AppColors.deepNavy,
//         size: 22,
//       ),
//       title: Text(
//         title,
//         style: AppTextTheme.bodyRegular.copyWith(
//           color: isDestructive ? AppColors.warmRed : AppColors.deepNavy,
//           fontSize: 14,
//         ),
//       ),
//       onTap: onTap,
//       contentPadding: EdgeInsets.zero,
//     );
//   }

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

//   void _handleNotificationTap(
//     SupportNotification notification,
//     String uid,
//     UserModel? user,
//   ) {
//     if (notification.relatedConversationId != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => ChatScreen(
//             conversationId: notification.relatedConversationId!,
//             userId: uid,
//             userName: user?.firstName ?? 'User',
//             userAvatar: user?.profilePic ?? '',
//             relatedTicket: null,
//           ),
//         ),
//       );
//     } else if (notification.relatedTicketId != null) {
//       _showMyTickets(uid);
//     }
//   }

//   Color _getStatusColor(TicketStatus status) {
//     switch (status) {
//       case TicketStatus.open:
//         return AppColors.primaryOrange;
//       case TicketStatus.assigned:
//         return Colors.blue;
//       case TicketStatus.inProgress:
//         return Colors.orange;
//       case TicketStatus.waiting:
//         return Colors.amber;
//       case TicketStatus.resolved:
//         return Colors.green;
//       case TicketStatus.closed:
//         return AppColors.textSecondary;
//       case TicketStatus.reopened:
//         return AppColors.warmRed;
//     }
//   }
// }

// extension on String {
//   String capitalize() {
//     if (isEmpty) return this;
//     return this[0].toUpperCase() + substring(1);
//   }
// }
// lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/support_service.dart';
import '../../services/wallet_service.dart';
import '../../models/user_model.dart';
import '../../models/support_models.dart';
import '../support/faq_widget.dart';
import '../support/support_ticket_form.dart';
import '../support/chat_screen_complete.dart';
import '../transactions/transactions_screen.dart';
import 'modals/withdrawal_modal.dart';
import 'tabs/home_tab.dart';
import 'tabs/savings_tab.dart';
import 'tabs/tokens_tab.dart';
import 'tabs/account_tab.dart';
import 'widgets/appbar.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/dashboard_support_menu.dart';
import 'widgets/settings_menu.dart';
import 'widgets/tickets_modal.dart';

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

              return Scaffold(
                backgroundColor: AppColors.backgroundNeutral,
                appBar: DashboardAppBar(
                  user: user,
                  uid: uid,
                  supportService: _supportService,
                  onNotificationTap: (notification, userId, userModel) {
                    _handleNotificationTap(notification, userId, userModel);
                  },
                  onSettingsTap: () => _showSettingsMenu(uid, user),
                ),
                body: _buildBody(uid, user),
                bottomNavigationBar: DashboardBottomNav(
                  currentIndex: _selectedTab,
                  onTabChanged: (index) {
                    setState(() => _selectedTab = index);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(String uid, UserModel? user) {
    return IndexedStack(
      index: _selectedTab,
      children: [
        HomeTab(
          uid: uid,
          onTopUp: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Top-up coming soon')));
          },
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
        ),
        SavingsTab(uid: uid),
        TokensTab(uid: uid),
        AccountTab(
          authProvider: context.read<AuthProvider>(),
          onEditProfile: () {},
          onChangePassword: () {},
          onSignOut: () => _handleSignOut(),
        ),
      ],
    );
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

  // ==================== SETTINGS MENU ====================

  void _showSettingsMenu(String uid, UserModel? user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DashboardSettingsMenu(
        uid: uid,
        user: user,
        onHelpAndSupport: () {
          Navigator.pop(context);
          _showSupportMenu();
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

  // ==================== SUPPORT MENU ====================

  void _showSupportMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DashboardSupportMenu(
        onFAQ: () {
          Navigator.pop(context);
          _showFAQModal();
        },
        onCreateTicket: () {
          Navigator.pop(context);
          final uid = context.read<AuthProvider>().currentUser!.uid;
          final user = context.read<AuthProvider>();
          // TODO: Get user data properly
          _showCreateTicketForm(uid, null);
        },
        onViewTickets: () {
          Navigator.pop(context);
          final uid = context.read<AuthProvider>().currentUser!.uid;
          _showMyTickets(uid);
        },
      ),
    );
  }

  // ==================== FAQ MODAL ====================

  void _showFAQModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.large),
            topRight: Radius.circular(AppBorderRadius.large),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.9,
        child: FAQWidget(
          onContactSupport: () {
            Navigator.pop(context);
            final uid = context.read<AuthProvider>().currentUser!.uid;
            _showCreateTicketForm(uid, null);
          },
        ),
      ),
    );
  }

  // ==================== CREATE TICKET FORM ====================

  void _showCreateTicketForm(String uid, UserModel? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.large),
            topRight: Radius.circular(AppBorderRadius.large),
          ),
        ),
        child: SupportTicketForm(
          userId: uid,
          userName: user?.firstName ?? 'User',
          userEmail: user?.email ?? '',
          onSubmitSuccess: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Support ticket created! You will hear from us soon.',
                ),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== MY TICKETS MODAL ====================

  void _showMyTickets(String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DashboardMyTickets(
        uid: uid,
        supportService: _supportService,
        onTicketTap: (ticket) {
          // Optional: handle ticket tap
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

  // ==================== NOTIFICATION TAP ====================

  void _handleNotificationTap(
    SupportNotification notification,
    String uid,
    UserModel? user,
  ) {
    if (notification.relatedConversationId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: notification.relatedConversationId!,
            userId: uid,
            userName: user?.firstName ?? 'User',
            userAvatar: user?.profilePic ?? '',
            relatedTicket: null,
          ),
        ),
      );
    } else if (notification.relatedTicketId != null) {
      _showMyTickets(uid);
    }
  }
}
