import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/shimmer_box.dart';
import '../controllers/home_controller.dart';
import '../widgets/product_card.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final name = controller.currentUser?.userMetadata?['full_name']
        ?.toString()
        .split(' ')
        .first ??
        '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshProducts,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            /// GREEN HEADER + OVERLAPPING SEARCH CARD
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Solid green block, rounded bottom corners.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 60),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          _Avatar(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty
                                      ? '${_greeting()} 👋'
                                      : '${_greeting()}, $name 👋',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                _LocationLabel(),
                              ],
                            ),
                          ),
                          _HeaderIconButton(
                            icon: Icons.auto_awesome,
                            onTap: () => Get.toNamed(AppRoutes.ai),
                          ),
                          const SizedBox(width: 8),
                          _HeaderIconButton(
                            icon: Icons.notifications_none_rounded,
                            showBadge: true,
                            onTap: () {
                              Get.snackbar(
                                'notifications'.tr,
                                'coming_soon'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  
                  Positioned(

                    left: 16,
                    right: 16,
                    bottom: -16,
                    child: _SearchCard(),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            /// PROMO BANNER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Container(
                  //height: 130,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentWarm. withOpacity(.85),
                        AppColors.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'promo_headline'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'promo_tagline'.tr,
                              style: TextStyle(
                                color: Colors.white.withOpacity(.9),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'shop_now'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.eco_rounded,
                        size: 64,
                        color: Colors.white.withOpacity(.25),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// CATEGORIES
            SliverToBoxAdapter(
              child: _SectionHeader(title: "categories".tr),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: Obx(
                      () => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length + 1,
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        final selected =
                            controller.selectedCategory.value.isEmpty;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryPill(
                            label: 'all'.tr,
                            selected: selected,
                            onTap: () => controller.selectCategory(null),
                          ),
                        );
                      }

                      final category = controller.categories[index - 1];
                      final selected =
                          controller.selectedCategory.value == category["id"];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _CategoryPill(
                          label: category["name"] ?? '',
                          selected: selected,
                          onTap: () => controller.selectCategory(
                            selected ? null : category["id"],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /// FEATURED / FRESH PICKS
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: "fresh_picks".tr,
                subtitle: "fresh_picks_subtitle".tr,
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.featuredProducts.isEmpty) {
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 150,
                          child: ShimmerBox(borderRadius: 18),
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 220,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.featuredProducts.length,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 150,
                          child: ProductCard(
                            product: controller.featuredProducts[index],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

            /// LATEST PRODUCTS
            SliverToBoxAdapter(
              child: _SectionHeader(title: "latest_products".tr),
            ),

            Obx(
                  () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: controller.isLoading.value &&
                    controller.products.isEmpty
                    ? SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (_, __) => const ShimmerBox(borderRadius: 20),
                    childCount: 6,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: .72,
                  ),
                )
                    : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (_, index) => ProductCard(
                      product: controller.products[index],
                    ),
                    childCount: controller.products.length,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: .72,
                  ),
                ),
              ),
            ),

            /// PAGINATION
            Obx(
                  () => SliverToBoxAdapter(
                child: controller.isLoadingMore.value
                    ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
                    : const SizedBox(height: 20),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends GetView<HomeController> {
  const _SearchCard();

  String _formatSuggestionPrice(dynamic price) {
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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.all(Radius.circular(100)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: "search_home_hint".tr,
                    hintStyle: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    prefixIcon:
                    Icon(Icons.search, color: AppColors.textSecondary),
                    // Voice search — was missing before. Not wired to
                    // real speech-to-text yet, just the entry point;
                    // flag if you want that built out.
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic_none_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () {
                        Get.snackbar(
                          'voice_search'.tr,
                          'coming_soon'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                Obx(() {
                  if (!controller.showSuggestions.value) {
                    return const SizedBox.shrink();
                  }
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Column(
                      children: [
                        Divider(height: 1, color: AppColors.border),
                        ...controller.searchSuggestions.map(
                              (product) => ListTile(
                            dense: true,
                            leading: Icon(Icons.search,
                                size: 18, color: AppColors.textSecondary),
                            title: Text(
                              product['title'] ?? '',
                              style:
                              AppTextStyles.body.copyWith(fontSize: 14),
                            ),
                            trailing: Text(
                              _formatSuggestionPrice(product['price']),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            onTap: () => controller
                                .selectSuggestion(product['title'] ?? ''),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.tune, color: AppColors.primary),
            onPressed: () {
              /// Filter BottomSheet
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryDark),
          ),
          if (showBadge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends GetView<HomeController> {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    final avatarUrl = controller.currentUser?.userMetadata?['avatar_url'];

    return GestureDetector(
      onTap: () => controller.changeTab(4),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Icon(Icons.person, color: AppColors.primary)
            : null,
      ),
    );
  }
}

class _LocationLabel extends GetView<HomeController> {
  const _LocationLabel();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cityId = controller.selectedCity.value;
      String? cityName;
      for (final city in controller.cities) {
        if (city['id'] == cityId) {
          cityName = city['name'];
          break;
        }
      }

      return GestureDetector(
        onTap: () => _openLocationPicker(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                cityName ?? 'select_location'.tr,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: Colors.black45),
          ],
        ),
      );
    });
  }

  void _openLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Obx(
                () => ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child:
                  Text('select_location'.tr, style: AppTextStyles.title),
                ),
                ListTile(
                  leading: const Icon(Icons.public),
                  title: Text('all_locations'.tr),
                  selected: controller.selectedCity.value.isEmpty,
                  onTap: () {
                    controller.selectCity(null);
                    Get.back();
                  },
                ),
                ...controller.cities.map(
                      (city) => ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(city['name'] ?? ''),
                    subtitle:
                    city['region'] != null ? Text(city['region']) : null,
                    selected: controller.selectedCity.value == city['id'],
                    onTap: () {
                      controller.selectCity(city['id']);
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              "see_all".tr,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}