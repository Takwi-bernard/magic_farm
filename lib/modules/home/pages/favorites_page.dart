import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/shimmer_box.dart';
import '../controllers/home_controller.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    controller.loadFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('favorites'.tr),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        shadowColor: Colors.black12,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.loadFavourites,
        child: Obx(() {
          if (controller.isLoadingFavourites.value &&
              controller.favouriteProducts.isEmpty) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .72,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const ShimmerBox(borderRadius: 20),
            );
          }

          if (controller.favouriteProducts.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 56, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'no_favourites_yet'.tr,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .72,
            ),
            itemCount: controller.favouriteProducts.length,
            itemBuilder: (_, index) {
              return ProductCard(product: controller.favouriteProducts[index]);
            },
          );
        }),
      ),
    );
  }
}