import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/user_model.dart';

// ─────────────────────────────────────────────────────────
// SUPABASE AUTH EXPLAINED:
//
// supabase.auth gives you the auth module.
// Key methods we use:
//
//   .signInWithPassword()  → login with email + password
//   .signUp()              → register new user
//   .signOut()             → logout
//   .currentUser           → get logged-in user (null if not)
//   .currentSession        → get session with JWT token
//   .onAuthStateChange     → stream of auth events (login/logout)
//
// Supabase auto-saves the session. On app restart, it
// restores the session automatically. You don't store
// anything in SharedPreferences for auth anymore.
// ─────────────────────────────────────────────────────────

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

  // ── REGISTER ───────────────────────────────────────────
  // ─────────────────────────────────────────────────────
  // HOW SUPABASE REGISTER WORKS:
  //
  // Step 1: signUp() creates entry in auth.users (Supabase managed)
  // Step 2: We manually insert into profiles table
  //         because profiles holds extra data (name) that
  //         auth.users doesn't have
  //
  // Your friend should set up a Supabase trigger that
  // auto-creates profiles row on signup — but we also
  // handle it manually here as a fallback.
  // ─────────────────────────────────────────────────────
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

    // Insert into profiles table
    // await _supabase.from('profiles').upsert({
    //   'id': user.id, // same as auth.users.id (the dashed link in schema)
    //   'name': name,
    //   'created_at': DateTime.now().toIso8601String(),
    // });

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

  // ── GET CURRENT USER ───────────────────────────────────
  // Returns null if not logged in
  // Returns UserModel if session exists (app restart scenario)
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

  // ── AUTH STATE STREAM ──────────────────────────────────
  // This stream fires whenever auth state changes:
  //   - User logs in  → AuthChangeEvent.signedIn
  //   - User logs out → AuthChangeEvent.signedOut
  //   - Token refreshes → AuthChangeEvent.tokenRefreshed
  //
  // We use this in the provider to react to auth changes
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;
}
