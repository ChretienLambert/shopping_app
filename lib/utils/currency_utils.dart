import 'package:intl/intl.dart';

class CurrencyUtils {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_CM', // Cameroon locale (often uses XAF)
    symbol: 'XAF',
    decimalDigits: 0,
    customPattern: '#,### \u00a4',
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatShort(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M XAF';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K XAF';
    }
    return format(amount);
  }
}
