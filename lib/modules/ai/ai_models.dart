/// One of the four AI features this app actually offers. Kept tight on
/// purpose — the previous version's 10-value enum (translation,
/// weather, disease detection, negotiation...) was scope well beyond
/// what was ever agreed on.
enum AIFeature {
  chat,
  demandForecast,
  listingHelper,
  priceSuggestion,
}

enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.role,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}