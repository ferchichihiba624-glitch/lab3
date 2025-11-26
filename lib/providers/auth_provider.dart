// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  // Reference to our auth service
  final AuthService _authService = AuthService();

  // Current user
  User? _user;
  User? get user => _user;

  // Loading state
  bool _loading = true;
  bool get loading => _loading;

  // Authentication state
  bool get isAuthenticated => _user != null;

  // Constructor - checks for existing session
  AuthProvider() {
    _checkUserStatus();
  }

  // Check if user is already logged in
  Future<void> _checkUserStatus() async {
    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _user = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Register a new user
  Future<bool> register(String email, String password, String name) async {
    try {
      await _authService.createAccount(email, password, name);
      _user = await _authService.getCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Login existing user
  Future<bool> login(String email, String password) async {
    try {
      await _authService.login(email, password);
      _user = await _authService.getCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }
}