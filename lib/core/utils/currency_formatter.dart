import 'package:intl/intl.dart';

/// Formats monetary values consistently across the app.
abstract final class CurrencyFormatter {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en',
    symbol: 'MWK ',
    decimalDigits: 2,
  );

  static final NumberFormat _compact = NumberFormat.compact(locale: 'en');

  /// Formats an amount into `"MWK 12,500.00"`.
  static String format(double amount) => _currency.format(amount);

  /// Formats an amount into a compact `"MWK 12.5K"`.
  static String formatCompact(double amount) => 'MWK ${_compact.format(amount)}';
}

