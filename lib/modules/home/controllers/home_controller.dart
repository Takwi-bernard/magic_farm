import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/home_repository.dart';

class HomeController extends GetxController {
  HomeController(this._repository);

  final HomeRepository _repository;

  final searchController = TextEditingController();
  final scrollController = ScrollController();

  final RxList<Map<String, dynamic>> products =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> featuredProducts =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> nearbyProducts =
      <Map<String, dynamic>>[].obs;

  // Favorites has its own nav tab (replacing Explore), reusing this
  // same controller rather than spinning up a separate module — it's
  // the same product data/toggling logic already living here.
  final RxList<Map<String, dynamic>> favouriteProducts =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingFavourites = false.obs;

  final RxList<Map<String, dynamic>> categories =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> cities = <Map<String, dynamic>>[].obs;

  // Search-as-you-type suggestions — separate from the main product
  // list/search entirely. Its own small piece of state so the
  // suggestions dropdown and the full results grid don't fight over
  // the same data.
  final RxList<Map<String, dynamic>> searchSuggestions =
      <Map<String, dynamic>>[].obs;
  final RxBool showSuggestions = false.obs;
  Timer? _suggestionsDebounce;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  final RxString selectedCategory = ''.obs;
  final RxString selectedCity = ''.obs;

  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 0.0.obs;

  final RxInt currentPage = 0.obs;
  final RxInt currentIndex = 0.obs;

  Timer? _debounce;

  User? get currentUser => Supabase.instance.client.auth.currentUser;

  String get role => currentUser?.userMetadata?['role'] ?? 'buyer';

  bool get isFarmer => role == 'farmer';

  bool get isBuyer => role == 'buyer';

  @override
  void onInit() {
    super.onInit();

    loadInitialData();

    searchController.addListener(_onSearchChanged);
    scrollController.addListener(_scrollListener);
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      // Future.wait fails fast on the first error and never runs
      // code after it — previously that meant isLoading stayed true
      // forever on any network failure. Wrapping the whole thing so
      // isLoading always resets, offline or not.
      await Future.wait([
        loadCategories(),
        loadCities(),
        loadFeaturedProducts(),
        loadProducts(refresh: true),
      ]);
    } catch (e) {
      _showLoadError();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 0;
      hasMore.value = true;
      products.clear();
    }

    if (!hasMore.value) return;

