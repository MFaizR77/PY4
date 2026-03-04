import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes menit yang lalu';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours jam yang lalu';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days hari yang lalu';
    } else {
      return DateFormat('d MMM yyyy', 'id_ID').format(dateTime);
    }
  }

  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('d MMM yyyy', 'id_ID').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm', 'id_ID').format(dateTime);
  }
}
