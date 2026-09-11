import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/home_controller.dart';

class ProductCard extends GetView<HomeController> {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final images = (product["product_images"] ?? []) as List;
    final seller = product["profiles"] as Map<String, dynamic>?;
    final city = product["cities"] as Map<String, dynamic>?;
    final image = images.isNotEmpty ? images.first["image_url"] : "";

    return GestureDetector(
      onTap: () => Get.toNamed("/product-details", arguments: product),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          // Whole card sits on a soft green tint, not white — matches
          // the reference, where the image inset and the text section
          // both live on the same tinted card rather than a white panel.
          color: AppColors.primary.withOpacity(.05),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image sits on its own margin from the card edges. Filled
            // edge-to-edge with cover (not floating cutout-style) since
            // real farm photos have backgrounds, unlike the reference's
            // pre-isolated product images.
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: AspectRatio(
                aspectRatio: 1.05,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        // Slightly deeper than the card's own tint so
                        // the image panel still reads as a distinct
                        // inset — the reference's two-tone green framing.
                        color: AppColors.primary.withOpacity(.10),
                        child: image.isEmpty
                            ? Icon(
                                Icons.image_outlined,
                                size: 36,
                                color: AppColors.textSecondary.withOpacity(.4),
                              )
                            : Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_outlined,
                                  size: 36,
                                  color:
                                      AppColors.textSecondary.withOpacity(.4),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    // Real "Featured" flag, not a fabricated rating —
                    // repurposed badge slot that only ever shows real data.
                    if (product["is_featured"] == true)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentWarm,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "featured".tr.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .4,
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavoriteButton(
                        isFavourite: controller.isFavourite(product),
                        onTap: () =>
                            controller.toggleFavourite(product["id"]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info section — same tinted card background carries through
            // here (no separate color set), matching the reference's
            // single continuous green card rather than a white panel.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price (+ real unit, if the product actually
                  // carries one) on the left, quick-add on the right —
                  // matches the reference's price-row structure.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _formatPrice(product["price"]),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (product["unit"] != null)
                                TextSpan(
                                  text: "/${product["unit"]}",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // _QuickAddButton(
                      //   onTap: () => controller.addToCart(product),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product["title"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.storefront_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          seller?["full_name"] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                      if (seller?["is_verified"] == true)
                        Icon(Icons.verified,
                            color: AppColors.primaryDark, size: 12),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _locationAndTime(city, product["created_at"]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return "";
    final value = price is num ? price : num.tryParse(price.toString());
    if (value == null) return "";
    final str = value.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return "${buffer.toString()} FCFA";
  }

  // Replaces the reference's "X kg left" (data we don't have) with
  // real posted-time derived from created_at — combined with city on
  // one line to keep the compact card from feeling crowded.
  String _locationAndTime(Map<String, dynamic>? city, dynamic createdAt) {
    final parts = <String>[];

    if (city?["name"] != null) {
      parts.add(city!["name"]);
    }

    final date =
        createdAt != null ? DateTime.tryParse(createdAt.toString()) : null;

    if (date != null) {
      final diff = DateTime.now().difference(date);
      if (diff.inHours < 24) {
        parts.add('posted_today'.tr);
      } else if (diff.inHours < 48) {
        parts.add('posted_yesterday'.tr);
      } else {
        parts.add(
          'posted_days_ago'.tr.replaceAll('{days}', diff.inDays.toString()),
        );
      }
    }

    return parts.join(' • ');
  }
}

// Ghost-outline circle instead of a solid white disc — makes the
// overlay icon feel like it's floating on the photo, matching the
// reference's wishlist button treatment.
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.isFavourite, required this.onTap});

  final bool isFavourite;
  final VoidCallback onTap;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  double _scale = 1;

  void _bounce() {
    setState(() => _scale = 1.3);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _scale = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _bounce();
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(.7), width: 1),
        ),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          child: Icon(
            widget.isFavourite ? Icons.favorite : Icons.favorite_border,
            color: widget.isFavourite ? Colors.red : Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}

// Small circular add-to-cart action, matching the reference's price-row button.
class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 16),
      ),
    );
  }
}