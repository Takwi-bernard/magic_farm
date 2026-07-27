import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ai_controller.dart';
import 'ai_models.dart';
import '../../../app/theme/app_colors.dart';

/// Everything for the AI module's UI lives in this one file: the tab
/// switcher, the chat thread, and the shared form-and-result widget
/// used by the other three features. The previous version spread this
/// across ~13 widget files — most were a single IconButton or a few
/// lines wrapping one property. Splitting a widget into its own file
/// only pays off once it's reused elsewhere or is large enough that
/// finding it inside a bigger file becomes painful. None of these
/// were either.
class AIPage extends GetView<AIController> {
  const AIPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Magic Farm AI"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _FeatureSwitcher(),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              switch (controller.selectedFeature.value) {
                case AIFeature.chat:
                  return const _ChatTab();
                case AIFeature.demandForecast:
                  return const _ToolTab(
                    feature: AIFeature.demandForecast,
                  );
                case AIFeature.listingHelper:
                  return const _ToolTab(
                    feature: AIFeature.listingHelper,
                  );
                case AIFeature.priceSuggestion:
                  return const _ToolTab(
                    feature: AIFeature.priceSuggestion,
                  );
              }
            }),
          ),
        ],
      ),
    );
  }
}

//==========================================================
// FEATURE SWITCHER — replaces the old sidebar Drawer that listed
// several unbuilt features (disease detection, livestock assistant,
// weather...). A simple top switcher scoped to the 4 real features
// is both simpler and more honest about what's actually here.
//==========================================================

class _FeatureSwitcher extends GetView<AIController> {
  const _FeatureSwitcher();

  @override
  Widget build(BuildContext context) {
    final items = [
      (AIFeature.chat, Icons.chat_bubble_outline, "Chat"),
      (AIFeature.demandForecast, Icons.trending_up, "Demand"),
      (AIFeature.listingHelper, Icons.description_outlined, "Listing"),
      (AIFeature.priceSuggestion, Icons.sell_outlined, "Price"),
    ];

    return Obx(
          () => SizedBox(
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: items.map((item) {
            final (feature, icon, label) = item;
            final selected = controller.selectedFeature.value == feature;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selected,
                onSelected: (_) => controller.selectFeature(feature),
                avatar: Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                label: Text(label),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

//==========================================================
// CHAT TAB
//==========================================================

class _ChatTab extends GetView<AIController> {
  const _ChatTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty) {
              return Center(
                child: Text(
                  "Ask about crops, buyers, or anything else.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              itemCount:
              controller.messages.length + (controller.isSending.value ? 1 : 0),
              itemBuilder: (_, index) {
                if (controller.isSending.value &&
                    index == controller.messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: controller.messages[index]);
              },
            );
          }),
        ),
        _ChatInputBar(),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          border: isUser ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text("Magic Farm AI is thinking...", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ChatInputBar extends GetView<AIController> {
  const _ChatInputBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                minLines: 1,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(),
                decoration: InputDecoration(
                  hintText: "Ask Magic Farm AI...",
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
                  () => IconButton(
                onPressed:
                controller.isSending.value ? null : controller.sendMessage,
                icon: const Icon(Icons.send_rounded),
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//==========================================================
// SHARED TOOL TAB — demand forecast, listing helper, price
// suggestion all follow the same shape: input(s) -> generate ->
// result card. One widget parametrized by feature, instead of three
// nearly-identical files.
//==========================================================

class _ToolTab extends GetView<AIController> {
  const _ToolTab({required this.feature});

  final AIFeature feature;

  ({
  String title,
  String inputLabel,
  bool needsCategory,
  String buttonLabel,
  }) get _copy {
    switch (feature) {
      case AIFeature.demandForecast:
        return (
        title: "See likely demand for a product before you harvest.",
        inputLabel: "Product name (e.g. Tomatoes)",
        needsCategory: false,
        buttonLabel: "Forecast demand",
        );
      case AIFeature.listingHelper:
        return (
        title: "Describe your product roughly — AI will write a clean listing.",
        inputLabel: "Rough description",
        needsCategory: true,
        buttonLabel: "Generate listing",
        );
      case AIFeature.priceSuggestion:
        return (
        title: "Get a fair price range based on similar recent listings.",
        inputLabel: "Product name",
        needsCategory: true,
        buttonLabel: "Suggest price",
        );
      case AIFeature.chat:
      // _ToolTab is never built for chat — the switch in AIPage
      // routes that case to _ChatTab instead.
        throw StateError("_ToolTab does not support AIFeature.chat");
    }
  }

  Future<void> _run() {
    switch (feature) {
      case AIFeature.demandForecast:
        return controller.runDemandForecast();
      case AIFeature.listingHelper:
        return controller.runListingHelper();
      case AIFeature.priceSuggestion:
        return controller.runPriceSuggestion();
      case AIFeature.chat:
        throw StateError("_ToolTab does not support AIFeature.chat");
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.title,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: controller.toolInputController,
            maxLines: copy.needsCategory ? 3 : 1,
            decoration: InputDecoration(
              labelText: copy.inputLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          if (copy.needsCategory) ...[
            const SizedBox(height: 14),
            TextField(
              controller: controller.toolCategoryController,
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(
                  () => ElevatedButton(
                onPressed: controller.isGenerating.value ? null : _run,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: controller.isGenerating.value
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : Text(copy.buttonLabel),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Obx(() {
            if (controller.toolResult.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                controller.toolResult.value,
                style: const TextStyle(height: 1.5),
              ),
            );
          }),
        ],
      ),
    );
  }
}