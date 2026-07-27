class TranslationModel {
  final String sourceLanguage;
  final String targetLanguage;
  final String originalText;
  final String translatedText;

  const TranslationModel({
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.originalText,
    required this.translatedText,
  });
}