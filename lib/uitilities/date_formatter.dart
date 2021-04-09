import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat monthTextAndYear = DateFormat("MMMM, y");
  static final DateFormat monthText = DateFormat("MMMM");
  static DateFormat time12hours = DateFormat.jm();
  static DateFormat time24hours = DateFormat.Hm();
}
