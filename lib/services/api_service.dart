import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  final AuthService _auth;
  ApiService(this._auth);

  String get _baseUrl => _auth.baseUrl ?? '';
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_auth.token ?? ''}',
  };

  Future<Map<String, dynamic>?> get(String path) async {
    try {
      final resp = await http.get(Uri.parse('$_baseUrl$path'), headers: _headers);
      if (resp.statusCode == 200) return jsonDecode(resp.body);
      return null;
    } catch (e) { return null; }
  }

  Future<Map<String, dynamic>?> post(String path, [Map<String, dynamic>? body]) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) return jsonDecode(resp.body);
      return null;
    } catch (e) { return null; }
  }

  Future<Map<String, dynamic>?> patch(String path, Map<String, dynamic> body) async {
    try {
      final resp = await http.patch(Uri.parse('$_baseUrl$path'), headers: _headers, body: jsonEncode(body));
      if (resp.statusCode == 200) return jsonDecode(resp.body);
      return null;
    } catch (e) { return null; }
  }

  Future<bool> delete(String path) async {
    try {
      final resp = await http.delete(Uri.parse('$_baseUrl$path'), headers: _headers);
      return resp.statusCode == 200;
    } catch (e) { return false; }
  }

  // Specific endpoints
  Future<Map<String, dynamic>?> getDashboard() => get('/api/dashboard');
  Future<List> getUsers() async { final r = await get('/api/users'); return r ?? []; }
  Future<List> getInbounds() async { final r = await get('/api/inbounds'); return r ?? []; }
  Future<Map<String, dynamic>?> getProfile() => get('/api/profile');
  Future<List> getNews() async { final r = await get('/api/news'); return r ?? []; }
  Future<List> getSettings() async { final r = await get('/api/settings'); return r ?? []; }
  Future<List> getApiKeys() async { final r = await get('/api/settings/apikeys'); return r ?? []; }
  Future<List> getProxies() async { final r = await get('/api/proxy'); return r ?? []; }

  Future<Map<String, dynamic>?> createUser(Map<String, dynamic> data) => post('/api/users', data);
  Future<Map<String, dynamic>?> createInbound(Map<String, dynamic> data) => post('/api/inbounds', data);
  Future<Map<String, dynamic>?> deleteUser(int id) async { await delete('/api/users/$id'); return {}; }
  Future<Map<String, dynamic>?> deleteInbound(int id) async { await delete('/api/inbounds/$id'); return {}; }

  Future<Map<String, dynamic>?> chatAI(String message) => post('/api/hermes/chat', {'message': message});
}
