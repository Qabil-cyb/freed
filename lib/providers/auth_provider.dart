import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthProvider extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthProvider() : super(const AuthState());

  Future<void> login(String backendToken) async {
    await _storage.write(key: 'backend_token', value: backendToken);
    await _storage.write(key: 'api_key', value: 'generated_api_key_from_token');
    state = AuthState(
      isAuthenticated: true,
      backendToken: backendToken,
      apiKey: 'generated_api_key_from_token',
    );
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }

  Future<void> loadFromStorage() async {
    state = const AuthState(isLoading: true);
    final backendToken = await _storage.read(key: 'backend_token');
    final apiKey = await _storage.read(key: 'api_key');
    state = AuthState(
      isAuthenticated: backendToken != null && apiKey != null,
      backendToken: backendToken,
      apiKey: apiKey,
    );
  }

  String get backendToken => state.backendToken;
  String? get apiKey => state.apiKey;
  bool get isAuthenticated => state.isAuthenticated;
  bool get isLoading => state.isLoading;
}

class AuthState {
  final bool isAuthenticated;
  final String? backendToken;
  final String? apiKey;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.backendToken,
    this.apiKey,
    this.isLoading = false,
  });
}