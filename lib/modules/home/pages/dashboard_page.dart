import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'home_page.dart';
import 'favorites_page.dart';
import '../widgets/home_bottom_navigation.dart';

import '../../create_post/bindings/create_post_binding.dart';
import '../../create_post/controllers/create_post_controller.dart';
import '../../create_post/pages/create_post_page.dart';
import '../../orders/pages/order_page.dart';
import '../../messages/pages/message_page.dart';
import '../../profile/pages/profile_page.dart';

class DashboardPage extends GetView<HomeController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // CreatePostPage is built directly as a widget inside IndexedStack
    // below, not navigated to via Get.toNamed() — and GetX bindings
    // ONLY fire on named-route navigation. Without this, GetView<
    // CreatePostController> inside CreatePostPage would throw "not
    // found" the moment a farmer opened that tab, since nothing would
    // have ever registered the controller. Guarded so it only runs
    // once even though build() can be called many times.
    if (controller.isFarmer && !Get.isRegistered<CreatePostController>()) {
      CreatePostBinding().dependencies();
    }

    return Obx(() {
      final pages = [
        const HomePage(),
        const FavoritesPage(),
        controller.isFarmer ? const CreatePostPage() : const OrdersPage(),
        const MessagesPage(),
        const ProfilePage(),
      ];

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: const HomeBottomNavigation(),
      );
    });
  }
}