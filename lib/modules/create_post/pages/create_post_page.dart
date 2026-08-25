import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/create_post_controller.dart';

class CreatePostPage extends GetView<CreatePostController> {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('create_post'.tr),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        shadowColor: Colors.black12,
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              _SectionCard(
                title: 'photos'.tr,
                subtitle: 'photos_subtitle'.tr,
                child: const _ImagePickerGrid(),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'listing_details'.tr,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.titleController,
                      decoration: InputDecoration(
                        labelText: 'product_title'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'err_title_required'.tr
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller.descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'product_description'.tr,
                        hintText: 'ai_rough_note_hint'.tr,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'err_description_required'.tr
                          : null,
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                            () => OutlinedButton.icon(
                          onPressed: controller.isGeneratingWithAI.value
                              ? null
                              : controller.generateWithAI,
                          icon: controller.isGeneratingWithAI.value
                              ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                              : Icon(Icons.auto_awesome,
                              size: 18, color: AppColors.primary),
                          label: Text('improve_with_ai'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller.priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'product_price'.tr,
                        suffixText: 'FCFA',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'err_price_required'.tr;
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'err_price_invalid'.tr;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'category_and_location'.tr,
                child: Obx(() {
                  if (controller.isLoadingOptions.value) {
                    return const _OptionsLoadingState();
                  }

                  return Column(
                    children: [
                      _DropdownField(
                        label: 'category'.tr,
                        value: controller.selectedCategoryName,
                        placeholder: 'select_category'.tr,
                        onTap: () => _openPicker(
                          context: context,
                          title: 'category'.tr,
                          options: controller.categories,
                          selectedId: controller.selectedCategoryId.value,
                          onSelect: controller.selectCategory,
                          onCreateNew: controller.addNewCategory,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DropdownField(
                        label: 'city'.tr,
                        value: controller.selectedCityName,
                        placeholder: 'select_city'.tr,
                        onTap: () => _openPicker(
                          context: context,
                          title: 'city'.tr,
                          options: controller.cities,
                          selectedId: controller.selectedCityId.value,
                          onSelect: controller.selectCity,
                          onCreateNew: controller.addNewCity,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(
                      () => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'publish_listing'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPicker({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> options,
    required String selectedId,
    required void Function(String id) onSelect,
    required Future<bool> Function(String name) onCreateNew,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PickerSheet(
        title: title,
        options: options,
        selectedId: selectedId,
        onSelect: onSelect,
        onCreateNew: onCreateNew,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? value : placeholder,
                    style: TextStyle(
                      fontSize: 15,
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onSelect,
    required this.onCreateNew,
  });

  final String title;
  final List<Map<String, dynamic>> options;
  final String selectedId;
  final void Function(String id) onSelect;
  final Future<bool> Function(String name) onCreateNew;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _creating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasExactMatch => widget.options.any(
        (o) => (o['name'] ?? '').toString().toLowerCase() ==
        _query.trim().toLowerCase(),
  );

  @override
  Widget build(BuildContext context) {
    final filtered = _query.trim().isEmpty
        ? widget.options
        : widget.options
        .where((o) => (o['name'] ?? '')
        .toString()
        .toLowerCase()
        .contains(_query.trim().toLowerCase()))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(widget.title, style: AppTextStyles.title),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'search_or_add_new'.tr,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // "Add new" option — only shown when the search
                      // text doesn't already exist as an option. This
                      // is the actual fix: previously there was simply
                      // no way forward if the list was empty or didn't
                      // have what a farmer needed.
                      if (_query.trim().isNotEmpty && !_hasExactMatch)
                        ListTile(
                          leading: Icon(Icons.add_circle_outline,
                              color: AppColors.primary),
                          title: Text(
                            '${'add_new'.tr} "${_query.trim()}"',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: _creating
                              ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                              : null,
                          onTap: _creating
                              ? null
                              : () async {
                            setState(() => _creating = true);
                            final success =
                            await widget.onCreateNew(_query.trim());
                            setState(() => _creating = false);
                            if (success && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      if (filtered.isEmpty && _query.trim().isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 20),
                          child: Text(
                            'no_options_yet'.tr,
                            textAlign: TextAlign.center,
                            style:
                            TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ...filtered.map((option) {
                        final selected = widget.selectedId == option['id'];
                        return ListTile(
                          title: Text(option['name'] ?? ''),
                          trailing: selected
                              ? Icon(Icons.check_circle,
                              color: AppColors.primary)
                              : null,
                          onTap: () {
                            widget.onSelect(option['id']);
                            Navigator.of(context).pop();
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title.copyWith(fontSize: 16)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _OptionsLoadingState extends StatelessWidget {
  const _OptionsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'loading_options'.tr,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerGrid extends GetView<CreatePostController> {
  const _ImagePickerGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ...List.generate(controller.selectedImages.length, (index) {
            final image = controller.selectedImages[index];
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: FutureBuilder<Uint8List>(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          width: 90,
                          height: 90,
                          color: AppColors.background,
                        );
                      }
                      return Image.memory(
                        snapshot.data!,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => controller.removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }),
          if (controller.selectedImages.length <
              CreatePostController.maxImages)
            GestureDetector(
              onTap: controller.pickImages,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        color: AppColors.primary, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      'add_photo'.tr,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}