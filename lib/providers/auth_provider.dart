// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _email;

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('isLoggedIn') ?? false;
    if (saved) {
      _email = prefs.getString('email');
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> login(String email, {bool persist = true}) async {
    _isLoggedIn = true;
    _email = email;
    notifyListeners();
    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email);
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _email = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('email');
  }
}