import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _apiKey = '';
  String _backendToken = '';
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isAuthenticated => _isAuthenticated;
  String get apiKey => _apiKey;
  String get backendToken => _backendToken;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _loadStoredTokens();
  }

  Future<void> _loadStoredTokens() async {
    try {
      final key = await ApiService().getApiKey();
      if (key != null && key.isNotEmpty) {
        _apiKey = key;
        _isAuthenticated = true;
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> setupBackend(String token) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService().setup(token);
      if (response.success) {
        _backendToken = token;
        _apiKey = response.data?['api_key'] ?? '';
        _isAuthenticated = _apiKey.isNotEmpty;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Setup failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyApiKey(String key) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService().verifyKey(key);
      if (response.success) {
        _apiKey = key;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Invalid API key';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _apiKey = '';
    _backendToken = '';
    _isAuthenticated = false;
    ApiService().clearApiKey();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
