import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final api = ApiService();

  AppUser? user;
  String? token;
  bool isLoading = true;
  String? error;

  bool get isAuthenticated => token != null && user != null;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('api_token');
    api.token = token;
    ApiService.sharedToken = token;

    if (token != null) {
      try {
        final response = await api.get('/me');
        user = AppUser.fromJson(response['user']);
      } catch (_) {
        await prefs.remove('api_token');
        token = null;
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response =
          await api.post('/login', {'email': email, 'password': password});
      token = response['token'];
      api.token = token;
      ApiService.sharedToken = token;
      user = AppUser.fromJson(response['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', token!);
      return true;
    } catch (exception) {
      error = exception.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String userIdentifier,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await api.post('/register', {
        'name': name,
        'user_identifier': userIdentifier,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      token = response['token'];
      api.token = token;
      ApiService.sharedToken = token;
      user = AppUser.fromJson(response['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', token!);
      return true;
    } catch (exception) {
      error = exception.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    String? userIdentifier,
    required String email,
    String? phone,
    String? address,
    String? bio,
  }) async {
    final response = await api.put('/profile', {
      'name': name,
      'user_identifier': userIdentifier,
      'email': email,
      'phone': phone,
      'address': address,
      'bio': bio,
    });
    user = AppUser.fromJson(response['user']);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await api.post('/logout', {});
    } catch (_) {
      // Session may already be invalid server-side.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    token = null;
    user = null;
    api.token = null;
    ApiService.sharedToken = null;
    notifyListeners();
  }
}
