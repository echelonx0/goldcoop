// lib/config/app_router.dart

import 'package:flutter/material.dart';
import 'package:gsa/screens/admin/dashboard/admin_dashboard.dart';
import 'package:gsa/screens/auth/login_screen.dart';
import 'package:gsa/screens/auth/signup_screen.dart';
import 'package:gsa/screens/auth/password_reset_screen.dart';
import 'package:gsa/screens/dashboard/dashboard_screen.dart';
import 'package:gsa/screens/investments/investments_screen.dart';
import 'package:gsa/screens/onboarding/splash_screen.dart';
import 'package:gsa/screens/onboarding/onboarding_carousel.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
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

      // Auth flow
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
        return MaterialPageRoute(builder: (_) => InvestmentsScreen(uid: uid));

      case admin:
        return MaterialPageRoute(
          builder: (_) =>
              const AdminDashboard(adminId: '', adminName: '', adminAvatar: ''),
        );

      // Unknown route
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }

  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const LoginScreen());
  }
}
