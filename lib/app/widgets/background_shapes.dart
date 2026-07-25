import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Soft, slowly-drifting color blobs used as ambient background texture.
/// Cheap to render (radial gradients, not real blur filters) so it stays
/// smooth on lower-end devices.
class BackgroundShapes extends StatefulWidget {
  final List<Color>? colors;

  const BackgroundShapes({super.key, this.colors});

  @override
  State<BackgroundShapes> createState() => _BackgroundShapesState();
}

class _BackgroundShapesState extends State<BackgroundShapes>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default now matches the actual brand mark (deep green + its
    // bright lime accent) instead of the placeholder gold used before
    // the real logo/theme were available.
    final palette = widget.colors ?? [AppColors.primary, AppColors.accent];
    final c1 = palette[0];
    final c2 = palette.length > 1 ? palette[1] : palette[0];

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _drift,
        builder: (context, _) {
          final t = _drift.value;
          return Stack(
            children: [
              Positioned(
                top: -90 + (t * 14),
                right: -70 - (t * 10),
                child: _blob(220, c1.withOpacity(.16)),
              ),
              Positioned(
                bottom: -60 - (t * 12),
                left: -80 + (t * 10),
                child: _blob(260, c2.withOpacity(.14)),
              ),
              Positioned(
                top: 180 - (t * 8),
                left: -50,
                child: _blob(140, c1.withOpacity(.10)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}
