import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'onboarding_data.dart';
import '../../../../app/widgets/floating_logo.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'language_selector_card.dart';

class OnboardingCard extends StatelessWidget {
  final OnboardingData data;
  final bool enableHero;

  const OnboardingCard({
    super.key,
    required this.data,
    this.enableHero = false,
  });

  @override
  Widget build(BuildContext context) {
    // Onboarding illustrations should feel large and immersive —
    // splash's logo is a small badge, but these are the actual visual
    // story of each slide. Sizing off screen width instead of a fixed
    // number keeps that "large" feeling consistent across phone sizes.
    final screenWidth = MediaQuery.of(context).size.width;
    final illustrationSize = (screenWidth * 0.72).clamp(220.0, 340.0);

    final logo = FloatingLogo(
      image: data.image,
      size: illustrationSize,
      useDeviceFrame: data.useDeviceFrame,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          enableHero ? Hero(tag: "app_logo", child: logo) : logo,

          const SizedBox(height: 44),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              data.title.tr,
              key: ValueKey(data.title),
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.3,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 14),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              data.description.tr,
              key: ValueKey(data.description),
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),

          if (data.showLanguageSelector) ...[
            const SizedBox(height: 28),
            LanguageSelectorCard(),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}