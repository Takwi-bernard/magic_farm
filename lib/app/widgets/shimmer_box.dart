import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A soft animated gradient sweep used as a loading placeholder,
/// instead of a plain spinner — this is the pattern most current apps
/// (Instagram, LinkedIn, etc.) use for content that's about to load,
/// since it hints at the shape of what's coming rather than just
/// signaling "wait."
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.borderRadius = 12,
  });

  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + _controller.value * 3, 0),
                end: Alignment(0 + _controller.value * 3, 0),
                colors: [
                  AppColors.border.withOpacity(.4),
                  AppColors.border.withOpacity(.9),
                  AppColors.border.withOpacity(.4),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}
