import 'package:get/get.dart';

import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/presentation/pages/splash_page.dart';

import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/presentation/pages/onboarding_page.dart';

import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/pages/auth_page.dart';
import '../../modules/auth/widgets/forgot_password.dart';

import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/pages/dashboard_page.dart';

import '../../modules/ai/ai_binding.dart';
import '../../modules/ai/ai_page.dart';

import 'app_routes.dart';
import '../../modules/create_post/pages/create_post_page.dart';
import '../../modules/create_post/bindings/create_post_binding.dart';

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


    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const DashboardPage(),
      binding: HomeBinding(),
    ),


    GetPage(
      name: AppRoutes.ai,
      page: () => const AIPage(),
      binding: AIBinding(),
    ),
  GetPage(
      name: AppRoutes.createPost,
      page: ()=> const CreatePostPage(),
      binding: CreatePostBinding(),

  )
  ];
}
