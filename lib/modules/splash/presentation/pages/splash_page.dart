import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/floating_logo.dart';
import '../../../../app/widgets/background_shapes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  late final Animation<double> logoOpacity;
  late final Animation<double> logoScale;
  late final Animation<double> nameOpacity;
  late final Animation<Offset> nameOffset;
  late final Animation<double> sloganOpacity;
  late final Animation<Offset> sloganOffset;
  late final Animation<double> spinnerOpacity;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    logoScale = Tween<double>(begin: .7, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    nameOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
      ),
    );
    nameOffset = Tween<Offset>(
      begin: const Offset(0, .2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
      ),
    );

    sloganOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );
    sloganOffset = Tween<Offset>(
      begin: const Offset(0, .3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );

    spinnerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          const BackgroundShapes(
            colors: [Colors.white, AppColors.accent],
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: logoOpacity,
                    child: ScaleTransition(
                      scale: logoScale,
                      child: const Hero(
                        tag: "app_logo",
                        child: FloatingLogo(
                          image: "assets/images/app_logo.jpeg",
                          size: 160,
                          fit: BoxFit.cover,
                          useCircleFrame: true,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  FadeTransition(
                    opacity: nameOpacity,
                    child: SlideTransition(
                      position: nameOffset,
                      child: Text(
                        'app_name'.tr,
                        style: AppTextStyles.display.copyWith(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  FadeTransition(
                    opacity: sloganOpacity,
                    child: SlideTransition(
                      position: sloganOffset,
                      child: Text(
                        'splash_tagline'.tr,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(.85),
                          letterSpacing: .2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  FadeTransition(
                    opacity: spinnerOpacity,
                    child: const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}