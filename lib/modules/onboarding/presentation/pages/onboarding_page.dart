import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/onboarding_data.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_next_button.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-bleed pages
          PageView.builder(
            controller: controller.pageController,
            itemCount: onboardingItems.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (_, index) {
              return OnboardingCard(
                data: onboardingItems[index],
                enableHero: index == 0,
              );
            },
          ),

          // Skip — floating top-right over the image
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: controller.isLastPage
                        ? const SizedBox.shrink()
                        : TextButton(
                            key: const ValueKey("skip"),
                            onPressed: controller.skip,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(.18),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "skip".tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),

          // Dots + Next/Get Started — floating bottom, over the image
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    OnboardingIndicator(),
                    SizedBox(height: 24),
                    OnboardingNextButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}