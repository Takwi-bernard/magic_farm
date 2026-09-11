import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'onboarding_data.dart';
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
    final image = Image(
      image: AssetImage(data.image),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-bleed background image
        enableHero ? Hero(tag: "app_logo", child: image) : image,

        // Dark scrim so white text/controls stay readable over any photo
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.55),
                Colors.black.withOpacity(.05),
                Colors.black.withOpacity(.70),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),

        // Your content, overlaid — title/description come from your own data
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 75),
            child: Column(
              children: [
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
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    data.description.tr,
                    key: ValueKey(data.description),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(.88),
                      height: 1.5,
                    ),
                  ),
                ),
                if (data.showLanguageSelector) ...[
                  const SizedBox(height: 24),
                  LanguageSelectorCard(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}