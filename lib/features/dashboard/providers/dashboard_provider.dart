import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock user name for now
// Later this will read from authProvider
final driverNameProvider = Provider<String>((ref) {
  return 'Udayan'; // hardcoded for now
});

// Greeting based on time of day
final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;

  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
});
