import 'package:get/get.dart';

import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/presentation/pages/splash_page.dart';

import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/presentation/pages/onboarding_page.dart';

import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/pages/auth_page.dart';
import '../../modules/auth/widgets/forgot_password.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),

    // login and signup share one page (AuthPage toggles between the
    // two forms via AuthController.isLogin), so both route names point
    // at the same page + binding.
    GetPage(
      name: AppRoutes.login,
      page: () => const AuthPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const AuthPage(),
      binding: AuthBinding(),
    ),

    // Uses AuthBinding too, since it needs AuthController for its
    // form (forgotEmailController, sendResetPasswordEmail(), etc.).
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),

    // home, product-details, etc. get added here the same way, one
    // GetPage per AppRoutes constant, as each module is built.
  ];
}