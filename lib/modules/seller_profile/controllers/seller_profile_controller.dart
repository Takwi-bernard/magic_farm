import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../product_details/repositories/product_details_repository.dart';

class SellerProfileController extends GetxController {
  SellerProfileController(this._repository);

  final ProductDetailsRepository _repository;

  final RxMap<String, dynamic> seller = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  String? sellerId;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map && args["sellerId"] != null) {
      sellerId = args["sellerId"].toString();
      loadSeller();
    } else {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  Future<void> loadSeller() async {
    if (sellerId == null) return;

    try {
      isLoading.value = true;
      hasError.value = false;

      final results = await Future.wait([
        _repository.getSellerProfile(sellerId!),
        _repository.getSellerProducts(sellerId!),
      ]);

      seller.value = results[0] as Map<String, dynamic>;
      products.value = results[1] as List<Map<String, dynamic>>;
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> callSeller() async {
    final phone = seller["phone"];
    if (phone == null || phone.toString().isEmpty) {
      Get.snackbar(
        'error'.tr,
        'phone_unavailable'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Was checking canLaunchUrl() first before attempting the call —
    // that check needs an Android manifest <queries> declaration to
    // give an accurate answer (Android 11+ package visibility rules),
    // and silently returns false without it even when the call would
    // actually work. Attempting the launch directly and catching any
    // real failure is more robust than gating on that pre-check.
    try {
      await launchUrl(
        Uri.parse("tel:$phone"),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      Get.snackbar(
        'error'.tr,
        'call_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Same honesty principle as ProductDetailsController — Messages
  // isn't a real chat destination yet, so this says so instead of
  // navigating somewhere that doesn't exist.
  void chatSeller() {
    Get.snackbar(
      'chat'.tr,
      'coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}