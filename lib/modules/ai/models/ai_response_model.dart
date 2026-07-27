class AIResponseModel {
  final bool success;
  final String response;
  final String? detectedLanguage;
  final List<String> suggestions;

  const AIResponseModel({
    required this.success,
    required this.response,
    this.detectedLanguage,
    this.suggestions = const [],
  });
}