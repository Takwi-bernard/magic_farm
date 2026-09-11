abstract class AppRoutes {
  AppRoutes._();

  static const splash = "/";
  static const onboarding = "/onboarding";
  static const login = "/login";
  static const signup = "/signup";
  static const forgotPassword = "/forgot-password";
  static const home = "/home";
  static const ai = "/ai";
  static const productDetails = "/product-details";

  // Was only ever a raw string ("/seller-profile") passed to
  // Get.toNamed() with no constant and no registered GetPage — same
  // class of gap we've hit repeatedly with other routes.
  static const sellerProfile = "/seller-profile";

  static const createPost = "/create-post";
  static const favorites = "/favorites";
  static const profile = "/profile";
  static const settings = "/settings";
  static const notifications = "/notifications";
  static const chat = "/chat";
  static const admin = "/admin";
}