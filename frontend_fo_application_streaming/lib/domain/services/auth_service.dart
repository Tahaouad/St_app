import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:5000/api/auth';
  final _storage = const FlutterSecureStorage();

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await _storage.write(key: 'token', value: data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // Registration method
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String? avatar,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': username,
          'email': email,
          'password': password,
          'avatar': avatar,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        // Store the token if it's provided during registration
        if (data['token'] != null) {
          await _storage.write(key: 'token', value: data['token']);
        }
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error fetching profile: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception while fetching profile: $e");
      return null;
    }
  }

  // Logout method
  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Get auth token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}
