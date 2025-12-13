import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registration screen for the LifeMerge app.
///
/// Provides optional name field, email and password form fields with
/// validation and a submit button. After successful registration the
/// user is automatically logged in and navigated to the onboarding
/// flow. Displays error messages and suggests actions if an account
/// already exists.
class RegisterScreen extends ConsumerWidget {
  /// Key for the registration form.
  final _formKey = GlobalKey<FormState>();

  RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    bool isFormValid() {
      final email = emailController.text.trim();
      final password = passwordController.text;
      return email.isNotEmpty &&
          RegExp(r'^[^@]+@[^@]+\.[^@]+\$').hasMatch(email) &&
          password.length >= 8;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerScreenTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              // Name field (optional).
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.nameFieldLabel,
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 20),
              // Submit button.
              ElevatedButton(
                onPressed: !isFormValid() || authState.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          final name = nameController.text.trim().isEmpty
                              ? null
                              : nameController.text.trim();
                          final result = await authNotifier.signUp(
                            emailController.text.trim(),
                            passwordController.text,
                            fullName: name,
                          );
                          if (result.isSuccess) {
                            // Navigate to onboarding immediately after successful registration.
                            Navigator.of(context).pushReplacementNamed('/onboarding');
                            // Prompt user to confirm email.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.confirmEmailNotice)),
                            );
                            // Log analytics event for sign up.
                            ref.read(analyticsProvider).logEvent('User_SignUp');
                          }
                        }
                      },
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : Text(l10n.registerButton),
              ),
              // Error messages and call to actions.
              if (authState.errorMessage != null) ...[
                const SizedBox(height: 16),
                if (authState.errorCode == AuthErrorCode.accountExists) ...[
                  Text(
                    l10n.errorAccountExists,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                        child: Text(l10n.goToLoginButton),
                      ),
                      Text(' ${l10n.or} '),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/recovery'),
                        child: Text(l10n.resetPasswordButton),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    authState.errorMessage!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              // Link to login screen.
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                child: Text(l10n.alreadyHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}