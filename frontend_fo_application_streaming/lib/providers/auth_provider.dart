// lib/data/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../core/models/api_models.dart';
import '../../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _checkAuthStatus();
  }

  // Vérifier le statut d'authentification au démarrage
  Future<void> _checkAuthStatus() async {
    try {
      _setLoading(true);
      final isLoggedIn = await _apiService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _apiService.getCurrentUser();
        if (user != null) {
          _user = user;
        } else {
          // Token invalide, déconnecter
          await logout();
        }
      }
    } catch (error) {
      _setError('Erreur lors de la vérification de l\'authentification');
    } finally {
      _setLoading(false);
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final loginRequest = LoginRequest(email: email, password: password);
      final authResponse = await _apiService.login(loginRequest);

      _user = authResponse.user;
      notifyListeners();
      return true;
    } catch (error) {
      if (error is ApiException) {
        _setError(error.message);
      } else if (error is NetworkException) {
        _setError(error.message);
      } else {
        _setError('Erreur de connexion: ${error.toString()}');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Inscription
  Future<bool> register(String name, String email, String password, String? avatar) async {
    try {
      _setLoading(true);
      _clearError();

      final registerRequest = RegisterRequest(
        name: name,
        email: email,
        password: password,
        avatar: avatar,
      );
      
      final authResponse = await _apiService.register(registerRequest);
      _user = authResponse.user;
      notifyListeners();
      return true;
    } catch (error) {
      if (error is ApiException) {
        _setError(error.message);
      } else if (error is NetworkException) {
        _setError(error.message);
      } else {
        _setError('Erreur d\'inscription: ${error.toString()}');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (error) {
      // Même en cas d'erreur, on déconnecte localement
      print('Erreur lors de la déconnexion: $error');
    } finally {
      _user = null;
      _clearError();
      notifyListeners();
    }
  }

  // Charger le profil utilisateur
  Future<void> loadUserProfile() async {
    if (!isAuthenticated) return;

    try {
      _setLoading(true);
      final user = await _apiService.getProfile();
      _user = user;
      notifyListeners();
    } catch (error) {
      if (error is ApiException && error.isAuthError) {
        // Token expiré, déconnecter
        await logout();
      } else {
        _setError('Erreur lors du chargement du profil');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Rafraîchir le profil
  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;
    await loadUserProfile();
  }

  // Méthodes utilitaires privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}