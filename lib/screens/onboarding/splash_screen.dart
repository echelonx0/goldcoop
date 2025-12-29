// // lib/screens/onboarding/splash_screen.dart

// import 'package:flutter/material.dart';
// import 'package:delayed_display/delayed_display.dart';
// import '../../core/theme/app_colors.dart';
// import '../../services/onboarding_service.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkOnboardingStatus();
//   }

//   Future<void> _checkOnboardingStatus() async {
//     await Future.delayed(const Duration(seconds: 3));

//     if (!mounted) return;

//     final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();

//     if (mounted) {
//       Navigator.of(
//         context,
//       ).pushReplacementNamed(hasSeenOnboarding ? '/login' : '/onboarding');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryOrange,
//       body: Center(
//         child: DelayedDisplay(
//           delay: const Duration(milliseconds: 300),
//           slidingBeginOffset: const Offset(0.0, 0.2),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFF8C00),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     'GS',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Gold Savings',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF0F1B3C),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Cooperative',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF0F1B3C),
//                 ),
//               ),
//               const SizedBox(height: 48),
//               const CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/onboarding/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../core/theme/app_colors.dart';
import '../../services/onboarding_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();

    if (mounted) {
      // Navigate to login-intro (not directly to login form)
      Navigator.of(context).pushReplacementNamed(
        hasSeenOnboarding ? '/login-intro' : '/onboarding',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: Center(
        child: DelayedDisplay(
          delay: const Duration(milliseconds: 300),
          slidingBeginOffset: const Offset(0.0, 0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Gold Savings &',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F1B3C),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Investment Cooperative',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F1B3C),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Save & Smile',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
