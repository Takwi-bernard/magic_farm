import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The shared image frame used across splash and onboarding.
///
/// Three frame styles:
/// - Blob frame (default) — organic shape, BoxFit.cover, for candid
///   onboarding photos.
/// - Circle frame (`useCircleFrame: true`) — clean, symmetric circle,
///   for the brand mark on splash. A logo isn't a photo; it shouldn't
///   get the same asymmetric crop treatment as one.
/// - Device frame (`useDeviceFrame: true`) — portrait phone-shaped
///   rounded rect, for screenshot-style images.
class FloatingLogo extends StatefulWidget {
  final String image;
  final double size;
  final BoxFit fit;
  final bool useDeviceFrame;
  final bool useCircleFrame;

  /// Fill shown behind the image before it's drawn. If the source
  /// asset has its own opaque background (e.g. a JPEG logo with a
  /// black matte) and BoxFit.cover is used, this rarely shows through —
  /// but with BoxFit.contain it fills any gap instead of leaving a
  /// mismatched halo.
  final Color frameBackground;

  const FloatingLogo({
    super.key,
    required this.image,
    this.size = 240,
    this.fit = BoxFit.cover,
    this.useDeviceFrame = false,
    this.useCircleFrame = false,
    this.frameBackground = Colors.white,
  });

  @override
  State<FloatingLogo> createState() => _FloatingLogoState();
}

class _FloatingLogoState extends State<FloatingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Widget _errorPlaceholder({double? iconSize}) => Container(
    color: AppColors.primary.withOpacity(.08),
    alignment: Alignment.center,
    child: Icon(
      Icons.image_outlined,
      color: AppColors.primary.withOpacity(.4),
      size: iconSize ?? widget.size * .18,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final dy = (_float.value - .5) * 10;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.useDeviceFrame
          ? _buildDeviceFrame()
          : widget.useCircleFrame
          ? _buildCircleFrame()
          : _buildBlobFrame(),
    );
  }

  Widget _buildCircleFrame() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size * .95,
            height: widget.size * .95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.18),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          ClipOval(
            child: Container(
              width: widget.size * .9,
              height: widget.size * .9,
              color: widget.frameBackground,
              child: Image.asset(
                widget.image,
                fit: widget.fit,
                errorBuilder: (_, __, ___) => _errorPlaceholder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlobFrame() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size * .92,
            height: widget.size * .92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.22),
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),
          ClipPath(
            clipper: const _BlobClipper(),
            child: Container(
              width: widget.size * .88,
              height: widget.size * .88,
              color: widget.frameBackground,
              child: Image.asset(
                widget.image,
                fit: widget.fit,
                errorBuilder: (_, __, ___) => _errorPlaceholder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceFrame() {
    final double frameHeight = widget.size;
    final double frameWidth = frameHeight * 0.5;

    return Container(
      width: frameWidth,
      height: frameHeight,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          widget.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _errorPlaceholder(iconSize: frameWidth * .35),
        ),
      ),
    );
  }
}

class _BlobClipper extends CustomClipper<Path> {
  const _BlobClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 0.85, 0, w, h * 0.2, w, h * 0.5)
      ..cubicTo(w, h * 0.82, w * 0.8, h, w * 0.5, h)
      ..cubicTo(w * 0.18, h, 0, h * 0.8, 0, h * 0.5)
      ..cubicTo(0, h * 0.2, w * 0.15, 0, w * 0.5, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}