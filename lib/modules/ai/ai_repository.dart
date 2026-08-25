import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Every AI feature routes through a Supabase Edge Function — never
/// straight to OpenAI. The OpenAI API key must never exist inside the
/// Flutter app; it lives only in the Edge Function's environment.
class AIRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const _timeout = Duration(seconds: 30);

  Future<String> chat(String message, {required String language}) async {
    return _invoke('ai-chat', {
      'message': message,
      'language': language,
    });
  }

  Future<String> demandForecast({
    required String productName,
    required String language,
  }) async {
    return _invoke('ai-demand-forecast', {
      'product_name': productName,
      'language': language,
    });
  }

  Future<String> generateListing({
    required String roughDescription,
    required String category,
    required String language,
  }) async {
    return _invoke('ai-listing-helper', {
      'description': roughDescription,
      'category': category,
      'language': language,
    });
  }

  Future<String> priceSuggestion({
    required String productName,
    required String category,
    required String language,
  }) async {
    return _invoke('ai-price-suggestion', {
      'product_name': productName,
      'category': category,
      'language': language,
    });
  }

  Future<String> _invoke(
      String functionName,
      Map<String, dynamic> body,
      ) async {
    try {
      final res = await _client.functions
          .invoke(functionName, body: body)
          .timeout(_timeout);

      final data = res.data;

      if (data is Map && data['text'] is String) {
        return data['text'] as String;
      }

      throw Exception('Unexpected response from $functionName.');
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your connection and try again.',
      );
    } on FunctionException catch (e) {
      throw Exception(_friendlyMessage(e));
    } catch (_) {
      throw Exception('AI request failed. Please try again.');
    }
  }

  // Was previously just calling e.details.toString() — that dumped
  // the raw error JSON/map straight onto the screen (a farmer seeing
  // "insufficient_quota" / "credit_balance_exhausted" means nothing
  // to them). This extracts a real message where possible, and
  // recognizes a couple of specific, likely-to-recur cases with a
  // clean explanation instead of ever showing raw JSON.
  String _friendlyMessage(FunctionException e) {
    final details = e.details;
    String raw = '';

    if (details is Map && details['error'] is String) {
      raw = details['error'] as String;
    } else if (details != null) {
      raw = details.toString();
    }

    if (raw.contains('insufficient_quota') ||
        raw.contains('credit_balance_exhausted')) {
      return 'AI features are temporarily unavailable. Please try again later.';
    }

    if (raw.contains('rate_limit')) {
      return 'The AI assistant is busy right now. Please try again in a moment.';
    }

    // Anything else unrecognized — still never show the raw JSON.
    return 'AI request failed. Please try again.';
  }
}