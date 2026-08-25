import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/home_controller.dart';

/// Was a fixed, always-the-same-height toolbar before — that static,
/// pinned pattern is one of the strongest "older app" signals there
/// is. This is a SliverAppBar instead: a bigger greeting area when
/// the list is at rest, which shrinks/collapses as the user scrolls
/// down, settling into a compact bar. That scroll-linked collapse is
/// the actual interaction, not just a visual restyle.
class HomeAppBar extends GetView<HomeController> {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final name = controller.currentUser?.userMetadata?['full_name']
        ?.toString()
        .split(' ')
        .first ??
        '';

    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0.5,
      shadowColor: Colors.black12,
      expandedHeight: 118,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: _Avatar(),
      ),
      actions: [
        IconButton(
          tooltip: 'ai_assistant'.tr,
          onPressed: () => Get.toNamed(AppRoutes.ai),
          icon: Icon(Icons.auto_awesome, color: AppColors.primary),
        ),
        IconButton(
          tooltip: 'notifications'.tr,
          onPressed: () {
            Get.snackbar(
              'notifications'.tr,
              'coming_soon'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 64, bottom: 16, right: 96),
        // This is what's shown once the bar has collapsed — kept
        // short since there's little room once scrolled.
        title: _LocationLabel(compact: true),
        // Shown only while expanded (at rest) — fades out as the
        // user scrolls, which is the actual collapse animation.
        background: Padding(
          padding: const EdgeInsets.fromLTRB(64, 46, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name.isEmpty
                    ? 'greeting_hi'.tr
                    : '${'greeting_hi'.tr}, $name',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              _LocationLabel(compact: false),
            ],
          ),
        ),
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
        radius: 18,
        backgroundColor: AppColors.primary.withOpacity(.1),
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Icon(Icons.person, color: AppColors.primary, size: 20)
            : null,
      ),
    );
  }
}

class _LocationLabel extends GetView<HomeController> {
  const _LocationLabel({required this.compact});

  final bool compact;

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
            Icon(Icons.location_on, size: compact ? 15 : 17,
                color: AppColors.primary),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                cityName ?? 'select_location'.tr,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? AppTextStyles.title.copyWith(fontSize: 16)
                    : AppTextStyles.title.copyWith(fontSize: 17),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppColors.textSecondary),
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
                  child: Text('select_location'.tr, style: AppTextStyles.title),
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
                    subtitle: city['region'] != null ? Text(city['region']) : null,
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
