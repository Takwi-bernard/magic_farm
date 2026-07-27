import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ai_models.dart';
import 'ai_repository.dart';
import '../../app/controllers/language_controller.dart';

class AIController extends GetxController {
  AIController(this._repository);

  final AIRepository _repository;

  //==========================================================
  // TAB / FEATURE SWITCH
  //==========================================================

  final selectedFeature = AIFeature.chat.obs;

  void selectFeature(AIFeature feature) {
    selectedFeature.value = feature;
  }

  //==========================================================
  // LANGUAGE
  //
  // Read fresh on every call rather than cached once — the user can
  // switch language mid-session (e.g. from the language picker), and
  // the very next AI response should honor that immediately.
  //==========================================================

  String get _currentLanguage =>
      Get.find<LanguageController>().currentLocale.languageCode;

  //==========================================================
  // CHAT
  //==========================================================

  final messages = <ChatMessage>[].obs;
  final messageController = TextEditingController();
  final isSending = false.obs;

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending.value) return;

    messages.add(ChatMessage(role: ChatRole.user, text: text));
    messageController.clear();

    try {
      isSending.value = true;

      final reply = await _repository.chat(text, language: _currentLanguage);

      messages.add(ChatMessage(role: ChatRole.assistant, text: reply));
    } catch (e) {
      messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          text: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      isSending.value = false;
    }
  }

  void clearChat() {
    messages.clear();
  }

  //==========================================================
  // DEMAND FORECAST / LISTING HELPER / PRICE SUGGESTION
  //
  // These three share one shape (an input, a "generate" action, a
  // result) rather than each needing their own bespoke controller
  // state — same pattern as the shared _ToolTab widget in ai_page.dart.
  //==========================================================

  final toolInputController = TextEditingController();
  final toolCategoryController = TextEditingController();
  final toolResult = ''.obs;
  final isGenerating = false.obs;

  Future<void> runDemandForecast() async {
    await _runTool(
          () => _repository.demandForecast(
        productName: toolInputController.text.trim(),
        language: _currentLanguage,
      ),
    );
  }

  Future<void> runListingHelper() async {
    await _runTool(
          () => _repository.generateListing(
        roughDescription: toolInputController.text.trim(),
        category: toolCategoryController.text.trim(),
        language: _currentLanguage,
      ),
    );
  }

  Future<void> runPriceSuggestion() async {
    await _runTool(
          () => _repository.priceSuggestion(
        productName: toolInputController.text.trim(),
        category: toolCategoryController.text.trim(),
        language: _currentLanguage,
      ),
    );
  }

  Future<void> _runTool(Future<String> Function() action) async {
    if (isGenerating.value) return;

    try {
      isGenerating.value = true;
      toolResult.value = '';

      toolResult.value = await action();
    } catch (e) {
      toolResult.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isGenerating.value = false;
    }
  }

  void clearTool() {
    toolInputController.clear();
    toolCategoryController.clear();
    toolResult.value = '';
  }

  @override
  void onClose() {
    messageController.dispose();
    toolInputController.dispose();
    toolCategoryController.dispose();
    super.onClose();
  }
}