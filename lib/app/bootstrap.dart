import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/providers.dart';

/// App bootstrap point.
///
/// Keep synchronous work minimal; do not perform feature initialization here.
Future<ProviderContainer> bootstrap() async {
  final container = ProviderContainer(overrides: appOverrides);

  // Placeholders for future: hydration, remote config, crash reporting initialization.
  return container;
}
