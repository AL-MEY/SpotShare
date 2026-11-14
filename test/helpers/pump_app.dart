import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/app.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/i18n/strings.g.dart';

import 'fake_auth_repository.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  AppLocale locale = AppLocale.fr,
  FakeAuthRepository? auth,
}) async {
  final repository = auth ?? FakeAuthRepository();
  addTearDown(repository.dispose);
  await tester.runAsync(() => LocaleSettings.setLocale(locale));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: TranslationProvider(child: const SpotShareApp()),
    ),
  );
  return ProviderScope.containerOf(tester.element(find.byType(SpotShareApp)));
}
