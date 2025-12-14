import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_service.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._analytics) : super(const AuthState());

  final AnalyticsService _analytics;

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(isLoading: false, errorMessage: null);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      await _analytics.logEvent('User_SignUp', parameters: <String, dynamic>{'email': email});
      state = state.copyWith(isLoading: false, errorMessage: null);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final analytics = ref.read(analyticsProvider);
  return AuthController(analytics);
});
