import 'ai_message_model.dart';

class AIChatModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AIMessageModel> messages;

  const AIChatModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  AIChatModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AIMessageModel>? messages,
  }) {
    return AIChatModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  factory AIChatModel.empty() {
    return AIChatModel(
      id: "",
      title: "New Chat",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: const [],
    );
  }
}