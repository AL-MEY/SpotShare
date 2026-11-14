import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/router/not_found_page.dart';
import 'package:spotshare/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:spotshare/features/auth/presentation/pages/login_page.dart';
import 'package:spotshare/features/auth/presentation/pages/sign_up_page.dart';
import 'package:spotshare/features/auth/presentation/pages/welcome_page.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:spotshare/home_page.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const signUp = '$onboarding/$_signUpSegment';
  static const _signUpSegment = 'sign-up';

  static const public = {welcome, login, signUp, forgotPassword, onboarding};
}

final routerProvider = Provider<GoRouter>((ref) {
  final authChanges = ValueNotifier(0);
  ref.listen(authStateProvider, (_, _) => authChanges.value++);
  ref.onDispose(authChanges.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final signedIn = ref.read(authRepositoryProvider).currentUser != null;
      final onPublic = AppRoutes.public.contains(state.matchedLocation);
      if (!signedIn) return onPublic ? null : AppRoutes.welcome;
      return onPublic ? AppRoutes.home : null;
    },
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
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
        routes: [
          GoRoute(
            path: AppRoutes._signUpSegment,
            builder: (context, state) => const SignUpPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
  ref.onDispose(router.dispose);
  return router;
});
