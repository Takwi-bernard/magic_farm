import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/onboarding_data.dart';
import '../controllers/onboarding_controller.dart';
import '../../../../app/widgets/background_shapes.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_next_button.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundShapes(),

            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 550 : double.infinity,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Obx(
                            () => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: controller.isLastPage
                                  ? const SizedBox.shrink()
                                  : TextButton(
                                      key: const ValueKey("skip"),
                                      onPressed: controller.skip,
                                      child: Text(
                                        "skip".tr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: PageView.builder(
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
                    ),

                    const SizedBox(height: 20),
                    const OnboardingIndicator(),
                    const SizedBox(height: 40),
                    const OnboardingNextButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
