import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login screen for the LifeMerge app.
///
/// Provides email and password form fields with validation, a link to
/// reset a forgotten password, and a button to navigate to the
/// registration screen. Submits the form via an [AuthController]
/// provider when the "Войти" button is pressed and handles loading
/// and error states.
class LoginScreen extends ConsumerWidget {
  /// Key for the login form.
  final _formKey = GlobalKey<FormState>();

  /// Creates a new [LoginScreen].
  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication state.
    final authState = ref.watch(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);
    // Localized strings. Replace with your localization provider.
    final l10n = AppLocalizations.of(context)!;

    // Controllers for the email and password fields.
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // Simple check for form validity to enable/disable the submit button.
    bool isFormValid() {
      final email = emailController.text.trim();
      final password = passwordController.text;
      return email.isNotEmpty &&
          RegExp(r'^[^@]+@[^@]+\.[^@]+\$').hasMatch(email) &&
          password.length >= 8;
    }

    return Scaffold(
      appBar: AppBar(title: Text('LifeMerge')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              // Email field.
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: l10n.emailFieldLabel,
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.errorFieldRequired;
                  }
                  final isValidEmail =
                      RegExp(r'^[^@]+@[^@]+\.[^@]+\$').hasMatch(value);
                  if (!isValidEmail) {
                    return l10n.errorEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Password field.
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: l10n.passwordFieldLabel,
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.errorFieldRequired;
                  }
                  if (value.length < 8) {
                    return l10n.errorPasswordShort;
                  }
                  return null;
                },
              ),
              // Forgot password link.
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/recovery'),
                  child: Text(l10n.forgotPasswordLink),
                ),
              ),
              const SizedBox(height: 20),
              // Submit button.
              ElevatedButton(
                onPressed: !isFormValid() || authState.isLoading
                    ? null
                    : () async {
                        // Dismiss keyboard.
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          final result = await authNotifier.signIn(
                            emailController.text.trim(),
                            passwordController.text,
                          );
                          if (result.isSuccess) {
                            final onboardingDone = await ref
                                .read(localStorageProvider)
                                .getOnboardingCompletedFlag();
                            if (!onboardingDone) {
                              Navigator.of(context).pushReplacementNamed('/onboarding');
                            } else {
                              Navigator.of(context).pushReplacementNamed('/calendar');
                            }
                          }
                        }
                      },
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : Text(l10n.loginButton),
              ),
              // Error message.
              if (authState.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  authState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              // Registration link.
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/register'),
                child: Text(l10n.noAccountRegister),
              ),
            ],
          ),
        ),
      ),
    );
  }
}