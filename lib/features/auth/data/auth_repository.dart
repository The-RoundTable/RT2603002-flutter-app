import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/user_model.dart';


class AuthRepository {
  final _supabase = Supabase.instance.client;

  // ── LOGIN ──────────────────────────────────────────────
  Future<UserModel> login(String email, String password) async {
    // signInWithPassword contacts Supabase auth server
    // If credentials are wrong → throws AuthException
    // If correct → returns AuthResponse with user + session
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Login failed. Please try again.');

    // Fetch profile from profiles table using user id
    // This gets the "name" field your friend set up
    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromSupabase(
      id: user.id,
      email: user.email ?? '',
      profile: profile,
    );
  }

  
  Future<UserModel> register(String name, String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name, // ✅ THIS FIXES EVERYTHING
      },
    );

    final user = response.user;
    if (user == null) throw Exception('Registration failed. Please try again.');

    

    return UserModel(
      id: user.id,
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  // ── LOGOUT ─────────────────────────────────────────────
  Future<void> logout() async {
    await _supabase.auth.signOut();
    // Supabase clears the saved session automatically
  }

  
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromSupabase(
        id: user.id,
        email: user.email ?? '',
        profile: profile,
      );
    } catch (_) {
      // Profile not found — return basic user from auth
      return UserModel(id: user.id, email: user.email ?? '', name: 'Driver');
    }
  }

  
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;
}
