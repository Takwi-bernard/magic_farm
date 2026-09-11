import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  late final Animation<double> _glowScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _nameOpacity;
  late final Animation<Offset> _nameOffset;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _dotsOpacity;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _glowScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _nameOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );
    _nameOffset = Tween<Offset>(
      begin: const Offset(0, .25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
      ),
    );

    _dotsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
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
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _entrance,
        builder: (context, _) {
          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 22),
                    _buildName(),
                  ],
                ),
              ),

              Positioned(
                left: 24,
                right: 24,
                bottom: 64,
                child: FadeTransition(
                  opacity: _taglineOpacity,
                  child: Text(
                    'splash_tagline'.tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(.85),
                      height: 1.4,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: FadeTransition(
                  opacity: _dotsOpacity,
                  child: const _PulsingDots(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

 Widget _buildLogo() {
  return SizedBox(
    width: 240,
    height: 240,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Soft shadow for depth
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        // Solid plate — gives the green artwork the contrast it needs
        FadeTransition(
          opacity: _logoOpacity,
          child: ScaleTransition(
            scale: _logoScale,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFFDF8), // warm off-white, not stark white
              ),
              padding: const EdgeInsets.all(28),
              child: Hero(
                tag: 'app_logo',
                child: Image(
                  image: const AssetImage('assets/images/app_logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildName() {
    return FadeTransition(
      opacity: _nameOpacity,
      child: SlideTransition(
        position: _nameOffset,
        child: Text(
          'app_name'.tr,
          style: AppTextStyles.display.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: .3,
          ),
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final t = (_controller.value - (i * 0.2)) % 1.0;
            final opacity =
                (0.3 + 0.7 * (1 - (t - 0.5).abs() * 2)).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}