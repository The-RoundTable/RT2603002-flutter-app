import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);
      final location = state.matchedLocation;

      if (authAsync.isLoading) return null;

      final isAuthenticated = authAsync.value?.isAuthenticated ?? false;

      if (!isAuthenticated) {
        if (location == '/login' || location == '/register') {
          return null;
        }
        return '/login'; 
      }
      if (isAuthenticated &&
          (location == '/splash' ||
              location == '/login' ||
              location == '/register')) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AsyncValue<AppAuthState>>(
      authProvider,
      (_, _) => notifyListeners(),
    );
  }
}
