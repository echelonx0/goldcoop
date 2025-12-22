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
          onTapGoals: () => setState(() => _selectedTab = 1),
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
