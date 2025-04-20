import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/User.dart';
import '../services/api_service.dart';
import '../services/user/user_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> loadUserFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    if (storedToken != null) {
      await ApiService.setToken(storedToken);
      _token = storedToken;

      try {
        _user = await UserService.getCurrentUser();
      } catch (_) {
        _user = null;
        _token = null;
        await prefs.remove('token');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
    await ApiService.setToken(token);

    _user = await UserService.getCurrentUser();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    _token = null;
    notifyListeners();
  }
}
