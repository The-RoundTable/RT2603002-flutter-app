import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_config.dart';
import 'app.dart';

// ─────────────────────────────────────────────────────────
// WHY Supabase.initialize() is here:
//
// Supabase must be initialized BEFORE the app runs.
// main() is async so we can await the initialization.
// After this line, anywhere in the app you can access
// Supabase via: Supabase.instance.client
//
// This also restores any existing session automatically —
// if user was logged in before, Supabase restores their
// token without you doing anything. No SharedPrefs needed.
// ─────────────────────────────────────────────────────────

void main() async {
  // Required before any async work in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase — must happen before runApp
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: DMSApp(),
    ),
  );
}

// Convenience getter — use this anywhere to access Supabase client
// Example: supabase.auth.currentUser
// Example: supabase.from('events').select()
final supabase = Supabase.instance.client;