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
      ),
    );
  }
}
