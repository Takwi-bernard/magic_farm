import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/home_controller.dart';

/// Matches the reference precisely this time: NOT one shared bar —
/// each tab is its own separate floating circle/pill with visible
/// gaps between them. Selected tab expands into a green pill with an
/// icon badge + label; every unselected tab is a plain gray circle,
/// icon only, no label.
class HomeBottomNavigation extends GetView<HomeController> {
  const HomeBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tabs = [
        (
        icon: Icons.home_outlined,
        label: 'home',
        index: 0,
        ),

        controller.isFarmer
            ? (
        icon: Icons.add_circle_outline,
        label: 'create_post',
        index: 2,
        )
            : (
        icon: Icons.shopping_bag_outlined,
        label: 'orders',
        index: 2,
        ),
        (
        icon: Icons.chat_bubble_outline,
        label: 'messages',
        index: 3,
        ),
        (
        icon: Icons.person_outline_rounded,
        label: 'profile',

        index: 4,
        ),
      ];

      final selectedIndex = controller.currentIndex.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: tabs.map((tab) {
            final selected = selectedIndex == tab.index;
            return _NavBubble(
              icon: tab.icon,
              label: tab.label,
              selected: selected,
              onTap: () => controller.changeTab(tab.index),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _NavBubble extends StatelessWidget {
  const _NavBubble({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        height: 52,
        padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 0),
        width: selected ? null : 52,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white60,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? AppColors.primary : Colors.black,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: selected
                  ? Padding(
                padding: const EdgeInsets.only(left: 8, right: 2),
                child: Text(
                  label.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              )
                  : const SizedBox(width: 0, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}