import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepository {
  HomeRepository({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const int pageSize = 20;

  String? get _currentUserId => _client.auth.currentUser?.id;

  // ===========================
  // PRODUCTS
  // ===========================

  Future<List<Map<String, dynamic>>> getProducts({
    int page = 0,
    String? search,
    String? categoryId,
    String? cityId,
    double? minPrice,
    double? maxPrice,
    bool newestFirst = true,
  }) async {
    dynamic query = _client
        .from('products')
        .select('''
          *,
          profiles!seller_id(
            id,
            full_name,
            avatar_url,
            phone,
            is_verified
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
        .eq('status', 'active')
        .range(
      page * pageSize,
      page * pageSize + pageSize - 1,
    );

    // Scopes the embedded favorites array to just the current user's
    // row (if any), instead of pulling every user who ever favourited
    // each product. Was previously unscoped — wasteful, and there's
    // no reason the app needs to know who else favourited something.
    if (_currentUserId != null) {
      query = query.eq('favorites.user_id', _currentUserId!);
    }

    if (search != null && search.trim().isNotEmpty) {
      query = query.textSearch(
        'search_vector',
        search.trim(),
      );
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }

    if (cityId != null && cityId.isNotEmpty) {
      query = query.eq('city_id', cityId);
    }

    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }

    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    query = query.order(
      newestFirst ? 'created_at' : 'price',
      ascending: !newestFirst,
    );

    final result = await query;

    return List<Map<String, dynamic>>.from(result);
  }

  // ===========================
  // SEARCH SUGGESTIONS
  //
  // Deliberately separate from getProducts — runs on every keystroke
  // (debounced), so it stays small and fast: 5 results, 3 columns,
  // no joins.
  // ===========================

  Future<List<Map<String, dynamic>>> getSearchSuggestions(
      String query,
      ) async {
    if (query.trim().isEmpty) return [];

    final result = await _client
        .from('products')
        .select('id, title, price')
        .eq('status', 'active')
        .ilike('title', '%${query.trim()}%')
        .order('created_at', ascending: false)
        .limit(5);

    return List<Map<String, dynamic>>.from(result);
  }

  // ===========================
  // FEATURED PRODUCTS
  // ===========================

  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    dynamic query = _client
        .from('products')
        .select('''
          *,
          profiles!seller_id(
            id,
            full_name,
            avatar_url,
            is_verified
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
            image_url
          ),
          favorites(
            user_id
          )
        ''')
        .eq('status', 'active')
        .eq('is_featured', true);

    // Was missing the favorites join entirely before — meant the
    // heart icon could never show as filled anywhere in the "Fresh
    // Picks" row, regardless of actual favorite status.
    if (_currentUserId != null) {
      query = query.eq('favorites.user_id', _currentUserId!);
    }

    final result = await query
        .order('created_at', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(result);
  }

  // ===========================
  // NEARBY PRODUCTS
  // ===========================

  Future<List<Map<String, dynamic>>> getNearbyProducts({
    required String cityId,
  }) async {
    dynamic query = _client
        .from('products')
        .select('''
          *,
          profiles!seller_id(
            id,
            full_name,
            avatar_url,
            is_verified
          ),
          product_images(
            image_url
          ),
          favorites(
            user_id
          )
        ''')
        .eq('status', 'active')
        .eq('city_id', cityId);

    // Same missing-join bug as getFeaturedProducts, fixed the same way.
    if (_currentUserId != null) {
      query = query.eq('favorites.user_id', _currentUserId!);
    }

    final result =
    await query.order('created_at', ascending: false).limit(20);

    return List<Map<String, dynamic>>.from(result);
  }

  // ===========================
  // CATEGORIES
  // ===========================

  Future<List<Map<String, dynamic>>> getCategories() async {
    final result = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(result);
  }

  // ===========================
  // CITIES
  // ===========================

  Future<List<Map<String, dynamic>>> getCities() async {
    final result = await _client.from('cities').select().order('name');

    return List<Map<String, dynamic>>.from(result);
  }

  // ===========================
  // FAVORITES
  // ===========================

  Future<void> toggleFavourite({
    required String userId,
    required String productId,
  }) async {
    final existing = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing == null) {
      await _client.from('favorites').insert({
        'user_id': userId,
        'product_id': productId,
      });
    } else {
      await _client.from('favorites').delete().eq('id', existing['id']);
    }
  }

  Future<List<Map<String, dynamic>>> getFavouriteProducts(
      String userId,
      ) async {
    final result = await _client
        .from('favorites')
        .select('''
          product_id,
          products(
            *,
            profiles!seller_id(
              id,
              full_name,
              avatar_url,
              is_verified
            ),
            product_images(
              image_url
            ),
            favorites(
              user_id
            )
          )
        ''')
        .eq('user_id', userId);

    // Every nested product's own `favorites` embed now includes this
    // same user's row too (it has to — that's how it ended up in this
    // query result in the first place), so ProductCard's heart shows
    // correctly filled here without any special-casing — previously
    // this nested select didn't include the favorites join at all,
    // so hearts on the Favorites page itself showed as empty.
    return List<Map<String, dynamic>>.from(result);
  }

  // ===========================
  // PRODUCT DETAILS
  // ===========================

  Future<Map<String, dynamic>> getProduct(String productId) async {
    dynamic query = _client
        .from('products')
        .select('''
          *,
          profiles!seller_id(
            *
          ),
          categories(
            *
          ),
          cities(
            *
          ),
          product_images(
            *
          ),
          favorites(
            user_id
          )
        ''')
        .eq('id', productId);

    if (_currentUserId != null) {
      query = query.eq('favorites.user_id', _currentUserId!);
    }

    final result = await query.single();

    return Map<String, dynamic>.from(result);
  }

  // ===========================
  // SHARE / VIEWS
  // ===========================

  Future<void> incrementViews(String productId) async {
    await _client.rpc(
      'increment_product_views',
      params: {'product_id': productId},
    );
  }

  // ===========================
  // REAL-TIME STREAM
  // ===========================

  Stream<List<Map<String, dynamic>>> productStream() {
    return _client
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('status', 'active');
  }
}