    try {
      final result = await _repository.getProducts(
        page: currentPage.value,
        search: searchController.text,
        categoryId:
        selectedCategory.value.isEmpty ? null : selectedCategory.value,
        cityId: selectedCity.value.isEmpty ? null : selectedCity.value,
        minPrice: minPrice.value == 0 ? null : minPrice.value,
        maxPrice: maxPrice.value == 0 ? null : maxPrice.value,
      );

      if (result.length < HomeRepository.pageSize) {
        hasMore.value = false;
      }

      products.addAll(result);
      currentPage.value++;
    } 
     catch (e, stackTrace) {
  debugPrint('========== LOAD PRODUCTS ERROR ==========');
  debugPrint('ERROR: $e');
  debugPrint('STACK TRACE: $stackTrace');
  debugPrint('==========================================');

  Get.snackbar(
    'Products Error',
    e.toString().replaceFirst('Exception: ', ''),
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 10),
  );
}
  }

  Future<void> loadFeaturedProducts() async {
    try {
      featuredProducts.value = await _repository.getFeaturedProducts();
    } catch (_) {
      // Featured products are a nice-to-have on the home screen —
      // fail silently rather than blocking the rest of the page with
      // an error just because this one section couldn't load.
    }
  }

  Future<void> loadNearbyProducts(String cityId) async {
    try {
      nearbyProducts.value = await _repository.getNearbyProducts(
        cityId: cityId,
      );
    } catch (_) {
      // Same reasoning as loadFeaturedProducts — non-critical section.
    }
  }

  Future<void> loadCategories() async {
    try {
      categories.value = await _repository.getCategories();
    } catch (_) {
      // Categories failing to load shouldn't block the rest of the
      // page — the filter chips will just be empty until retried.
    }
  }

  Future<void> loadCities() async {
    try {
      cities.value = await _repository.getCities();
    } catch (_) {}
  }

  Future<void> refreshProducts() async {
    try {
      await loadProducts(refresh: true);
      await loadFeaturedProducts();

      if (selectedCity.value.isNotEmpty) {
        await loadNearbyProducts(selectedCity.value);
      }
    } catch (_) {
      _showLoadError();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      await loadProducts();
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _onSearchChanged() {
    final text = searchController.text;

    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
          () => loadProducts(refresh: true),
    );

    // Suggestions get their own, separate debounce — kept apart from
    // the main product search so typing quickly doesn't trigger two
    // competing timers stepping on each other.
    _suggestionsDebounce?.cancel();

    if (text.trim().isEmpty) {
      searchSuggestions.clear();
      showSuggestions.value = false;
      return;
    }

    _suggestionsDebounce = Timer(
      const Duration(milliseconds: 250),
          () => _fetchSuggestions(text),
    );
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final results = await _repository.getSearchSuggestions(query);

      // Guard against a stale, slow response overwriting a newer,
      // faster one if the user kept typing — only apply this result
      // if the search box still holds the same text it was for.
      if (searchController.text.trim() == query.trim()) {
        searchSuggestions.value = results;
        showSuggestions.value = results.isNotEmpty;
      }
    } catch (_) {
      // Suggestions failing silently is fine — worst case the
      // dropdown just doesn't appear, full search still works.
      searchSuggestions.clear();
      showSuggestions.value = false;
    }
  }

  void selectSuggestion(String title) {
    searchController.text = title;
    showSuggestions.value = false;
    searchSuggestions.clear();
    loadProducts(refresh: true);
  }

  void dismissSuggestions() {
    showSuggestions.value = false;
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 300) {
      loadMore();
    }
  }

  void selectCategory(String? id) {
    selectedCategory.value = id ?? '';
    loadProducts(refresh: true);
  }

  void selectCity(String? id) {
    selectedCity.value = id ?? '';
    loadProducts(refresh: true);

    if (id != null && id.isNotEmpty) {
      loadNearbyProducts(id);
    }
  }

  void updatePriceFilter({double? minimum, double? maximum}) {
    if (minimum != null) minPrice.value = minimum;
    if (maximum != null) maxPrice.value = maximum;

    loadProducts(refresh: true);
  }

  Future<void> clearFilters() async {
    selectedCategory.value = '';
    selectedCity.value = '';
    minPrice.value = 0;
    maxPrice.value = 0;
    searchController.clear();

    await loadProducts(refresh: true);
  }

  Future<void> toggleFavourite(String productId) async {
    if (currentUser == null) return;

    try {
      await _repository.toggleFavourite(
        userId: currentUser!.id,
        productId: productId,
      );
      await loadProducts(refresh: true);
      await loadFavourites();
    } catch (_) {
      Get.snackbar(
        'error'.tr,
        'favourite_update_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadFavourites() async {
    if (currentUser == null) return;

    try {
      isLoadingFavourites.value = true;
      final raw = await _repository.getFavouriteProducts(currentUser!.id);

      // getFavouriteProducts returns rows shaped like
      // { product_id, products: {...} } — flatten to just the
      // product maps so FavoritesPage can reuse ProductCard directly.
      favouriteProducts.value = raw
          .map((row) => row['products'] as Map<String, dynamic>?)
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      // Non-fatal — favorites tab just shows empty/stale until retry.
    } finally {
      isLoadingFavourites.value = false;
    }
  }

  bool isFavourite(Map<String, dynamic> product) {
    // Was checking product["is_favourite"] before — that key never
    // existed. The actual joined field from getProducts() is
    // "favorites", a list of {user_id: ...} rows for whoever
    // favourited this product. Checking it directly against the
    // current user is what this should have been doing all along.
    final favs = product['favorites'] as List?;
    if (favs == null || favs.isEmpty || currentUser == null) return false;

    return favs.any(
          (f) => f is Map && f['user_id'] == currentUser!.id,
    );
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void _showLoadError() {
    Get.snackbar(
      'error'.tr,
      'products_load_failed'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _suggestionsDebounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}