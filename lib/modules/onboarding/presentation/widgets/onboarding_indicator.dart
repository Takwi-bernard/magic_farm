import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_data.dart';

class OnboardingIndicator extends GetView<OnboardingController> {
  const OnboardingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          onboardingItems.length, // was hardcoded to 4 — now matches your real slide count
          (index) {
            final selected = controller.currentPage.value == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: selected ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.white.withOpacity(.4),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      );
    });
  }
}