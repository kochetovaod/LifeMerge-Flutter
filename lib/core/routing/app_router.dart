import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/shell/presentation/app_shell.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/calendar/presentation/calendar_day_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/pro/presentation/pro_screen.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.login,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: Routes.calendarDay,
            builder: (context, state) => const CalendarDayScreen(),
          ),
          GoRoute(
            path: Routes.tasks,
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: Routes.inbox,
            builder: (context, state) => const InboxScreen(),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: Routes.pro,
            builder: (context, state) => const ProScreen(),
          ),
        ],
      ),
    ],
  );
});
