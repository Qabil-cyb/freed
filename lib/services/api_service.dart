import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:spider_vpn/providers/settings_provider.dart';
import 'package:spider_vpn/models/user_model.dart';
import 'package:spider_vpn/services/api_service.dart';

class ApiService {
  static const String _baseUrlKey = 'panel_url';
  static const String _apiKeyKey = 'api_key';
  static const String _tokenKey = 'access_token';
  static const FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static ApiService? _instance;
  String? _baseUrl;
  String? _apiKey;
  String? _token;
  
  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }
  
  ApiService._();
  
  // Store credentials
  Future<void> saveCredentials({
    required String baseUrl,
    required String apiKey,
    String? token,
  }) async {
    _baseUrl = baseUrl;
    _apiKey = apiKey;
    _token = token;
    await _storage.write(key: _baseUrlKey, value: baseUrl);
    await _storage.write(key: _apiKeyKey, value: apiKey);
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
    }
  }
  
  Future<void> loadCredentials() async {
    _baseUrl = await _storage.read(key: _baseUrlKey);
    _apiKey = await _storage.read(key: _apiKeyKey);
    _token = await _storage.read(key: _tokenKey);
  }
  
  Future<void> clearCredentials() async {
    _baseUrl = null;
    _apiKey = null;
    _token = null;
    await _storage.delete(key: _baseUrlKey);
    await _storage.delete(key: _apiKeyKey);
    await _storage.delete(key: _tokenKey);
  }
  
  bool get hasCredentials => _baseUrl != null && _apiKey != null;
  String? get baseUrl => _baseUrl;
  String? get apiKey => _apiKey;
  String? get token => _token;
  
  // HTTP helper
  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = '${_baseUrl ?? ''}$path';
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
      if (headers != null) ...headers,
    };
    
    http.Response response;
    
    switch (method) {
      case 'GET':
        response = await http.get(Uri.parse(url), headers: requestHeaders);
        break;
      case 'POST':
        response = await http.post(
          Uri.parse(url),
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          Uri.parse(url),
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(Uri.parse(url), headers: requestHeaders);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
  
  // ====== AUTH ======
  Future<Map<String, dynamic>> login(String email, String password) async {
    return _request('POST', '/api/v1/auth/login', body: {
      'email': email,
      'password': password,
    });
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    return _request('POST', '/api/v1/auth/register', body: data);
  }
  
  Future<Map<String, dynamic>> getProfile() async {
    return _request('GET', '/api/v1/auth/me');
  }
  
  // ====== DASHBOARD ======
  Future<Map<String, dynamic>> getDashboardStats() async {
    return _request('GET', '/api/v1/dashboard/stats');
  }
  
  // ====== INBOUNDS ======
  Future<List<dynamic>> getInbounds({int page = 1}) async {
    final result = await _request('GET', '/api/v1/inbounds/?page=$page');
    return result is List ? result : [];
  }
  
  Future<Map<String, dynamic>> createInbound(Map<String, dynamic> data) async {
    return _request('POST', '/api/v1/inbounds/', body: data);
  }
  
  Future<Map<String, dynamic>> getInbound(String id) async {
    return _request('GET', '/api/v1/inbounds/$id');
  }
  
  Future<Map<String, dynamic>> updateInbound(String id, Map<String, dynamic> data) async {
    return _request('PUT', '/api/v1/inbounds/$id', body: data);
  }
  
  Future<void> deleteInbound(String id) async {
    await _request('DELETE', '/api/v1/inbounds/$id');
  }
  
  // ====== CLIENTS ======
  Future<List<dynamic>> getClients(String inboundId) async {
    final result = await _request('GET', '/api/v1/inbounds/$inboundId/clients');
    return result is List ? result : [];
  }
  
  Future<Map<String, dynamic>> createClient(String inboundId, Map<String, dynamic> data) async {
    return _request('POST', '/api/v1/inbounds/$inboundId/clients', body: data);
  }
  
  Future<Map<String, dynamic>> getClientLink(String inboundId, String clientId, {String format = 'xray'}) async {
    return _request('GET', '/api/v1/inbounds/$inboundId/clients/$clientId/link?format=$format');
  }
  
  Future<Map<String, dynamic>> getClientQR(String inboundId, String clientId) async {
    return _request('GET', '/api/v1/inbounds/$inboundId/clients/$clientId/qr');
  }
  
  // ====== API KEYS ======
  Future<List<dynamic>> getApiKeys() async {
    final result = await _request('GET', '/api/v1/api-keys/');
    return result is List ? result : [];
  }
  
  Future<Map<String, dynamic>> addApiKey({
    required String name,
    required String panelUrl,
    required String apiKey,
    bool isDefault = false,
  }) async {
    return _request('POST', '/api/v1/api-keys/', body: {
      'name': name,
      'panel_url': panelUrl,
      'api_key': apiKey,
      'is_default': isDefault,
    });
  }
  
  Future<Map<String, dynamic>> switchApiKey(String keyId) async {
    return _request('POST', '/api/v1/api-keys/$keyId/switch');
  }
  
  Future<void> deleteApiKey(String keyId) async {
    await _request('DELETE', '/api/v1/api-keys/$keyId');
  }
  
  // ====== IP PROXIES ======
  Future<List<dynamic>> getIpProxies({String? country}) async {
    String path = '/api/v1/ip-proxies/';
    if (country != null) path += '?country=$country';
    final result = await _request('GET', path);
    return result is List ? result : [];
  }
  
  Future<Map<String, dynamic>> addIpProxy(Map<String, dynamic> data) async {
    return _request('POST', '/api/v1/ip-proxies/', body: data);
  }
  
  Future<Map<String, dynamic>> bulkImportIpProxies(List<Map<String, dynamic>> proxies) async {
    return _request('POST', '/api/v1/ip-proxies/bulk', body: {'proxies': proxies});
  }
  
  Future<Map<String, dynamic>> applyIpProxy(String proxyId, String inboundId) async {
    return _request('POST', '/api/v1/ip-proxies/$proxyId/apply', body: {
      'inbound_id': inboundId,
    });
  }
  
  // ====== AI ======
  Future<Map<String, dynamic>> sendAiMessage({
    required String message,
    List<Map<String, dynamic>>? history,
    String? apiKey,
  }) async {
    return _request('POST', '/api/v1/ai/chat', body: {
      'message': message,
      'conversation_history': history ?? [],
      'api_key': apiKey,
    });
  }
  
  // ====== NEWS ======
  Future<Map<String, dynamic>> getNews({int page = 1}) async {
    return _request('GET', '/api/v1/news/?page=$page');
  }
  
  // ====== SETTINGS ======
  Future<Map<String, dynamic>> getSettings() async {
    return _request('GET', '/api/v1/settings/');
  }
  
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    return _request('PUT', '/api/v1/settings/', body: data);
  }
  
  Future<Map<String, dynamic>> setupTelegramBot(String botToken, String adminChatId) async {
    return _request('POST', '/api/v1/settings/telegram-bot', body: {
      'bot_token': botToken,
      'admin_chat_id': adminChatId,
    });
  }
  
  Future<Map<String, dynamic>> resetPanel(Map<String, dynamic> data) async {
    return _request('POST', '/api/v1/settings/reset', body: data);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException({required this.statusCode, required this.message});
  
  @override
  String toString() => 'ApiException($statusCode): $message';
}