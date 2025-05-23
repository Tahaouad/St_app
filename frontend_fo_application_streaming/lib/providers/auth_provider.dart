// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';

// État d'authentification
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// Classe pour gérer l'état d'auth
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final ApiService _apiService;
  User? _currentUser;

  AuthNotifier(this._apiService) : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  User? get currentUser => _currentUser;

  // Vérifier le statut d'authentification au démarrage
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _apiService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          state = AsyncValue.data(user);
        } else {
          // Token invalide, déconnecter
          await logout();
        }
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();

      final loginRequest = LoginRequest(email: email, password: password);
      final authResponse = await _apiService.login(loginRequest);

      _currentUser = authResponse.user;
      state = AsyncValue.data(authResponse.user);

      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  // Inscription
  Future<bool> register(String name, String email, String password,
      {String? avatar}) async {
    try {
      state = const AsyncValue.loading();

      final registerRequest = RegisterRequest(
        name: name,
        email: email,
        password: password,
        avatar: avatar,
      );
      final authResponse = await _apiService.register(registerRequest);

      _currentUser = authResponse.user;
      state = AsyncValue.data(authResponse.user);

      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _apiService.logout();
      _currentUser = null;
      state = const AsyncValue.data(null);
    } catch (error) {
      // Même en cas d'erreur, on déconnecte localement
      _currentUser = null;
      state = const AsyncValue.data(null);
    }
  }

  // Rafraîchir le profil
  Future<void> refreshProfile() async {
    try {
      if (_currentUser != null) {
        final user = await _apiService.getProfile();
        _currentUser = user;
        state = AsyncValue.data(user);
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool get isAuthenticated => _currentUser != null;
}

// Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});

// Provider pour obtenir l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.asData?.value;
});

// Provider pour vérifier si l'utilisateur est connecté
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
