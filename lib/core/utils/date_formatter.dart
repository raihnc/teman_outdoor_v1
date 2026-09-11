import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dateOnly = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _dayMonth = DateFormat('dd MMM', 'id_ID');
  static final _fullDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

  static String formatDate(DateTime date) => _dateOnly.format(date);
  static String formatDateTime(DateTime date) => _dateTime.format(date);
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);
  static String formatFullDate(DateTime date) => _fullDate.format(date);

  static String formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}
