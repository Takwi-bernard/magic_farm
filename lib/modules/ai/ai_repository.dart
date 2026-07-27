import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Every AI feature routes through a Supabase Edge Function — never
/// straight to OpenAI. The OpenAI API key must never exist inside the
/// Flutter app; it lives only in the Edge Function's environment.
///
/// This is one concrete class, not an abstract interface + separate
/// implementation + separate service wrapper (that split existed in
/// the previous version across ai_repository.dart, openai_repository.dart,
/// and ai_service.dart with no real difference in behavior between
/// them). For a module this size, that's three files doing the job of
/// one — collapsed here on purpose.
///
/// NOTE: the four Edge Functions referenced below ('ai-chat',
/// 'ai-demand-forecast', 'ai-listing-helper', 'ai-price-suggestion')
/// are separate Deno/TypeScript files you deploy to Supabase — not
/// something that lives in this Flutter project. Happy to write those
/// next once this side is settled.
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
      throw Exception(e.details?.toString() ?? 'AI request failed.');
    } catch (_) {
      throw Exception('AI request failed. Please try again.');
    }
  }
}