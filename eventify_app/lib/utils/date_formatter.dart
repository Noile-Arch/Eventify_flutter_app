import 'package:intl/intl.dart';

class DateFormatter {
  static final _displayFormat = DateFormat('E, MMM d • h:mm a');
  static final _dateFormat = DateFormat('MMM d, y');

  static String format(dynamic date) {
    if (date == null) return '';
    
    try {
      DateTime dateTime;
      if (date is String) {
        // Parse as UTC and convert to local
        dateTime = DateTime.parse(date).toLocal();
      } else if (date is DateTime) {
        dateTime = date.toLocal();
      } else {
        return '';
      }

      return _displayFormat.format(dateTime);
    } catch (e) {
      print('Date formatting error: $e');
      return date.toString();
    }
  }

  static String formatDate(dynamic date) {
    if (date == null) return '';
    
    try {
      DateTime dateTime;
      if (date is String) {
        // Parse as UTC and convert to local
        dateTime = DateTime.parse(date).toLocal();
      } else if (date is DateTime) {
        dateTime = date.toLocal();
      } else {
        return '';
      }

      return _dateFormat.format(dateTime);
    } catch (e) {
      print('Date formatting error: $e');
      return date.toString();
    }
  }
} 