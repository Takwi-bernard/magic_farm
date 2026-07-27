import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/product_card.dart';

class ExplorePage extends GetView<HomeController> {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Products"),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15),
                itemCount: controller.categories.length,
                itemBuilder: (_, index) {
                  final category =
                      controller.categories[index];

                  return Padding(
                    padding:
                        const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(category["name"]),
                      selected:
                          controller.selectedCategory.value ==
                              category["id"],
                      onSelected: (_) {
                        controller.selectCategory(
                          category["id"],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Obx(
              () => GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.products.length,
                itemBuilder: (_, index) {
                  return ProductCard(
                    product: controller.products[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}