import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../app/routes/app_routes.dart';
import '../widgets/onboarding_data.dart';

class OnboardingController extends GetxController {
  final GetStorage _storage = GetStorage();

  final PageController pageController = PageController();

  final RxInt currentPage = 0.obs;

  static const String onboardingKey = "onboardingCompleted";

  bool get isLastPage =>
      currentPage.value == onboardingItems.length - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skip() {
    pageController.animateToPage(
      onboardingItems.length - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> next() async {
    if (!isLastPage) {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      return;
    }

    await finishOnboarding();
  }

  Future<void> finishOnboarding() async {
    await _storage.write(onboardingKey, true);

    Get.offAllNamed(AppRoutes.login);
  }

  bool get hasCompletedOnboarding =>
      _storage.read(onboardingKey) ?? false;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}