import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Greeting
final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning,';
  if (hour < 17) return 'Good afternoon,';
  return 'Good evening,';
});

// Driver name
final driverNameProvider = Provider<String>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  final meta = user?.userMetadata;
  final name = meta?['name'] as String?;
  if (name == null || name.trim().isEmpty) return 'Driver';
  return name.trim().split(' ').first;
});