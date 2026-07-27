import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/product_card.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      bottomNavigationBar:
          const HomeBottomNavigation(),
      body: RefreshIndicator(
        onRefresh: controller.refreshProducts,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: [
            /// SEARCH BAR
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  15,
                  15,
                  15,
                  10,
                ),
                child: TextField(
                  controller:
                      controller.searchController,
                  decoration: InputDecoration(
                    hintText:
                        "Search products...",
                    prefixIcon:
                        const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.tune,
                      ),
                      onPressed: () {
                        /// Filter BottomSheet
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),

            /// CATEGORIES
            SliverToBoxAdapter(
              child: SizedBox(
                height: 55,
                child: Obx(
                  () => ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    scrollDirection:
                        Axis.horizontal,
                    itemCount:
                        controller.categories.length,
                    itemBuilder: (_, index) {
                      final category =
                          controller.categories[index];

                      final selected =
                          controller
                                  .selectedCategory
                                  .value ==
                              category["id"];

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          right: 10,
                        ),
                        child: ChoiceChip(
                          selected: selected,
                          label: Text(
                            category["name"],
                          ),
                          onSelected: (_) {
                            controller
                                .selectCategory(
                              category["id"],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /// FEATURED
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  15,
                  20,
                  15,
                  10,
                ),
                child: Text(
                  "Featured Products",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 265,
                child: Obx(
                  () => ListView.builder(
                    scrollDirection:
                        Axis.horizontal,
                    itemCount: controller
                        .featuredProducts
                        .length,
                    itemBuilder: (_, index) {
                      return SizedBox(
                        width: 280,
                        child: ProductCard(
                          product: controller
                                  .featuredProducts[
                              index],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /// ALL PRODUCTS
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  15,
                  20,
                  15,
                  10,
                ),
                child: Text(
                  "Latest Products",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),
              ),
            ),

            Obx(
              () => SliverPadding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                sliver: SliverGrid(
                  delegate:
                      SliverChildBuilderDelegate(
                    (_, index) {
                      return ProductCard(
                        product: controller
                            .products[index],
                      );
                    },
                    childCount:
                        controller.products.length,
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
                child: controller
                        .isLoadingMore.value
                    ? const Padding(
                        padding:
                            EdgeInsets.all(20),
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox(
                        height: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}