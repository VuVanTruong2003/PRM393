import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  static final _day = DateFormat('dd/MM/yyyy');
  static final _month = DateFormat('MM/yyyy');

  static String money(int amount) => _currency.format(amount);
  static String day(DateTime d) => _day.format(d);
  static String month(DateTime d) => _month.format(d);
}

