// ─────────────────────────────────────────────────────────
// HOW TO GET THESE VALUES:
//
// 1. Go to https://supabase.com
// 2. Create a new project (or open existing one)
// 3. Go to Project Settings → API
// 4. Copy "Project URL" → paste as supabaseUrl
// 5. Copy "anon public" key → paste as supabaseAnonKey
//
// The anon key is SAFE to put in Flutter code.
// It only has the permissions your friend sets in Supabase RLS.
// Never put the "service_role" key in Flutter — that's private.
// ─────────────────────────────────────────────────────────

class SupabaseConfig {
  // Replace these with your actual values from Supabase dashboard
  static const String supabaseUrl = 'https://wockzxbhomlnffyrxxtf.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvY2t6eGJob21sbmZmeXJ4eHRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0ODI1MjIsImV4cCI6MjA5MTA1ODUyMn0.JjJDynmc9y7C6pIQczkUA8IPevzjsFtFrL5SXBA4L_0';
}