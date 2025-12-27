// lib/screens/onboarding/onboarding_carousel.dart

import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../core/theme/app_colors.dart';
import '../../services/onboarding_service.dart';
import 'auth_options_modal.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          _buildSlide(
            index: 0,
            image: 'assets/images/onboarding_1.png',
            headline: 'Save On Your Own Terms!',
            description:
                'Flexible savings for your goals with competitive rates and zero hidden charges.',
            accentColor: AppColors.primaryOrange,
          ),
          _buildSlide(
            index: 1,
            image: 'assets/images/onboarding_2.png',
            headline: 'Track Every Step of Your Progress',
            description:
                'Watch your savings grow with real-time updates and detailed analytics.',
            accentColor: AppColors.tealSuccess,
          ),
          _buildSlide(
            index: 2,
            image: 'assets/images/onboarding_3.png',
            headline: 'Get Rewards While You Save!',
            description:
                'Earn tokens. Enjoy perks. Build wealth faster with our rewards program.',
            accentColor: AppColors.emerald,
          ),
        ],
      ),
    );
  }

  Widget _buildSlide({
    required int index,
    required String image,
    required String headline,
    required String description,
    required Color accentColor,
  }) {
    return Column(
      children: [
        // Image section - fixed height, not expanding
        Container(
          height: 280,
          color: accentColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              DelayedDisplay(
                delay: const Duration(milliseconds: 0),
                slidingBeginOffset: const Offset(0.0, -0.2),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: accentColor.withAlpha(200),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.white.withAlpha(127),
                      ),
                    );
                  },
                ),
              ),
              // Subtle gradient overlay
              DelayedDisplay(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withAlpha(51), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content section - scrollable, takes remaining space
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent bar
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 150),
                    slidingBeginOffset: const Offset(-0.3, 0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Headline
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 250),
                    slidingBeginOffset: const Offset(0.0, 0.15),
                    child: Text(
                      headline,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 350),
                    slidingBeginOffset: const Offset(0.0, 0.15),
                    child: Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Controls section - fixed at bottom
        DelayedDisplay(
          delay: const Duration(milliseconds: 500),
          slidingBeginOffset: const Offset(0.0, 0.2),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: _currentPage == i ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.primaryOrange
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentPage > 0
                      ? Row(
                          key: const ValueKey('two-buttons'),
                          children: [
                            Expanded(
                              child: DelayedDisplay(
                                delay: const Duration(milliseconds: 100),
                                slidingBeginOffset: const Offset(-0.1, 0),
                                child: OutlinedButton(
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.deepNavy,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Back',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.deepNavy,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DelayedDisplay(
                                delay: const Duration(milliseconds: 150),
                                slidingBeginOffset: const Offset(0.1, 0),
                                child: _buildPrimaryButton(
                                  label: _currentPage == 2
                                      ? 'Get Started'
                                      : 'Next',
                                  onPressed: () {
                                    if (_currentPage < 2) {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      // Mark onboarding as complete before showing auth modal
                                      OnboardingService.completeOnboarding();
                                      showAuthOptionsModal(context);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          key: const ValueKey('one-button'),
                          width: double.infinity,
                          child: DelayedDisplay(
                            delay: const Duration(milliseconds: 200),
                            slidingBeginOffset: const Offset(0.0, 0.1),
                            child: _buildPrimaryButton(
                              label: 'Next',
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange,
            AppColors.primaryOrange.withAlpha(230),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withAlpha(76),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
