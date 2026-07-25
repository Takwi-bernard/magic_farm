import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class GoogleButton extends GetView<AuthController> {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Obx(
            () => OutlinedButton.icon(
          onPressed: controller.isLoading.value
              ? null
              : controller.loginWithGoogle,
          icon: controller.isLoading.value
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Image.asset(
            "assets/images/google.png",
            width: 60,
            height: 80,
          ),
          label: Text(
            (controller.isLogin.value
                ? 'continue_with_google'
                : 'signup_with_google')
                .tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            side: BorderSide(
              color: AppColors.primary,
              width: 1,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ),
    );
  }
}