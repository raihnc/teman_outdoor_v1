import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(int amount) {
    return _idrFormat.format(amount);
  }

  static String formatPerDay(int amount) {
    return '${_idrFormat.format(amount)}/hari';
  }
}
