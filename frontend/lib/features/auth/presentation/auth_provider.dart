import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/auth_api_service.dart';
import '../data/auth_repository.dart';
import '../domain/models/auth_models.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApiService(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  return AuthRepository(apiService: apiService);
});

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithGoogle();
    
    state = result.copyWith(isLoading: false);
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = AuthState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

// For backward compatibility with the router if needed, or we can just use the controller
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authControllerProvider);
});
