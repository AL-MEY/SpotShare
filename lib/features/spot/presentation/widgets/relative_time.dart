import 'package:intl/intl.dart';
import 'package:spotshare/i18n/strings.g.dart';

String formatRelativeTime(
  DateTime date,
  DateTime now,
  Translations t,
  String locale,
) {
  final c = t.spot.comments;
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return c.justNow;
  if (diff.inHours < 1) return c.minutesAgo(n: diff.inMinutes);
  if (diff.inDays < 1) return c.hoursAgo(n: diff.inHours);
  if (diff.inDays < 7) return c.daysAgo(n: diff.inDays);
  return DateFormat.yMMMd(locale).format(date);
}
