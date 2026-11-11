import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/router/not_found_page.dart';
import 'package:spotshare/features/auth/presentation/pages/login_page.dart';
import 'package:spotshare/features/auth/presentation/pages/welcome_page.dart';
import 'package:spotshare/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:spotshare/home_page.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const onboarding = '/onboarding';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.welcome,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
  ref.onDispose(router.dispose);
  return router;
});
