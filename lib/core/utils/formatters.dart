import 'package:intl/intl.dart';

/// Common UI-friendly formatting helpers.
abstract final class Formatters {
  /// Formats an ISO-8601 UTC timestamp into local date/time.
  static String formatLocalDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateFormat('dd MMM yyyy, HH:mm').format(local);
  }

  /// Formats local date/time like the canonical UI: `15 Mar 2026 · 14:32`.
  static String formatDateTimeDot(DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateFormat('dd MMM yyyy · HH:mm').format(local);
  }

  /// Formats a local date.
  static String formatDate(DateTime dateTime) =>
      DateFormat('dd MMM yyyy').format(dateTime.toLocal());
}
