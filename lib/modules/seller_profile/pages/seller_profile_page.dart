import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/seller_profile_controller.dart';
import '../../home/widgets/product_card.dart';

class SellerProfilePage extends GetView<SellerProfileController> {
  const SellerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('seller_profile'.tr),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        shadowColor: Colors.black12,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'seller_load_failed'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadSeller,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            ),
          );
        }

        final seller = controller.seller;
        final memberSince = _memberSince(seller["created_at"]);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary.withOpacity(.1),
                    backgroundImage: seller["avatar_url"] != null
                        ? NetworkImage(seller["avatar_url"])
                        : null,
                    child: seller["avatar_url"] == null
                        ? Icon(Icons.person, size: 44, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        seller["full_name"] ?? "",
                        style: AppTextStyles.headline.copyWith(fontSize: 22),
                      ),
                      if (seller["is_verified"] == true)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(Icons.verified,
                              color: AppColors.primaryDark, size: 20),
                        ),
                    ],
                  ),
                  if (memberSince != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${'member_since'.tr} $memberSince',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
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
                  child: ElevatedButton.icon(
                    onPressed: controller.callSeller,
                    icon: const Icon(Icons.call),
                    label: Text('call'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Text('active_listings'.tr, style: AppTextStyles.title),
            const SizedBox(height: 12),

            controller.products.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'no_active_listings'.tr,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: .72,
                    ),
                    itemCount: controller.products.length,
                    itemBuilder: (_, index) {
                      return ProductCard(product: controller.products[index]);
                    },
                  ),
          ],
        );
      }),
    );
  }

  String? _memberSince(dynamic createdAt) {
    if (createdAt == null) return null;
    final date = DateTime.tryParse(createdAt.toString());
    if (date == null) return null;

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}