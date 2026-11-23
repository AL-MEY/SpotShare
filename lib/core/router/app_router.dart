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
import 'package:spotshare/features/profile/presentation/pages/profile_loading_page.dart';
import 'package:spotshare/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:spotshare/features/profile/presentation/providers/profile_providers.dart';
import 'package:spotshare/features/spot/presentation/pages/spot_detail_page.dart';
import 'package:spotshare/home_page.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const signUp = '$onboarding/$_signUpSegment';
  static const _signUpSegment = 'sign-up';
  static const profileLoading = '/loading';
  static const profileSetup = '/profile-setup';

  static const _spotsPrefix = '/spots';

  static String spotDetail(String spotId) => '$_spotsPrefix/$spotId';
  static String spotMedia(String spotId, int index) =>
      '${spotDetail(spotId)}/media?index=$index';

  static const public = {welcome, login, signUp, forgotPassword, onboarding};

  static const _leaveOnceReady = {...public, profileLoading, profileSetup};
}

final routerProvider = Provider<GoRouter>((ref) {
  final sessionChanges = ValueNotifier(0);
  ref.listen(authStateProvider, (_, _) => sessionChanges.value++);
  ref.listen(currentProfileProvider, (_, _) => sessionChanges.value++);
  ref.onDispose(sessionChanges.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: sessionChanges,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (ref.read(authRepositoryProvider).currentUser == null) {
        return AppRoutes.public.contains(location) ? null : AppRoutes.welcome;
      }
      final gate = switch (ref.read(currentProfileProvider)) {
        AsyncData(value: null) => AppRoutes.profileSetup,
        AsyncData() => null,
        _ => AppRoutes.profileLoading,
      };
      if (gate != null) return location == gate ? null : gate;
      return AppRoutes._leaveOnceReady.contains(location)
          ? AppRoutes.home
          : null;
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
        path: AppRoutes.profileLoading,
        builder: (context, state) => const ProfileLoadingPage(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: '${AppRoutes._spotsPrefix}/:spotId',
        builder: (context, state) =>
            SpotDetailPage(spotId: state.pathParameters['spotId']!),
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
