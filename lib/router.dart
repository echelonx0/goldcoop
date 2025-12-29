// // lib/config/app_router.dart

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gsa/screens/admin/dashboard/admin_dashboard.dart';
// import 'package:gsa/screens/auth/login_screen.dart';
// import 'package:gsa/screens/auth/signup_screen.dart';
// import 'package:gsa/screens/auth/password_reset_screen.dart';
// import 'package:gsa/screens/dashboard/dashboard_screen.dart';
// import 'package:gsa/screens/investments/investments_screen.dart';
// import 'package:gsa/screens/investments/investments_landing_screen.dart';
// import 'package:gsa/screens/onboarding/splash_screen.dart';
// import 'package:gsa/screens/onboarding/onboarding_carousel.dart';

// class AppRouter {
//   static const String splash = '/';
//   static const String onboarding = '/onboarding';
//   static const String login = '/login';
//   static const String signup = '/signup';
//   static const String passwordReset = '/password-reset';
//   static const String forgotPassword = '/forgot-password';
//   static const String dashboard = '/dashboard';
//   static const String invest = '/invest';
//   static const String admin = '/admin';

//   static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       // Onboarding flow
//       case splash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());

//       case onboarding:
//         return MaterialPageRoute(builder: (_) => const OnboardingCarousel());

//       // Auth flow
//       case login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());

//       case signup:
//         return MaterialPageRoute(builder: (_) => const SignupScreen());

//       case passwordReset:
//         return MaterialPageRoute(builder: (_) => const PasswordResetScreen());

//       case forgotPassword:
//         return MaterialPageRoute(builder: (_) => const PasswordResetScreen());

//       // App flow
//       case dashboard:
//         return MaterialPageRoute(builder: (_) => const DashboardScreen());

//       case invest:
//         final args = settings.arguments as Map<String, dynamic>?;
//         final uid = args?['uid'] as String? ?? '';
//         return MaterialPageRoute(
//           builder: (_) => _InvestmentsRouteBuilder(uid: uid),
//         );

//       case admin:
//         return MaterialPageRoute(
//           builder: (_) =>
//               const AdminDashboard(adminId: '', adminName: '', adminAvatar: ''),
//         );

//       // Unknown route
//       default:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//     }
//   }

//   static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
//     return MaterialPageRoute(builder: (_) => const LoginScreen());
//   }
// }

// /// Route builder that checks if user has seen investments landing screen
// class _InvestmentsRouteBuilder extends StatefulWidget {
//   final String uid;

//   const _InvestmentsRouteBuilder({required this.uid});

//   @override
//   State<_InvestmentsRouteBuilder> createState() =>
//       _InvestmentsRouteBuilderState();
// }

// class _InvestmentsRouteBuilderState extends State<_InvestmentsRouteBuilder> {
//   bool _isLoading = true;
//   bool _hasSeenLanding = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLandingStatus();
//   }

//   Future<void> _checkLandingStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasSeenLanding = prefs.getBool('hasSeenInvestmentsLanding') ?? false;

//     if (mounted) {
//       setState(() {
//         _hasSeenLanding = hasSeenLanding;
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       // Show minimal loading indicator while checking preference
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     // Return appropriate screen based on landing status
//     return _hasSeenLanding
//         ? InvestmentsScreen(uid: widget.uid)
//         : InvestmentsLandingScreen(uid: widget.uid);
//   }
// }
// lib/config/app_router.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gsa/screens/admin/dashboard/admin_dashboard.dart';
import 'package:gsa/screens/auth/login_screen.dart';
import 'package:gsa/screens/auth/login_intro_screen.dart';
import 'package:gsa/screens/auth/signup_screen.dart';
import 'package:gsa/screens/auth/password_reset_screen.dart';
import 'package:gsa/screens/dashboard/dashboard_screen.dart';
import 'package:gsa/screens/investments/investments_screen.dart';
import 'package:gsa/screens/investments/investments_landing_screen.dart';
import 'package:gsa/screens/onboarding/splash_screen.dart';
import 'package:gsa/screens/onboarding/onboarding_carousel.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String loginIntro = '/login-intro';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String passwordReset = '/password-reset';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String invest = '/invest';
  static const String admin = '/admin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Onboarding flow
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingCarousel());

      // Auth flow - NEW intro screen
      case loginIntro:
        return MaterialPageRoute(builder: (_) => const LoginIntroScreen());

      // Auth flow - form screen
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case passwordReset:
        return MaterialPageRoute(builder: (_) => const PasswordResetScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const PasswordResetScreen());

      // App flow
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case invest:
        final args = settings.arguments as Map<String, dynamic>?;
        final uid = args?['uid'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => _InvestmentsRouteBuilder(uid: uid),
        );

      case admin:
        return MaterialPageRoute(
          builder: (_) =>
              const AdminDashboard(adminId: '', adminName: '', adminAvatar: ''),
        );

      // Unknown route - send to login intro
      default:
        return MaterialPageRoute(builder: (_) => const LoginIntroScreen());
    }
  }

  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const LoginIntroScreen());
  }
}

/// Route builder that checks if user has seen investments landing screen
class _InvestmentsRouteBuilder extends StatefulWidget {
  final String uid;

  const _InvestmentsRouteBuilder({required this.uid});

  @override
  State<_InvestmentsRouteBuilder> createState() =>
      _InvestmentsRouteBuilderState();
}

class _InvestmentsRouteBuilderState extends State<_InvestmentsRouteBuilder> {
  bool _isLoading = true;
  bool _hasSeenLanding = false;

  @override
  void initState() {
    super.initState();
    _checkLandingStatus();
  }

  Future<void> _checkLandingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenLanding = prefs.getBool('hasSeenInvestmentsLanding') ?? false;

    if (mounted) {
      setState(() {
        _hasSeenLanding = hasSeenLanding;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show minimal loading indicator while checking preference
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Return appropriate screen based on landing status
    return _hasSeenLanding
        ? InvestmentsScreen(uid: widget.uid)
        : InvestmentsLandingScreen(uid: widget.uid);
  }
}
