import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import '../../../../app/theme/app_colors.dart';

class OnboardingIndicator extends GetView<OnboardingController> {

  const OnboardingIndicator({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      return Row(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: List.generate(

          4,

          (index) {

            final selected =
                controller.currentPage.value == index;

            return AnimatedContainer(

              duration:
                  const Duration(milliseconds:300),

              margin:
                  const EdgeInsets.symmetric(horizontal:4),

              width:
                  selected ? 34 : 10,

              height:10,

              decoration: BoxDecoration(

                color: selected
                    ? AppColors.primary
                    : Colors.grey.shade300,

                borderRadius:
                    BorderRadius.circular(20),

              ),

            );

          },

        ),

      );

    });

  }

}