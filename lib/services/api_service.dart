import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/models.dart';
import '../providers/settings_provider.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  String _baseUrl = 'https://api.example.com';

  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> _getHeaders(String? apiKey) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (apiKey != null && apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
    };
  }

  // Setup Service Discovery - Get backend URL from a setup service
  Future<ApiResponse<SetupInfo>> discoverBackend(String setupUrl) async {
    try {
      final response = await http.get(
        Uri.parse(setupUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final setupInfo = SetupInfo.fromJson(data['data']);
        // Auto-configure base URL
        setBaseUrl(setupInfo.apiUrl);
        return ApiResponse(success: true, data: setupInfo);
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Discovery failed', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Discovery error: $e');
    }
  }

  // Setup - First launch with backend token
  Future<ApiResponse<Map<String, dynamic>>> setup(String backendToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/setup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'backend_token': backendToken}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final apiKey = data['data']?['api_key'];
        if (apiKey != null) {
          await _storage.write(key: 'api_key', value: apiKey);
          await _storage.write(key: 'backend_token', value: backendToken);
        }
        return ApiResponse(success: true, data: data['data']);
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Setup failed', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  // Verify API Key
  Future<ApiResponse<bool>> verifyKey(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/verify-key'),
        headers: _getHeaders(apiKey),
        body: jsonEncode({'api_key': apiKey}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await _storage.write(key: 'api_key', value: apiKey);
        return ApiResponse(success: true, data: true);
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Invalid API key', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  // Get stored API key
  Future<String?> getApiKey() async {
    return await _storage.read(key: 'api_key');
  }

  Future<String?> getBackendToken() async {
    return await _storage.read(key: 'backend_token');
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: 'api_key');
    await _storage.delete(key: 'backend_token');
  }

  // Get real-time stats
  Future<ApiResponse<ServerStats>> getStats(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/stats/realtime'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: ServerStats.fromJson(data['data']));
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Failed to fetch stats', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  // Inbounds
  Future<ApiResponse<List<Inbound>>> getInbounds(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/inbounds'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final list = (data['data'] as List?)?.map((e) => Inbound.fromJson(e)).toList() ?? [];
        return ApiResponse(success: true, data: list);
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Failed to fetch inbounds', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<ApiResponse<Inbound>> addInbound(String apiKey, Inbound inbound) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/inbounds'),
        headers: _getHeaders(apiKey),
        body: jsonEncode(inbound.toJson()),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: Inbound.fromJson(data['data']));
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Failed to add inbound', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<ApiResponse<bool>> updateInbound(String apiKey, String id, Inbound inbound) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/inbounds/$id'),
        headers: _getHeaders(apiKey),
        body: jsonEncode(inbound.toJson()),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      return ApiResponse(success: data['success'] ?? false, message: data['message'], statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<ApiResponse<bool>> deleteInbound(String apiKey, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/inbounds/$id'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      return ApiResponse(success: data['success'] ?? false, message: data['message'], statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  // Users
  Future<ApiResponse<List<User>>> getUsers(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final list = (data['data'] as List?)?.map((e) => User.fromJson(e)).toList() ?? [];
        return ApiResponse(success: true, data: list);
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Failed to fetch users', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<ApiResponse<User>> addUser(String apiKey, User user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users'),
        headers: _getHeaders(apiKey),
        body: jsonEncode(user.toJson()),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: User.fromJson(data['data']));
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Failed to add user', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<ApiResponse<bool>> deleteUser(String apiKey, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/users/$id'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      return ApiResponse(success: data['success'] ?? false, message: data['message'], statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<ApiResponse<String>> getUserSubscription(String apiKey, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/$userId/subscription'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: data['data']['sub_link']);
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Failed to get subscription', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  // Scanner
  Future<ApiResponse<bool>> startScan(String apiKey, String category) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/scanner/start'),
        headers: _getHeaders(apiKey),
        body: jsonEncode({'category': category}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      return ApiResponse(success: data['success'] ?? false, message: data['message'], statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<ApiResponse<ScanCategory>> getScanStatus(String apiKey, String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/scanner/status/$category'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: ScanCategory.fromJson(data['data']));
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Failed to get scan status', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  // Profile
  Future<ApiResponse<ProfileInfo>> getProfile(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: ProfileInfo.fromJson(data['data']));
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Failed to get profile', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  // Settings
  Future<ApiResponse<bool>> updateSettings(String apiKey, Map<String, dynamic> settings) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/settings'),
        headers: _getHeaders(apiKey),
        body: jsonEncode(settings),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      return ApiResponse(success: data['success'] ?? false, message: data['message'], statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<ApiResponse<bool>> resetUsers(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/reset/users'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      return ApiResponse(success: data['success'] ?? false, message: data['message'], statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<ApiResponse<bool>> resetConfig(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/reset/config'),
        headers: _getHeaders(apiKey),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      return ApiResponse(success: data['success'] ?? false, message: data['message'], statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<void> logout() async {
    await clearApiKey();
  }
}

// Setup Info Model
class SetupInfo {
  final String apiUrl;
  final String backendToken;
  final String? apiKey;
  final String? panelDomain;
  final int? port;

  SetupInfo({
    required this.apiUrl,
    required this.backendToken,
    this.apiKey,
    this.panelDomain,
    this.port,
  });

  factory SetupInfo.fromJson(Map<String, dynamic> json) {
    // Flatten: fields can be at root level or nested inside panel_info
    final panelInfo = json['panel_info'] as Map<String, dynamic>? ?? {};
    return SetupInfo(
      apiUrl: json['api_url'] ?? panelInfo['api_url'] ?? '',
      backendToken: json['backend_token'] ?? panelInfo['backend_token'] ?? '',
      apiKey: json['api_key'] ?? panelInfo['api_key'],
      panelDomain: json['panel_domain'] ?? panelInfo['panel_domain'] ?? '',
      port: json['port'] ?? panelInfo['port'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api_url': apiUrl,
      'backend_token': backendToken,
      if (apiKey != null) 'api_key': apiKey,
      if (panelDomain != null) 'panel_domain': panelDomain,
      if (port != null) 'port': port,
    };
  }
}