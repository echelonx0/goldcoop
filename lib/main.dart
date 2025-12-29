// lib/main.dart
// Gold Savings App - Main entry point

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gsa/firebase_options.dart';
import 'package:gsa/router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding/splash_screen.dart';

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
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
        builder: (context, child) {
          // Wrap entire app with keyboard dismissal
          return DismissKeyboardWrapper(child: child!);
        },
      ),
    );
  }
}

/// Wraps the entire app to dismiss keyboard when user taps outside text fields.
/// Handles tap gestures on non-interactive areas and unfocuses text input.
class DismissKeyboardWrapper extends StatelessWidget {
  final Widget child;

  const DismissKeyboardWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus current focus node (dismisses keyboard)
        FocusManager.instance.primaryFocus?.unfocus();
      },
      // Important: onTapDown allows the gesture to be registered before
      // other widgets in the tree process the tap
      onTapDown: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
