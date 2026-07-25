import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class LoginForm extends GetView<AuthController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Email
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: "email".tr,
              hintText: "email_hint".tr,
              prefixIcon: const Icon(Icons.email_outlined ,color: AppColors.primary,),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "err_email_required".tr;
              }
              if (!GetUtils.isEmail(value.trim())) {
                return "err_email_invalid".tr;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          /// Password
          Obx(
                () => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.hideLoginPassword.value,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: "password".tr,
                hintText: "password_hint".tr,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary,),
                suffixIcon: IconButton(
                  onPressed: controller.toggleLoginPassword,
                  icon: Icon(
                    controller.hideLoginPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.primary,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "err_password_required".tr;
                }
                if (value.length < 6) {
                  return "err_password_min".tr;
                }
                return null;
              },
              onFieldSubmitted: (_) {
                controller.login();
              },
            ),
          ),

          const SizedBox(height: 10),

          /// Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Was a hardcoded '/forgot-password' string before —
                // using the AppRoutes constant instead, so a future
                // route rename can't silently desync this button.
                Get.toNamed(AppRoutes.forgotPassword);
              },
              child: Text("forgot_password".tr,style: TextStyle(fontSize: 16),),
            ),
          ),

          const SizedBox(height: 15),

          /// Login Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: Obx(
                  () => ElevatedButton(
                onPressed:
                controller.isLoading.value ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  "login".tr.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}