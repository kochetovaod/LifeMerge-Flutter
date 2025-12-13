import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Login placeholder'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(Routes.onboarding),
              child: const Text('Continue to onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}
