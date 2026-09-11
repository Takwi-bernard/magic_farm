import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailsRepository {
  ProductDetailsRepository({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _timeout = Duration(seconds: 20);

  String? get _currentUserId => _client.auth.currentUser?.id;

  Future<Map<String, dynamic>> getProduct(String productId) async {
    try {
      dynamic query = _client
          .from("products")
          .select('''
            *,
            profiles!seller_id(
              id,
              full_name,
              avatar_url,
              phone,
              email,
              is_verified,
              created_at
            ),
            categories(
              id,
              name
            ),
            cities(
              id,
              name,
              region
            ),
            product_images(
              id,
              image_url,
              sort_order
            ),
            favorites(
              user_id
            )
          ''')
          .eq("id", productId);

      // Scoped the same way as HomeRepository — without this, the
      // favorites array either comes back empty (so the heart can
      // never show as filled) or unscoped (pulling every user who
      // favourited it, which is both wasteful and unnecessary).
      if (_currentUserId != null) {
        query = query.eq('favorites.user_id', _currentUserId!);
      }

      final result = await query.single().timeout(_timeout);
      return Map<String, dynamic>.from(result);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } catch (_) {
      throw Exception("Unable to load this product.");
    }
  }

  Future<List<Map<String, dynamic>>> getSimilarProducts({
    required String categoryId,
    required String productId,
  }) async {
    try {
      final result = await _client
          .from("products")
          .select('''
            *,
            product_images(image_url)
          ''')
          .eq("category_id", categoryId)
          .neq("id", productId)
          .eq("status", "active")
          .limit(10)
          .timeout(_timeout);

      return List<Map<String, dynamic>>.from(result);
    } catch (_) {
      // Non-fatal — similar products failing to load shouldn't block
      // the rest of the page.
      return [];
    }
  }

  // toggleFavourite was duplicated here before — identical logic
  // already lives in HomeRepository. Removed; ProductDetailsController
  // now reuses HomeController's copy instead of maintaining two
  // independent implementations of the same thing.

  Future<void> increaseViews(String productId) async {
    try {
      await _client
          .rpc("increment_product_views", params: {"product_id": productId})
          .timeout(_timeout);
    } catch (_) {
      // View counting failing shouldn't block the page — silent fail.
    }
  }

  // ===========================
  // SELLER PROFILE
  //
  // The profiles table already has everything needed for this —
  // full_name, avatar_url, phone, email, is_verified, created_at —
  // no schema gap here, just needed the actual page built.
  // ===========================

  Future<Map<String, dynamic>> getSellerProfile(String sellerId) async {
    try {
      final result = await _client
          .from("profiles")
          .select("id, full_name, avatar_url, phone, is_verified, created_at")
          .eq("id", sellerId)
          .single()
          .timeout(_timeout);

      return Map<String, dynamic>.from(result);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } catch (_) {
      throw Exception("Unable to load this seller's profile.");
    }
  }

  Future<List<Map<String, dynamic>>> getSellerProducts(
    String sellerId,
  ) async {
    try {
      final result = await _client
          .from("products")
          .select('''
            *,
            product_images(image_url)
          ''')
          .eq("seller_id", sellerId)
          .eq("status", "active")
          .order("created_at", ascending: false)
          .timeout(_timeout);

      return List<Map<String, dynamic>>.from(result);
    } catch (_) {
      // Non-fatal — seller's listings failing to load shouldn't block
      // the rest of the profile page from showing.
      return [];
    }
  }

  // NOTE: this assumes an "orders" table with columns (buyer_id,
  // seller_id, product_id, quantity, status) already exists. Orders
  // is explicitly a future module in this project — if that table
  // isn't built yet, this will throw a clear error rather than fail
  // silently, which is the right behavior until Orders is real.
  Future<void> reserveProduct({
    required String buyerId,
    required String productId,
    required int quantity,
    required String sellerId,
  }) async {
    try {
      await _client.from("orders").insert({
        "buyer_id": buyerId,
        "seller_id": sellerId,
        "product_id": productId,
        "quantity": quantity,
        "status": "pending",
      }).timeout(_timeout);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } on PostgrestException catch (e) {
      throw Exception("${e.message} (code: ${e.code})");
    } catch (e) {
      throw Exception("Unable to reserve this product: $e");
    }
  }
}