import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../data/auth_repository.dart';
import '../../../core/models/user_model.dart';



// Repository provider — single instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Our clean auth state
enum AuthStatus { unknown, authenticated, unauthenticated }

class AppAuthState {
  final AuthStatus status;
  final UserModel? user;

  const AppAuthState({this.status = AuthStatus.unknown, this.user});

  bool get isAuthenticated => status == AuthStatus.authenticated;
}


final authProvider = StreamProvider<AppAuthState>((ref) async* {
  final repo = ref.watch(authRepositoryProvider);

  // Convert Supabase's auth stream to our AppAuthState stream
  await for (final supaAuthState in repo.authStateStream) {
    final event = supaAuthState.event;
    final session = supaAuthState.session;

    if (event == supa.AuthChangeEvent.signedIn ||
        event == supa.AuthChangeEvent.tokenRefreshed ||
        event == supa.AuthChangeEvent.initialSession) {
      if (session != null) {
        // User is logged in — fetch their profile
        final user = await repo.getCurrentUser();
        yield AppAuthState(status: AuthStatus.authenticated, user: user);
      } else {
        yield const AppAuthState(status: AuthStatus.unauthenticated);
      }
    } else if (event == supa.AuthChangeEvent.signedOut) {
      yield const AppAuthState(status: AuthStatus.unauthenticated);
    }
  }
});


class AuthActionsNotifier extends AsyncNotifier<void> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.login(email, password));
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.register(name, email, password));
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.logout());
  }
}

final authActionsProvider = AsyncNotifierProvider<AuthActionsNotifier, void>(
  AuthActionsNotifier.new,
);
