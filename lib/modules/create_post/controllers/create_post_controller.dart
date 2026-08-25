import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/create_post_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../ai/ai_repository.dart';
import '../../../app/controllers/language_controller.dart';

class CreatePostController extends GetxController {
  CreatePostController(
      this._repository,
      this._homeController,
      this._aiRepository,
      );

  final CreatePostRepository _repository;
  final HomeController _homeController;
  final AIRepository _aiRepository;

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedCityId = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isGeneratingWithAI = false.obs;
  final RxBool isLoadingOptions = false.obs;
  final RxBool isSavingNewOption = false.obs;

  static const int maxImages = 6;

  // Reads straight from HomeController's lists — when a new category/
  // city gets added here, it's appended to these same RxLists, so
  // Home's own category chips update immediately too, app-wide, with
  // no separate refresh needed.
  List<Map<String, dynamic>> get categories => _homeController.categories;
  List<Map<String, dynamic>> get cities => _homeController.cities;

  User? get currentUser => Supabase.instance.client.auth.currentUser;

  String get selectedCategoryName {
    for (final c in categories) {
      if (c['id'] == selectedCategoryId.value) return c['name'] ?? '';
    }
    return '';
  }

  String get selectedCityName {
    for (final c in cities) {
      if (c['id'] == selectedCityId.value) return c['name'] ?? '';
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    ensureOptionsLoaded();
  }

  Future<void> ensureOptionsLoaded() async {
    if (categories.isNotEmpty && cities.isNotEmpty) return;

    try {
      isLoadingOptions.value = true;
      await Future.wait([
        if (categories.isEmpty) _homeController.loadCategories(),
        if (cities.isEmpty) _homeController.loadCities(),
      ]);
    } finally {
      isLoadingOptions.value = false;
    }
  }

  Future<void> pickImages() async {
    if (selectedImages.length >= maxImages) {
      Get.snackbar(
        'error'.tr,
        'max_images_reached'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(imageQuality: 70);

      if (picked.isEmpty) return;

      final remaining = maxImages - selectedImages.length;
      selectedImages.addAll(picked.take(remaining));
    } catch (_) {
      Get.snackbar(
        'error'.tr,
        'image_pick_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  void selectCategory(String id) => selectedCategoryId.value = id;
  void selectCity(String id) => selectedCityId.value = id;

  //==========================================================
  // CREATE NEW CATEGORY / CITY
  //
  // Used when a farmer searches for a category or city that isn't in
  // the list yet. Creates a real row, adds it to the shared list
  // (visible to every user from now on, not just this session), and
  // selects it immediately.
  //==========================================================

  Future<bool> addNewCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    // Guard against creating a near-duplicate of something that
    // already exists (case-insensitive match).
    for (final c in categories) {
      if ((c['name'] ?? '').toString().toLowerCase() ==
          trimmed.toLowerCase()) {
        selectCategory(c['id']);
        return true;
      }
    }

    try {
      isSavingNewOption.value = true;
      final created = await _repository.createCategory(trimmed);
      categories.add(created);
      selectCategory(created['id']);
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSavingNewOption.value = false;
    }
  }

  Future<bool> addNewCity(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    for (final c in cities) {
      if ((c['name'] ?? '').toString().toLowerCase() ==
          trimmed.toLowerCase()) {
        selectCity(c['id']);
        return true;
      }
    }

    try {
      isSavingNewOption.value = true;
      final created = await _repository.createCity(trimmed);
      cities.add(created);
      selectCity(created['id']);
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSavingNewOption.value = false;
    }
  }

  //==========================================================
  // AI LISTING HELPER
  //==========================================================

  Future<void> generateWithAI() async {
    final roughNote = descriptionController.text.trim().isNotEmpty
        ? descriptionController.text.trim()
        : titleController.text.trim();

    if (roughNote.isEmpty) {
      Get.snackbar(
        'ai_listing_helper'.tr,
        'ai_needs_rough_note'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isGeneratingWithAI.value = true;

      final language =
          Get.find<LanguageController>().currentLocale.languageCode;

      final raw = await _aiRepository.generateListing(
        roughDescription: roughNote,
        category: selectedCategoryName,
        language: language,
      );

      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        descriptionController.text = raw;
        Get.snackbar(
          'ai_listing_helper'.tr,
          'ai_response_unparsed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (parsed['title'] is String) {
        titleController.text = parsed['title'];
      }
      if (parsed['description'] is String) {
        descriptionController.text = parsed['description'];
      }
    } catch (e) {
      Get.snackbar(
        'ai_listing_helper'.tr,
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGeneratingWithAI.value = false;
    }
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (selectedImages.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'at_least_one_image'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedCategoryId.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'select_category_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (currentUser == null) return;

    try {
      isSubmitting.value = true;

      final price = double.tryParse(priceController.text.trim()) ?? 0;

      final productId = await _repository.createProduct(
        product: {
          "seller_id": currentUser!.id,
          "title": titleController.text.trim(),
          "description": descriptionController.text.trim(),
          "price": price,
          "category_id": selectedCategoryId.value,
          "city_id":
          selectedCityId.value.isEmpty ? null : selectedCityId.value,
          "status": "active",
        },
      );

      for (int i = 0; i < selectedImages.length; i++) {
        final url = await _repository.uploadImage(
          image: selectedImages[i],
          sellerId: currentUser!.id,
        );

        await _repository.addProductImage(
          productId: productId,
          imageUrl: url,
          order: i,
        );
      }

      Get.snackbar(
        'success'.tr,
        'listing_created'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      _resetForm();

      _homeController.changeTab(0);
      await _homeController.loadProducts(refresh: true);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedImages.clear();
    selectedCategoryId.value = '';
    selectedCityId.value = '';
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }
}