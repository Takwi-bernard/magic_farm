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

  final RxList<Map<String, dynamic>> categories =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> cities =
      <Map<String, dynamic>>[].obs;

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

  User? get currentUser =>
      Supabase.instance.client.auth.currentUser;

  String get role =>
      currentUser?.userMetadata?['role'] ?? 'buyer';

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
    isLoading.value = true;

    await Future.wait([
      loadCategories(),
      loadCities(),
      loadFeaturedProducts(),
      loadProducts(refresh: true),
    ]);

    isLoading.value = false;
  }

  Future<void> loadProducts({
    bool refresh = false,
  }) async {
    if (refresh) {
      currentPage.value = 0;
      hasMore.value = true;
      products.clear();
    }

    if (!hasMore.value) return;

    final result = await _repository.getProducts(
      page: currentPage.value,
      search: searchController.text,
      categoryId: selectedCategory.value.isEmpty
          ? null
          : selectedCategory.value,
      cityId: selectedCity.value.isEmpty
          ? null
          : selectedCity.value,
      minPrice:
          minPrice.value == 0 ? null : minPrice.value,
      maxPrice:
          maxPrice.value == 0 ? null : maxPrice.value,
    );

    if (result.length < HomeRepository.pageSize) {
      hasMore.value = false;
    }

    products.addAll(result);
    currentPage.value++;
  }

  Future<void> loadFeaturedProducts() async {
    featuredProducts.value =
        await _repository.getFeaturedProducts();
  }

  Future<void> loadNearbyProducts(
      String cityId) async {
    nearbyProducts.value =
        await _repository.getNearbyProducts(
      cityId: cityId,
    );
  }

  Future<void> loadCategories() async {
    categories.value =
        await _repository.getCategories();
  }

  Future<void> loadCities() async {
    cities.value =
        await _repository.getCities();
  }

  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);

    await loadFeaturedProducts();

    if (selectedCity.value.isNotEmpty) {
      await loadNearbyProducts(
        selectedCity.value,
      );
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) {
      return;
    }

    isLoadingMore.value = true;

    await loadProducts();

    isLoadingMore.value = false;
  }

  void _onSearchChanged() {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => loadProducts(refresh: true),
    );
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent -
            300) {
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

  void updatePriceFilter({
    double? minimum,
    double? maximum,
  }) {
    if (minimum != null) {
      minPrice.value = minimum;
    }

    if (maximum != null) {
      maxPrice.value = maximum;
    }

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

  Future<void> toggleFavourite(
      String productId) async {
    if (currentUser == null) return;

    await _repository.toggleFavourite(
      userId: currentUser!.id,
      productId: productId,
    );

    await loadProducts(refresh: true);
  }

  bool isFavourite(
      Map<String, dynamic> product) {
    return product["is_favourite"] == true;
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    _debounce?.cancel();

    searchController.dispose();
    scrollController.dispose();

    super.onClose();
  }
}