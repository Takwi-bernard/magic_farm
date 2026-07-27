import 'package:flutter/foundation.dart';

enum AIMessageRole {
  user,
  assistant,
  system,
}

@immutable
class AIMessageModel {
  final String id;
  final AIMessageRole role;
  final String message;
  final DateTime createdAt;

  const AIMessageModel({
    required this.id,
    required this.role,
    required this.message,
    required this.createdAt,
  });

  AIMessageModel copyWith({
    String? id,
    AIMessageRole? role,
    String? message,
    DateTime? createdAt,
  }) {
    return AIMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AIMessageModel.fromMap(Map<String, dynamic> map) {
    return AIMessageModel(
      id: map["id"],
      role: AIMessageRole.values.firstWhere(
            (e) => e.name == map["role"],
      ),
      message: map["message"],
      createdAt: DateTime.parse(map["created_at"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "role": role.name,
      "message": message,
      "created_at": createdAt.toIso8601String(),
    };
  }
}