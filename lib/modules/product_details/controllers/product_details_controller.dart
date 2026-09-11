import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../repositories/product_details_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../../app/routes/app_routes.dart';

class ProductDetailsController extends GetxController {
  ProductDetailsController(this._repository, this._homeController);

  final ProductDetailsRepository _repository;

  // Reused for the actual favorite toggle (repository call already
  // exists there, correctly) and to keep Home/Favorites in sync the
  // moment this page changes something.
  final HomeController _homeController;

  final RxMap<String, dynamic> product = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> similarProducts =
      <Map<String, dynamic>>[].obs;

  final RxInt currentImage = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxBool isFavourite = false.obs;
  final RxInt quantity = 1.obs;
  final RxBool isReserving = false.obs;

  String? productId;

  User? get currentUser => Supabase.instance.client.auth.currentUser;

  @override
  void onInit() {
    super.onInit();

    // Get.arguments is the whole product map (that's what ProductCard
    // passes) — guarding against it being null or missing "id"
    // instead of assuming it's always well-formed, since a stray deep
    // link or bad navigation call would otherwise crash the page.
    final args = Get.arguments;
    if (args is Map && args["id"] != null) {
      productId = args["id"].toString();
      loadProduct();
    } else {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  Future<void> loadProduct() async {
    if (productId == null) return;

    try {
      isLoading.value = true;
      hasError.value = false;

      final result = await _repository.getProduct(productId!);
      product.value = result;

      // Computed the same way as HomeController.isFavourite() — was
      // previously just left at its initial `false`, meaning the
      // heart never reflected whether this product was actually
      // already favourited.
      _syncFavouriteState();

      await _repository.increaseViews(productId!);
      await loadSimilarProducts();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _syncFavouriteState() {
    final favs = product['favorites'] as List?;
    if (favs == null || favs.isEmpty || currentUser == null) {
      isFavourite.value = false;
      return;
    }
    isFavourite.value =
        favs.any((f) => f is Map && f['user_id'] == currentUser!.id);
  }

  Future<void> loadSimilarProducts() async {
    final categoryId = product["category_id"];
    if (categoryId == null || productId == null) return;

    similarProducts.value = await _repository.getSimilarProducts(
      categoryId: categoryId,
      productId: productId!,
    );
  }

  void changeImage(int index) {
    currentImage.value = index;
  }

  void increaseQuantity() => quantity.value++;

  void decreaseQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  Future<void> toggleFavourite() async {
    if (currentUser == null || productId == null) return;

    // Optimistic update, then confirmed by refetching real state —
    // this replaces the old blind `.toggle()` that could drift out of
    // sync with the database after the very first tap.
    final previous = isFavourite.value;
    isFavourite.value = !previous;

    try {
      await _homeController.toggleFavourite(productId!);
    } catch (_) {
      isFavourite.value = previous;
      return;
    }

    // Keep Home/Favorites tabs in sync immediately.
    await _homeController.loadFavourites();
  }

  Future<void> reserveProduct() async {
    if (currentUser == null || productId == null) return;

    final sellerId = product["seller_id"];
    if (sellerId == null) return;

    try {
      isReserving.value = true;

      await _repository.reserveProduct(
        buyerId: currentUser!.id,
        sellerId: sellerId,
        productId: productId!,
        quantity: quantity.value,
      );

      Get.snackbar(
        'reservation'.tr,
        'reservation_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'reservation'.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isReserving.value = false;
    }
  }

  Future<void> callSeller() async {
    final phone = product["profiles"]?["phone"];
    if (phone == null || phone.toString().isEmpty) {
      Get.snackbar(
        'error'.tr,
        'phone_unavailable'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Same fix as SellerProfileController.callSeller() — skipping
    // canLaunchUrl(), which needs an Android manifest <queries>
    // declaration to answer accurately and silently returns false
    // without it, even when the call would actually work.
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

  // Messages module is still a placeholder stub with no real chat
  // screen or route wired up yet — this is honest about that instead
  // of navigating to a route that doesn't exist.
  void chatSeller() {
    Get.snackbar(
      'chat'.tr,
      'coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void viewSellerProfile() {
    final sellerId = product["seller_id"];
    if (sellerId == null) return;

    Get.toNamed(
      AppRoutes.sellerProfile,
      arguments: {"sellerId": sellerId},
    );
  }

  Future<void> openMap() async {
    final cityName = product["cities"]?["name"];
    if (cityName == null) {
      Get.snackbar(
        'error'.tr,
        'location_unavailable'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$cityName",
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        'error'.tr,
        'map_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> shareProduct() async {
    // Was "£${product["price"]}" before — same currency bug we fixed
    // in ProductCard, reintroduced here.
    final price = product["price"];
    await Share.share(
      "${product["title"] ?? ''}\n"
      "${'price'.tr}: $price FCFA\n"
      "${product["description"] ?? ''}",
    );
  }

  // translateDescription() and generateAISummary() were previously
  // just a 1-second delay doing nothing — fake functionality is worse
  // than none. Being honest about "not built yet" instead.
  void translateDescription() {
    Get.snackbar(
      'translate'.tr,
      'coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void generateAISummary() {
    Get.snackbar(
      'ai_summary'.tr,
      'coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}