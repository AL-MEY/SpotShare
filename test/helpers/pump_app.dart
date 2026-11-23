import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/app.dart';
import 'package:spotshare/core/network/connectivity_provider.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/profile/presentation/providers/profile_providers.dart';
import 'package:spotshare/i18n/strings.g.dart';

import 'fake_auth_repository.dart';
import 'fake_connectivity.dart';
import 'fake_profile_repository.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  AppLocale locale = AppLocale.fr,
  FakeAuthRepository? auth,
  FakeProfileRepository? profile,
  bool online = true,
  List<Override> overrides = const [],
}) async {
  final authRepository = auth ?? FakeAuthRepository();
  final profileRepository = profile ?? FakeProfileRepository();
  addTearDown(authRepository.dispose);
  addTearDown(profileRepository.dispose);
  await tester.runAsync(() => LocaleSettings.setLocale(locale));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        connectivityProvider.overrideWithValue(
          FakeConnectivity(online: online),
        ),
        ...overrides,
      ],
      child: TranslationProvider(child: const SpotShareApp()),
    ),
  );
  return ProviderScope.containerOf(tester.element(find.byType(SpotShareApp)));
}
