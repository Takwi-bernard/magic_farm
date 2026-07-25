import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class RegisterForm extends GetView<AuthController> {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Full Name
          TextFormField(
            controller: controller.registerNameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: "full_name".tr,
              hintText: "full_name_hint".tr,
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary,),
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
                return "err_fullname_required".tr;
              }
              if (value.trim().length < 3) {
                return "err_fullname_short".tr;
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          /// Email
          TextFormField(
            controller: controller.registerEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: "email".tr,
              hintText: "email_hint".tr,
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary,),
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
                return "err_email_required".tr;
              }
              if (!GetUtils.isEmail(value.trim())) {
                return "err_email_invalid".tr;
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          /// Phone
          TextFormField(
            controller: controller.registerPhoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: "phone_number".tr,
              hintText: "phone_number_hint".tr,
              prefixIcon: const Icon(Icons.phone_outlined,color: AppColors.primary,),
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
                return "err_phone_required".tr;
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          /// Role
          Obx(
                () => DropdownButtonFormField<String>(
              initialValue: controller.selectedRole.value,
              decoration: InputDecoration(
                labelText: "account_type".tr,
                prefixIcon: const Icon(Icons.groups_outlined,color: AppColors.primary,),
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
              items: [
                DropdownMenuItem(
                  value: "buyer",
                  child: Text("buyer".tr),
                ),
                DropdownMenuItem(
                  value: "farmer",
                  child: Text("farmer".tr),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.changeRole(value);
                }
              },
            ),
          ),

          const SizedBox(height: 18),

          /// Password
          Obx(
                () => TextFormField(
              controller: controller.registerPasswordController,
              obscureText: controller.hideRegisterPassword.value,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "password".tr,
                prefixIcon: const Icon(Icons.lock_outline ,color: AppColors.primary,),
                suffixIcon: IconButton(
                  onPressed: controller.toggleRegisterPassword,
                  icon: Icon(
                    controller.hideRegisterPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,color: AppColors.primary,
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
                if (value == null || value.isEmpty) {
                  return "err_password_required".tr;
                }
                if (value.length < 6) {
                  return "err_password_min".tr;
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 18),

          /// Confirm Password
          Obx(
                () => TextFormField(
              controller: controller.confirmPasswordController,
              obscureText: controller.hideConfirmPassword.value,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: "confirm_password".tr,
                prefixIcon: const Icon(Icons.lock_outline,color: AppColors.primary,),
                suffixIcon: IconButton(
                  onPressed: controller.toggleConfirmPassword,
                  icon: Icon(
                    controller.hideConfirmPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,color: AppColors.primary,
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
                if (value == null || value.isEmpty) {
                  return "err_confirm_password_required".tr;
                }
                if (value != controller.registerPasswordController.text) {
                  return "err_passwords_mismatch".tr;
                }
                return null;
              },
              onFieldSubmitted: (_) {
                controller.register();
              },
            ),
          ),

          const SizedBox(height: 28),

          /// Register Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: Obx(
                  () => ElevatedButton(
                onPressed:
                controller.isLoading.value ? null : controller.register,
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
                  "signup".tr.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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