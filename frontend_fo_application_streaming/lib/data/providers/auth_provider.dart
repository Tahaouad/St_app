import 'package:flutter/foundation.dart';
import 'package:frontend_fo_application_streaming/domain/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      if (result['success']) {
        // Récupérer le profil immédiatement après le login
        final profile = await _authService.getProfile();
        if (profile != null) {
          _user = profile;
        } else {
          _error = 'Impossible de charger le profil utilisateur';
        }
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Une erreur est survenue: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String? avatar,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        username,
        email,
        password,
        avatar,
      );
      if (result['success']) {
        await login(email, password);
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Une erreur est survenue: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
    } catch (e) {
      _error =
          'Une erreur est survenue lors de la déconnexion: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile() async {
    if (_user != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.getProfile();
    } catch (e) {
      _error = 'Une erreur est survenue: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
