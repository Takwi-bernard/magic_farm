import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Intentionally not wired into OnboardingCard yet. This will replace
// FloatingLogo once each onboarding slide has a matching .json Lottie
// animation (currently the slides use static PNGs via `data.image`).
// Swap-in point: onboarding_card.dart, once assets/animations/*.json
// exist for each slide.
class FloatingIllustration extends StatefulWidget {

  final String asset;

  const FloatingIllustration({
    super.key,
    required this.asset,
  });

  @override
  State<FloatingIllustration> createState() =>
      _FloatingIllustrationState();
}

class _FloatingIllustrationState
    extends State<FloatingIllustration>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(

      animation: _controller,

      builder: (_, child) {

        return Transform.translate(

          offset: Offset(
            0,
            _controller.value * 12,
          ),

          child: child,

        );

      },

      child: SizedBox(
        height: 280,
        child: Lottie.asset(widget.asset),
      ),

    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}