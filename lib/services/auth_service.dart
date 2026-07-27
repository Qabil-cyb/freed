import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  String? _token;
  String? _baseUrl;
  String? _apiKey;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _accounts = [];

  String? get token => _token;
  String? get baseUrl => _baseUrl;
  String? get apiKey => _apiKey;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoggedIn => _token != null;
  List<Map<String, dynamic>> get accounts => _accounts;

  Future<void> init() async {
    _token = await _storage.read(key: 'token');
    _baseUrl = await _storage.read(key: 'base_url');
    _apiKey = await _storage.read(key: 'api_key');
    _accounts = await _loadAccounts();
    notifyListeners();
  }

  Future<bool> login(String apiUrl, String apiKey) async {
    try {
      final resp = await http.post(
        Uri.parse('$apiUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'api_key': apiKey, 'device_id': 'android'}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _token = data['token'];
        _baseUrl = apiUrl;
        _apiKey = apiKey;
        _profile = data['profile'];

        await _storage.write(key: 'token', value: _token);
        await _storage.write(key: 'base_url', value: _baseUrl);
        await _storage.write(key: 'api_key', value: _apiKey);

        await _saveAccount(apiUrl, apiKey, _profile?['name'] ?? 'Panel');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> addAccount(String apiUrl, String apiKey, String name) async {
    final accounts = await _loadAccounts();
    accounts.add({'url': apiUrl, 'key': apiKey, 'name': name});
    await _storage.write(key: 'accounts', value: jsonEncode(accounts));
    _accounts = accounts;
    notifyListeners();
  }

  Future<void> switchAccount(int index) async {
    final accounts = await _loadAccounts();
    if (index < accounts.length) {
      await login(accounts[index]['url'], accounts[index]['key']);
    }
  }

  Future<void> removeAccount(int index) async {
    final accounts = await _loadAccounts();
    accounts.removeAt(index);
    await _storage.write(key: 'accounts', value: jsonEncode(accounts));
    _accounts = accounts;
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _baseUrl = null;
    _apiKey = null;
    _profile = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> _loadAccounts() async {
    final json = await _storage.read(key: 'accounts');
    if (json != null) {
      return (jsonDecode(json) as List).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  Future<void> _saveAccount(String url, String key, String name) async {
    final accounts = await _loadAccounts();
    if (!accounts.any((a) => a['url'] == url && a['key'] == key)) {
      accounts.add({'url': url, 'key': key, 'name': name});
      await _storage.write(key: 'accounts', value: jsonEncode(accounts));
      _accounts = accounts;
    }
  }
}
