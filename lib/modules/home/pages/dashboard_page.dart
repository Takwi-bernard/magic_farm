import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'explore_page.dart';
import 'home_page.dart';

// These pages will be created next
import '../../create_post/pages/create_post_page.dart';
import '../../orders/pages/orders_page.dart';
import '../../messages/pages/messages_page.dart';
import '../../profile/pages/profile_page.dart';

class DashboardPage extends GetView<HomeController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pages = [
        const HomePage(),
        const ExplorePage(),
        controller.isFarmer
            ? const CreatePostPage()
            : const OrdersPage(),
        const MessagesPage(),
        const ProfilePage(),
      ];

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: "Home",
            ),
            const NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: "Explore",
            ),
            controller.isFarmer
                ? const NavigationDestination(
                    icon: Icon(Icons.add_box_outlined),
                    selectedIcon: Icon(Icons.add_box),
                    label: "Create",
                  )
                : const NavigationDestination(
                    icon: Icon(Icons.shopping_bag_outlined),
                    selectedIcon: Icon(Icons.shopping_bag),
                    label: "Orders",
                  ),
            const NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat),
              label: "Messages",
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      );
    });
  }
}