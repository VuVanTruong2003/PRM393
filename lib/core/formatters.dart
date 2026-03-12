import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  static final _day = DateFormat('dd/MM/yyyy');
  static final _month = DateFormat('MM/yyyy');
  static final _dayNumber = DateFormat('d');

  static String money(int amount) => _currency.format(amount);
  static String day(DateTime d) => _day.format(d);
  static String month(DateTime d) => _month.format(d);
  static String dayNumber(DateTime d) => _dayNumber.format(d);

  static String weekdayVi(DateTime d) {
    return switch (d.weekday) {
      DateTime.monday => 'Thứ 2',
      DateTime.tuesday => 'Thứ 3',
      DateTime.wednesday => 'Thứ 4',
      DateTime.thursday => 'Thứ 5',
      DateTime.friday => 'Thứ 6',
      DateTime.saturday => 'Thứ 7',
      DateTime.sunday => 'Chủ nhật',
      _ => '',
    };
  }
}

