import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';
import '../../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  AuthController({
    required this.repository,
  });

  final AuthRepository repository;

  //==========================================================
  // CONTROLLERS
  //==========================================================

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPhoneController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final forgotEmailController = TextEditingController();

  //==========================================================
  // FORM KEYS
  //==========================================================

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();

  //==========================================================
  // OBSERVABLES
  //==========================================================

  final isLogin = true.obs;

  final isLoading = false.obs;

  final hideLoginPassword = true.obs;

  final hideRegisterPassword = true.obs;

  final hideConfirmPassword = true.obs;

  final selectedRole = "buyer".obs;

  final selectedLanguage = "en".obs;

  //==========================================================
  // GETTERS
  //==========================================================

  bool get loginMode => isLogin.value;

  //==========================================================
  // SWITCH AUTH MODE
  //==========================================================

  void switchMode() {
    isLogin.toggle();
  }

  //==========================================================
  // PASSWORD VISIBILITY
  //==========================================================

  void toggleLoginPassword() {
    hideLoginPassword.toggle();
  }

  void toggleRegisterPassword() {
    hideRegisterPassword.toggle();
  }

  void toggleConfirmPassword() {
    hideConfirmPassword.toggle();
  }

  //==========================================================
  // ROLE
  //==========================================================

  void changeRole(String role) {
    selectedRole.value = role;
  }

  //==========================================================
  // LANGUAGE
  //==========================================================

  void changeLanguage(String language) {
    selectedLanguage.value = language;
  }

  //==========================================================
  // LOGIN
  //==========================================================

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isLoading.value = true;

      await repository.signIn(
        email: emailController.text,
        password: passwordController.text,
      );

      // NOTE: no separate "loggedIn" flag is written here anymore.
      // Splash now checks Supabase's actual persisted session instead
      // of a hand-maintained flag that could silently go stale (e.g.
      // if a token is later revoked, or the flag is just never set —
      // which was the actual bug before this fix).
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        "login_failed".tr,
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //==========================================================
  // REGISTER
  //==========================================================

  Future<void> register() async {
    if (!(registerFormKey.currentState?.validate() ?? false)) {
      return;
    }

    if (registerPasswordController.text !=
        confirmPasswordController.text) {
      Get.snackbar(
        "password".tr,
        "err_passwords_mismatch".tr,
      );
      return;
    }

    try {
      isLoading.value = true;

      await repository.register(
        fullName: registerNameController.text,
        email: registerEmailController.text,
        phone: registerPhoneController.text,
        password: registerPasswordController.text,
        role: selectedRole.value,
        language: selectedLanguage.value,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        "registration_failed".tr,
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //==========================================================
  // GOOGLE LOGIN
  //==========================================================

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // Native sign-in (unlike the old browser-based OAuth flow)
      // returns as soon as login actually completes — no need to wait
      // for a deep link — so navigation happens directly here.
      await repository.signInWithGoogle();

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        "google_signin_failed".tr,
        e.toString().replaceFirst("Exception: ", ""),
      );
    } finally {
      isLoading.value = false;
    }
  }

  User? get currentUser => repository.currentUser;

  //==========================================================
  // PROFILE
  //==========================================================

  Future<Map<String, dynamic>> getProfile() async {
    return await repository.getProfile();
  }

  Future<void> updateProfile(
      Map<String, dynamic> data,
      ) async {
    try {
      isLoading.value = true;

      await repository.updateProfile(
        data: data,
      );

      Get.snackbar(
        "success".tr,
        "profile_updated".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "profile".tr,
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //==========================================================
  // CHANGE PASSWORD
  //==========================================================

  Future<void> changePassword(
      String newPassword,
      ) async {
    try {
      isLoading.value = true;

      await repository.changePassword(
        newPassword,
      );

      Get.snackbar(
        "success".tr,
        "password_updated".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "password".tr,
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //==========================================================
  // FORGOT PASSWORD
  //==========================================================

  // forgot_password.dart calls this, but it never existed here before —
  // the repository had sendPasswordResetEmail(), but nothing in the
  // controller wrapped it for the form to actually call.
  Future<void> sendResetPasswordEmail() async {
    if (!(forgotPasswordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isLoading.value = true;

      await repository.sendPasswordResetEmail(
        forgotEmailController.text,
      );

      Get.snackbar(
        "success".tr,
        "reset_link_sent".tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        "reset_password".tr,
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //==========================================================
  // REFRESH USER
  //==========================================================

  Future<void> refreshUser() async {
    try {
      await repository.refreshSession();
    } catch (_) {}
  }

  //==========================================================
  // LOGOUT
  //==========================================================

  Future<void> logout() async {
    try {
      await repository.signOut();
    } catch (_) {
      // Even if the network sign-out call fails, still clear local
      // state and route to login — better than leaving someone stuck
      // in a logged-in-looking screen with a dead session.
    } finally {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    registerNameController.dispose();
    registerEmailController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();

    forgotEmailController.dispose();

    super.onClose();
  }
}