import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_api_service.dart';

class AuthRepository {
  AuthRepository(this._api);

  final AuthApiService _api;

  Future<AuthSession> signUp({required String email, required String password}) async {
    final token = await _api.signUp(email: email, password: password);
    return AuthSession(email: email, token: token);
  }

  Future<AuthSession> login({required String email, required String password}) async {
    final token = await _api.login(email: email, password: password);
    return AuthSession(email: email, token: token);
  }

  Future<void> requestPasswordReset(String email) => _api.requestPasswordReset(email);

  Future<void> logout(String token) => _api.logout(token);
}

class AuthSession {
  const AuthSession({required this.email, required this.token});

  final String email;
  final String token;
}

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(authApiServiceProvider);
  return AuthRepository(api);
});
