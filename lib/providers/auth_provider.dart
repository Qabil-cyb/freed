import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spider_vpn/services/api_service.dart';
import 'package:spider_vpn/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  String? _apiKey;
  String? _panelUrl;
  bool _isLoading = false;
  String? _error;
  
  UserModel? get user => _user;
  String? get token => _token;
  String? get apiKey => _apiKey;
  String? get panelUrl => _panelUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;
  
  AuthProvider() {
    _loadAuth();
  }
  
  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    _apiKey = prefs.getString('api_key');
    _panelUrl = prefs.getString('panel_url');
    
    // Load user data
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        _user = UserModel.fromJson(userJson);
      } catch (e) {
        _user = null;
      }
    }
    
    // Also load from secure storage
    await ApiService.instance.loadCredentials();
    
    notifyListeners();
  }
  
  Future<bool> login({
    required String email,
    required String password,
    String? apiKey,
    String? panelUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // First try local auth
      final result = await ApiService.instance.login(email, password);
      
      _token = result['access_token'];
      _user = UserModel.fromJson(result);
      _apiKey = apiKey;
      _panelUrl = panelUrl;
      
      // Save credentials
      await _saveAuth();
      
      // Save API key to secure storage
      if (apiKey != null && panelUrl != null) {
        await ApiService.instance.saveCredentials(
          baseUrl: panelUrl!,
          apiKey: apiKey!,
          token: _token,
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
    String? apiKey,
    String? panelUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await ApiService.instance.register({
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
        'api_key': apiKey,
        'panel_url': panelUrl,
      });
      
      _token = result['access_token'];
      _user = UserModel.fromJson(result);
      _apiKey = apiKey;
      _panelUrl = panelUrl;
      
      await _saveAuth();
      
      if (apiKey != null && panelUrl != null) {
        await ApiService.instance.saveCredentials(
          baseUrl: panelUrl!,
          apiKey: apiKey!,
          token: _token,
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    _user = null;
    _token = null;
    _apiKey = null;
    _panelUrl = null;
    _error = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('api_key');
    await prefs.remove('panel_url');
    await prefs.remove('user_data');
    
    await ApiService.instance.clearCredentials();
    
    notifyListeners();
  }
  
  Future<void> _saveAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString('access_token', _token!);
    if (_apiKey != null) await prefs.setString('api_key', _apiKey!);
    if (_panelUrl != null) await prefs.setString('panel_url', _panelUrl!);
    if (_user != null) await prefs.setString('user_data', _user!.toJson());
  }
  
  Future<void> updateUser(UserModel user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toJson());
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<bool> checkPanelPassword(String password) async {
    // Check if panel password is set
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('panelPassword');
    if (savedPassword == null) return true;
    return savedPassword == password;
  }
}