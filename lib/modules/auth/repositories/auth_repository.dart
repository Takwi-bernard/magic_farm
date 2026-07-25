import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const _networkTimeout = Duration(seconds: 15);

  //==========================================================
  // AUTH
  //==========================================================

  GoTrueClient get auth => _supabase.auth;

  Session? get currentSession => auth.currentSession;

  User? get currentUser => auth.currentUser;

  bool get isLoggedIn => currentSession != null;

  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  //==========================================================
  // SIGN IN
  //==========================================================

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await auth
          .signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      )
          .timeout(_networkTimeout);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } catch (_) {
      throw Exception(
        "Unable to sign in. Please try again.",
      );
    }
  }

  //==========================================================
  // REGISTER
  //==========================================================

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String language,
    required String role,
  }) async {
    try {
      return await auth
          .signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {
          "full_name": fullName.trim(),
          "phone": phone.trim(),
          "language": language,
          "role": role,
        },
      )
          .timeout(_networkTimeout);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } catch (_) {
      throw Exception(
        "Registration failed.",
      );
    }
  }

  //==========================================================
  // GOOGLE SIGN IN
  //==========================================================

  Future<void> signInWithGoogle() async {
    try {
      await auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? null
            : 'io.supabase.flutterquickstart://login-callback',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(
        "Google Sign In failed.",
      );
    }
  }

  //==========================================================
  // RESET PASSWORD
  //==========================================================

  Future<void> sendPasswordResetEmail(
      String email,
      ) async {
    try {
      await auth
          .resetPasswordForEmail(
        email.trim().toLowerCase(),
      )
          .timeout(_networkTimeout);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    }
  }

  //==========================================================
  // CHANGE PASSWORD
  //==========================================================

  Future<void> changePassword(
      String newPassword,
      ) async {
    try {
      await auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  //==========================================================
  // SIGN OUT
  //==========================================================

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  //==========================================================
  // REFRESH SESSION
  //==========================================================

  Future<void> refreshSession() async {
    try {
      await auth.refreshSession();
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  //==========================================================
  // USER
  //==========================================================

  Future<User?> reloadUser() async {
    await refreshSession();
    return auth.currentUser;
  }

  //==========================================================
  // PROFILE
  //==========================================================

  Future<Map<String, dynamic>> getProfile() async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(
        "Unable to load profile.",
      );
    }
  }

  //==========================================================
  // UPDATE PROFILE
  //==========================================================

  Future<void> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      await _supabase
          .from('profiles')
          .update(data)
          .eq('id', user.id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(
        "Unable to update profile.",
      );
    }
  }

  //==========================================================
  // UPDATE PROFILE PHOTO
  //==========================================================

  Future<void> updateProfilePhoto(
      String imageUrl,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      await _supabase
          .from('profiles')
          .update({
        "profile_photo": imageUrl,
      })
          .eq('id', user.id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(
        "Unable to update profile photo.",
      );
    }
  }

  //==========================================================
  // UPDATE LOCATION
  //==========================================================

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String country,
    required String region,
    required String division,
    required String subdivision,
    required String village,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      await _supabase
          .from('profiles')
          .update({
        "latitude": latitude,
        "longitude": longitude,
        "country": country,
        "region": region,
        "division": division,
        "subdivision": subdivision,
        "village": village,
      })
          .eq("id", user.id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(
        "Unable to update location.",
      );
    }
  }

  //==========================================================
  // UPDATE LANGUAGE
  //==========================================================

  Future<void> updateLanguage(
      String language,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      await _supabase
          .from("profiles")
          .update({
        "language": language,
      })
          .eq("id", user.id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  //==========================================================
  // UPDATE ROLE
  //==========================================================

  Future<void> updateRole(
      String role,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      await _supabase
          .from('profiles')
          .update({
        "role": role,
      })
          .eq('id', user.id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(
        "Unable to update role.",
      );
    }
  }

  //==========================================================
  // UPDATE PHONE
  //==========================================================

  Future<void> updatePhone(
      String phone,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      await _supabase
          .from('profiles')
          .update({
        "phone": phone.trim(),
      })
          .eq('id', user.id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(
        "Unable to update phone number.",
      );
    }
  }

  //==========================================================
  // UPDATE FULL NAME
  //==========================================================

  Future<void> updateFullName(
      String fullName,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      await _supabase
          .from('profiles')
          .update({
        "full_name": fullName.trim(),
      })
          .eq('id', user.id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(
        "Unable to update full name.",
      );
    }
  }

  //==========================================================
  // UPDATE BIO
  //==========================================================

  Future<void> updateBio(
      String bio,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception("No authenticated user.");
    }

    try {
      await _supabase
          .from('profiles')
          .update({
        "bio": bio.trim(),
      })
          .eq('id', user.id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(
        "Unable to update bio.",
      );
    }
  }

  //==========================================================
  // GET USER ROLE
  //==========================================================

  Future<String> getUserRole() async {
    final profile = await getProfile();

    return (profile["role"] ?? "buyer").toString();
  }

  //==========================================================
  // CHECK ADMIN
  //==========================================================

  Future<bool> isAdmin() async {
    return (await getUserRole()) == "admin";
  }

  //==========================================================
  // DELETE AUTH ACCOUNT
  //==========================================================

  Future<void> deleteCurrentUser() async {
    throw UnimplementedError(
      "Delete user should be handled by a Supabase Edge Function with service_role permissions.",
    );
  }
}