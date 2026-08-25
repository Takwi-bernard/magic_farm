import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostRepository {
  CreatePostRepository({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _timeout = Duration(seconds: 30);

  Future<String> uploadImage({
    required XFile image,
    required String sellerId,
  }) async {
    try {
      final bytes = await image.readAsBytes();
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final path = "$sellerId/$fileName";

      await _client.storage
          .from("products")
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          )
          .timeout(_timeout);

      return _client.storage.from("products").getPublicUrl(path);
    } on TimeoutException {
      throw Exception(
        "Upload timed out. Please check your connection and try again.",
      );
    } catch (_) {
      throw Exception("Unable to upload image.");
    }
  }

  Future<String> createProduct({
    required Map<String, dynamic> product,
  }) async {
    try {
      final result = await _client
          .from("products")
          .insert(product)
          .select("id")
          .single()
          .timeout(_timeout);

      return result["id"];
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } catch (_) {
      throw Exception("Unable to create listing.");
    }
  }

  Future<void> addProductImage({
    required String productId,
    required String imageUrl,
    required int order,
  }) async {
    try {
      await _client.from("product_images").insert({
        "product_id": productId,
        "image_url": imageUrl,
        "sort_order": order,
      }).timeout(_timeout);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } catch (_) {
      throw Exception("Unable to save image.");
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _client.from("products").delete().eq("id", productId).timeout(
            _timeout,
          );
    } catch (_) {
      throw Exception("Unable to delete listing.");
    }
  }

  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client
          .from("products")
          .update(data)
          .eq("id", productId)
          .timeout(_timeout);
    } catch (_) {
      throw Exception("Unable to update listing.");
    }
  }

  Future<List<Map<String, dynamic>>> getMyProducts(String sellerId) async {
    try {
      final result = await _client
          .from("products")
          .select("""
            *,
            product_images(image_url)
          """)
          .eq("seller_id", sellerId)
          .order("created_at", ascending: false)
          .timeout(_timeout);

      return List<Map<String, dynamic>>.from(result);
    } catch (_) {
      throw Exception("Unable to load your listings.");
    }
  }

  // ===========================
  // CATEGORY / CITY CREATION
  // ===========================

  Future<Map<String, dynamic>> createCategory(String name) async {
    try {
      final result = await _client
          .from("categories")
          .insert({
            "name": name.trim(),
            "is_active": true,
          })
          .select("id, name")
          .single()
          .timeout(_timeout);

      return Map<String, dynamic>.from(result);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } on PostgrestException catch (e) {
      // Surfacing the real database error instead of a generic
      // message — this is genuinely necessary right now, not just
      // nice-to-have. A silently swallowed error here means an RLS
      // policy blocking this insert (the most likely cause) would be
      // completely invisible and undebuggable.
      throw Exception("${e.message} (code: ${e.code})");
    } catch (e) {
      throw Exception("Unable to create category: $e");
    }
  }

  Future<Map<String, dynamic>> createCity(String name) async {
    try {
      final result = await _client
          .from("cities")
          .insert({
            "name": name.trim(),
          })
          .select("id, name, region")
          .single()
          .timeout(_timeout);

      return Map<String, dynamic>.from(result);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } on PostgrestException catch (e) {
      throw Exception("${e.message} (code: ${e.code})");
    } catch (e) {
      throw Exception("Unable to create city: $e");
    }
  }
}