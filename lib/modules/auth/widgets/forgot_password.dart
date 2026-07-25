import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordPage extends GetView<AuthController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          "forgot_password".tr,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: controller.forgotPasswordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor:
                            AppColors.primary.withOpacity(.1),
                            child: const Icon(
                              Icons.lock_reset,
                              color: AppColors.primary,
                              size: 45,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: Text(
                            "reset_password".tr,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: Text(
                            "reset_password_description".tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              height: 1.5,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        TextFormField(
                          controller: controller.forgotEmailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            // Was a stray duplicate "Email Address"
                            // string sitting here before, as a bare
                            // positional argument inside a
                            // named-argument-only constructor call —
                            // that alone was a compile error.
                            labelText: "email".tr,
                            hintText: "email_hint".tr,
                            prefixIcon: const Icon(Icons.email_outlined,color: AppColors.primary,),
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
                          onFieldSubmitted: (_) {
                            controller.sendResetPasswordEmail();
                          },
                        ),

                        const SizedBox(height: 35),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Obx(
                                () => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.sendResetPasswordEmail,
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
                                "send_reset_link".tr.toUpperCase(),
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} // <- this closing brace for the class was missing before; the file
//    just stopped after the Scaffold, which was also a compile error.