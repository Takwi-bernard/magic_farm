import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingNextButton
    extends GetView<OnboardingController> {
  const OnboardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final last = controller.isLastPage;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: last ? 180 : 60,
        height: 60,

        child: ElevatedButton(
          onPressed: controller.next,

          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),

          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),

            child: last
                ? Text(
                    "get_started".tr,
                    key: const ValueKey("text"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward,
                    key: ValueKey("icon"),
                    color: Colors.white,
                  ),
          ),
        ),
      );
    });
  }
}