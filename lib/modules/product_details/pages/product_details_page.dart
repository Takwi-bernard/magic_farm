import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/product_details_controller.dart';
import 'full_screen_gallery_page.dart';
import '../../home/widgets/product_card.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  // Was `extends GetView<ProductDetailsController>` before, which
  // does an untagged Get.find() — that's what silently returned the
  // wrong (previous) product's controller. Resolving the specific
  // tagged instance here instead, matching how the binding registers
  // it.
  ProductDetailsController get controller {
    final args = Get.arguments;
    final productId =
        (args is Map && args["id"] != null) ? args["id"].toString() : null;
    return Get.find<ProductDetailsController>(tag: productId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (controller.hasError.value) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0.5),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'product_load_failed'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final product = controller.product;
      final images = (product["product_images"] ?? []) as List;
      final imageUrls =
          images.map((i) => i["image_url"].toString()).toList();
      final seller = product["profiles"] as Map<String, dynamic>?;
      final city = product["cities"] as Map<String, dynamic>?;
      final category = product["categories"] as Map<String, dynamic>?;
      final heroTag = "product_${product["id"]}";

      return Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: _BottomBar(controller: controller),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              backgroundColor: AppColors.surface,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: Get.back,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Obx(
                      () => IconButton(
                        onPressed: controller.toggleFavourite,
                        icon: Icon(
                          controller.isFavourite.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: imageUrls.isEmpty
                    ? Container(
                        color: AppColors.primary.withOpacity(.06),
                        child: Icon(Icons.image_outlined,
                            size: 60, color: AppColors.textSecondary),
                      )
                    : Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(
                              () => FullScreenGalleryPage(
                                images: imageUrls,
                                heroTag: heroTag,
                                initialIndex: controller.currentImage.value,
                              ),
                            ),
                            child: Hero(
                              tag: heroTag,
                              child: CarouselSlider.builder(
                                itemCount: imageUrls.length,
                                itemBuilder: (_, index, __) {
                                  return CachedNetworkImage(
                                    imageUrl: imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (_, __) => Container(
                                      color: AppColors.primary.withOpacity(.06),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppColors.primary.withOpacity(.06),
                                      child: Icon(Icons.image_outlined,
                                          color: AppColors.textSecondary),
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  viewportFraction: 1,
                                  height: 340,
                                  onPageChanged: (index, _) =>
                                      controller.changeImage(index),
                                ),
                              ),
                            ),
                          ),
                          if (imageUrls.length > 1)
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Obx(
                                () => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(imageUrls.length,
                                      (index) {
                                    final selected =
                                        controller.currentImage.value == index;
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.all(3),
                                      width: selected ? 22 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (product["is_featured"] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentWarm,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'featured_product'.tr.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),

                  Text(
                    product["title"] ?? "",
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(product["price"]),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),

                  GestureDetector(
                    onTap: controller.viewSellerProfile,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withOpacity(.1),
                        backgroundImage: seller?["avatar_url"] != null
                            ? NetworkImage(seller!["avatar_url"])
                            : null,
                        child: seller?["avatar_url"] == null
                            ? Icon(Icons.person, color: AppColors.primary)
                            : null,
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              seller?["full_name"] ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.title.copyWith(fontSize: 15),
                            ),
                          ),
                          if (seller?["is_verified"] == true)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified,
                                  size: 16, color: AppColors.primaryDark),
                            ),
                        ],
                      ),
                      subtitle: Text(seller?["phone"] ?? ""),
                      trailing: OutlinedButton(
                        onPressed: controller.viewSellerProfile,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Text('view_profile'.tr),
                      ),
                    ),
                  ),
                  Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  Text('description'.tr, style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  Text(
                    product["description"] ?? "",
                    style: AppTextStyles.body.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.translateDescription,
                          icon: const Icon(Icons.translate, size: 18),
                          label: Text('translate'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.generateAISummary,
                          icon: Icon(Icons.auto_awesome,
                              size: 18, color: AppColors.primary),
                          label: Text('ai_summary'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Text('product_information'.tr, style: AppTextStyles.title),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading:
                              Icon(Icons.category, color: AppColors.primary),
                          title: Text('category'.tr),
                          subtitle: Text(category?["name"] ?? '—'),
                        ),
                        Divider(height: 1, color: AppColors.border),
                        ListTile(
                          leading: Icon(Icons.location_on,
                              color: AppColors.primary),
                          title: Text('location'.tr),
                          subtitle: Text(city?["name"] ?? '—'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (city != null)
                    OutlinedButton.icon(
                      onPressed: controller.openMap,
                      icon: Icon(Icons.map, color: AppColors.primary),
                      label: Text('open_location'.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  const SizedBox(height: 32),

                  if (controller.similarProducts.isNotEmpty) ...[
                    Text('similar_products'.tr, style: AppTextStyles.title),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: Obx(
                        () => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.similarProducts.length,
                          itemBuilder: (_, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: 170,
                                child: ProductCard(
                                  product: controller.similarProducts[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      );
    });
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
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.chatSeller,
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text('chat'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isReserving.value ? null : controller.reserveProduct,
                  icon: controller.isReserving.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.shopping_bag_outlined),
                  label: Text('reserve_now'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}