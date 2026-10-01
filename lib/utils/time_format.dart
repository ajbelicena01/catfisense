import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

/// "just now", "5 min ago", "3 hours ago", "2 days ago", then a date.
String timeAgo(AppLocalizations l10n, DateTime time, DateTime now) {
  final elapsed = now.difference(time);
  if (elapsed.inMinutes < 1) return l10n.timeJustNow;
  if (elapsed.inHours < 1) return l10n.timeMinutesAgo(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.timeHoursAgo(elapsed.inHours);
  if (elapsed.inDays < 7) return l10n.timeDaysAgo(elapsed.inDays);
  return DateFormat.yMMMd(l10n.localeName).format(time);
}

/// "Sep 30, 7:36 AM" in the app's language.
String dateTimeLabel(AppLocalizations l10n, DateTime time) =>
    DateFormat.MMMd(l10n.localeName).add_jm().format(time);

/// "7:36 AM" in the app's language.
String timeLabel(AppLocalizations l10n, DateTime time) => DateFormat.jm(l10n.localeName).format(time);

/// "2h 15m", "40m", or "under 1m" for how long something lasted.
String durationLabel(AppLocalizations l10n, Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (hours > 0) return l10n.durationHoursMinutes(hours, minutes);
  if (minutes > 0) return l10n.durationMinutes(minutes);
  return l10n.durationUnderMinute;
}

/// "Wed, Sep 30" in the app's language.
String dateLabel(AppLocalizations l10n, DateTime day) => DateFormat.MMMEd(l10n.localeName).format(day);
