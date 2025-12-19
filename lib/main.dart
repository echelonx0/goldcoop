// lib/main.dart
// Gold Savings App - Main entry point

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gsa/firebase_options.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'providers/auth_provider.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/password_reset_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/investments/investments_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add more providers here as needed
      ],
      child: MaterialApp(
        title: 'Gold Savings',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/password-reset': (context) => const PasswordResetScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes that need parameters
          if (settings.name == '/invest') {
            final args = settings.arguments as Map<String, dynamic>?;
            final uid = args?['uid'] as String? ?? '';
            return MaterialPageRoute(
              builder: (context) => InvestmentsScreen(uid: uid),
            );
          }

          if (settings.name == '/admin') {
            return MaterialPageRoute(
              builder: (context) =>
                  AdminDashboard(adminId: '', adminName: '', adminAvatar: ''),
            );
          }
          return null;
        },
        // Handle unknown routes
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
        },
      ),
    );
  }
}

// ==================== SPLASH SCREEN ====================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated) {
      // User is logged in, navigate to dashboard
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      // No user, navigate to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'GS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gold Savings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F1B3C),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
            ),
          ],
        ),
      ),
    );
  }
}
