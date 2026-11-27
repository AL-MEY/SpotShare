import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spotshare/features/spot/presentation/widgets/relative_time.dart';
import 'package:spotshare/i18n/strings.g.dart';

void main() {
  final now = DateTime(2026, 11, 23, 12);
  late final Translations fr;
  late final Translations en;

  setUpAll(() async {
    fr = await AppLocale.fr.build();
    en = await AppLocale.en.build();
    await initializeDateFormatting('fr');
    await initializeDateFormatting('en');
  });

  String format(Duration ago, Translations t, String locale) =>
      formatRelativeTime(now.subtract(ago), now, t, locale);

  group('formatRelativeTime', () {
    test('FR : chaque seuil', () {
      expect(format(const Duration(seconds: 59), fr, 'fr'), 'À l’instant');
      expect(format(const Duration(minutes: 1), fr, 'fr'), 'Il y a 1 minute');
      expect(
        format(const Duration(minutes: 59), fr, 'fr'),
        'Il y a 59 minutes',
      );
      expect(format(const Duration(hours: 1), fr, 'fr'), 'Il y a 1 heure');
      expect(format(const Duration(hours: 23), fr, 'fr'), 'Il y a 23 heures');
      expect(format(const Duration(days: 1), fr, 'fr'), 'Il y a 1 jour');
      expect(format(const Duration(days: 6), fr, 'fr'), 'Il y a 6 jours');
      expect(format(const Duration(days: 7), fr, 'fr'), '16 nov. 2026');
    });

    test('EN : chaque seuil', () {
      expect(format(const Duration(seconds: 59), en, 'en'), 'Just now');
      expect(format(const Duration(minutes: 1), en, 'en'), '1 minute ago');
      expect(format(const Duration(minutes: 59), en, 'en'), '59 minutes ago');
      expect(format(const Duration(hours: 1), en, 'en'), '1 hour ago');
      expect(format(const Duration(hours: 23), en, 'en'), '23 hours ago');
      expect(format(const Duration(days: 1), en, 'en'), '1 day ago');
      expect(format(const Duration(days: 6), en, 'en'), '6 days ago');
      expect(format(const Duration(days: 7), en, 'en'), 'Nov 16, 2026');
    });

    test('une date dans le futur (horloge décalée) donne « à l’instant »', () {
      expect(
        formatRelativeTime(now.add(const Duration(minutes: 5)), now, fr, 'fr'),
        'À l’instant',
      );
    });
  });
}
