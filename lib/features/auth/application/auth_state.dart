class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.email,
    this.token,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final String? email;
  final String? token;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? email,
    String? token,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      token: token ?? this.token,
      errorMessage: clearError ? null : errorMessage,
    );
  }
}
