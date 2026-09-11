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
import '../../modules/product_details/pages/product_details_page.dart';
import '../../modules/product_details/bindings/product_details_binding.dart';
import '../../modules/seller_profile/pages/seller_profile_page.dart';
import '../../modules/seller_profile/bindings/seller_profile_binding.dart'; 
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

  ),
    // Was never registered despite ProductCard calling
    // Get.toNamed(AppRoutes.productDetails) since the very first
    // version of that widget — every product tap has been silently
    // going nowhere this whole time.
    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsPage(),
      binding: ProductDetailsBinding(),
    ),
 

 GetPage(
      name: AppRoutes.sellerProfile,
      page: () => const SellerProfilePage(),
      binding: SellerProfileBinding(),
    ),
    // orders, chat, seller-profile, etc. get added here the same
    // way, one GetPage per AppRoutes constant, as each module is
    // built for real.
  

  ];
}
